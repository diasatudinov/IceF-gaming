//
//  PGSettingsView.swift
//  IceF-gaming
//
//


import SwiftUI

struct IFSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var settingsVM = IFSettingsViewModel()
    var body: some View {
        ZStack {
            
            VStack {
                
                ZStack {
                    
                    Image(.settingsBgIF)
                        .resizable()
                        .scaledToFit()
                    
                    
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            VStack {
                                
                                Image(.soundsTextIF)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:30)
                                
                                HStack {
                                    Button {
                                        withAnimation {
                                            settingsVM.soundEnabled.toggle()
                                        }
                                    } label: {
                                        Image(settingsVM.soundEnabled ? .onIF:.offIF)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:50)
                                    }
                                }
                            }
                        }
                        
                        Image(.languageIconIF)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:100)
                        
                        
                    }.padding(.top,30)
                }.frame(height: ZZDeviceManager.shared.deviceType == .pad ? 88:420)
                
            }
            
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        Image(.backIconIF)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:60)
                    }
                    
                    Spacer()
                    
                    ZZCoinBg()
                    
                }.padding()
                Spacer()
                
            }
        }.frame(maxWidth: .infinity)
            .background(
                ZStack {
                    Image(.appBgIF)
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFill()
                }
            )
    }
}

#Preview {
    IFSettingsView()
}
