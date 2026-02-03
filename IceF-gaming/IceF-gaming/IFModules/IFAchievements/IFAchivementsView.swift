//
//  PGAchivementsView.swift
//  IceF-gaming
//
//


import SwiftUI

struct IFAchivementsView: View {
    @StateObject var user = ZZUser.shared
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = IFAchievementsViewModel()
    @State private var index = 0
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
                
                HStack {
                    Image(.achievementsTextIF)
                        .resizable()
                        .scaledToFit()
                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 80:90)
                }
                
                VStack {
                    
                    
                    ForEach(viewModel.achievements, id: \.self) { item in
                        Image(item.isAchieved ? item.image : "\(item.image)Off")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 90)
                            .onTapGesture {
                                if item.isAchieved {
                                    user.updateUserMoney(for: 10)
                                }
                                viewModel.achieveToggle(item)
                            }
                        
                    }
                }
                .frame(maxHeight: .infinity)
                
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
    IFAchivementsView()
}
