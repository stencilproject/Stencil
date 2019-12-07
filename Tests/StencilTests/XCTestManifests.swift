import XCTest

extension ContextTests {
    static let __allTests = [
        ("testContextRestoration", testContextRestoration),
        ("testContextSubscripting", testContextSubscripting),
    ]
}

extension EnvironmentBaseAndChildTemplateTests {
    static let __allTests = [
        ("testRuntimeErrorInBaseTemplate", testRuntimeErrorInBaseTemplate),
        ("testRuntimeErrorInChildTemplate", testRuntimeErrorInChildTemplate),
        ("testSyntaxErrorInBaseTemplate", testSyntaxErrorInBaseTemplate),
        ("testSyntaxErrorInChildTemplate", testSyntaxErrorInChildTemplate),
    ]
}

extension EnvironmentIncludeTemplateTests {
    static let __allTests = [
        ("testRuntimeError", testRuntimeError),
        ("testSyntaxError", testSyntaxError),
    ]
}

extension EnvironmentTests {
    static let __allTests = [
        ("testLoading", testLoading),
        ("testRendering", testRendering),
        ("testRenderingError", testRenderingError),
        ("testSyntaxError", testSyntaxError),
        ("testUnknownFilter", testUnknownFilter),
    ]
}

extension ExpressionsTests {
    static let __allTests = [
        ("testAndExpression", testAndExpression),
        ("testEqualityExpression", testEqualityExpression),
        ("testExpressionParsing", testExpressionParsing),
        ("testFalseExpressions", testFalseExpressions),
        ("testFalseInExpression", testFalseInExpression),
        ("testInequalityExpression", testInequalityExpression),
        ("testLessThanEqualExpression", testLessThanEqualExpression),
        ("testLessThanExpression", testLessThanExpression),
        ("testMoreThanEqualExpression", testMoreThanEqualExpression),
        ("testMoreThanExpression", testMoreThanExpression),
        ("testMultipleExpressions", testMultipleExpressions),
        ("testNotExpression", testNotExpression),
        ("testOrExpression", testOrExpression),
        ("testTrueExpressions", testTrueExpressions),
        ("testTrueInExpression", testTrueInExpression),
    ]
}

extension FilterTagTests {
    static let __allTests = [
        ("testFilterTag", testFilterTag),
    ]
}

extension FilterTests {
    static let __allTests = [
        ("testDefaultFilter", testDefaultFilter),
        ("testDynamicFilters", testDynamicFilters),
        ("testFilterSuggestion", testFilterSuggestion),
        ("testIndentContent", testIndentContent),
        ("testIndentFirstLine", testIndentFirstLine),
        ("testIndentNotEmptyLines", testIndentNotEmptyLines),
        ("testIndentWithArbitraryCharacter", testIndentWithArbitraryCharacter),
        ("testJoinFilter", testJoinFilter),
        ("testRegistration", testRegistration),
        ("testRegistrationOverrideDefault", testRegistrationOverrideDefault),
        ("testRegistrationWithArguments", testRegistrationWithArguments),
        ("testSplitFilter", testSplitFilter),
        ("testStringFilters", testStringFilters),
        ("testStringFiltersWithArrays", testStringFiltersWithArrays),
    ]
}

extension ForNodeTests {
    static let __allTests = [
        ("testArrayOfTuples", testArrayOfTuples),
        ("testForNode", testForNode),
        ("testHandleInvalidInput", testHandleInvalidInput),
        ("testIterateDictionary", testIterateDictionary),
        ("testIterateRange", testIterateRange),
        ("testIterateUsingMirroring", testIterateUsingMirroring),
        ("testLoopMetadata", testLoopMetadata),
        ("testWhereExpression", testWhereExpression),
    ]
}

extension IfNodeTests {
    static let __allTests = [
        ("testEvaluatesNilAsFalse", testEvaluatesNilAsFalse),
        ("testParseIf", testParseIf),
        ("testParseIfnot", testParseIfnot),
        ("testParseIfWithElif", testParseIfWithElif),
        ("testParseIfWithElifWithoutElse", testParseIfWithElifWithoutElse),
        ("testParseIfWithElse", testParseIfWithElse),
        ("testParseMultipleElif", testParseMultipleElif),
        ("testParsingErrors", testParsingErrors),
        ("testRendering", testRendering),
        ("testSupportsRangeVariables", testSupportsRangeVariables),
        ("testSupportVariableFilters", testSupportVariableFilters),
    ]
}

extension IncludeTests {
    static let __allTests = [
        ("testParsing", testParsing),
        ("testRendering", testRendering),
    ]
}

extension InheritanceTests {
    static let __allTests = [
        ("testInheritance", testInheritance),
    ]
}

extension LexerTests {
    static let __allTests = [
        ("testComment", testComment),
        ("testContentMixture", testContentMixture),
        ("testEmptyVariable", testEmptyVariable),
        ("testEscapeSequence", testEscapeSequence),
        ("testNewlines", testNewlines),
        ("testPerformance", testPerformance),
        ("testText", testText),
        ("testTokenizeIncorrectSyntaxWithoutCrashing", testTokenizeIncorrectSyntaxWithoutCrashing),
        ("testTokenWithoutSpaces", testTokenWithoutSpaces),
        ("testUnclosedBlock", testUnclosedBlock),
        ("testUnclosedTag", testUnclosedTag),
        ("testVariable", testVariable),
        ("testVariablesWithoutBeingGreedy", testVariablesWithoutBeingGreedy),
    ]
}

extension NodeTests {
    static let __allTests = [
        ("testRendering", testRendering),
        ("testTextNode", testTextNode),
        ("testVariableNode", testVariableNode),
    ]
}

extension NowNodeTests {
    static let __allTests = [
        ("testParsing", testParsing),
        ("testRendering", testRendering),
    ]
}

extension StencilTests {
    static let __allTests = [
        ("testStencil", testStencil),
    ]
}

extension TemplateLoaderTests {
    static let __allTests = [
        ("testDictionaryLoader", testDictionaryLoader),
        ("testFileSystemLoader", testFileSystemLoader),
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
        ("testArray", testArray),
        ("testDictionary", testDictionary),
        ("testKVO", testKVO),
        ("testLiterals", testLiterals),
        ("testMultipleSubscripting", testMultipleSubscripting),
        ("testOptional", testOptional),
        ("testRangeVariable", testRangeVariable),
        ("testReflection", testReflection),
        ("testSubscripting", testSubscripting),
        ("testTuple", testTuple),
        ("testVariable", testVariable),
    ]
}

#if !os(macOS)
public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(ContextTests.__allTests),
        testCase(EnvironmentBaseAndChildTemplateTests.__allTests),
        testCase(EnvironmentIncludeTemplateTests.__allTests),
        testCase(EnvironmentTests.__allTests),
        testCase(ExpressionsTests.__allTests),
        testCase(FilterTagTests.__allTests),
        testCase(FilterTests.__allTests),
        testCase(ForNodeTests.__allTests),
        testCase(IfNodeTests.__allTests),
        testCase(IncludeTests.__allTests),
        testCase(InheritanceTests.__allTests),
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
