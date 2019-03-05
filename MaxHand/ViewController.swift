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

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    @IBOutlet weak var oneMultSegButton: UISegmentedControl!
    
    var sceneController = MaxScene()
    var didInitializeMax: Bool = false
    var isDetectPlane: Bool = false
    var detectedPlanes: [String : SCNNode] = [:]
    var isOneCharaterMode: Bool = true

    @IBAction func resetButton(){
        resetTracking();
        sceneController.removeAllMax();
        didInitializeMax = false;
        isDetectPlane = false;
        detectedPlanes = [:]
    }
    @IBAction func oneMultSegButtonValueChangeAction(_ sender: Any) {
        if (oneMultSegButton.selectedSegmentIndex == 0){
            self.isOneCharaterMode = true
            let rootnode = sceneView.scene.rootNode
            rootnode.enumerateChildNodes { (node, stop) in
                if (node.name == "planeNode"){
                    node.removeFromParentNode()
                }
            }
        } else{
            self.isOneCharaterMode = false
            self.isDetectPlane = false
            let rootnode = sceneView.scene.rootNode
            rootnode.enumerateChildNodes { (node, stop) in
                if (node.name == "planeNode"){
                    node.removeFromParentNode()
                }
            }

        }
    }
    //시스템에의해 자동으로 호출, 리소스 초기화나 초기 화면 구성용도, 화면 처음 만들어질 때 한 번만 실행.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self

        // Create a new scene
        if let scene = sceneController.scene {
            sceneView.scene = scene
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTapScreen))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    // 뷰가 이제 나타날 거라는 신호
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpSceneView()
    }
    // - TAG: StartARSession
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
    @objc func didTapScreen(recognizer: UITapGestureRecognizer) {
        print("touch")
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, types: .existingPlaneUsingExtent)
        guard let hitTestResult = hitTestResults.first
            else { return }

        let translation = hitTestResult.worldTransform.columns.3
        let x = translation.x
        let y = translation.y
        let z = translation.z
        let max = Max()
        max.position = SCNVector3(x,y,z)
        guard let plane = sceneView.scene.rootNode.childNode(withName: nodeEnum.plane.rawValue, recursively: true)
            else {print("return")
                return}
        plane.addChildNode(max)
        sceneView.scene.rootNode.addChildNode(max)
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
        
        if (isOneCharaterMode) {
            self.isDetectPlane = true
        } else {
            self.isDetectPlane = false
        }
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        
        let maxExtentValue = maxExtent(a: planeAnchor.extent.x, b: planeAnchor.extent.y)

        let planeNode = Plane(width: CGFloat(maxExtentValue), height: CGFloat(maxExtentValue), content: UIImage(named: "square") as Any, doubleSided: false, horizontal: true)

        let x = planeAnchor.center.x
        let y = planeAnchor.center.y
        let z = planeAnchor.center.z
        planeNode.position = SCNVector3Make(x,y,z)
        planeNode.name = nodeEnum.plane.rawValue
        
        node.name = "planeNode"
        node.addChildNode(planeNode)
        //each ancor has an unique identifier
        detectedPlanes[planeAnchor.identifier.uuidString] = planeNode
//        print(detectedPlanes)
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, willUpdate node: SCNNode, for anchor: ARAnchor) {
//
//    }
    
    // - Tag: UpdateARContent
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        guard let planeAnchor = anchor as? ARPlaneAnchor
//        else {
////            print("planeAnchor((((((((()))) )))))")
//            return
//        }
//        guard let planeNode = detectedPlanes[planeAnchor.identifier.uuidString]
//        else {
////            print("planeNode(((((((((((")
//            return
//        }
//
//        guard let planeGeometry = planeNode.geometry as? SCNPlane
//            else{
////                print("planeGeometry")
//                return
//        }
//
//        planeGeometry.width = CGFloat(planeAnchor.extent.x)
//        planeGeometry.height = CGFloat(planeAnchor.extent.z)
//
//        let x = planeAnchor.center.x
//        let y = planeAnchor.center.y
//        let z = planeAnchor.center.z
//        planeNode.position = SCNVector3Make(x,y,z)

    }
}

extension ViewController: ARSessionDelegate{
    
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
        sessionInfoView.isHidden = message.isEmpty
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
}
