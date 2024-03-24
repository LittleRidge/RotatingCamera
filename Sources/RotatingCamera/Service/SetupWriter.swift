//
//  RotatingCamera+SetupWriter.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import Foundation
import AVFoundation

extension RotatingCameraService {
    
    func setupWriter() {
        do {
            fileName = UUID().uuidString
            
            let folder = NSTemporaryDirectory()
            let manager = FileManager.default
            
            if manager.fileExists(atPath: folder, isDirectory: nil) {
                
            } else {
                try manager.createDirectory(atPath: folder, withIntermediateDirectories: true)
            }
            
            let path = folder + "/\(fileName).mp4"
            let videoPath = URL(fileURLWithPath: path)
            
            assetWriter = try AVAssetWriter(url: videoPath, fileType: AVFileType.mp4)
            let videoSettings = videoDataOutput.recommendedVideoSettingsForAssetWriter(writingTo: .mp4)
            assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            assetWriterVideoInput.mediaTimeScale = CMTimeScale(bitPattern: 600)
            assetWriterVideoInput.expectsMediaDataInRealTime = true
            
            if assetWriter.canAdd(assetWriterVideoInput) {
                assetWriter.add(assetWriterVideoInput)
            }
            
            assetWriterAudioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 1,
                AVSampleRateKey: 44100,
                AVEncoderBitRateKey: 64000,
            ])
            assetWriterAudioInput.expectsMediaDataInRealTime = true
            
            if assetWriter.canAdd(assetWriterAudioInput) {
                assetWriter.add(assetWriterAudioInput)
            }
            
            assetWriter.startWriting()
        }
        catch(let error) {
            fatalError("could not create writer. Reason - \(error.localizedDescription)")
        }
    }
}
