//
//  Presenter.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import Foundation
import UIKit

final class RotatingCameraPresenter {
    
    // MARK: Properties
    
    private weak var customCameraInput: RotatingCameraViewProtocol?
    private var cameraService = RotatingCameraService()
    
    // MARK: Initialization
    
    init() {
        cameraService.completionHandler = { [weak self] url in
            self?.customCameraInput?.continueWriting(url: url)
        }
    }
    
    func setCustomCameraInput(customCameraInput: RotatingCameraViewProtocol?) {
        self.customCameraInput = customCameraInput
    }
    
    private func setupPreviewLayer() {
        self.customCameraInput?.setupInitial(backCameraCaptureSession: cameraService.backCameraCaptureSession,
                                             frontCameraCaptureSession: cameraService.frontCameraCaptureSession,
                                             isUsingBackCamera: cameraService.isUsingBackCamera)
    }
    
    private func switchPrewiewLayer() {
        self.customCameraInput?.switchPrewiewLayer(isUsingBackCamera: cameraService.isUsingBackCamera)
    }
    
    private func closeVC() {
        self.customCameraInput?.closeVC()
    }
}

// MARK: - CustomCamera Presenter Interface
extension RotatingCameraPresenter: RotatingCameraPresenterProtocol {
    func initialZoomTransfer() -> CGFloat {
        cameraService.initialZoomTransfer()
    }
    
    func setupPreview() {
        cameraService.checkPermission() { [weak self] request in
            DispatchQueue.main.async {
                if request {
                    self?.cameraService.setupCameras()
                    self?.setupPreviewLayer()
                } else {
                    self?.closeVC()
                }
            }
        }
    }
    
    func switchCamera() {
        DispatchQueue.main.async { [weak self] in
            self?.cameraService.switchCameraInput()
            self?.switchPrewiewLayer()
        }
    }
    
    func captureAction() {
        cameraService.captureAction()
    }
    
    func changeVideoOrientation(orientation: UIDeviceOrientation) {
        cameraService.changeVideoOutputOrientation(orientation: orientation)
    }
    
    func adjustZoom(scale: CGFloat) {
        cameraService.zooming(scale: scale)
    }
}
