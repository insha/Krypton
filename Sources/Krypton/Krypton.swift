//
//  Krypton.swift
//  Krypton
//
//  Copyright © 2019-2020 Farhan Ahmed. All rights reserved.
//

import Foundation

public typealias Payload = [String: Any]

protocol StateMachine
{
    associatedtype States
    associatedtype Events

    var isActive: Bool { get }
    var currentState: State { get }
    var initialState: State { get }

    func activate()
    func canFire(event: Event) -> Bool
    func fire(event: Event, userInfo: [String: Any]) -> Result<Bool, KryptonError>
}

public enum KryptonError: Error
{
    case notFound
    case notActivated
    case cannotFire(message: String)
    case declined(message: String)
}

public class Krypton: StateMachine
{
    typealias States = Set<State>
    typealias Events = Set<Event>

    private(set) var states: States
    private(set) var events: Events
    private(set) var isActive: Bool
    private(set) var initialState: State
    private(set) var currentState: State

    public init(initialState: State)
    {
        self.initialState = initialState
        states = []
        events = []
        isActive = false
        currentState = State(name: "Starting-State", userInfo: nil, lifeCycle: State.LifeCycle())
    }

    public func add(state: State)
    {
        guard !isActive
        else
        {
            return
        }

        if case .failure = self.state(named: state.name)
        {
            states.insert(state)
        }
        else
        {
            // Nothing else needs to be done.
        }
    }

    public func add(newStates: Set<State>)
    {
        guard
            !isActive,
            !newStates.isEmpty
        else
        {
            return
        }

        newStates.forEach
        { state in
            self.add(state: state)
        }
    }

    public func add(event: Event)
    {
        guard !isActive
        else
        {
            return
        }

        if case .failure = self.event(named: event.name)
        {
            events.insert(event)
        }
        else
        {
            // Nothing to do
        }
    }

    public func add(newEvents: Set<Event>)
    {
        guard !isActive
        else
        {
            return
        }

        newEvents.forEach
        { event in
            self.add(event: event)
        }
    }

    public func state(named: String) -> Result<State, KryptonError>
    {
        let result: Result<State, KryptonError>
        let foundState = states.first { $0.name == named }

        if let foundState = foundState
        {
            result = Result.success(foundState)
        }
        else
        {
            result = Result.failure(KryptonError.notFound)
        }

        return result
    }

    public func event(named: String) -> Result<Event, KryptonError>
    {
        let result: Result<Event, KryptonError>
        let foundEvent = events.first { $0.name == named }

        if let foundEvent = foundEvent
        {
            result = Result.success(foundEvent)
        }
        else
        {
            result = Result.failure(KryptonError.notFound)
        }

        return result
    }

    public func isIn(state: State) -> Bool
    {
        return currentState == state
    }

    public func activate()
    {
        guard !isActive
        else
        {
            return
        }

        isActive = true

        // Invoke lifecycle events
        if let block = initialState.lifeCycle?.willEnter
        {
            block(initialState, nil)
        }
        else
        {
            // Nothing to do.
        }

        currentState = initialState

        if let block = initialState.lifeCycle?.didEnter
        {
            block(initialState, nil)
        }
        else
        {
            // Nothing to do.
        }
    }

    public func canFire(event: Event) -> Bool
    {
        return event.sources.isEmpty || event.sources.contains(currentState)
    }

    public func fire(event: Event, userInfo: [String: Any] = [:]) -> Result<Bool, KryptonError>
    {
        guard isActive
        else
        {
            return Result.failure(KryptonError.notActivated)
        }

        // Check if the transition is permitted
        if !canFire(event: event)
        {
            let message = "An attempt was made to fire the `\(event.name)` event " +
                          "while in the `\(currentState.name)` state. This event can " +
                          "only be fired from the following states: \(event.sources)"
            return Result.failure(KryptonError.cannotFire(message: message))
        }
        else
        {
            // Nothing to do.
        }

        let transition = Transition(event: event, source: currentState, in: self, userInfo: userInfo)

        if let block = event.lifeCycle?.shouldFire
        {
            if !block(event, transition)
            {
                let message = "An attempt to fire the `\(event.name)` event was declined " +
                              "because `shouldFire` method returned `false`."
                return Result.failure(KryptonError.declined(message: message))
            }
            else
            {
                // Nothing to do.
            }
        }
        else
        {
            // When the `shouldFire` closure is not provided, that
            // is the same as if it has returned the value `true`.
            // therefore the event will be triggered and all
            // associated lifecycle closures will be invoked, if available.
        }

        let oldState = currentState
        let newState = event.destination

        eventLifeCycle(event: event, transition: transition, block: event.lifeCycle?.willFire)
        stateLifeCycle(state: oldState, transition: transition, block: oldState.lifeCycle?.willExit)
        stateLifeCycle(state: newState, transition: transition, block: newState.lifeCycle?.willEnter)

        currentState = newState

        stateLifeCycle(state: oldState, transition: transition, block: oldState.lifeCycle?.didExit)
        stateLifeCycle(state: newState, transition: transition, block: newState.lifeCycle?.didEnter)
        eventLifeCycle(event: event, transition: transition, block: event.lifeCycle?.didFire)

        return Result.success(true)
    }

    private func eventLifeCycle(event: Event, transition: Transition, block: Event.EventLifeCycleHook?)
    {
        if let block = block
        {
            block(event, transition)
        }
        else
        {
            // Nothing to do.
        }
    }

    private func stateLifeCycle(state: State, transition: Transition?, block: State.StateLifeCycle?)
    {
        if let block = block
        {
            block(state, transition)
        }
        else
        {
            // Nothing to do.
        }
    }
}

extension Krypton: CustomStringConvertible
{
    public var description: String
    {
        return "State Machine: \(states.count) States | \(events.count) Events | Current State: \(currentState)"
    }

    public var dotDescription: String
    {
        var dotGraph = "digraph StateMachine {\n"

        dotGraph += "  \"\" [style=\"invis\"]; \"\" -> \"\(initialState.name)\" [dir=both, arrowtail=dot]; // Initial State\n"
        dotGraph += "  \"\(currentState.name)\" [style=bold]; // Current State\n"

        for event in events
        {
            for source in event.sources
            {
                dotGraph += "  \"\(source.name)\" -> \"\(event.destination.name)\" [label=\"\(event.name)\", " +
                            "fontname=\"Menlo Italic\", fontsize=9];\n"
            }
        }

        dotGraph += "}"

        return dotGraph
    }
}
