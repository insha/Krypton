//
//  Event.swift
//  Krypton
//
//  Copyright © 2019-2020 Farhan Ahmed. All rights reserved.
//

import Foundation

public struct Event
{
    public typealias EventLifeCycleHook = (_ event: Event, _ transition: Transition) -> Void
    public typealias EventTriggerCheck = (_ event: Event, _ transition: Transition) -> Bool

    public struct EventLifeCycle
    {
        public var shouldFire: EventTriggerCheck?
        public var willFire: EventLifeCycleHook?
        public var didFire: EventLifeCycleHook?

        public init(shouldFire: EventTriggerCheck? = nil,
                    willFire: EventLifeCycleHook? = nil,
                    didFire: EventLifeCycleHook? = nil)
        {
            self.shouldFire = shouldFire
            self.willFire = willFire
            self.didFire = didFire
        }
    }

    let name: String
    let sources: Set<State>
    let destination: State
    let lifeCycle: EventLifeCycle?

    public init(name: String, sources: Set<State>, destination: State, lifeCycle: EventLifeCycle)
    {
        guard !name.isEmpty
        else
        {
            fatalError("The event name cannot be blank.")
        }

        self.name = name
        self.sources = sources
        self.destination = destination
        self.lifeCycle = lifeCycle
    }
}

extension Event: Hashable
{
    public static func == (lhs: Event, rhs: Event) -> Bool
    {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(name)
    }
}

extension Event: CustomStringConvertible
{
    public var description: String
    {
        var sourceStates: String = ""
        let sortedSources = sources.sorted()

        for (index, state) in sortedSources.enumerated()
        {
            if sources.count == 1
            {
                sourceStates = "\(state.name) "
            }
            else if index == sources.count - 2
            {
                sourceStates += "\(state.name), and "
            }
            else
            {
                sourceStates += "\(state.name), "
            }
        }

        return "Event `\(name)` transitions from \(sourceStates)to `\(destination.name)`"
    }
}
