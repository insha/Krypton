import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry]
{
    return [
        testCase(KryptonTests.allTests),
        testCase(KryptonEventTests.allTests)
    ]
}
#endif
