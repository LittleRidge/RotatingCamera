//
//  ViewController.swift
//  RotatingCamera
//
//  Created by Евгений Сергеев on 07.03.2024.
//

import AVFoundation
import AVKit
import ImageIO
import Photos

public final class RotatingCameraVC: UIViewController, UIGestureRecognizerDelegate {
    
    private let presenter = RotatingCameraPresenter()
    private weak var customCameraOutput: RotatingCameraPresenterProtocol?
    public var completionHandler: ((URL) -> Void)?
    
    var backCameraPreviewLayer : AVCaptureVideoPreviewLayer!
    var frontCameraPreviewLayer : AVCaptureVideoPreviewLayer!
    
    let switchCameraButton = UIButton()
    let backButton = UIButton()
    let captureButton = CaptureButton()
    let indicatorLoading = UIActivityIndicatorView()

    var angle : CGFloat!
    var initialZoom: CGFloat!
    
    var previousOrientation: UIDeviceOrientation = .portrait
    var currentOrientation: UIDeviceOrientation = .portrait
    
    private var isRecording = false
    
    
    //MARK:- Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        presenter.setCustomCameraInput(customCameraInput: self)
        customCameraOutput = presenter
        customCameraOutput?.setupPreview()
        setupActions()
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /* lock screen from going to sleep after close VC */
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        /* unlock screen from going to sleep after close VC */
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension RotatingCameraVC: RotatingCameraViewProtocol {
    func switchPrewiewLayer(isUsingBackCamera: Bool) {
        self.backCameraPreviewLayer.isHidden = !isUsingBackCamera
        self.frontCameraPreviewLayer.isHidden = isUsingBackCamera
    }
    
    func setupInitial(backCameraCaptureSession: AVCaptureSession, frontCameraCaptureSession: AVCaptureSession, isUsingBackCamera: Bool) {
        self.backCameraPreviewLayer = AVCaptureVideoPreviewLayer(session: backCameraCaptureSession)
        self.backCameraPreviewLayer.videoGravity = .resizeAspectFill
        self.backCameraPreviewLayer.isHidden = !isUsingBackCamera
        
        self.frontCameraPreviewLayer = AVCaptureVideoPreviewLayer(session: frontCameraCaptureSession)
        self.frontCameraPreviewLayer.videoGravity = .resizeAspectFill
        self.frontCameraPreviewLayer.isHidden = isUsingBackCamera
        
        setupPreviewLayers()
    }
    
    func closeVC() {
        presentAccessAlert(title: "Ошибка доступа к камере",
                           message: "Добавьте разрешение доступа к камере и микрофону в настройках устройства для использования данной функции")
    }
}

extension RotatingCameraVC {
    private func setupActions() {
        setupLongPressGesture()
        setupPinchGesture()
        setupButtonActions()
    }
    
    private func setupButtonActions() {
        switchCameraButton.addTarget(self, action: #selector(switchAction), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
    }
    
    private func setupLongPressGesture() {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler(gesture:)))
        recognizer.delegate = self
        recognizer.minimumPressDuration = 0
        captureButton.addGestureRecognizer(recognizer)
    }
    
    private func setupPinchGesture() {
        let recognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandler(gesture:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
    }
    
    private func checkDeviceOrientation() -> Bool {
        if UIDevice.current.orientation == .portraitUpsideDown || UIDevice.current.orientation == .faceUp || UIDevice.current.orientation == .faceDown {
            return true
        } else {
            return false
        }
    }
    
    private func calculateZoom(_ initialZoom: CGFloat, _ scale: CGFloat) -> CGFloat {
        let minimalZoomFactor: CGFloat = 1.0
        let maximalZoomFactor: CGFloat = 5.0
        
        return max(minimalZoomFactor, min(scale * initialZoom, maximalZoomFactor))
    }
    
    private func presentAccessAlert(title: String? = nil, message: String? = nil) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        alertController.addAction(
            UIAlertAction(title: "Отмена", style: .cancel) { _ in
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "Настройки",
                style: .default,
                handler: { _ in
                    /* Redirect to Settings app */
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
        )
        
        present(alertController, animated: true, completion: nil)
    }
    
    func continueWriting(url: URL) {
        indicatorLoading.stopAnimating()
        
        completionHandler?(url)
    }
    
    @objc func switchAction() {
        customCameraOutput?.switchCamera()
    }
    
    @objc func dismissAction() {
        dismiss(animated: true)
    }
    
    @objc func longPressHandler(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if isRecording {
                captureButton.pressedButNotReleasedToStopCapture()
            } else {
                captureButton.pressedButNotReleasedToStartCapture()
            }
        case .changed:
            break
        case .ended, .cancelled, .failed, .possible:
            if isRecording {
                captureButton.pressedEndReleasedToStopCapture()
                indicatorLoading.startAnimating()
            } else {
                captureButton.pressedEndReleasedToStartCapture()
            }
            isRecording = !isRecording
            customCameraOutput?.captureAction()
        @unknown default: ()
        }
    }
    
    @objc func pinchHandler(gesture: UIPinchGestureRecognizer){
        switch gesture.state {
        case .began:
            initialZoom = customCameraOutput?.initialZoomTransfer()
        case .changed:
            customCameraOutput?.adjustZoom(scale: calculateZoom(initialZoom, gesture.scale))
        default:
            break
        }
    }
    
    @objc private func orientationChanged() {
        if isRecording || checkDeviceOrientation() {
            return
        } else {
            switchUIOrientation()
            changePreviousOrientation()
            customCameraOutput?.changeVideoOrientation(orientation: UIDevice.current.orientation)
        }
    }
}
