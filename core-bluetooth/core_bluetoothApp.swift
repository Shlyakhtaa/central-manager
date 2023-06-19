//
//  core_bluetoothApp.swift
//  core-bluetooth
//
//  Created by Andrew on 2022-07-14.
//

import SwiftUI

let scanDateArray = ScanDateArray()
let textFieldgroupNumber = TextFieldGroupData()

@main
struct core_bluetoothApp: App {
    var body: some Scene {
        WindowGroup {
            MainBoard()
                .environmentObject(textFieldgroupNumber)
                .environmentObject(scanDateArray)
        }
    }
}
