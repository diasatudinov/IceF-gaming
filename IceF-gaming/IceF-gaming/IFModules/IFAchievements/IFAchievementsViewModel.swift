//
//  ZZAchievementsViewModel.swift
//  IceF-gaming
//
//


import SwiftUI

class IFAchievementsViewModel: ObservableObject {
    
    @Published var achievements: [NEGAchievement] = [
        NEGAchievement(image: "achieve1ImageIF", title: "achieve1TextIF", isAchieved: false),
        NEGAchievement(image: "achieve2ImageIF", title: "achieve2TextIF", isAchieved: false),
        NEGAchievement(image: "achieve3ImageIF", title: "achieve3TextIF", isAchieved: false),
        NEGAchievement(image: "achieve4ImageIF", title: "achieve4TextIF", isAchieved: false),
        NEGAchievement(image: "achieve5ImageIF", title: "achieve5TextIF", isAchieved: false),
    ] {
        didSet {
            saveAchievementsItem()
        }
    }
        
    init() {
        loadAchievementsItem()
    }
    
    private let userDefaultsAchievementsKey = "achievementsKeyIF"
    
    func achieveToggle(_ achive: NEGAchievement) {
        guard let index = achievements.firstIndex(where: { $0.id == achive.id })
        else {
            return
        }
        achievements[index].isAchieved.toggle()
        
    }
   
    
    
    func saveAchievementsItem() {
        if let encodedData = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsAchievementsKey)
        }
        
    }
    
    func loadAchievementsItem() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsAchievementsKey),
           let loadedItem = try? JSONDecoder().decode([NEGAchievement].self, from: savedData) {
            achievements = loadedItem
        } else {
            print("No saved data found")
        }
    }
}

struct NEGAchievement: Codable, Hashable, Identifiable {
    var id = UUID()
    var image: String
    var title: String
    var isAchieved: Bool
}
