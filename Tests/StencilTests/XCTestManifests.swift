import XCTest

extension ContextTests {
    static let __allTests = [
        ("testContext", testContext),
    ]
}

extension EnvironmentTests {
    static let __allTests = [
        ("testEnvironment", testEnvironment),
    ]
}

extension ExpressionsTests {
    static let __allTests = [
        ("testExpressions", testExpressions),
    ]
}

extension FilterTagTests {
    static let __allTests = [
        ("testFilterTag", testFilterTag),
    ]
}

extension FilterTests {
    static let __allTests = [
        ("testFilter", testFilter),
    ]
}

extension ForNodeTests {
    static let __allTests = [
        ("testForNode", testForNode),
    ]
}

extension IfNodeTests {
    static let __allTests = [
        ("testIfNode", testIfNode),
    ]
}

extension IncludeTests {
    static let __allTests = [
        ("testInclude", testInclude),
    ]
}

extension InheritenceTests {
    static let __allTests = [
        ("testInheritence", testInheritence),
    ]
}

extension LexerTests {
    static let __allTests = [
        ("testLexer", testLexer),
    ]
}

extension NodeTests {
    static let __allTests = [
        ("testNode", testNode),
    ]
}

extension NowNodeTests {
    static let __allTests = [
        ("testNowNode", testNowNode),
    ]
}

extension StencilTests {
    static let __allTests = [
        ("testStencil", testStencil),
    ]
}

extension TemplateLoaderTests {
    static let __allTests = [
        ("testTemplateLoader", testTemplateLoader),
    ]
}

extension TemplateTests {
    static let __allTests = [
        ("testTemplate", testTemplate),
    ]
}

extension TokenParserTests {
    static let __allTests = [
        ("testTokenParser", testTokenParser),
    ]
}

extension TokenTests {
    static let __allTests = [
        ("testToken", testToken),
    ]
}

extension VariableTests {
    static let __allTests = [
        ("testVariable", testVariable),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ContextTests.__allTests),
        testCase(EnvironmentTests.__allTests),
        testCase(ExpressionsTests.__allTests),
        testCase(FilterTagTests.__allTests),
        testCase(FilterTests.__allTests),
        testCase(ForNodeTests.__allTests),
        testCase(IfNodeTests.__allTests),
        testCase(IncludeTests.__allTests),
        testCase(InheritenceTests.__allTests),
        testCase(LexerTests.__allTests),
        testCase(NodeTests.__allTests),
        testCase(NowNodeTests.__allTests),
        testCase(StencilTests.__allTests),
        testCase(TemplateLoaderTests.__allTests),
        testCase(TemplateTests.__allTests),
        testCase(TokenParserTests.__allTests),
        testCase(TokenTests.__allTests),
        testCase(VariableTests.__allTests),
    ]
}
#endif
