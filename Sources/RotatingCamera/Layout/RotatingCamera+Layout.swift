//
//  RotatingCamera+Layout.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import UIKit

extension RotatingCameraVC {    
    func setupUI(){
        view.backgroundColor = .black
        
        setupSwitchCameraButton()
        setupBackCameraButton()
        setupIndicatorLoading()
        
        view.addSubview(switchCameraButton)
        view.addSubview(captureButton)
        view.addSubview(backButton)
        view.addSubview(indicatorLoading)
        
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        indicatorLoading.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            switchCameraButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25.0),
            switchCameraButton.heightAnchor.constraint(equalToConstant: 45.0),
            switchCameraButton.widthAnchor.constraint(equalToConstant: 45.0),
            switchCameraButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            backButton.heightAnchor.constraint(equalToConstant: 30.0),
            backButton.widthAnchor.constraint(equalToConstant: 30.0),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25.0),
            backButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            captureButton.heightAnchor.constraint(equalToConstant: 72.0),
            captureButton.widthAnchor.constraint(equalToConstant: 72.0),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -81.0),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorLoading.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicatorLoading.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            indicatorLoading.widthAnchor.constraint(equalTo: view.widthAnchor),
            indicatorLoading.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        captureButton.backgroundColor = .clear
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
        switchCameraButton.setImage(UIImage(systemName: "arrow.triangle.2.circlepath.camera"), for: .normal)
        switchCameraButton.tintColor = .white
        switchCameraButton.imageView?.contentMode = .scaleAspectFit
        switchCameraButton.contentHorizontalAlignment = .fill
        switchCameraButton.contentVerticalAlignment = .fill
        switchCameraButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupBackCameraButton() {
        backButton.backgroundColor = .clear
        backButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        backButton.tintColor = .white
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.contentHorizontalAlignment = .fill
        backButton.contentVerticalAlignment = .fill
        backButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupIndicatorLoading() {
        indicatorLoading.transform = CGAffineTransform(scaleX: 2.4, y: 2.4)
        indicatorLoading.color = .white
        indicatorLoading.hidesWhenStopped = true
    }
}
