//
//  Transition.swift
//  Krypton
//
//  Copyright © 2019-2020 Farhan Ahmed. All rights reserved.
//

import Foundation

public struct Transition
{
    let event: Event
    let source: State
    let system: Krypton
    let userInfo: Payload?

    var destination: State
    {
        return event.destination
    }

    init(event: Event, source: State, in system: Krypton, userInfo: Payload?)
    {
        self.event = event
        self.source = source
        self.system = system
        self.userInfo = userInfo
    }
}
