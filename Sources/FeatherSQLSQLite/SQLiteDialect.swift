public import FeatherSQL

/// The `SQLDialect` defintions for SQLite.
///
/// > Note: There is only ever one SQLite library in use by SQLiteNIO in any given process (even if there are
/// > other versions of the library being used by other things). As such, there is no need for the dialect to
/// > concern itself with what version the connection using it "connected" to - it can always just look up the
/// > global "runtime version".
public struct SQLiteDialect: SQLDialect {
    /// Create a new ``SQLiteDialect``.
    public init() {}

    // See `SQLDialect.name`.
    public var name: String {
        "sqlite"
    }

    // See `SQLDialect.identifierQuote`.
    public var identifierQuote: any SQLExpression {
        SQLRaw(#"""#)
    }

    // See `SQLDialect.literalStringQuote`.
    public var literalStringQuote: any SQLExpression {
        SQLRaw("'")
    }

    // See `SQLDialect.bindPlaceholder(at:)`.
    public func bindPlaceholder(at position: Int) -> any SQLExpression {
        SQLRaw("?\(position)")
    }

    // See `SQLDialect.literalBoolean(_:)`.
    public func literalBoolean(_ value: Bool) -> any SQLExpression {
        SQLRaw(value ? "TRUE" : "FALSE")
    }

    // See `SQLDialect.literalDefault`.
    public var literalDefault: any SQLExpression {
        SQLLiteral.null
    }

    // See `SQLDialect.supportsIfExists`.
    public var supportsIfExists: Bool {
        true
    }

    // See `SQLDialect.supportsDropBehavior`.
    public var supportsDropBehavior: Bool {
        false
    }

    // See `SQLDialect.supportsAutoIncrement`.
    public var supportsAutoIncrement: Bool {
        false
    }

    // See `SQLDialect.autoIncrementClause`.
    public var autoIncrementClause: any SQLExpression {
        SQLRaw("AUTOINCREMENT")
    }

    // See `SQLDialect.enumSyntax`.
    public var enumSyntax: SQLEnumSyntax {
        .unsupported
    }

    // See `SQLDialect.triggerSyntax`.
    public var triggerSyntax: SQLTriggerSyntax {
        .init(
            create: [
                .supportsBody, .supportsCondition, .supportsUpdateColumns,
            ],
            drop: []
        )
    }

    // See `SQLDialect.alterTableSyntax`.
    public var alterTableSyntax: SQLAlterTableSyntax {
        .init(allowsBatch: false)
    }

    // See `SQLDialect.upsertSyntax`.
    public var upsertSyntax: SQLUpsertSyntax {
        .standard
    }

    // See `SQLDialect.supportsReturning`.
    public var supportsReturning: Bool {
        true
    }

    // See `SQLDialect.unionFeatures`.
    public var unionFeatures: SQLUnionFeatures {
        [.union, .unionAll, .intersect, .except]
    }

    // See `SQLDialect.customDataType(for:)`.
    public func customDataType(for dataType: SQLDataType) -> (
        any SQLExpression
    )? {
        if case .bigint = dataType {
            // Translate requests for bigint to requests for SQLite's plain integer type. This yields the autoincrement
            // primary key behavior when a 64-bit integer is requested from a higher layer.
            return SQLDataType.int
        }
        return nil
    }

    // See `SQLDialect.nestedSubpathExpression(in:for:)`.
    public func nestedSubpathExpression(
        in column: any SQLExpression,
        for path: [String]
    ) -> (any SQLExpression)? {
        guard !path.isEmpty else { return nil }

        return SQLFunction(
            "json_extract",
            args: [
                column,
                SQLLiteral.string("$.\(path.joined(separator: "."))"),
            ]
        )
    }
}

extension SQLBuilder {

    public static var sqlite: Self {
        Self(dialect: SQLiteDialect())
    }
}
