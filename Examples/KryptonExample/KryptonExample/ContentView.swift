//
//  ContentView.swift
//  KryptonExample
//
//  Created by Farhan Ahmed on 1/20/23.
//

import SwiftUI

struct ContentView: View
{
    @ObservedObject var service: AlarmService
    @State private var alarm_code = ""

    var body: some View
    {
        VStack(alignment: .leading)
        {
            TextField("Alarm Code", text: $alarm_code)

            Divider()

            Text("State: \(service.current_state.rawValue)")
                .padding(.vertical)

            Divider()

            HStack(spacing: 20)
            {
                Spacer()

                Button(action: { service.arm() })
                {
                    Text("Arm")
                }
                .disabled(!service.can_trigger(event: .arm))

                Button(action: {service.disarm(code: alarm_code)})
                {
                    Text("Disarm")
                }
                .disabled(!service.can_trigger(event: .disarm))

                Button(action: {service.reset(code: alarm_code)})
                {
                    Text("Reset")
                }
                .disabled(!service.can_trigger(event: .reset))

                Button(action: {service.panic()})
                {
                    Text("Panic")
                }
                .disabled(!service.can_trigger(event: .panic))

                Spacer()
            }
            .padding(.vertical, 20)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View
    {
        ContentView(service: AlarmService(code: "123456"))
    }
}
