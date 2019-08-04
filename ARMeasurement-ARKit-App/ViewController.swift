//
//  ViewController.swift
//  ARMeasurement-ARKit-App
//
//  Created by Xinzhao Li on 8/4/19.
//  Copyright © 2019 Jaega. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    var dotNodes = [SCNNode]()
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(location, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addDot(at: hitResult)
            }
        }
        
    }
    
    private func addDot(at hitResult: ARHitTestResult) {
        let dot = SCNSphere(radius: 0.005)
        
        let dotMaterial = SCNMaterial()
        dotMaterial.diffuse.contents = UIColor.white
        
        dot.materials = [dotMaterial]
        
        let node = SCNNode(geometry: dot)
        
        let worldLocation = hitResult.worldTransform.columns.3
        node.position = SCNVector3(worldLocation.x, worldLocation.y, worldLocation.z)
        
        sceneView.scene.rootNode.addChildNode(node)
        
        dotNodes.append(node)
        
        if dotNodes.count >= 2 {
            calculate()
        }
    }
    
    private func calculate() {
        let start = dotNodes[0].position
        let end = dotNodes[1].position
        var textDisplayPosition = SCNVector3(0, 0, 0);
        
        let a = start.x - end.x
        let b = start.y - end.y
        let c = start.z - end.z
        let distance = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        
        if start.x > end.x {
            textDisplayPosition = end
        } else {
            textDisplayPosition = start
        }
        updateText(text: "\(distance)", atPosition: textDisplayPosition)
    }
    
    private func updateText(text: String, atPosition position: SCNVector3) {
        let textGeometry = SCNText(string: text, extrusionDepth: 0.1)
        
        textGeometry.firstMaterial?.diffuse.contents = UIColor.yellow
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
        textNode.scale = SCNVector3(0.003, 0.003, 0.003)
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    

}
