//
//  StateBuilder.swift
//  Krypton
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

import Foundation

public final class StateBuilder
{
    private var state_name: String
    private var user_info: Payload
    private var context_action_will_enter: TransitionContextAction<State>?
    private var context_action_did_enter: TransitionContextAction<State>?
    private var context_action_will_exit: TransitionContextAction<State>?
    private var context_action_did_exit: TransitionContextAction<State>?

    public init()
    {
        state_name = ""
        user_info = [:]
    }

    public func name(_ value: String) -> Self
    {
        state_name = value

        return self
    }

    public func payload(_ value: Payload) -> Self
    {
        user_info = value

        return self
    }

    public func action_will_enter(_ action: @escaping TransitionContextAction<State>) -> Self
    {
        context_action_will_enter = action

        return self
    }

    public func action_did_enter(_ action: @escaping TransitionContextAction<State>) -> Self
    {
        context_action_did_enter = action

        return self
    }

    public func action_will_exit(_ action: @escaping TransitionContextAction<State>) -> Self
    {
        context_action_will_exit = action

        return self
    }

    public func action_did_exit(_ action: @escaping TransitionContextAction<State>) -> Self
    {
        context_action_did_exit = action

        return self
    }

    public func build() throws -> State
    {
        guard !state_name.isEmpty
        else
        {
            throw KryptonError.invalid_state
        }

        return try State(name: state_name,
                         user_info: user_info,
                         transition_context: State.Context(will_enter: context_action_will_enter,
                                                           did_enter: context_action_did_enter,
                                                           will_exit: context_action_will_exit,
                                                           did_exit: context_action_did_exit))
    }
}
