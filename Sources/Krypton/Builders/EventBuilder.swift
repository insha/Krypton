//
//  EventBuilder.swift
//  Krypton
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

import Foundation

public final class EventBuilder
{
    private var event_name: String
    private var source_states: Set<State>
    private var destination_state: State?
    private var context_action_should_fire: Event.TransitionTriggerValidation?
    private var context_action_will_fire: TransitionContextAction<Event>?
    private var context_action_did_fire: TransitionContextAction<Event>?

    public init()
    {
        event_name = ""
        source_states = []
    }

    public func name(_ value: String) -> Self
    {
        event_name = value

        return self
    }

    public func source(state: State) -> Self
    {
        source_states.insert(state)

        return self
    }

    public func destination(state: State) -> Self
    {
        destination_state = state

        return self
    }

    public func event_validation(_ action: @escaping Event.TransitionTriggerValidation) -> Self
    {
        context_action_should_fire = action

        return self
    }

    public func action_will_fire(_ action: @escaping TransitionContextAction<Event>) -> Self
    {
        context_action_will_fire = action

        return self
    }

    public func action_did_fire(_ action: @escaping TransitionContextAction<Event>) -> Self
    {
        context_action_did_fire = action

        return self
    }

    public func build() throws -> Event
    {
        guard !event_name.isEmpty,
              !source_states.isEmpty,
              let destination_state = destination_state
        else
        {
            throw KryptonError.invalid_event
        }

        return try Event(name: event_name,
                         sources: source_states,
                         destination: destination_state,
                         transition_context: Event.TransitionContext(should_fire: context_action_should_fire,
                                                                     will_fire: context_action_will_fire,
                                                                     did_fire: context_action_did_fire))
    }
}
