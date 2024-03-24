//
//  RotatingCameraService+SetupActions.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import Foundation
import AVFoundation
import CoreImage

extension RotatingCameraService {
    struct Video: Equatable {
        enum CameraMode {
            case front
            case back
        }
        
        let url: URL
        let mode: CameraMode
    }
    
    enum VideoQueue {
        case first
        case last
    }
    
    func switchCameraInput(){
        if isRecording {
            switchStop()
            setupCameraSessionWhenSwitching()
            configVideoOutputByOrientation()
            captureAction()
        } else {
            setupCameraSessionWhenSwitching()
            configVideoOutputByOrientation()
        }
    }
    
    func captureAction() {
        if isRecording {
            stop()
        } else {
            configVideoOutputByOrientation()
            setupWriter()
            start()
        }
    }
    
    func canWrite() -> Bool {
        return isRecording
        && assetWriter != nil
        && assetWriter.status == .writing
    }
    
    private func start() {
        guard !isRecording else { return }
        isRecording = true
        sessionAtSourceTime = nil
    }
    
    private func stop() {
        guard isRecording else { return }
        isRecording = false
        
        assetWriter.finishWriting { [weak self] in
            guard let self = self  else { return }
            
            self.sessionAtSourceTime = nil
            let url = self.assetWriter.outputURL
            
            self.mergeQueue.async {
                self.lock.lock()
                
                var videos = self.videos
                self.videos.removeAll()
                
                self.blurVideo(at: url, in: .last) { url, error in
                    if let url = url {
                        videos.append(Video(url: url, mode: self.isUsingBackCamera == true ? .back : .front))
                        
                        self.merge(videos: videos) { url, error in
                            if let url = url {
                                self.completionHandler?(url)
                            }
                            self.lock.unlock()
                        }
                    } else {
                        self.lock.unlock()
                    }
                }
            }
        }
    }
    
    private func switchStop() {
        guard isRecording else { return }
        isRecording = false
        assetWriter.finishWriting { [weak self] in
            guard let url = self?.assetWriter.outputURL else { return }
            
            self?.mergeQueue.async {
                self?.lock.lock()
                self?.blurVideo(at: url, in: .first) { url, error in
                    if let url = url {
                        self?.videos.append(Video(url: url, mode: self?.isUsingBackCamera == true ? .back : .front))
                        self?.sessionAtSourceTime = nil
                    }
                    self?.lock.unlock()
                }
            }
        }
    }
    
    private func configVideoOutputByOrientation() {
        adjustCameraMirror()
        switch currentOrientation {
        case .portrait:
            videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
        case .landscapeLeft:
            videoDataOutput.connection(with: .video)?.videoOrientation = .landscapeRight
        case .landscapeRight:
            videoDataOutput.connection(with: .video)?.videoOrientation = .landscapeLeft
        default:
            videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
        }
    }
    
    private func adjustCameraMirror() {
        guard !isUsingBackCamera else { return }
        videoDataOutput.connection(with: .video)?.isVideoMirrored = true
    }
    
    private func merge(videos: [Video], completion: @escaping (URL?, Error?) -> Void) {
        
        if let video = videos.first, videos.count == 1 {
            DispatchQueue.main.async {
                completion(video.url, nil)
            }
            return
        }
        
        let composition = AVMutableComposition()
        let videoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        var time = CMTime.zero
        
        do {
            for video in videos {
                let asset = AVAsset(url: video.url)
                
                guard let video = asset.tracks(withMediaType: .video).first else {
                    continue
                }
                
                try videoTrack?.insertTimeRange(.init(start: .zero, end: asset.duration),
                                                of: video,
                                                at: time)
                
                if let audio = asset.tracks(withMediaType: .audio).first {
                    try audioTrack?.insertTimeRange(.init(start: .zero, end: asset.duration),
                                                    of: audio,
                                                    at: time)
                }
                time = CMTimeAdd(time, asset.duration)
            }
            
            let url = exportURL()
            let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
            
            exporter?.outputURL = url
            exporter?.outputFileType = AVFileType.mp4
            exporter?.shouldOptimizeForNetworkUse = true
            
            exporter?.exportAsynchronously {
                DispatchQueue.main.async {
                    completion(url, nil)
                }
            }
        } catch(let error) {
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
    
    private func exportURL() -> URL {
        let uuid = UUID().uuidString
        return URL(fileURLWithPath: NSTemporaryDirectory() + "\(uuid).mp4")
    }
    
    private func blurVideo(at url: URL, in queue: VideoQueue, completion: @escaping (URL?, Error?) -> Void) {
        let player = AVPlayer(url: url)
        let duration = CMTimeGetSeconds(player.currentItem!.asset.duration)
        
        let filter = CIFilter(name: "CIGaussianBlur")!
        let composition = AVVideoComposition(asset: AVAsset(url: url), applyingCIFiltersWithHandler: { request in
        
            let source = request.sourceImage.clampedToExtent()
        
            filter.setValue(source, forKey: kCIInputImageKey)
            let seconds = CMTimeGetSeconds(request.compositionTime)
        
            filter.setValue(0, forKey: kCIInputRadiusKey)
        
            switch queue {
                
            case .first:
                if seconds >= (duration - 0.4) {
                    filter.setValue(seconds * 20, forKey: kCIInputRadiusKey)
                }
            case .last:
                filter.setValue(0, forKey: kCIInputRadiusKey)
            }
        
            let output = filter.outputImage!.cropped(to: request.sourceImage.extent)
        
            request.finish(with: output, context: nil)
        })
        
        let exportURL = exportURL()
        let export = AVAssetExportSession(asset: AVAsset(url: url), presetName: AVAssetExportPresetHighestQuality)
        export?.outputFileType = AVFileType.mp4
        export?.outputURL = exportURL
        export?.videoComposition = composition
        
        export?.exportAsynchronously {
            DispatchQueue.main.async {
                completion(exportURL, nil)
            }
        }
    }
 
    func initialZoomTransfer() -> CGFloat {
        if isUsingBackCamera {
            return backCameraInput.device.videoZoomFactor
        } else {
            return frontCameraInput.device.videoZoomFactor
        }
    }
    
    func zooming(scale: CGFloat) {
        if isUsingBackCamera {
            do {
                try backCameraInput.device.lockForConfiguration()
                backCameraInput.device.videoZoomFactor = scale
                backCameraInput.device.unlockForConfiguration()
            } catch {
                debugPrint("No back camera")
            }
        } else {
            do {
                try frontCameraInput.device.lockForConfiguration()
                frontCameraInput.device.videoZoomFactor = scale
                frontCameraInput.device.unlockForConfiguration()
            } catch {
                debugPrint("No front camera")
            }
        }
    }
}
