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
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let event = try Event(name: "From-A-to-B", sources: [stateA], destination: stateB)

        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.states.count == 2, "We expected the state machine to have 2 states, but it has `\(system.states.count)` states.")
    }

    func testStateMachineIsImmutableAfterActivation() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let event = try Event(name: "From-A-to-B", sources: [stateA], destination: stateB)

        let system = try Krypton(initialState: stateA)

        system.activate()

        system.add(newStates: [stateA, stateB])
        system.add(event: event)
        system.add(newEvents: [event])

        XCTAssertTrue(system.states.isEmpty, "We expected to not have any states, but the state machine has states.")
    }

    func testStateMachineWithSingleEvent() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let event = try Event(name: "From-A-to-B", sources: [stateA], destination: stateB)

        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.events.count == 1, "We expected the state machine to have 1 event, but it has `\(system.events.count)` events.")
    }

    func testStateMachineByAddingSameStateTwice() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let event = try Event(name: "From-A-to-B", sources: [stateA], destination: stateB)

        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(state: stateA)
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.states.count == 2, "We expected the state machine to have 2 states, but it has `\(system.states.count)` states.")
    }

    func testStateMachineByAddingSameEventTwice() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let event = try Event(name: "From-A-to-B", sources: [stateA], destination: stateB)

        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(event: event)
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.events.count == 1, "We expected the state machine to have 1 event, but it has `\(system.events.count)` events.")
    }

    func testAddingMultipleEvents() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let eventA = try Event(name: "From-A-to-B", sources: [stateA], destination: stateB)
        let eventB = try Event(name: "From-B-to-A", sources: [stateB], destination: stateA)

        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(newEvents: [eventA, eventB])
        system.activate()

        XCTAssertTrue(system.events.count == 2, "We expected the state machine to have 2 events, but it has `\(system.events.count)` events.")
    }

    func testAddingAStateAfterActivation() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")

        let system = try Krypton(initialState: stateA)

        system.activate()

        system.add(state: stateB)

        XCTAssertTrue(system.states.isEmpty, "We expected to not have any states, but the state machine has states.")
    }

    func testEventLookupPerformance() throws
    {
        var states: Set<State> = []

        for index in 0 ... 10000
        {
            states.insert(try State(name: "State-\(index)"))
        }

        let initialState = try State(name: "State-Initial")
        let system = try Krypton(initialState: initialState)

        system.add(newStates: states)
        system.activate()

        measure
        {
            _ = system.event(named: "State-4200")
        }
    }

    func testStateLookupPerformance() throws
    {
        var events: Set<Event> = []
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])

        for index in 0 ... 10000
        {
            events.insert(try Event(name: "Event-\(index)", sources: [stateA, stateB], destination: stateB))
        }

        system.add(newEvents: events)
        system.activate()

        measure
        {
            _ = system.event(named: "Event-4200")
        }
    }

    func testFiringEventPerformance() throws
    {
        var events: Set<Event> = []
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])

        for index in 0 ... 10000
        {
            events.insert(try Event(name: "Event-\(index)", sources: [stateA, stateB], destination: stateB))
        }

        system.add(newEvents: events)
        system.activate()

        let result = system.event(named: "Event-4200")
        let fireEvent: Event

        if case .success(let event) = result
        {
            fireEvent = event

            self.measure
            {
                _ = system.fire(event: fireEvent)
            }
        }
        else
        {
            XCTFail("An event was not found.")
        }
    }

    func testStateLookupFailure() throws
    {
        let stateA = try State(name: "State-A")
        let system = try Krypton(initialState: stateA)
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

        XCTAssertTrue(value,
                      "We expected the state machine to return a `notActivated` error, but did not received any error.")
    }

    func testStateMachineInCorrectState() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let eventA = try Event(name: "Event-A-to-B", sources: [stateA], destination: stateB)
        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(newEvents: [eventA])

        system.activate()

        _ = system.fire(event: eventA)

        XCTAssertTrue(system.isIn(state: stateB),
                      "We expected the state machine to be in state `\(stateB.name)`, but it is in `\(system.current_state.name)`.")
    }

    func testStateMachineCannotFireEventWhenNotActivated() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let eventA = try Event(name: "Event-A-to-B", sources: [stateA], destination: stateB)
        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(newEvents: [eventA])

        let result = system.fire(event: eventA)
        var value = false

        if case .failure(let expectedError) = result
        {
            if case .not_activated = expectedError
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

        XCTAssertTrue(value, "We expected the `cannotFire` error, but received the error `\(result)`.")
    }

    func testTransitionIsNotPermitted() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let stateC = try State(name: "State-C")
        let eventA = try Event(name: "Event-A-to-B", sources: [stateA], destination: stateB)
        let system = try Krypton(initialState: stateC)
        var value = false

        system.add(newStates: [stateA, stateB, stateC])
        system.add(newEvents: [eventA])

        system.activate()

        let result = system.fire(event: eventA)

        if case .failure(let expectedError) = result
        {
            if case .cannot_fire = expectedError
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

        XCTAssertTrue(value, "We expected the state machine to return the error `cannotFire`, but we received `\(result)`")
    }

    func testEventThatIsDeclined() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let eventShouldNotFire: Event.TransitionTriggerValidation = { _, _ -> Bool in false }
        let eventLifeCycle = Event.TransitionContext(should_fire: eventShouldNotFire,
                                                     will_fire: nil,
                                                     did_fire: nil)
        let eventA = try Event(name: "Event-A-to-B", sources: [stateA], destination: stateB, transition_context: eventLifeCycle)
        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(newEvents: [eventA])
        system.activate()

        let result = system.fire(event: eventA)
        var value = false

        if case .failure(let expectedError) = result
        {
            if case .declined = expectedError
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

        XCTAssertTrue(value, "We expected the state machine to decline the event, but it was not declined.")
    }

    func testEventThatIsExplicitlyAllowedToBeTriggered() throws
    {
        let stateA = try State(name: "State-A")
        let stateB = try State(name: "State-B")
        let eventShouldNotFire: Event.TransitionTriggerValidation = { _, _ -> Bool in true }
        let eventLifeCycle = Event.TransitionContext(should_fire: eventShouldNotFire,
                                                     will_fire: nil,
                                                     did_fire: nil)
        let eventA = try Event(name: "Event-A-to-B", sources: [stateA], destination: stateB, transition_context: eventLifeCycle)
        let system = try Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(newEvents: [eventA])
        system.activate()

        let result = system.fire(event: eventA)
        var value = false

        if case .success(let resultValue) = result
        {
            value = resultValue
        }
        else
        {
            // Nothing to do.
        }

        XCTAssertTrue(value, "We expected the state machine to allow the event, but it was declined.")
    }
}
