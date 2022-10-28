//
//  GameViewController.swift
//  Game_assigment
//
//  Created by RICHARDSON, LIAM RICHARDSON (Student) on 03/12/2020.
//  Copyright © 2020 LIAM RICHARDSON (Student). All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreMotion

class GameViewController: UIViewController {
    
    let motion = CMMotionManager()
    var timer = Timer()

    //create gamescene variable
    var gameScene = GameScene()
    
    //create a variable as SKVIEW to keep a refernce to skView
    var skView: SKView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //crete a copy of the Current view (the gamescene)
        if let view = self.view as! SKView?{
            //make the skView varible the same as the Current view
            skView = view
        }
        
        gameScene.GameViewControllerV = self
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Copy gameplay related content over to the scene
                sceneNode.GameViewControllerV = self
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .resizeFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                    view.showsPhysics = true
                }
            }
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //When motion has ended E.G after a shake
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        //check to see if the current view is the gameScene
        if let gameScene = skView.scene as? GameScene{
            if motion == .motionShake { // Check to see if shaked
                gameScene.reset() //Reset the game level
        }
        
            
    }
    
}
    
    // GET GYRO DATA
    //UNFORTUNTLY COULD NOT TEST SO NEVER IMPLEMENTED
    func startGyro(){
        if motion.isGyroAvailable {
            self.motion.gyroUpdateInterval = 1.0 / 60.0
            self.motion.startGyroUpdates()
            
            
            //timer for accel data
            self.timer = Timer(fire: Date(), interval: (1.0/60.0), repeats: true, block: { (timer) in
                
                //gyro data
                if let data = self.motion.gyroData {
                    
                   // let y = data.rotationRate.y
                    
                }
                
                //use data to change the direction of the arrow
                // :(
                
                
                
                
            })
        }
    }
    
//    func stopGyro() {
//        if self.timer != nil {
//            self.timer?.invalidate()
//            self.timer = nil
//            
//            self.motion.stopGyroUpdates()
//        }
//    }
    
}

