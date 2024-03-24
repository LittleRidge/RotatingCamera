//
//  Cleaner.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 11.03.2024.
//

import Foundation

final class TemporaryVideoCleaner {
    
    private let fm = FileManager.default
    private let tempFolderPath = NSTemporaryDirectory()
    private let queue = DispatchQueue.global(qos: .background)
    private var isCleaning = false
    
    static let shared = TemporaryVideoCleaner()
    
    private init() {
        
    }
    
    func clean() {
        if isCleaning {
            return
        }
        isCleaning = true
        queue.async {
            self.cleanTMPTrueLine(folder: "")
            self.isCleaning = false
        }
        
    }
    
    private func cleanTMPTrueLine(folder: String) {
        do {
            let filePaths = try self.fm.contentsOfDirectory(atPath: self.tempFolderPath + folder)
            debugPrint("pathis \(filePaths)")
            for filePath in filePaths {
                guard let url = NSURL(fileURLWithPath: self.tempFolderPath.appending(folder)).appendingPathComponent(filePath) else { return }
                try self.fm.removeItem(at: url)
            }
        } catch {
            debugPrint("Cleaning videos in tmp/TrueLine error")
        }
    }
}
