//
//  CPSettingsViewModel.swift
//  IceF-gaming
//
//  Created by Dias Atudinov on 02.02.2026.
//


import SwiftUI

class SettingsViewModel: ObservableObject {
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("musicEnabled") var musicEnabled: Bool = true

}
