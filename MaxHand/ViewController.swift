//
//  ViewController.swift
//  knowWhere
//
//  Created by 권영호 on 14/01/2019.
//  Copyright © 2019 0ho_kwon. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var oneOrMultiMaxModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var instantOrPlaneMaxAppearSegmentedControl: UISegmentedControl!
    
    let handDetector = HandDetector()//class
    
    var isOneCharaterMode: Bool = true
    var isInstantMode: Bool = true
    var isDetectPlane: Bool = false
    var detectedPlanes: [String : SCNNode] = [:]
    
    var currentBuffer: CVPixelBuffer?
    var currentCameraTransform:simd_float4x4?
    var handPreviewView = UIImageView()
    var spinning: Bool = false;

    @IBAction func resetButton(){
        resetTracking();
        self.isDetectPlane = false;
        self.isOneCharaterMode = true;
        self.isInstantMode = true;
        self.oneOrMultiMaxModeSegmentedControl.selectedSegmentIndex = 0
        self.instantOrPlaneMaxAppearSegmentedControl.selectedSegmentIndex = 0
        
        detectedPlanes = [:]
        let rootnode = self.sceneView.scene.rootNode
        rootnode.enumerateChildNodes { (node, stop) in
            if (node.name == "planeNode"){
                node.removeFromParentNode()
            }
        }
    }
    
    @IBAction func oneOrMultiMaxModeSegmentedControlValueChangeAction(_ sender: Any) {
        if (oneOrMultiMaxModeSegmentedControl.selectedSegmentIndex == 0){
            self.isOneCharaterMode = true
            let rootnode = self.sceneView.scene.rootNode
            rootnode.enumerateChildNodes { (node, stop) in
                if (node.name == "planeNode"){
                    node.removeFromParentNode()
                }
            }
        } else{
            self.isOneCharaterMode = false
            self.isDetectPlane = false
            let rootnode = self.sceneView.scene.rootNode
            rootnode.enumerateChildNodes { (node, stop) in
                if (node.name == "planeNode"){
                    node.removeFromParentNode()
                }
            }

        }
    }

    @IBAction func instantOrPlaneMaxAppearSegmentedControlValueChangeAction(_ sender: Any) {
        if(instantOrPlaneMaxAppearSegmentedControl.selectedSegmentIndex == 0){
            self.isInstantMode = true
        } else{
            self.isInstantMode = false
        }
    
    }
    @IBAction func tapPlane(_ gesture: UITapGestureRecognizer) {
        if self.isInstantMode {return}
        
        let tapLocation = gesture.location(in: self.sceneView)
        guard let hitTest = self.sceneView.hitTest(tapLocation).first else {return}
       
        let hitNode = hitTest.node

        switch hitNode.name {
        case "Plane":
            let node = hitNode;
            let translation = node.worldPosition
            print(node)
            print(translation)
            let x = translation.x
            let y = translation.y
            let z = translation.z
            let max = Max()
            max.position = SCNVector3(x,y,z)
            max.look(at: SCNVector3((currentCameraTransform?.columns.3.x)!, y, (currentCameraTransform?.columns.3.z)!))
            self.sceneView.scene.rootNode.addChildNode(max)
            node.removeFromParentNode()
            break
        default:
            break
        }
    }
    
    //시스템에의해 자동으로 호출, 리소스 초기화나 초기 화면 구성용도, 화면 처음 만들어질 때 한 번만 실행.
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        self.sceneView.delegate = self
    }
    // 뷰가 이제 나타날 거라는 신호
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    
}
extension ViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate

