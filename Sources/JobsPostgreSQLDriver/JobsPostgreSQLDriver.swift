//
//  JobsPostgreSQLDriver.swift
//  App
//
//  Created by TJ on 14/02/2019.
//

import Foundation
import Vapor
import Jobs
import FluentPostgreSQL
import NIO


/// A wrapper that conforms to `JobsPersistenceLayer`
public struct JobsPostgreSQLDriver {
  
  /// The `PostgreSQLDatabase` to run commands on
  let database: PostgreSQLDatabase
  
  /// The `EventLoop` to run jobs on
  public let eventLoop: EventLoop
  
  /// Creates a new `JobsPostgreSQLDriver` instance
  ///
  /// - Parameters:
  ///   - database: The `PostgreSQLDatabase` to run commands on
  ///   - eventLoop: The `EventLoop` to run jobs on
  public init(database: PostgreSQLDatabase, eventLoop: EventLoop) {
    self.database = database
    self.eventLoop = eventLoop
  }
}

extension JobsPostgreSQLDriver: JobsPersistenceLayer {
  public func get(key: String) -> EventLoopFuture<JobStorage?> {
    // Establish a database connection
    return database.newConnection(on: eventLoop).flatMap { conn in

      // We ned to use SKIP LOCKED in order to handle multiple threads all getting the next job
      // Not sure how to make use of SKIP LOCKED in the QueryBuilder, saw raw SQL it is ...
      let sql = PostgreSQLQuery(stringLiteral: """
        UPDATE job SET state = 'processing',
        updated_at = clock_timestamp()
        WHERE id = (
        SELECT id
        FROM job
        WHERE key = '\(key)'
        AND state = 'pending'
        ORDER BY id
        FOR UPDATE SKIP LOCKED
        LIMIT 1
        )
        RETURNING *
        """)

      // Retrieve the next Job
      return conn.query(sql).map(to: JobStorage?.self) { rows in
        if let job = rows.first,
          let data = job.firstValue(name: "data")?.binary {
          // Now decode the Job for processing
          let decoder = try JSONDecoder().decode(DecoderUnwrapper.self, from: data)
          return try JobStorage(from: decoder.decoder)
        }
        return nil
      }
    }
  }
  
  public func set(key: String, jobStorage: JobStorage) -> EventLoopFuture<Void> {
    // Establish a database connection
    return database.newConnection(on: eventLoop).map { conn in
      // Encode and save the Job
      let data = try JSONEncoder().encode(jobStorage)
      let _ = JobModel(key: key, jobId: jobStorage.id, data: data).save(on: conn)
    }
  }
  
  public func completed(key: String, jobStorage: JobStorage) -> EventLoopFuture<Void> {
    // Establish a database connection
    return database.newConnection(on: eventLoop).flatMap { conn in
      // Update the state
      return JobModel.query(on: conn).filter(\.jobId == jobStorage.id).first().map { jobModel in
        jobModel?.state = JobState.completed.rawValue
        jobModel?.updatedAt = Date()
        let _ = jobModel?.save(on: conn)
      }
    }
  }
  
  /// Not used in PostgreSQL implementation!
  public func processingKey(key: String) -> String {
    return "\(key)-processing"
  }
}

struct DecoderUnwrapper: Decodable {
  let decoder: Decoder
  init(from decoder: Decoder) { self.decoder = decoder }
}

enum JobState: String, Codable {
  case pending = "pending"
  case processing = "processing"
  case completed = "completed"
}
public final class JobModel: PostgreSQLModel {
  /// Types
  public typealias Database = PostgreSQLDatabase
  public typealias ID = Int
  public static let idKey: IDKey = \.id
  
  /// Properties
  public static let entity = "job"
  public var id: Int?
  
  /// The Job key
  var key: String
  /// The unique Job uuid
  var jobId: String
  /// The Job data
  var data: Data
  /// The current state of the Job
  var state: String
  
  /// The created timestamp
  var createdAt: Date
  /// The updated timestamp
  var updatedAt: Date
  
  /// Codable keys
  enum CodingKeys: String, CodingKey {
    case id
    case key
    case jobId = "job_id"
    case data
    case state
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
  
  init(key: String,
       jobId: String,
       data: Data,
       state: JobState = .pending,
       createdAt: Date = Date(),
       updatedAt: Date = Date()) {
    self.key = key
    self.jobId = jobId
    self.data = data
    self.state = state.rawValue
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}

/// Allows `JobModel` to be used as a dynamic migration.
extension JobModel: Migration { }

/// Allows `JobModel` to be encoded to and decoded from HTTP messages.
extension JobModel: Content { }

/// Allows `JobModel` to be used as a dynamic parameter in route definitions.
extension JobModel: Parameter { }


