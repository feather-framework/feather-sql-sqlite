// Serialization scenarios adapted from Vapor SQLKit and SQLiteKit tests.
import FeatherSQL
import FeatherSQLSQLite
import Testing

@Suite("SQLKit-derived SQLite serialization")
struct SQLiteSerializationTests {

    @Test("serializes identifiers and positional bindings")
    func selectWithBoundValue() {
        let result = SQLBuilder.sqlite
            .select()
            .column("id")
            .column("display_name")
            .from("items")
            .where("display_name", .equal, SQLBind("Feather"))
            .build()

        #expect(
            result.sql
                == #"SELECT "id", "display_name" FROM "items" WHERE "display_name" = ?1"#
        )
        #expect(result.bindings.count == 1)
        #expect(result.bindings.first as? String == "Feather")
    }

    // SQL generation scenarios adapted from Vapor SQLiteKit's testPlanets.
    @Test("serializes SQLite schema and grouped query expressions")
    func sqliteSpecificExpressions() throws {
        let table = SQLBuilder.sqlite
            .create(table: "planets")
            .ifNotExists()
            .column("id", type: .int, .primaryKey(autoIncrement: false))
            .column("name", type: .text)
            .build()

        #expect(
            table.sql
                == #"CREATE TABLE IF NOT EXISTS "planets" ("id" INTEGER PRIMARY KEY, "name" TEXT)"#
        )

        let query = SQLBuilder.sqlite
            .select()
            .column("*")
            .from("planets")
            .where("name", .notEqual, SQLLiteral.null)
            .where {
                $0.orWhere("name", .equal, SQLBind("Earth"))
                    .orWhere("name", .equal, SQLBind("Mars"))
            }
            .groupBy("id")
            .orderBy("name", .descending)
            .build()

        #expect(
            query.sql
                == #"SELECT * FROM "planets" WHERE "name" <> NULL AND ("name" = ?1 OR "name" = ?2) GROUP BY "id" ORDER BY "name" DESC"#
        )
        #expect(query.bindings.count == 2)

        let jsonPath = SQLBuilder.sqlite.build(
            SQLNestedSubpathExpression(
                column: "payload",
                path: ["member", "name"]
            )
        )
        #expect(jsonPath.sql == #"json_extract("payload", '$.member.name')"#)
    }

    @Test("covers SQLite dialect features and fallback paths")
    func dialectFeaturesAndFallbacks() throws {
        let dialect = SQLiteDialect()

        #expect(dialect.name == "sqlite")
        #expect(SQLBuilder.sqlite.build(dialect.identifierQuote).sql == "\"")
        #expect(SQLBuilder.sqlite.build(dialect.literalStringQuote).sql == "'")
        #expect(
            SQLBuilder.sqlite.build(dialect.bindPlaceholder(at: 7)).sql == "?7"
        )
        #expect(
            SQLBuilder.sqlite.build(dialect.literalBoolean(true)).sql == "TRUE"
        )
        #expect(
            SQLBuilder.sqlite.build(dialect.literalBoolean(false)).sql
                == "FALSE"
        )
        #expect(SQLBuilder.sqlite.build(dialect.literalDefault).sql == "NULL")
        #expect(dialect.supportsIfExists)
        #expect(!dialect.supportsDropBehavior)
        #expect(!dialect.supportsAutoIncrement)
        #expect(
            SQLBuilder.sqlite.build(dialect.autoIncrementClause).sql
                == "AUTOINCREMENT"
        )
        #expect(dialect.enumSyntax == .unsupported)
        #expect(dialect.triggerSyntax.create.contains(.supportsBody))
        #expect(dialect.triggerSyntax.create.contains(.supportsUpdateColumns))
        #expect(!dialect.alterTableSyntax.allowsBatch)
        #expect(dialect.alterTableSyntax.alterColumnDefinitionClause == nil)
        #expect(dialect.upsertSyntax == .standard)
        #expect(dialect.supportsReturning)
        #expect(dialect.unionFeatures.contains(.intersect))

        let bigIntegerType = try #require(dialect.customDataType(for: .bigint))
        #expect(SQLBuilder.sqlite.build(bigIntegerType).sql == "INTEGER")
        if let otherType = dialect.customDataType(for: .text) {
            Issue.record(
                "Unexpected custom type: \(SQLBuilder.sqlite.build(otherType).sql)"
            )
        }

        #expect(
            dialect.nestedSubpathExpression(
                in: SQLIdentifier("payload"),
                for: []
            ) == nil
        )
        let nestedPath = try #require(
            dialect.nestedSubpathExpression(
                in: SQLIdentifier("payload"),
                for: ["member", "name"]
            )
        )
        #expect(
            SQLBuilder.sqlite.build(nestedPath).sql
                == #"json_extract("payload", '$.member.name')"#
        )
    }
}
