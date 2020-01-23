# Krypton
## A State Machine

### Quick Start

```
enum SystemState: String, CaseIterable
{
    case disarmed
    case armed
    case alarm

    var stateValue: State
    {
        return State(name: self.rawValue, lifeCycle: State.LifeCycle())
    }
}

enum SystemEvent: String, CaseIterable
{
    case arm
    case disarm
    case reset
    case breach
    case panic

    var eventValue: Event
    {
        let event: Event

        switch self
        {
            case .arm:
                event = Event(name: self.rawValue,
                              sources: [SystemState.disarmed.stateValue],
                              destination: SystemState.armed.stateValue,
                              lifeCycle: Event.EventLifeCycle())
            case .disarm:
                event = Event(name: self.rawValue,
                              sources: [SystemState.armed.stateValue],
                              destination: SystemState.disarmed.stateValue,
                              lifeCycle: Event.EventLifeCycle())
            case .breach:
                event = Event(name: self.rawValue,
                              sources: [SystemState.armed.stateValue],
                              destination: SystemState.alarm.stateValue,
                              lifeCycle: Event.EventLifeCycle())
            case .panic:
                event = Event(name: self.rawValue,
                              sources: [SystemState.armed.stateValue],
                              destination: SystemState.alarm.stateValue,
                              lifeCycle: Event.EventLifeCycle())
            case .reset:
                event = Event(name: self.rawValue,
                              sources: [SystemState.alarm.stateValue],
                              destination: SystemState.disarmed.stateValue,
                              lifeCycle: Event.EventLifeCycle())
        }

        return event
    }
}

class AlarmSystem: CustomStringConvertible
{
    private let system: StateMachine
    private let code: String

    var description: String
    {
        return system.dotDescription
    }

    init(code: String)
    {
        self.code = code

        let fsm = Krypton(initialState: SystemState.disarmed.stateValue)

        fsm.add(newStates: Set(SystemState.allCases.map{ $0.stateValue }))
        fsm.add(newEvents: Set(SystemEvent.allCases.map{ $0.eventValue }))
        fsm.activate()

        self.system = fsm

        print(system)
    }

    func breach()
    {
        process(event: SystemEvent.breach.eventValue)
    }

    private func process(event: Event, userInfo: [String: Any]? = nil)
    {
        let result = system.fire(event: event, userInfo: userInfo)

        if case .failure(let error) = result
        {
            if case .cannotFire(let message) = error
            {
                print(message)
            }
            else
            {
                print("Failure: \(error)")
            }
        }
        else
        {
            // Nothing to do.
            print(system)
        }
    }
}

let test = AlarmSystem(code: "1234")

test.breach()
```
