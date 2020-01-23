//
//  KryptonEventTests.swift
//  KryptonKitTests
//
//  Copyright © 2019-2020 Farhan Ahmed. All rights reserved.
//

import XCTest
@testable import Krypton

class KryptonEventTests: XCTestCase
{
    func testCreateAnEvent()
    {
        let state = State(name: "State A", userInfo: nil, lifeCycle: State.LifeCycle())
        let event = Event(name: "Event A", sources: [state], destination: state, lifeCycle: Event.EventLifeCycle())

        XCTAssertTrue(event.name == "Event A", "The name of the event should have been `Event A`, but it is `\(event.name)`")
    }

    func testAnEventForEquality()
    {
        let state = State(name: "State A", userInfo: nil, lifeCycle: State.LifeCycle())
        let eventA = Event(name: "Event A", sources: [state], destination: state, lifeCycle: Event.EventLifeCycle())
        let eventB = eventA

        XCTAssertTrue(eventA == eventB, "Both event should have been equal, but they are not.")
    }

    func testAnEventHash()
    {
        let state = State(name: "State A", userInfo: nil, lifeCycle: State.LifeCycle())
        let event = Event(name: "Event A", sources: [state], destination: state, lifeCycle: Event.EventLifeCycle())
        let setOfEvents: Set<Event> = [event, event]

        XCTAssertTrue(setOfEvents.count == 1, "There should have only been a single event, but there are more.")
    }

    func testAnEventDescriptionWithOneSourceState()
    {
        let state = State(name: "State A", userInfo: nil, lifeCycle: State.LifeCycle())
        let event = Event(name: "Event A", sources: [state], destination: state, lifeCycle: Event.EventLifeCycle())
        let expectedValue = "Event `Event A` transitions from State A to `State A`"
        let actualValue   = String(describing: event)

        XCTAssertTrue(actualValue == expectedValue,
                      "The description, `\(actualValue)`, does not match what was expected, `\(expectedValue)`")
    }

    func testAnEventDescriptionWithMultipleSourceState()
    {
        let state = State(name: "State A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State B", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateC = State(name: "State C", userInfo: nil, lifeCycle: State.LifeCycle())
        let event = Event(name: "Event A", sources: [state, stateB, stateC], destination: state, lifeCycle: Event.EventLifeCycle())
        let expectedValue = "Event `Event A` transitions from State A, State B, and State C, to `State A`"
        let actualValue   = String(describing: event)

        XCTAssertTrue(actualValue == expectedValue,
                      "The description, `\(actualValue)`, does not match what was expected, `\(expectedValue)`")
    }
}
