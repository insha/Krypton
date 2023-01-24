//
//  KryptonEventTests.swift
//  KryptonKitTests
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

@testable import Krypton
import XCTest

class KryptonEventTests: XCTestCase
{
    func testCreateAnEvent() throws
    {
        let state = try State(name: "State A")
        let event = try Event(name: "Event A", sources: [state], destination: state)

        XCTAssertTrue(event.name == "Event A", "The name of the event should have been `Event A`, but it is `\(event.name)`")
    }

    func testAnEventForEquality() throws
    {
        let state = try State(name: "State A")
        let eventA = try Event(name: "Event A", sources: [state], destination: state)
        let eventB = eventA

        XCTAssertTrue(eventA == eventB, "Both event should have been equal, but they are not.")
    }

    func testAnEventHash() throws
    {
        let state = try State(name: "State A")
        let event = try Event(name: "Event A", sources: [state], destination: state)
        let setOfEvents: Set<Event> = [event, event]

        XCTAssertTrue(setOfEvents.count == 1, "There should have only been a single event, but there are more.")
    }

    func testAnEventDescriptionWithOneSourceState() throws
    {
        let state = try State(name: "State A")
        let event = try Event(name: "Event A", sources: [state], destination: state)
        let expectedValue = "Triggered: Event `Event A` | transition: State A  -> `State A`"
        let actualValue = String(describing: event)

        XCTAssertTrue(actualValue == expectedValue,
                      "The description, `\(actualValue)`, does not match what was expected, `\(expectedValue)`")
    }

    func testAnEventDescriptionWithMultipleSourceState() throws
    {
        let state = try State(name: "State A")
        let stateB = try State(name: "State B")
        let stateC = try State(name: "State C")
        let event = try Event(name: "Event A", sources: [state, stateB, stateC], destination: state)
        let expectedValue = "Triggered: Event `Event A` | transition: State A, State B, and State C,  -> `State A`"
        let actualValue = String(describing: event)

        XCTAssertTrue(actualValue == expectedValue,
                      "The description, `\(actualValue)`, does not match what was expected, `\(expectedValue)`")
    }
}
