//
//  GameView.swift
//  IceF-gaming
//
//


import SwiftUI
import SpriteKit

struct GameView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: CPShopViewModel
    @State private var gameOver = false
    @State private var score: Int = 0
    @State private var scene: GameScene = {
        let s = GameScene()
        s.scaleMode = .resizeFill
        s.backgroundColor = .clear
        return s
    }()
    @State private var sceneID = UUID() // чтобы пересоздавать сцену при рестарте
    
    @AppStorage("maxScore") var maxScore: Int = 0
    
    var body: some View {
        ZStack {
            
            SpriteViewContainer(scene: scene)
                .id(sceneID)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        Image(.backIconIF)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:50)
                    }
                    
                    Button {
                        restart()
                    } label: {
                        Image(.restartIconIF)
                            .resizable()
                            .scaledToFit()
                            .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:50)
                    }
                    
                    Spacer()
                    
                    ZZCoinBg()
                    
                }.padding()
                
                
                
                
                
                Text("\(score)")
                    .font(.system(size: 54, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                
            }.padding(.vertical, 32)
            
            
            
            
            if gameOver {
                Color.black.opacity(0.55).ignoresSafeArea()
                Image(.gameOverBgIF)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 600)
                    .padding(.trailing, 40)
                    .overlay {
                        VStack {
                            
                            VStack(spacing: 0) {
                                Text("Score: \(score)")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                
                                Text("Best Score: \(maxScore)")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            
                            Button {
                                restart()
                            } label: {
                                Image(.restartBtnIF)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:70)
                            }
                            
                            Button {
                                presentationMode.wrappedValue.dismiss()
                            } label: {
                                Image(.menuBtnIF)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: ZZDeviceManager.shared.deviceType == .pad ? 100:70)
                            }
                        }.padding(.bottom, 70)
                    }
            }
        }
        .background(
            ZStack {
                if let currentBg = viewModel.currentBgItem {
                    Image(currentBg.image)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                }
            }
        )
        .onAppear { wireCallbacks() }
            .onChange(of: sceneID) { _ in
                wireCallbacks()
            }
    }
    
    private func bestScoreDetect() {
        if score > maxScore {
            maxScore = score
        }
    }
    
    private func wireCallbacks() {
        scene.onScore = { newScore in
            DispatchQueue.main.async {
                score = newScore
            }
        }
        scene.onGameOver = { finalScore in
            DispatchQueue.main.async {
                score = finalScore
                bestScoreDetect()
                ZZUser.shared.updateUserMoney(for: 10)
                gameOver = true
            }
        }
    }
    
    private func restart() {
        gameOver = false
        score = 0
        
        let s = GameScene()
        s.scaleMode = .resizeFill
        s.backgroundColor = .clear
        scene = s
        
        sceneID = UUID()
    }
}

#Preview {
    GameView(viewModel: CPShopViewModel())
}
