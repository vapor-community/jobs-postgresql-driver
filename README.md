# JobsPostgreSQLDriver

A package that sits on top of the Jobs package (https://github.com/vapor/jobs) and implements PostgreSQL as a persistence layer. 

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
