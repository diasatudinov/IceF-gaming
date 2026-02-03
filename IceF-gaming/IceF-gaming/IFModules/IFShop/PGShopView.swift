//
//  PGShopView.swift
//  IceF-gaming
//
//


import SwiftUI

struct PGShopView: View {
    @StateObject var user = ZZUser.shared
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CPShopViewModel
    @State var category: JGItemCategory?
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            
            if let category = category {
                VStack(spacing: 35) {
                    
                    Image(category == .skin ? .skinsHeadIF : .bgHeadIF)
                        .resizable()
                        .scaledToFit()
                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:70)
                    
                    LazyVGrid(columns: columns, spacing: 12) {
                        
                        ForEach(category == .skin ? viewModel.shopSkinItems :viewModel.shopBgItems, id: \.self) { item in
                            achievementItem(item: item, category: category == .skin ? .skin : .background)
                            
                        }
                    }
                    
                }
            } else {
                ZStack {
                    
                    Image(.shopBgIF)
                        .resizable()
                        .scaledToFit()
                    
                    VStack(spacing: 20) {
                        Button {
                            category = .skin
                        } label: {
                            Image(.skinsBtnIF)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:75)
                        }
                        
                        Button {
                            category = .background
                        } label: {
                            Image(.bgBtnIF)
                                .resizable()
                                .scaledToFit()
                                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:75)
                        }
                    }
                    
                }.frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:400)
            }
            
            
            
            VStack {
                HStack {
                    Button {
                        if category == nil {
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            category = nil
                        }
                        
                    } label: {
                        Image(.backIconIF)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:65)
                    }
                    
                    Spacer()
                    
                    ZZCoinBg()
                    
                    
                    
                }.padding()
                Spacer()
                
                
                
            }
        }.frame(maxWidth: .infinity)
            .background(
                Image(.appBgIF)
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFill()
            )
            .overlay(alignment: .bottomLeading) {
                if category == nil {
                    Image(.personIconIF)
                        .resizable()
                        .scaledToFit()
                        .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:300)
                }
            }.ignoresSafeArea(edges: .bottom)
    }
    
    @ViewBuilder func achievementItem(item: JGItem, category: JGItemCategory) -> some View {
        ZStack {
            Image(.itemBgIF)
                .resizable()
                .scaledToFit()
            
            Image(item.icon)
                .resizable()
                .scaledToFit()
                .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 200:125)
                .padding(.bottom, 30)
            
            VStack {
                Spacer()
                Button {
                    viewModel.selectOrBuy(item, user: user, category: category)
                } label: {
                    
                    if viewModel.isPurchased(item, category: category) {
                        ZStack {
                            Image(viewModel.isCurrentItem(item: item, category: category) ? .usedBtnBgIF : .useBtnBgIF)
                                .resizable()
                                .scaledToFit()
                            
                        }.frame(height: ZZDeviceManager.shared.deviceType == .pad ? 50:47)
                        
                    } else {
                        Image(viewModel.isMoneyEnough(item: item, user: user, category: category) ? "hundredCoinIF" : "hundredOffCoinIF")
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 50:47)
                    }
                    
                    
                }
            }.offset(y: 0)
            
        }.frame(height: ZZDeviceManager.shared.deviceType == .pad ? 300:230)
        
    }
}

#Preview {
    PGShopView(viewModel: CPShopViewModel())
}
