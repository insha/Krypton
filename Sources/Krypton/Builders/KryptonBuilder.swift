//
//  KryptonBuilder.swift
//  Krypton
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

import Foundation

public final class KryptonBuilder
{
    private var states: Set<State>
    private var events: Set<Event>
    private var starting_state: State?

    init()
    {
        states = []
        events = []
    }

    func state(_ value: State) -> Self
    {
        states.insert(value)

        return self
    }

    func states(_ values: State...) -> Self
    {
        values.forEach(
        { item in
            states.insert(item)
        })

        return self
    }

    func event(_ value: Event) -> Self
    {
        events.insert(value)

        return self
    }

    func events(_ values: Event...) -> Self
    {
        values.forEach(
        { item in
            events.insert(item)
        })

        return self
    }

    func initial_state(_ value: State) -> Self
    {
        starting_state = value

        return self
    }

    func build() throws -> Krypton
    {
        guard !states.isEmpty,
              !events.isEmpty,
              let starting_state = starting_state
        else
        {
            throw KryptonError.declined(message: "Validtion failed during state machine creation.")
        }

        let fsm = try Krypton(initial_state: starting_state)

        fsm.add(states: states)
        fsm.add(events: events)

        return fsm
    }
}
