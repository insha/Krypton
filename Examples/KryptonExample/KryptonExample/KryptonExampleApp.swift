//
//  KryptonExampleApp.swift
//  KryptonExample
//
//  Created by Farhan Ahmed on 1/20/23.
//

import SwiftUI

@main
struct KryptonExampleApp: App
{
    var body: some Scene
    {
        WindowGroup
        {
            ContentView(service: AlarmService(code: "123456"))
        }
    }
}
