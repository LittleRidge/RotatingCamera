//
//  RotatingCameraService.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import AVKit
import ImageIO
import Photos

final class RotatingCameraService: NSObject {
    //MARK: - Properties
    var backCameraCaptureSession = AVCaptureSession()
    var frontCameraCaptureSession = AVCaptureSession()
    
    var videoDataOutput = AVCaptureVideoDataOutput()
    var audioDataOutput = AVCaptureAudioDataOutput()
    
    var backCameraInput: AVCaptureDeviceInput!
    var frontCameraInput: AVCaptureDeviceInput!
    var audioInput: AVCaptureDeviceInput!
    
    var assetWriter: AVAssetWriter!
    var assetWriterVideoInput: AVAssetWriterInput!
    var assetWriterAudioInput: AVAssetWriterInput!
    var sessionAtSourceTime: CMTime?
    
    var isUsingBackCamera = true
    var isRecording = false
    var currentOrientation: UIDeviceOrientation = .portrait
    
    private var lastTimeStamp = CMTime()
    public weak var delegate: VideoCaptureDelegate?
    
    var completionHandler: ((URL) -> Void)?
    var fileName = ""
    
    let lock = NSLock()
    var videos: [Video] = []
    
    let mergeQueue = DispatchQueue(label: "mergeQueue", qos: .userInitiated)
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func checkPermission(closure: @escaping (Bool) -> Void) {
        let device = AVCaptureDevice.self
        
        if device.authorizationStatus(for: .video) == .authorized && device.authorizationStatus(for: .audio) == .authorized {
            closure(true)
        } else {
            device.requestAccess(for: .video) { success in
                if success {
                    device.requestAccess(for: .audio) { closure($0) }
                } else {
                    closure(false)
                }
            }
        }
    }

    func changeVideoOutputOrientation(orientation: UIDeviceOrientation) {
        self.currentOrientation = orientation
    }
}

extension RotatingCameraService: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, 
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard CMSampleBufferDataIsReady(sampleBuffer) else { return }
        
        let writable = canWrite()
        
        if writable {
            if connection.isVideoOrientationSupported {
                if sessionAtSourceTime == nil {
                    sessionAtSourceTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    let sessionAtSourceTimeDelay = CMTimeMake(value: 1, timescale: 2)
                    
                    guard let sessionAtSourceTime else { return }
                    
                    let sessionStartTime = CMTimeAdd(sessionAtSourceTime, sessionAtSourceTimeDelay)
                    assetWriter.startSession(atSourceTime: sessionStartTime)
                }
                
                if assetWriterVideoInput.isReadyForMoreMediaData {
                    assetWriterVideoInput.append(sampleBuffer)
                }
            } else {
                if assetWriterAudioInput.isReadyForMoreMediaData && sessionAtSourceTime != nil {
                    assetWriterAudioInput.append(sampleBuffer)
                }
            }
        }
    }
}

protocol VideoCaptureDelegate: AnyObject {
    func videoCapture(_ capture: RotatingCameraService, didCaptureVideoFrame: CVPixelBuffer?, timestamp: CMTime)
}
