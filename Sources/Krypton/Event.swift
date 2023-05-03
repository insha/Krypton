//
//  Event.swift
//  Krypton
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

import Foundation

public extension StateMachine
{
    struct Event
    {
        public typealias TransitionTriggerValidation = (_ event: Event, _ transition: Transition) -> Bool

        public struct TransitionContext
        {
            private(set) var should_fire: TransitionTriggerValidation?
            private(set) var will_fire: TransitionContextAction<Event>?
            private(set) var did_fire: TransitionContextAction<Event>?

            public init(
                should_fire: TransitionTriggerValidation? = nil,
                will_fire: TransitionContextAction<Event>? = nil,
                did_fire: TransitionContextAction<Event>? = nil
            )
            {
                self.should_fire = should_fire
                self.will_fire = will_fire
                self.did_fire = did_fire
            }
        }

        public let name: String
        public let sources: Set<State>
        public let destination: State

        let transition_context: TransitionContext?

        public init(
            name: String,
            sources: Set<State>,
            destination: State,
            transition_context: TransitionContext = TransitionContext()
        ) throws
        {
            guard !name.isEmpty
            else
            {
                throw StateMachine.Error.invalid_event
            }

            self.name = name
            self.sources = sources
            self.destination = destination
            self.transition_context = transition_context
        }
    }
}

extension StateMachine.Event: Hashable
{
    public static func == (lhs: StateMachine.Event, rhs: StateMachine.Event) -> Bool
    {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(name)
    }
}

extension StateMachine.Event: CustomStringConvertible
{
    public var description: String
    {
        var source_states = ""
        let sorted_sources = sources.sorted()

        for (index, state) in sorted_sources.enumerated()
        {
            if sources.count == 1
            {
                source_states = "\(state.name) "
            }
            else if index == sources.count - 2
            {
                source_states += "\(state.name), and "
            }
            else
            {
                source_states += "\(state.name), "
            }
        }

        return "Triggered: Event `\(name)` | transition: \(source_states) -> \(destination.name)"
    }
}
