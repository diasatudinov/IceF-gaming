//
//  GameView.swift
//  IceF-gaming
//
//  Created by Dias Atudinov on 30.01.2026.
//


import SwiftUI
import SpriteKit

struct GameView: View {
    @State private var gameOver = false
    @State private var score: Int = 0
    @State private var sceneID = UUID() // чтобы пересоздавать сцену при рестарте

    var body: some View {
        ZStack {
            SpriteView(scene: makeScene(),
                       options: [.ignoresSiblingOrder],
                       debugOptions: [])
                .ignoresSafeArea()

            VStack {
                HStack {
                    Text("Score: \(score)")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.35))
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)

                Spacer()
            }

            if gameOver {
                Color.black.opacity(0.55).ignoresSafeArea()

                VStack(spacing: 12) {
                    Text("Game Over")
                        .font(.system(size: 34, weight: .bold))
                    Text("Score: \(score)")
                        .font(.system(size: 20, weight: .semibold))
                        .opacity(0.9)

                    Button {
                        gameOver = false
                        score = 0
                        sceneID = UUID()
                    } label: {
                        Text("Restart")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal, 26)
                            .padding(.vertical, 12)
                            .background(.white)
                            .foregroundColor(.black)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 8)
                }
                .foregroundColor(.white)
            }
        }
    }

    private func makeScene() -> SKScene {
        let s = GameScene()
        s.scaleMode = .resizeFill

        s.onScore = { newScore in
            score = newScore
        }
        s.onGameOver = { finalScore in
            score = finalScore
            gameOver = true
        }

        // Используем sceneID, чтобы SpriteView пересоздал сцену при рестарте
        _ = sceneID
        return s
    }
}