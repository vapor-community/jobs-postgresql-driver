# JobsPostgreSQLDriver

A package that sits on top of the Jobs package (https://github.com/vapor-community/jobs) and implements PostgreSQL as a persistence layer. 

# Installation
Add this to your Package.swift:

```swift
.package(url: "https://github.com/vapor-community/jobs-postgresql-driver", from: "0.1.0")
```

Create the `jobs` table in your database:

```swift
CREATE TABLE job (
    id SERIAL PRIMARY KEY,
    key character varying(255) NOT NULL,
    job_id character varying(255) NOT NULL,
    data bytea NOT NULL,
    state character varying(255) NOT NULL,
    created_at timestamp with time zone NOT NULL DEFAULT clock_timestamp(),
    updated_at timestamp with time zone NOT NULL DEFAULT clock_timestamp()
);
CREATE INDEX job_key_idx ON job(key);
```

Initialize the Jobs service and set the default database for the `JobModel` model in your `confirgure.swift`:

```swift
import Jobs
import JobsPostgreSQLDriver

/// Register the Jobs service, with PostgreSQL persistence layer
services.register(JobsPersistenceLayer.self) { container -> JobsPostgreSQLDriver in
    return JobsPostgreSQLDriver(database: postgresql, eventLoop: container.next())
}
try jobs(&services)

/// Set the default database on the JobModel
JobModel.defaultDatabase = .psql
```

Where `postgresql` is the instance of your `PostgreSQLDatabase`. ie:

```swift
let postgresql = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(url: ConfigVars.DATABASE_URL)!)
```


Follow the instructions in the `Jobs` package for more setup and configuration information. 
