import XCTest
@testable import Krypton

final class KryptonTests: XCTestCase
{
    func testCreateStatemachineWithTwoStates()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let event  = Event(name: "From-A-to-B", sources: [stateA], destination: stateB, lifeCycle: Event.EventLifeCycle())

        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.states.count == 2, "We expected the state machine to have 2 states, but it has `\(system.states.count)` states.")
    }

    func testStateMachineIsImmutableAfterActivation()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let event  = Event(name: "From-A-to-B", sources: [stateA], destination: stateB, lifeCycle: Event.EventLifeCycle())

        let system = Krypton(initialState: stateA)

        system.activate()

        system.add(newStates: [stateA, stateB])
        system.add(event: event)
        system.add(newEvents: [event])

        XCTAssertTrue(system.states.count == 0, "We expected to not have any states, but the state machine has states.")
    }

    func testStateMachineWithSingleEvent()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let event  = Event(name: "From-A-to-B", sources: [stateA], destination: stateB, lifeCycle: Event.EventLifeCycle())

        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.events.count == 1, "We expected the state machine to have 1 event, but it has `\(system.events.count)` events.")
    }

    func testStateMachineByAddingSameStateTwice()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let event  = Event(name: "From-A-to-B", sources: [stateA], destination: stateB, lifeCycle: Event.EventLifeCycle())

        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(state: stateA)
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.states.count == 2, "We expected the state machine to have 2 states, but it has `\(system.states.count)` states.")
    }

    func testStateMachineByAddingSameEventTwice()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let event  = Event(name: "From-A-to-B", sources: [stateA], destination: stateB, lifeCycle: Event.EventLifeCycle())

        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(event: event)
        system.add(event: event)
        system.activate()

        XCTAssertTrue(system.events.count == 1, "We expected the state machine to have 1 event, but it has `\(system.events.count)` events.")
    }

    func testAddingMultipleEvents()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let eventA  = Event(name: "From-A-to-B", sources: [stateA], destination: stateB, lifeCycle: Event.EventLifeCycle())
        let eventB  = Event(name: "From-B-to-A", sources: [stateB], destination: stateA, lifeCycle: Event.EventLifeCycle())

        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(newEvents: [eventA, eventB])
        system.activate()

        XCTAssertTrue(system.events.count == 2, "We expected the state machine to have 2 events, but it has `\(system.events.count)` events.")
    }

    func testAddingAStateAfterActivation()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())

        let system = Krypton(initialState: stateA)

        system.activate()

        system.add(state: stateB)

        XCTAssertTrue(system.states.count == 0, "We expected to not have any states, but the state machine has states.")
    }

    func testEventLookupPerformance()
    {
        var states: Set<State> = []

        for index in 0...10_000
        {
            states.insert(State(name: "State-\(index)", userInfo: nil, lifeCycle: State.LifeCycle()))
        }

        let initialState = State(name: "State-Initial", userInfo: nil, lifeCycle: State.LifeCycle())
        let system = Krypton(initialState: initialState)

        system.add(newStates: states)
        system.activate()

        self.measure
        {
            let _ = system.event(named: "State-4200")
        }
    }

    func testStateLookupPerformance()
    {
        var events: Set<Event> = []
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])

        for index in 0...10_000
        {
            events.insert(Event(name: "Event-\(index)", sources: [stateA, stateB], destination: stateB, lifeCycle: Event.EventLifeCycle()))
        }

        system.add(newEvents: events)
        system.activate()

        self.measure
        {
            let _ = system.event(named: "Event-4200")
        }
    }

    func testFiringEventPerformance()
    {
        var events: Set<Event> = []
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])

        for index in 0...10_000
        {
            events.insert(Event(name: "Event-\(index)", sources: [stateA, stateB], destination: stateB, lifeCycle: Event.EventLifeCycle()))
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
                let _ = system.fire(event: fireEvent, userInfo: [:])
            }
        }
        else
        {
            XCTFail("An event was not found.")
        }
    }

    func testStateLookupFailure()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let system = Krypton(initialState: stateA)
        let result = system.state(named: "State-B")
        var value  = false

        if case .failure(let expectedError) = result
        {
            if case .notFound = expectedError
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

    func testStateMachineInCorrectState()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let eventA = Event(name: "Event-A-to-B", sources: [stateA], destination: stateB, lifeCycle: Event.EventLifeCycle())
        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(newEvents: [eventA])

        system.activate()

        let _ = system.fire(event: eventA, userInfo: [:])

        XCTAssertTrue(system.isIn(state: stateB),
                      "We expected the state machine to be in state `\(stateB.name)`, but it is in `\(system.currentState.name)`.")
    }

    func testStateMachineCannotFireEventWhenNotActivated()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let eventA = Event(name: "Event-A-to-B", sources: [stateA], destination: stateB, lifeCycle: Event.EventLifeCycle())
        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(newEvents: [eventA])

        let result = system.fire(event: eventA, userInfo: [:])
        var value = false

        if case .failure(let expectedError) = result
        {
            if case .notActivated = expectedError
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

    func testTransitionIsNotPermitted()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateC = State(name: "State-C", userInfo: nil, lifeCycle: State.LifeCycle())
        let eventA = Event(name: "Event-A-to-B", sources: [stateA], destination: stateB, lifeCycle: Event.EventLifeCycle())
        let system = Krypton(initialState: stateC)
        var value  = false

        system.add(newStates: [stateA, stateB, stateC])
        system.add(newEvents: [eventA])

        system.activate()

        let result = system.fire(event: eventA, userInfo: [:])

        if case .failure(let expectedError) = result
        {
            if case .cannotFire = expectedError
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

    func testEventThatIsDeclined()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let eventShouldNotFire: Event.EventTriggerCheck = { (event, transition) -> Bool in return false }
        let eventLifeCycle = Event.EventLifeCycle(shouldFire:eventShouldNotFire,
                                                  willFire: nil,
                                                  didFire: nil)
        let eventA = Event(name: "Event-A-to-B", sources: [stateA], destination: stateB, lifeCycle: eventLifeCycle)
        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(newEvents: [eventA])
        system.activate()

        let result = system.fire(event: eventA, userInfo: [:])
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

    func testEventThatIsExplicitlyAllowedToBeTriggered()
    {
        let stateA = State(name: "State-A", userInfo: nil, lifeCycle: State.LifeCycle())
        let stateB = State(name: "State-B", userInfo: nil, lifeCycle: State.LifeCycle())
        let eventShouldNotFire: Event.EventTriggerCheck = { (event, transition) -> Bool in return true }
        let eventLifeCycle = Event.EventLifeCycle(shouldFire:eventShouldNotFire,
                                                  willFire: nil,
                                                  didFire: nil)
        let eventA = Event(name: "Event-A-to-B", sources: [stateA], destination: stateB, lifeCycle: eventLifeCycle)
        let system = Krypton(initialState: stateA)

        system.add(newStates: [stateA, stateB])
        system.add(newEvents: [eventA])
        system.activate()

        let result = system.fire(event: eventA, userInfo: [:])
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
