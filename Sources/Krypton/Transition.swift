//
//  Transition.swift
//  Krypton
//
//  Copyright © 2019-2023 Farhan Ahmed. All rights reserved.
//

import Foundation

public extension StateMachine
{
    struct Transition
    {
        let event: Event
        let source: State
        let system: StateMachine
        let user_info: Payload

        var destination: State
        {
            return event.destination
        }

        init(event: Event, source: State, in system: StateMachine, user_info: Payload = [:])
        {
            self.event = event
            self.source = source
            self.system = system
            self.user_info = user_info
        }
    }
}
