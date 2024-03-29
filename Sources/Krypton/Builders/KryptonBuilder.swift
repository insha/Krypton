//
//  KryptonBuilder.swift
//  Krypton
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

import Foundation

public final class KryptonBuilder
{
    private var states: Set<StateMachine.State>
    private var events: Set<StateMachine.Event>
    private var starting_state: StateMachine.State?

    init()
    {
        states = []
        events = []
    }

    func state(_ value: StateMachine.State) -> Self
    {
        states.insert(value)

        return self
    }

    func states(_ values: StateMachine.State...) -> Self
    {
        values.forEach
        { item in
            states.insert(item)
        }

        return self
    }

    func event(_ value: StateMachine.Event) -> Self
    {
        events.insert(value)

        return self
    }

    func events(_ values: StateMachine.Event...) -> Self
    {
        values.forEach
        { item in
            events.insert(item)
        }

        return self
    }

    func initial_state(_ value: StateMachine.State) -> Self
    {
        starting_state = value

        return self
    }

    func build() throws -> StateMachine
    {
        guard !states.isEmpty,
              !events.isEmpty,
              let starting_state = starting_state
        else
        {
            throw StateMachine.Error.declined(message: "Validtion failed during state machine creation.")
        }

        let fsm = try StateMachine(initial_state: starting_state)

        fsm.add(states: states)
        fsm.add(events: events)

        return fsm
    }
}
