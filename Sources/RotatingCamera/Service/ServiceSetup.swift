//
//  RotatingCamera+Setup.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import Foundation
import AVFoundation

extension RotatingCameraService {
    
    //MARK: - Camera Setup
    func setupCameras(){
        
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else { return }
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else { return }
        
        setupPresets(for: backCamera, for: frontCamera)
        
        //MARK: - Start configuration
        startConfigurations()
        
        //MARK: - Setup inputs
        guard let backVideoInput = try? AVCaptureDeviceInput(device: backCamera),
              let frontVideoInput = try? AVCaptureDeviceInput(device: frontCamera),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice)
        else {
            fatalError("could not create input device")
        }
        
        self.backCameraInput = backVideoInput
        self.frontCameraInput = frontVideoInput
        self.audioInput = audioInput
        
        if backCameraCaptureSession.canAddInput(backCameraInput) {
            backCameraCaptureSession.addInput(backCameraInput)
        }
        
        if frontCameraCaptureSession.canAddInput(backCameraInput) {
            frontCameraCaptureSession.addInput(frontCameraInput)
        }
        
        if backCameraCaptureSession.canAddInput(audioInput) && frontCameraCaptureSession.canAddInput(audioInput) {
            if isUsingBackCamera {
                backCameraCaptureSession.addInput(audioInput)
            } else {
                frontCameraCaptureSession.addInput(audioInput)
            }
        }
        
        //MARK: - Setup output
        setupOutputs()
        
        //MARK: - Commit configuration
        commitConfigurations()
        
        //MARK: - Start running sessions
        startSession()
    }
    
    private func setupPresets(for backCamera: AVCaptureDevice, for frontCamera: AVCaptureDevice) {
        backCameraCaptureSession.sessionPreset = setResolution(by: backCamera)
        frontCameraCaptureSession.sessionPreset = setResolution(by: frontCamera)
    }
    
    private func startConfigurations() {
        backCameraCaptureSession.beginConfiguration()
        frontCameraCaptureSession.beginConfiguration()
    }
    
    private func setupOutputs() {
        let queue = DispatchQueue(label: "com.rotating-camera")
        
        videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
        ]
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
        
        if backCameraCaptureSession.canAddOutput(videoDataOutput) && frontCameraCaptureSession.canAddOutput(videoDataOutput) {
            if isUsingBackCamera {
                videoDataOutput.setSampleBufferDelegate(self, queue: queue)
                backCameraCaptureSession.addOutput(videoDataOutput)
            } else {
                videoDataOutput.setSampleBufferDelegate(self, queue: queue)
                frontCameraCaptureSession.addOutput(videoDataOutput)
            }
        }
        
        if backCameraCaptureSession.canAddOutput(audioDataOutput) && frontCameraCaptureSession.canAddOutput(audioDataOutput) {
            if isUsingBackCamera {
                audioDataOutput.setSampleBufferDelegate(self, queue: queue)
                backCameraCaptureSession.addOutput(audioDataOutput)
            } else {
                audioDataOutput.setSampleBufferDelegate(self, queue: queue)
                frontCameraCaptureSession.addOutput(audioDataOutput)
            }
        }
    }
    
    private func commitConfigurations() {
        self.backCameraCaptureSession.commitConfiguration()
        self.frontCameraCaptureSession.commitConfiguration()
    }
    
    private func startSession() {
        DispatchQueue.global().async {
            self.backCameraCaptureSession.startRunning()
            self.frontCameraCaptureSession.startRunning()
        }
    }
    
    func setupCameraSessionWhenSwitching() {
        if isUsingBackCamera {
            removeSessionConfiguration()
            returnSessionConfiguration()
            
            isUsingBackCamera = false
        } else {
            removeSessionConfiguration()
            returnSessionConfiguration()
            
            isUsingBackCamera = true
        }
    }
    
    private func removeSessionConfiguration() {
        if isUsingBackCamera {
            backCameraCaptureSession.beginConfiguration()
            
            backCameraCaptureSession.removeInput(backCameraInput)
            backCameraCaptureSession.removeOutput(videoDataOutput)
            
            backCameraCaptureSession.commitConfiguration()
        } else {
            frontCameraCaptureSession.beginConfiguration()
            
            frontCameraCaptureSession.removeInput(frontCameraInput)
            frontCameraCaptureSession.removeOutput(videoDataOutput)
            
            frontCameraCaptureSession.commitConfiguration()
        }
    }
    
    private func returnSessionConfiguration() {
        if isUsingBackCamera {
            frontCameraCaptureSession.beginConfiguration()
            
            frontCameraCaptureSession.addInput(frontCameraInput)
            frontCameraCaptureSession.addOutput(videoDataOutput)
            
            frontCameraCaptureSession.commitConfiguration()
        } else {
            backCameraCaptureSession.beginConfiguration()
            
            backCameraCaptureSession.addInput(backCameraInput)
            backCameraCaptureSession.addOutput(videoDataOutput)
            
            backCameraCaptureSession.commitConfiguration()
        }
    }
    
    private func setResolution(by device: AVCaptureDevice) -> AVCaptureSession.Preset {
        let format = device.activeFormat.formatDescription
        let dimension = CMVideoFormatDescriptionGetDimensions(format)
        let resolution = CGSize(width: CGFloat(dimension.width), height: CGFloat(dimension.height))
        
        switch resolution.width {
        case 1280.0:
            return .hd1280x720
        case 1920.0:
            return .hd1920x1080
        case 3840.0:
            return .hd4K3840x2160
        default:
            return .hd1280x720
        }
    }
}
