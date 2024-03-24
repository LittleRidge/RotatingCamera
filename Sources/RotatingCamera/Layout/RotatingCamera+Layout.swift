//
//  RotatingCamera+Layout.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import UIKit
import SnapKit

extension RotatingCameraVC {    
    func setupUI(){
        view.backgroundColor = .black
        
        setupSwitchCameraButton()
        setupBackCameraButton()
        
        view.addSubview(switchCameraButton)
        view.addSubview(captureButton)
        view.addSubview(backButton)
        
        switchCameraButton.snp.makeConstraints { make in
            make.width.height.equalTo(45)
            make.right.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().inset(95)
        }
        
        captureButton.snp.makeConstraints { make in
            make.width.height.equalTo(72)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(81)
        }
        captureButton.backgroundColor = .clear
        
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(45)
            make.left.equalToSuperview().inset(25)
            make.bottom.equalToSuperview().inset(95)
        }
    }
        
    func switchUIOrientation() {
        switch (UIDevice.current.orientation.rawValue - previousOrientation.rawValue) {
        case 1:
            angle = .pi
        case 2:
            angle = .pi / 2
        case 3:
            angle = -.pi / 2
        case -1:
            angle = -.pi
        case -2:
            angle = -.pi / 2
        case -3:
            angle = .pi / 2
        default:
            return
        }
        
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       animations: { [weak self] () -> Void in
            guard let self = self else { return }
            self.switchCameraButton.transform = self.switchCameraButton.transform.rotated(by: (self.angle))
            self.backButton.transform = self.backButton.transform.rotated(by: (self.angle))
        })
    }
    
    func changePreviousOrientation() {
        previousOrientation = UIDevice.current.orientation
    }
    
    func setupPreviewLayers() {
        self.view.layer.insertSublayer(self.backCameraPreviewLayer, below: self.switchCameraButton.layer)
        self.backCameraPreviewLayer.frame = self.view.layer.frame
        
        self.view.layer.insertSublayer(self.frontCameraPreviewLayer, below: self.switchCameraButton.layer)
        self.frontCameraPreviewLayer.frame = self.view.layer.frame
    }
    
    // MARK: - Configuring
    
    func setupSwitchCameraButton() {
        switchCameraButton.backgroundColor = .clear
        switchCameraButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        switchCameraButton.tintColor = .white
        switchCameraButton.imageView?.contentMode = .scaleAspectFit
        switchCameraButton.contentHorizontalAlignment = .fill
        switchCameraButton.contentVerticalAlignment = .fill
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupBackCameraButton() {
        backButton.backgroundColor = .clear
        backButton.setImage(UIImage(systemName: "arrow.uturn.left"), for: .normal)
        backButton.tintColor = .white
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.contentHorizontalAlignment = .fill
        backButton.contentVerticalAlignment = .fill
        backButton.translatesAutoresizingMaskIntoConstraints = false
    }
}
