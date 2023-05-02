//
//  KryptonTests.swift
//  KryptonTests
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

@testable import Krypton
import XCTest

final class KryptonTests: XCTestCase
{
    func testCreateStatemachineWithTwoStates() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let event = try StateMachine.Event(name: "From-A-to-B", sources: [stateA], destination: stateB)

        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.states.count == 2, "We expected the state machine to have 2 states, but it has `\(system.states.count)` states.")
    }

    func testStateMachineIsImmutableAfterActivation() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let event = try StateMachine.Event(name: "From-A-to-B", sources: [stateA], destination: stateB)

        let system = try StateMachine(initial_state: stateA)

        system.activate()

        system.add(states: [stateA, stateB])
        system.add(event: event)
        system.add(events: [event])

        XCTAssertTrue(system.states.isEmpty, "We expected to not have any states, but the state machine has states.")
    }

    func testStateMachineWithSingleEvent() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let event = try StateMachine.Event(name: "From-A-to-B", sources: [stateA], destination: stateB)

        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.events.count == 1, "We expected the state machine to have 1 event, but it has `\(system.events.count)` events.")
    }

    func testStateMachineByAddingSameStateTwice() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let event = try StateMachine.Event(name: "From-A-to-B", sources: [stateA], destination: stateB)

        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])
        system.add(state: stateA)
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.states.count == 2, "We expected the state machine to have 2 states, but it has `\(system.states.count)` states.")
    }

    func testStateMachineByAddingSameEventTwice() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let event = try StateMachine.Event(name: "From-A-to-B", sources: [stateA], destination: stateB)

        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])
        system.add(event: event)
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.events.count == 1, "We expected the state machine to have 1 event, but it has `\(system.events.count)` events.")
    }

    func testAddingMultipleEvents() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let eventA = try StateMachine.Event(name: "From-A-to-B", sources: [stateA], destination: stateB)
        let eventB = try StateMachine.Event(name: "From-B-to-A", sources: [stateB], destination: stateA)

        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])
        system.add(events: [eventA, eventB])
        system.activate()

        XCTAssertTrue(system.events.count == 2, "We expected the state machine to have 2 events, but it has `\(system.events.count)` events.")
    }

    func testAddingAStateAfterActivation() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")

        let system = try StateMachine(initial_state: stateA)

        system.activate()

        system.add(state: stateB)

        XCTAssertTrue(system.states.isEmpty, "We expected to not have any states, but the state machine has states.")
    }

    func testEventLookupPerformance() throws
    {
        var states: Set<StateMachine.State> = []

        for index in 0 ... 10000
        {
            try states.insert(StateMachine.State(name: "State-\(index)"))
        }

        let initialState = try StateMachine.State(name: "State-Initial")
        let system = try StateMachine(initial_state: initialState)

        system.add(states: states)
        system.activate()

        measure
        {
            _ = system.event(named: "State-4200")
        }
    }

    func testStateLookupPerformance() throws
    {
        var events: Set<StateMachine.Event> = []
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])

        for index in 0 ... 10000
        {
            try events.insert(StateMachine.Event(name: "Event-\(index)", sources: [stateA, stateB], destination: stateB))
        }

        system.add(events: events)
        system.activate()

        measure
        {
            _ = system.event(named: "Event-4200")
        }
    }

    func testFiringEventPerformance() throws
    {
        var events: Set<StateMachine.Event> = []
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])

        for index in 0 ... 10000
        {
            try events.insert(StateMachine.Event(name: "Event-\(index)", sources: [stateA, stateB], destination: stateB))
        }

        system.add(events: events)
        system.activate()

        let result = system.event(named: "Event-4200")
        let fireEvent: StateMachine.Event

        if case .success(let event) = result
        {
            fireEvent = event

            measure
            {
                try? system.fire(event: fireEvent)
            }
        }
        else
        {
            XCTFail("An event was not found.")
        }
    }

    func testStateLookupFailure() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let system = try StateMachine(initial_state: stateA)
        let result = system.state(named: "State-B")
        var value = false

        if case .failure(let expectedError) = result
        {
            if case .not_found = expectedError
            {
                value = true
            }
            else
            {
                // Nothing to do.
            }
        }
        else
        {
            // Nothing to do.
        }

        XCTAssertTrue(
            value,
            "We expected the state machine to return a `notActivated` error, but did not received any error."
        )
    }

    func testStateMachineInCorrectState() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let eventA = try StateMachine.Event(name: "Event-A-to-B", sources: [stateA], destination: stateB)
        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])
        system.add(events: [eventA])

        system.activate()

        try system.fire(event: eventA)

        XCTAssertTrue(
            system.isIn(state: stateB),
            "We expected the state machine to be in state `\(stateB.name)`, but it is in `\(system.current_state.name)`."
        )
    }

    func testStateMachineCannotFireEventWhenNotActivated() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let eventA = try StateMachine.Event(name: "Event-A-to-B", sources: [stateA], destination: stateB)
        let system = try StateMachine(initial_state: stateA)

        system.add(states: [stateA, stateB])
        system.add(events: [eventA])

        XCTAssertThrowsError(
            try system.fire(event: eventA),
            "We expected the `not_activated` error; but no errors were thrown."
        )
    }

    func testTransitionIsNotPermitted() throws
    {
        let stateA = try StateMachine.State(name: "State-A")
        let stateB = try StateMachine.State(name: "State-B")
        let stateC = try StateMachine.State(name: "State-C")
        let eventA = try StateMachine.Event(name: "Event-A-to-B", sources: [stateA], destination: stateB)
        let system = try StateMachine(initial_state: stateC)

        system.add(states: [stateA, stateB, stateC])
        system.add(events: [eventA])

        system.activate()

        XCTAssertThrowsError(
            try system.fire(event: eventA),
            "We expected the `cannot_fire` error; but no errors were thrown."
        )
    }
}
