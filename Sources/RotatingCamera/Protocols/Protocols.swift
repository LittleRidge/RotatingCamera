//
//  Protocols.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import Foundation
import AVFoundation
import UIKit

protocol RotatingCameraViewProtocol: AnyObject {
    func setupInitial(backCameraCaptureSession: AVCaptureSession,
                      frontCameraCaptureSession: AVCaptureSession,
                      isUsingBackCamera: Bool)
    
    func switchPrewiewLayer(isUsingBackCamera: Bool)
    
    func continueWriting(url: URL)
    
    func closeVC()
}

protocol RotatingCameraPresenterProtocol: AnyObject {
    func setupPreview()
    func switchCamera()
    func captureAction()
    func changeVideoOrientation(orientation: UIDeviceOrientation)
    func adjustZoom(scale: CGFloat)
    func initialZoomTransfer() -> CGFloat
}
