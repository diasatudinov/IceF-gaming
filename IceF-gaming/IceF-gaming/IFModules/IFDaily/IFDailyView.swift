//
//  IFDailyView.swift
//  IceF-gaming
//
//

import SwiftUI

struct IFDailyView: View {
    @StateObject var user = ZZUser.shared
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("claim") var claim: Bool = false
    var body: some View {
        ZStack {
            
            VStack {
                
                ZStack {
                    
                    HStack(alignment: .center) {
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
                        
                    }.padding(.horizontal).padding([.top])
                }
                
                
                Image(.dailyBgIF)
                    .resizable()
                    .scaledToFit()
                    .padding(.trailing, 50)
                    .overlay(alignment: .bottom) {
                        Button {
                            claim.toggle()
                        } label: {
                            
                            Image(!claim ? .claimBtnIF:.collectedBtnIF)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:75)
                        }
                    }
                
                Spacer()
            }
        }.background(
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
    IFDailyView()
}
