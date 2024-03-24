//
//  Spinner.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import Foundation
import UIKit
import MBProgressHUD

final class SpinnerConfiguration {
    var appearance: Appearance = .light
    var graceTime: TimeInterval = 0.1
    var minShowTime: TimeInterval = 0.4
    
    enum Appearance {
        case light
        case dark
    }
    
    init(appearance: Appearance) {
        self.appearance = appearance
    }
    
    static var primary: Self {
        return .init(appearance: .light)
    }
    
    static var dark: Self {
        return .init(appearance: .dark)
    }
}

extension UIView {
    
    func showSpinner(spinnerConfig: SpinnerConfiguration) {
        
        let hud = MBProgressHUD(view: self)
        
        /* behavior */
        hud.minShowTime = spinnerConfig.minShowTime
        hud.graceTime = spinnerConfig.graceTime
        hud.areDefaultMotionEffectsEnabled = false
        hud.removeFromSuperViewOnHide = true
        
        /* visuals */
        hud.bezelView.style = .solidColor
        hud.animationType = .fade
        hud.mode = .indeterminate
        
        /* theme-specific appearance */
        switch spinnerConfig.appearance {
            
        case .light:
            hud.contentColor = .black
            hud.bezelView.color = .gray
            
        case .dark:
            hud.contentColor = .white
            hud.bezelView.color = .black
        }
        
        /* showing spinner */
        addSubview(hud)
        hud.show(animated: true)
    }
    
    func hideSpinner() {
        guard let hud = MBProgressHUD.forView(self) else { return }
        hud.hide(animated: true)
    }
}

