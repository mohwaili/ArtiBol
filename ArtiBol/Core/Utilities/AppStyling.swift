//
//  AppStyling.swift
//  ArtiBol
//
//  Created by Mohammed Al Waili on 30/05/2025.
//

import UIKit

@MainActor
struct AppStyling {
    
    static func apply() {
        let design = UIFontDescriptor.SystemDesign.monospaced
        applyTabBarStyling(design: design)
        applyNavigationBarStyling(design: design)
    }
}

// MARK: - Private -

private extension AppStyling {
    
    static func applyTabBarStyling(design: UIFontDescriptor.SystemDesign) {
        let tabItemDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .caption1)
            .withDesign(design)!
        let tabItemFont = UIFont.init(descriptor: tabItemDescriptor, size: 12)
        UITabBarItem.appearance().setTitleTextAttributes([.font: tabItemFont], for: .normal)
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .font: tabItemFont,
            .foregroundColor: UIColor.systemGray
        ]
        
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.content
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .font: tabItemFont,
            .foregroundColor: UIColor.content
        ]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    static func applyNavigationBarStyling(design: UIFontDescriptor.SystemDesign) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        
        let largeTitleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
            .withDesign(design)!
        let largeTitleFont = UIFont.init(descriptor: largeTitleDescriptor, size: 32)
        navigationBarAppearance.largeTitleTextAttributes = [.font : largeTitleFont]
        
        let titleDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
            .withDesign(design)!
        let titleFont = UIFont.init(descriptor: titleDescriptor, size: 18)
        navigationBarAppearance.titleTextAttributes = [.font : titleFont]
        
        let backImage = UIImage(resource: .icArrowleft)
            .withTintColor(UIColor(resource: .content), renderingMode: .alwaysOriginal)
        navigationBarAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.focused.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.disabled.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        
        navigationBarAppearance.backButtonAppearance = backButtonAppearance
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
    }
}
