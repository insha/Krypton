//
//  State.swift
//  Krypton
//
//  Copyright © 2019-2020 Farhan Ahmed. All rights reserved.
//

import Foundation

public struct State
{
    public typealias StateLifeCycle = (_ state: State, _ transition: Transition?) -> Void

    public struct LifeCycle
    {
        public var willEnter: StateLifeCycle?
        public var didEnter: StateLifeCycle?
        public var willExit: StateLifeCycle?
        public var didExit: StateLifeCycle?

        public init(willEnter: StateLifeCycle? = nil,
                    didEnter: StateLifeCycle? = nil,
                    willExit: StateLifeCycle? = nil,
                    didExit: StateLifeCycle? = nil)
        {
            self.willEnter = willEnter
            self.didEnter = didEnter
            self.willExit = willExit
            self.didExit = didExit
        }
    }

    let name: String
    let userInfo: Payload?
    let lifeCycle: LifeCycle?

    public init(name: String, userInfo: Payload? = nil, lifeCycle: LifeCycle?)
    {
        guard !name.isEmpty
        else
        {
            fatalError("The state name cannot be blank.")
        }

        self.name = name
        self.userInfo = userInfo
        self.lifeCycle = lifeCycle
    }
}

extension State: Hashable
{
    public static func == (lhs: State, rhs: State) -> Bool
    {
        return lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher)
    {
        hasher.combine(name)
    }
}

extension State: Comparable
{
    public static func < (lhs: State, rhs: State) -> Bool
    {
        return lhs.name < rhs.name
    }
}

extension State: CustomStringConvertible
{
    public var description: String
    {
        return "\(name)"
    }
}

extension State: RawRepresentable
{
    public typealias RawValue = String

    public init?(rawValue: RawValue)
    {
        guard !rawValue.isEmpty
        else
        {
            fatalError("The state name cannot be blank.")
        }

        name = rawValue
        userInfo = nil
        lifeCycle = LifeCycle()
    }

    public var rawValue: String
    {
        return name
    }
}
