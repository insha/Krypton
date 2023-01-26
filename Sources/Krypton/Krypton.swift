//
//  Krypton.swift
//  Krypton
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

import Foundation

public typealias Payload = [String: Any]
public typealias TransitionContextAction<Context> = (_ context: Context, _ transition: Transition?) -> Void

protocol StateMachine
{
    associatedtype States
    associatedtype Events

    var is_active: Bool { get }
    var current_state: State { get }
    var initial_state: State { get }

    func activate()
    func can_fire(event: Event) -> Bool
    func fire(event: Event, user_info: Payload) throws
}

public enum KryptonError: Error
{
    case not_found
    case not_activated
    case cannot_fire(message: String)
    case declined(message: String)
    case invalid_state
    case invalid_event
}

public class Krypton: StateMachine
{
    typealias States = [String: State]
    typealias Events = [String: Event]

    private(set) var states: States
    private(set) var events: Events
    private(set) var initial_state: State
    public private(set) var is_active: Bool
    public private(set) var current_state: State

    public init(initial_state: State) throws
    {
        self.initial_state = initial_state
        states = [:]
        events = [:]
        is_active = false
        current_state = try State(name: "Starting-State")
    }

    public func add(state: State)
    {
        guard !is_active
        else
        {
            return
        }

        if case .failure = self.state(named: state.name)
        {
            states[state.name] = state
        }
        else
        {
            // Nothing else needs to be done.
        }
    }

    public func add(states: Set<State>)
    {
        guard
            !is_active,
            !states.isEmpty
        else
        {
            return
        }

        states.forEach
        { state in
            self.add(state: state)
        }
    }

    public func add(event: Event)
    {
        guard !is_active
        else
        {
            return
        }

        if case .failure = self.event(named: event.name)
        {
            events[event.name] = event
        }
        else
        {
            // Nothing to do
        }
    }

    public func add(events: Set<Event>)
    {
        guard !is_active
        else
        {
            return
        }

        events.forEach
        { event in
            self.add(event: event)
        }
    }

    public func state(named: String) -> Result<State, KryptonError>
    {
        let result: Result<State, KryptonError>

        if let foundState = states[named]
        {
            result = Result.success(foundState)
        }
        else
        {
            result = Result.failure(KryptonError.not_found)
        }

        return result
    }

    public func event(named: String) -> Result<Event, KryptonError>
    {
        let result: Result<Event, KryptonError>

        if let foundEvent = events[named]
        {
            result = Result.success(foundEvent)
        }
        else
        {
            result = Result.failure(KryptonError.not_found)
        }

        return result
    }

    public func isIn(state: State) -> Bool
    {
        return current_state == state
    }

    public func activate()
    {
        guard !is_active
        else
        {
            return
        }

        is_active = true

        // Invoke lifecycle events
        if let block = initial_state.transition_context?.will_enter
        {
            block(initial_state, nil)
        }
        else
        {
            // Nothing to do.
        }

        current_state = initial_state

        if let block = initial_state.transition_context?.did_enter
        {
            block(initial_state, nil)
        }
        else
        {
            // Nothing to do.
        }
    }

    public func can_fire(event: Event) -> Bool
    {
        return event.sources.isEmpty || event.sources.contains(current_state)
    }

    public func fire(event: Event, user_info: Payload = [:]) throws
    {
        guard is_active
        else
        {
            throw KryptonError.not_activated
        }

        // Check if the transition is permitted
        if !can_fire(event: event)
        {
            let message = "An attempt was made to fire the `\(event.name)` event " +
                "while in the `\(current_state.name)` state. This event can " +
                "only be fired from the following states: \(event.sources)"

            throw KryptonError.cannot_fire(message: message)
        }
        else
        {
            // Nothing to do.
        }

        let transition = Transition(event: event, source: current_state, in: self, user_info: user_info)

        if let should_file = event.transition_context?.should_fire,
           !should_file(event, transition)
        {
            let message = "An attempt to fire the `\(event.name)` event was declined " +
                "because `shouldFire` method returned `false`."

            throw KryptonError.declined(message: message)
        }
        else
        {
            // When the `should_fire` closure is not provided, that
            // is the same as if it has returned the value `true`.
            // therefore the event will be triggered and all
            // associated lifecycle closures will be invoked, if available.
        }

        let old_state = current_state
        let new_state = event.destination

        event_transition(event: event, transition: transition, block: event.transition_context?.will_fire)
        state_transition(state: old_state, transition: transition, block: old_state.transition_context?.will_exit)

        event_transition(event: event, transition: transition, block: event.transition_context?.did_fire)

        state_transition(state: old_state, transition: transition, block: old_state.transition_context?.did_exit)
        state_transition(state: new_state, transition: transition, block: new_state.transition_context?.will_enter)

        current_state = new_state

        state_transition(state: new_state, transition: transition, block: new_state.transition_context?.did_enter)
    }

    private func event_transition(event: Event, transition: Transition, block: TransitionContextAction<Event>?)
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

    private func state_transition(state: State, transition: Transition?, block: TransitionContextAction<State>?)
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
        return "State Machine: \(states.count) States | \(events.count) Events | Current State: \(current_state)"
    }

    public var dot_description: String
    {
        var dot_graph = "digraph StateMachine {\n"

        dot_graph += "  \"\" [style=\"invis\"]; \"\" -> \"\(initial_state.name)\" [dir=both, arrowtail=dot]; // Initial State\n"
        dot_graph += "  \"\(current_state.name)\" [style=bold]; // Current State\n"

        for (_, event) in events
        {
            for source in event.sources
            {
                dot_graph += "  \"\(source.name)\" -> \"\(event.destination.name)\" [label=\"\(event.name)\", " +
                    "fontname=\"Menlo Italic\", fontsize=9];\n"
            }
        }

        dot_graph += "}"

        return dot_graph
    }
}
