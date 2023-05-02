//
//  State.swift
//  Krypton
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

import Foundation

public extension StateMachine
{
    struct State
    {
        public struct Context
        {
            private(set) var will_enter: TransitionContextAction<State>?
            private(set) var did_enter: TransitionContextAction<State>?
            private(set) var will_exit: TransitionContextAction<State>?
            private(set) var did_exit: TransitionContextAction<State>?

            public init(
                will_enter: TransitionContextAction<State>? = nil,
                did_enter: TransitionContextAction<State>? = nil,
                will_exit: TransitionContextAction<State>? = nil,
                did_exit: TransitionContextAction<State>? = nil
            )
            {
                self.will_enter = will_enter
                self.did_enter = did_enter
                self.will_exit = will_exit
                self.did_exit = did_exit
            }
        }

        let name: String
        let user_info: Payload
        let transition_context: Context?

        public init(name: String, user_info: Payload = [:], transition_context: Context? = nil) throws
        {
            guard !name.isEmpty
            else
            {
                throw StateMachine.Error.invalid_state
            }

            self.name = name
            self.user_info = user_info
            self.transition_context = transition_context
        }
    }
}

extension StateMachine.State: Hashable
{
    public static func == (lhs: StateMachine.State, rhs: StateMachine.State) -> Bool
    {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(name)
    }
}

extension StateMachine.State: Comparable
{
    public static func < (lhs: StateMachine.State, rhs: StateMachine.State) -> Bool
    {
        return lhs.name < rhs.name
    }
}

extension StateMachine.State: CustomStringConvertible
{
    public var description: String
    {
        return "\(name)"
    }
}

extension StateMachine.State: RawRepresentable
{
    public typealias RawValue = String

    public init?(rawValue: RawValue)
    {
        guard !rawValue.isEmpty
        else
        {
            return nil
        }

        name = rawValue
        user_info = [:]
        transition_context = Context()
    }

    public var rawValue: String
    {
        return name
    }
}
