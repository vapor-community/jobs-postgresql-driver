# JobsPostgreSQLDriver
A PostgreSQL Persistance Layer for the Vapor Jobs framework:

[Jobs]https://github.com/vapor/jobs

```
  // Configure the PostgreSQL database
  let postgresql = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(url: ConfigVars.DATABASE_URL)!)
  databases.add(database: postgresql, as: .psql)

  /// Register the Jobs service, with PostgreSQL persistence layer
  services.register(JobsPersistenceLayer.self) { container -> JobsPostgreSQLDriver in
    return JobsPostgreSQLDriver(database: postgresql, eventLoop: container.next())
  }
  try jobs(&services)
```