//    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//        return nil
//    }
    
    /// - Tag: PlaceARContent
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if self.isDetectPlane { return }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
//        planeAnchor.transform.columns.3 이것이 진짜로 위치.
        //node.addchildnode 했을때의 우치 비밀을 찾아야한다.
        if (isOneCharaterMode) {
            self.isDetectPlane = true
        } else {
            self.isDetectPlane = false
        }
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        
        if self.isInstantMode {
            let max = Max()
            let pos = planeAnchor.transform.columns.3
            max.position = SCNVector3(pos.x,pos.y, pos.z)
            max.look(at: SCNVector3((currentCameraTransform?.columns.3.x)!, pos.y, (currentCameraTransform?.columns.3.z)!))
            self.sceneView.scene.rootNode.addChildNode(max)
        }
        else{
            let maxExtentValue = minExtent(a: planeAnchor.extent.x, b: planeAnchor.extent.z)
            
            let planeNode = Plane(width: CGFloat(maxExtentValue), height: CGFloat(maxExtentValue), content: UIColor.brown.withAlphaComponent(0.7) as Any, doubleSided: false, horizontal: true)
            planeNode.name = nodeEnum.plane.rawValue
            node.name = "planeNode"
            node.addChildNode(planeNode)//이경우 위치가 왜 잡히는지 확인 필요.
        
            //each ancor has an unique identifier
            detectedPlanes[planeAnchor.identifier.uuidString] = planeNode
        }
        
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
//
//    }
    
    // - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {


    }
}

extension ViewController: ARSessionDelegate{
    
    func session(_ session: ARSession, didUpdate frame: ARFrame){
        //currentBuffer가 nil이아니거나 camera의 state가 normal이 아니면 리턴.
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        currentCameraTransform = frame.camera.transform
        currentBuffer = frame.capturedImage
        startDetection()
        
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else { return }
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
        sessionInfoLabel.text = "Session was interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
        sessionInfoLabel.text = "Session interruption ended"
        resetTracking()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.resetTracking()
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private methods
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal and vertical surfaces."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""
            
        }
        sessionInfoLabel.text = message
        
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        self.sceneView.session.run(configuration)
        sceneView.showsStatistics = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        sceneView.session.delegate = self
    }
    private func setUpSceneView() {
        view = sceneView
        sceneView.delegate = self
        // Start the view's AR session with a configuration that uses the rear camera,
        // device position and orientation tracking, and plane detection.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
        
        // Set a delegate to track the number of plane anchors for providing UI feedback.
        sceneView.session.delegate = self
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
        
        // Show debug UI to view performance metrics (e.g. frames per second).
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        view.addSubview(handPreviewView)
        
        handPreviewView.translatesAutoresizingMaskIntoConstraints = false
        handPreviewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        handPreviewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension ViewController {
    func maxExtent(a: Float,b: Float) -> Float{
        if a>b {return a}
        else {return b}
    }
    func minExtent(a: Float,b: Float) -> Float{
        if a<b {return a}
        else {return b}
    }
    
    private func startDetection() {
        guard let buffer = currentBuffer else { return }
        handDetector.performDetection(inputBuffer: buffer) {outputBuffer, _ in
            var previewImage: UIImage?
            var normalizedFingerTip: CGPoint?
            
            defer{
                DispatchQueue.main.async {
                    self.handPreviewView.image = previewImage
                    //현재 버퍼 처리가 완료되면 다음 부터 데이터로 프로세싱하기 위해.
                    self.currentBuffer = nil

                    guard let tipPoint = normalizedFingerTip else {
                        self.spinning = false
                        return
                    }
                    
                    let imageFingerPoint = VNImagePointForNormalizedPoint(tipPoint, Int(self.view.bounds.size.width), Int(self.view.bounds.size.height))
                    
                    guard let hitTest = self.sceneView.hitTest(imageFingerPoint).first else {return}

                    let hitNode = hitTest.node
                    print(hitNode)
                    print(hitNode.childNodes)
                    if let maxNode = hitNode.topmost(until: self.sceneView.scene.rootNode) as? Max{
                        if (self.spinning == false) {
                            DispatchQueue.main.async {
                                let generator = UIImpactFeedbackGenerator(style: .heavy)
                                generator.impactOccurred()
                            }
                            self.spinning = true
                            print(maxNode)
                            maxNode.spin()
                        }
                    }
                }
            }
            guard let outBuffer = outputBuffer else {
                return
            }
            previewImage = UIImage(ciImage: CIImage(cvPixelBuffer: outBuffer))
            normalizedFingerTip = outBuffer.searchTopPoint()
        }
    }
}
