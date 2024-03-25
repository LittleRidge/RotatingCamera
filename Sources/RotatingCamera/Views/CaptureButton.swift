//
//  CaptureButton.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import UIKit

final class CaptureButton: UIView {
    private var circle = UIView()
    private var square = UIView()
    
    private let overlaySize: Double = 72
    private let externalSize: Double = 66
    private let innerCircleSize: Double = 55
    private let innerCircleSizeTapped: Double = 49
    private let innerRectSize: Double = 29
    private let lineWidth: Double = 6
    
    init() {
        super.init(frame: .zero)
        setupCaptureButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCaptureButton(){
        
        self.addSubview(circle)
        self.addSubview(square)
        
        circle.translatesAutoresizingMaskIntoConstraints = false
        square.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            circle.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            circle.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            circle.widthAnchor.constraint(equalToConstant: innerCircleSize),
            circle.heightAnchor.constraint(equalToConstant: innerCircleSize),
            square.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            square.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            square.widthAnchor.constraint(equalToConstant: innerRectSize),
            square.heightAnchor.constraint(equalToConstant: innerRectSize)
        ])
        
        circle.backgroundColor = .red
        circle.layer.cornerRadius = innerCircleSize/2
        square.backgroundColor = .red
        square.layer.cornerRadius = 4
    }
    
    override func draw(_ rect: CGRect) {
        let ring = UIBezierPath(arcCenter: CGPoint(x: overlaySize/2, y: overlaySize/2), 
                                radius: (overlaySize/2 - lineWidth/2),
                                startAngle: 0,
                                endAngle: 2 * CGFloat.pi,
                                clockwise: true)
        ring.lineWidth = 6
        UIColor.white.setStroke()
        ring.stroke()
    }
    
    func pressedButNotReleasedToStartCapture() {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       animations: { [weak self] () -> Void in
            guard let self = self else { return }
            self.circle.transform = CGAffineTransform(scaleX: (self.innerCircleSizeTapped/self.innerCircleSize), y: (self.innerCircleSizeTapped/self.innerCircleSize))
        })
    }
    
    func pressedEndReleasedToStartCapture() {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       animations: { [weak self] () -> Void in
            guard let self = self else { return }
            self.circle.transform = CGAffineTransform(scaleX: (self.innerRectSize/self.innerCircleSize), y: (self.innerRectSize/self.innerCircleSize))
        })
    }
    
    func pressedEndReleasedToStopCapture() {
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       animations: { [weak self] () -> Void in
            guard let self = self else { return }
            self.circle.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.square.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    func pressedButNotReleasedToStopCapture() {
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       animations: { [weak self] () -> Void in
            guard let self = self else { return }
            self.square.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        })
    }
}
