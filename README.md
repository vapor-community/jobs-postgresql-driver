# JobsPostgreSQLDriver

A package that sits on top of the Jobs package (https://github.com/vapor/jobs) and implements PostgreSQL as a persistence layer. 

# Installation

Add this to your Package.swift:

```swift
.package(url: "https://github.com/vapor-community/jobs-postgresql-driver", from: "0.1.0")
```

Create the `jobs` table in your database via a migration:

```swift
var migrations = MigrationConfig()

migrations.add(model: JobModel.self, database: .psql)

services.register(migrations)
```

Initialize the Jobs service and set the default database for the `JobModel` model in your `configure.swift`:

```swift
import Jobs
import JobsPostgreSQLDriver

/// Register the Jobs service, with PostgreSQL persistence layer
services.register(JobsPersistenceLayer.self) { container -> JobsPostgreSQLDriver in
    return JobsPostgreSQLDriver(databaseIdentifier: .psql, container: container)
}
try jobs(&services)

/// Set the default database on the JobModel
JobModel.defaultDatabase = .psql
```

Follow the instructions in the `Jobs` package for more setup and configuration information. 
