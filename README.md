# FeatherSQLSQLite

SQLite dialect for [FeatherSQL](https://github.com/feather-framework/feather-sql).
It provides SQLite-specific SQL syntax and serialization; it does not include
a database connection or query execution layer.

[![Release: 1.0.0-alpha.1](https://img.shields.io/badge/Release-1.0.0--alpha.1-F05138)](https://github.com/feather-framework/feather-sql-sqlite/releases/tag/1.0.0-alpha.1)
![Swift 6.3+](https://img.shields.io/badge/Swift-6.3%2B-F05138)

## Requirements

- Swift 6.3 or later
- macOS 15+, iOS 18+, tvOS 18+, watchOS 11+, or visionOS 2+
- Linux

## Installation

Add FeatherSQL and its SQLite dialect to your package:

```swift
.package(url: "https://github.com/feather-framework/feather-sql", exact: "1.0.0-alpha.1"),
.package(url: "https://github.com/feather-framework/feather-sql-sqlite", exact: "1.0.0-alpha.1"),
```

```swift
.product(name: "FeatherSQL", package: "feather-sql"),
.product(name: "FeatherSQLSQLite", package: "feather-sql-sqlite"),
```

This is an alpha release; APIs may change before the stable `1.0.0` release.

## Usage

Select the SQLite builder to generate SQL using SQLite syntax:

```swift
import FeatherSQL
import FeatherSQLSQLite

let statement = SQLBuilder.sqlite
    .select()
    .column("id")
    .column("email")
    .from("users")
    .build()

print(statement.sql)
```

FeatherSQLSQLite only generates SQL. Use a database adapter to execute it.

## Origins and attribution

FeatherSQLSQLite is a fork and adaptation of the SQLite dialect code from
Vapor's [SQLiteKit](https://github.com/vapor/sqlite-kit) and
[SQLKit](https://github.com/vapor/sql-kit), ported to use FeatherSQL and
excluding connection and execution layers. It is not an official Vapor
project or release. Upstream copyright and license notices are retained in
[LICENSES.md](LICENSES.md).
FeatherSQLSQLite's own work is copyright Binary Birds Kft. and is distributed
under the MIT License in [LICENSE](LICENSE).
