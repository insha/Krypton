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
        let state = try StateMachine.State(name: "State A")
        let event = try StateMachine.Event(name: "Event A", sources: [state], destination: state)

        XCTAssertTrue(event.name == "Event A", "The name of the event should have been `Event A`, but it is `\(event.name)`")
    }

    func testAnEventForEquality() throws
    {
        let state = try StateMachine.State(name: "State A")
        let eventA = try StateMachine.Event(name: "Event A", sources: [state], destination: state)
        let eventB = eventA

        XCTAssertTrue(eventA == eventB, "Both event should have been equal, but they are not.")
    }

    func testAnEventHash() throws
    {
        let state = try StateMachine.State(name: "State A")
        let event = try StateMachine.Event(name: "Event A", sources: [state], destination: state)
        let setOfEvents: Set<StateMachine.Event> = [event, event]

        XCTAssertTrue(setOfEvents.count == 1, "There should have only been a single event, but there are more.")
    }

    func testAnEventDescriptionWithOneSourceState() throws
    {
        let state = try StateMachine.State(name: "State A")
        let event = try StateMachine.Event(name: "Event A", sources: [state], destination: state)
        let expectedValue = "Triggered: Event `Event A` | transition: State A  -> State A"
        let actualValue = String(describing: event)

        XCTAssertTrue(
            actualValue == expectedValue,
            "The description, `\(actualValue)`, does not match what was expected, `\(expectedValue)`"
        )
    }

    func testAnEventDescriptionWithMultipleSourceState() throws
    {
        let state = try StateMachine.State(name: "State A")
        let stateB = try StateMachine.State(name: "State B")
        let stateC = try StateMachine.State(name: "State C")
        let event = try StateMachine.Event(name: "Event A", sources: [state, stateB, stateC], destination: state)
        let expectedValue = "Triggered: Event `Event A` | transition: State A, State B, and State C,  -> State A"
        let actualValue = String(describing: event)

        XCTAssertTrue(
            actualValue == expectedValue,
            "The description, `\(actualValue)`, does not match what was expected, `\(expectedValue)`"
        )
    }

    func testEventThatIsDeclined() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let disallow_event: StateMachine.Event.TransitionTriggerValidation = { _, _ -> Bool in false }
        let event_transition = StateMachine.Event.TransitionContext(
            should_fire: disallow_event,
            will_fire: nil,
            did_fire: nil
        )
        let eventA = try StateMachine.Event(
            name: "Event-A-to-B",
            sources: [stateA],
            destination: stateB,
            transition_context: event_transition
        )
        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])
        system.add(events: [eventA])
        system.activate()

        XCTAssertThrowsError(
            try system.fire(event: eventA),
            "We expected the `declined` error; but no errors were thrown."
        )
    }

    func testEventThatIsExplicitlyAllowedToBeTriggered() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let allow_event: StateMachine.Event.TransitionTriggerValidation = { _, _ -> Bool in true }
        let event_transition = StateMachine.Event.TransitionContext(
            should_fire: allow_event,
            will_fire: nil,
            did_fire: nil
        )
        let eventA = try StateMachine.Event(
            name: "Event-A-to-B",
            sources: [stateA],
            destination: stateB,
            transition_context: event_transition
        )
        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])
        system.add(events: [eventA])
        system.activate()

        XCTAssertNoThrow(
            try system.fire(event: eventA),
            "We expected the state machine to allow the event, but it was declined."
        )
    }
}
