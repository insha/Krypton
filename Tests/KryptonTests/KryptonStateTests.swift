//
//  KryptonStateTests.swift
//  KryptonTests
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

@testable import Krypton
import XCTest

final class KryptonStateTests: XCTestCase
{
    func testCreatingStateSuccessfully() throws
    {
        XCTAssertNoThrow(try State(name: "State-A"),
                         "We expected an state to be created; but it wasn't.")
    }

    func testFailureToCreateAState() throws
    {
        XCTAssertThrowsError(try State(name: ""), "We expected the `invalidState` error to be rasied; but it was not.")
    }

    func testCreatingStateUsingRawValue() throws
    {
        let state = State(rawValue: "State-A")

        XCTAssertNotNil(state, "We expected a non-nil state object; but received a `nil` object")
        XCTAssertTrue(state?.rawValue == "State-A")
    }

    func testFailureToCreateStateUsingRawValue() throws
    {
        let state = State(rawValue: "")

        XCTAssertNil(state, "We expected a nil state object; but received a non-nil object")
    }
}
