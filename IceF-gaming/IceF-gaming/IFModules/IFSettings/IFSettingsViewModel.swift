//
//  CPSettingsViewModel.swift
//  IceF-gaming
//
//


import SwiftUI

class IFSettingsViewModel: ObservableObject {
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("musicEnabled") var musicEnabled: Bool = true

}
