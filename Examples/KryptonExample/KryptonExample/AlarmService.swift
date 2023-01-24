//
//  AlarmService.swift
//  KryptonExample
//
//  Created by Farhan Ahmed on 1/20/23.
//

import Foundation
import Krypton

final class AlarmService: ObservableObject
{
    private let fsm: Krypton
    private let code: String

    @Published
    private(set) var current_state: State

    init(code: String)
    {
        self.code = code

        fsm = Self.create_fsm()

        fsm.activate()

        current_state = fsm.current_state
    }

    func can_trigger(event: Events) -> Bool
    {
        do
        {
            let event = try event.event(in: fsm)

            return fsm.can_fire(event: event)
        }
        catch
        {
            return false
        }
    }
}

extension AlarmService
{
    enum Events: String
    {
        case arm = "Arm"
        case disarm = "Disarm"
        case reset = "Reset"
        case breach = "Breach"
        case panic = "Panic"

        func event(in fsm: Krypton) throws -> Event
        {
            try fsm.event(named: self.rawValue).get()
        }
    }

    func arm()
    {
        process(event: .arm)
    }

    func disarm(code: String)
    {
        if code == self.code
        {
            process(event: .disarm)
        }
        else
        {
            debugPrint("Incorrect code entered.")
        }
    }

    func breach()
    {
        process(event: .breach)
    }

    func panic()
    {
        process(event: .panic)
    }

    func reset(code: String)
    {
        if code == self.code
        {
            process(event: .reset)
        }
        else
        {
            debugPrint("Incorrect code entered.")
        }
    }
}

extension AlarmService
{
    private func process(event: AlarmService.Events, user_info: Payload = [:])
    {
        do
        {
            let event = try event.event(in: fsm)
            let result = fsm.fire(event: event, user_info: user_info)

            if case .failure(let message) = result
            {
                debugPrint("Failure: \(message)")
            }
            else
            {
                debugPrint("\(event.description)")
                current_state = fsm.current_state
            }
        }
        catch
        {
            debugPrint(error)
        }
    }
}

extension AlarmService
{
    static func create_fsm() -> Krypton
    {
        do
        {
            let (states, events, initial_state) = try states_and_events()
            let fsm = try Krypton(initialState: initial_state)

            fsm.add(newStates: states)
            fsm.add(newEvents: events)

            return fsm
        }
        catch
        {
            fatalError("Oh, Snap! We could not create the state machine.")
        }
    }

    private static func states_and_events() throws -> (states: Set<State>,
                                                       events: Set<Event>,
                                                       initial: State)
    {
        let state_armed = try State(name: "Armed")
        let state_disarmed = try State(name: "Disarmed")
        let state_alarm = try State(name: "Alarm")

        let event_arm = try Event(name: Events.arm.rawValue, sources: [state_disarmed], destination: state_armed)
        let event_disarm = try Event(name: Events.disarm.rawValue, sources: [state_armed], destination: state_disarmed)
        let event_breach = try Event(name: Events.breach.rawValue, sources: [state_armed], destination: state_alarm)
        let event_panic = try Event(name: Events.panic.rawValue, sources: [state_armed], destination: state_alarm)
        let event_reset = try Event(name: Events.reset.rawValue, sources: [state_alarm], destination: state_disarmed)

        return (states: [state_armed, state_disarmed, state_alarm],
                events: [event_arm, event_disarm, event_reset, event_breach, event_panic],
                initial: state_disarmed)
    }
}
