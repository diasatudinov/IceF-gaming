//
//  SpriteViewContainer.swift
//  IceF-gaming
//
//


import SwiftUI
import SpriteKit


struct SpriteViewContainer: UIViewRepresentable {
    var scene: GameScene

    func makeUIView(context: Context) -> SKView {
        let skView = SKView(frame: UIScreen.main.bounds)
        skView.backgroundColor = .clear
        skView.presentScene(scene)
        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        uiView.frame = UIScreen.main.bounds

        // Если подменили сцену (Restart), показываем новую
        if uiView.scene !== scene {
            uiView.presentScene(scene)
        }
    }
}
