//
//  GameScene.swift
//  Game_assigment
//
//  Created by RICHARDSON, LIAM RICHARDSON (Student) on 03/12/2020.
//  Copyright © 2020 LIAM RICHARDSON (Student). All rights reserved.
//

import SpriteKit
import GameplayKit
import QuartzCore
import AVFoundation
import UIKit

//For calcuating the angle of the arrow projectile while it moves through the air
#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat{sqrtf(float(a))}
}
#endif


extension CGVector {
    func speed() -> CGFloat {
        return sqrt(dx*dx+dy*dy)
    }
    func angle() -> CGFloat {
        return atan2(dy,dx)
    }
}


//Category types for pyhsics collision
struct PhysicsCatrgory {
    static let none : UInt32 = 0
    static let all  : UInt32 = UInt32.max
    static let Arrow: UInt32 = 0b1
    static let Legs : UInt32 = 0b10
    static let Body : UInt32 = 0b100
    static let Head : UInt32 = 0b1000
}





class GameScene: SKScene {
    
    //Create a reference to the gameViewControler
    var GameViewControllerV: GameViewController!
    
    //Create al of the assests that will be used in the game
    //Player assets
    let Player = SKSpriteNode(imageNamed: "Player")
    let Bow = SKSpriteNode(imageNamed: "Bow")
    let Arrow = SKSpriteNode(imageNamed: "Arrow")
    let Arrow1 = SKSpriteNode(imageNamed: "Arrow")
    let Arrow2 = SKSpriteNode(imageNamed: "Arrow")
    
    //Enemy Assets
    let BodyLegs = SKSpriteNode(imageNamed: "Legs")
    let bodyTorso = SKSpriteNode(imageNamed: "Body")
    let BodyHead = SKSpriteNode(imageNamed: "Head")
    let empty = SKSpriteNode(imageNamed: "Head")
    
    //Eviroment assets
    let Floor = SKSpriteNode(imageNamed: "floor")
    let FloorE = SKSpriteNode(imageNamed: "floor")
    
    //Creating all of the different texts thats will appear on screen
    let restartText = SKLabelNode()
    var TextPower = SKLabelNode()
    var NewGame = SKLabelNode()
    var Options = SKLabelNode()
    var MainMenu = SKLabelNode()
    var Title = SKLabelNode()
    
    //Createing arrays for the Enemy Body parts and The arrows
    var BodyArray :[SKSpriteNode] = [SKSpriteNode]()
    var ArrowArray :[SKSpriteNode] = [SKSpriteNode]()
    
    //Creating Bools for conditions in the game
    var Launched = false
    var options = false
    var music = true
    var zoom = true
    var Menu = true
    var won = false
    var moveCam = true
    var TextPow = true
    
    //Audio
    var AudioPlayer = SKAudioNode(fileNamed: "BackGroudMusic.mp3")
    
    //CGPoints for when you touch the screen
    var TouchBegin: CGPoint = .init(x: 0, y: 0)
    let offset: CGFloat = .init(0)
    var AngleStart: CGFloat  = .init(0)
    var start: CGPoint = .init(x:0, y:0)
    var text = 0
    
    //For camera
    let Cam = SKCameraNode()
    var CameraStart = CGFloat()
    var CamStart = CGFloat()
    
    //Misc Gameplay Related
    var Score = 0
    var ArrowN = 0
    
    //Rect
    var framee = UIView()
    var rect: CGRect = .init()
    
    
    
    
    override func didMove(to view: SKView){
        
        //Setup
        
        //Pinch Gesture
        let pinchG = UIPinchGestureRecognizer()
        addChild(AudioPlayer)
        pinchG.addTarget(self, action: #selector(PinchGestureA(_:)))
        view.addGestureRecognizer(pinchG)
        
        //World
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        //Camera
        CamStart = Cam.xScale
        CameraTextSetup()
        
        //PlayerSetup
        Player.zPosition = -1
        Bow.zPosition = 0
        addChild(Player)
        addChild(Bow)
        ArrowSetup()
        
        
        //misc
        EnemySetup()
        Mainmenu()
        
        
        //SwitchModeBUtton Setup
        rect = CGRect(x: size.width * 0.05, y:  size.height * 0.05 , width: 100 , height: 100)
        framee = UIView(frame: rect)
        framee.backgroundColor = UIColor.blue
        self.view?.addSubview(framee)
        
        
        
    }
    
    
    
    func  Mainmenu () {
        
        won = false
        
        //Set cam position to far away point
        Cam.position = CGPoint (x:0,y:-500)
        
        Title.text = "Infected Killer"
        Title.position = CGPoint(x:0, y: -360)
        Title.fontColor = SKColor.red
        Title.fontSize = 40
        
        
        NewGame.fontSize = 40
        NewGame.text = "New Game"
        NewGame.fontColor = SKColor.red
        NewGame.position = CGPoint (x: 0, y: -510)
        
        
        Options.fontSize = 40
        Options.text = "Options"
        Options.fontColor = SKColor.red
        Options.position = CGPoint(x: 0, y: -610)
        
        
        //Show we are in the menus
        //if not in menus already then add the etxt
        if Menu == true {
            Menu = false
            addChild(Title)
            addChild(NewGame)
            addChild(Options)
        }
        
        
    }
    
    func ArrowSetup(){
        
        //Add to Array
        ArrowArray.append(Arrow)
        ArrowArray.append(Arrow1)
        ArrowArray.append(Arrow2)
        
        //Positions
        Player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.3)
        Bow.position = CGPoint(x: size.width * 0.105, y: size.height * 0.35)
        
        for i in (0...2){
            ArrowArray[i].position = CGPoint (x: size.width * 0.105, y: size.height * 0.352)
            ArrowArray[i].zPosition = 1
        }
        addChild(ArrowArray[ArrowN])
        
        
        AngleStart = ArrowArray[ArrowN].zRotation
    }
    
    func EnemySetup(){
        
        //Enemy Setup
        let Number = CGFloat.random(in: 2..<5)
        let NumberY: CGFloat = 0.23
        
        //add to array
        BodyArray.append(BodyLegs)
        BodyArray.append(bodyTorso)
        BodyArray.append(BodyHead)
        
        //set positions
        for i in (0...1){
            if i == 0 {
                BodyArray[i].position = CGPoint (x: size.width * Number, y: size.height * NumberY)
            }
            else {
                BodyArray[i].position = CGPoint (x: size.width * Number, y: size.height * NumberY + BodyArray[0].size.height)
                BodyArray[i+1].position = CGPoint (x: size.width * Number, y: BodyArray[i].position.y + BodyArray[i].size.height - (size.height * 0.02))
            }
            
        }
        //setup Physicbod and collisoin
        for i in (0...2){
            
            BodyArray[i].physicsBody = SKPhysicsBody(rectangleOf: BodyArray[i].size)
            BodyArray[i].physicsBody?.isDynamic = false
            BodyArray[i].physicsBody?.contactTestBitMask = PhysicsCatrgory.Arrow
            BodyArray[i].physicsBody?.collisionBitMask = PhysicsCatrgory.none
            
            switch i {
            case 0:
                BodyArray[i].physicsBody?.categoryBitMask = PhysicsCatrgory.Legs
                
            case 1:
                BodyArray[i].physicsBody?.categoryBitMask = PhysicsCatrgory.Body
                
            case 2:
                BodyArray[i].physicsBody?.categoryBitMask = PhysicsCatrgory.Head
                print("head")
            default:
                return
                
                
            }
            //add to scene
            addChild(BodyArray[i])
            
        }
        Floor.position = CGPoint(x: 0, y: size.height * 0.18)
        addChild(Floor)
        FloorE.position = CGPoint (x: BodyLegs.position.x , y: size.height * 0.18)
        addChild(FloorE)
        
    }
    
    
    func End() {
        //Endgame func
        Cam.position = CGPoint(x: 0, y: -500)
        
        Launched = false
        won = true
        
        Title.text = "Your Final Score Was : \(Score)"
        
        NewGame.text = "Restart"
        
        Options.text = "MainMenu"
        
        if Menu == true {
            Menu = false
            addChild(Title)
            addChild(NewGame)
            addChild(Options)
        }
        
    }
    
    func CameraTextSetup() {
        empty.position = CGPoint(x: size.width * 0.45, y: size.height * 0.5 )
        self.camera = Cam
        
        
    }
    
    
    
    
    @objc func PinchGestureA(_ sender: UIPinchGestureRecognizer) {
        guard won == false else {
            return
        }
        guard Menu == true else{
            return
        }
        
        guard let Camera = self.camera else {
            return
        }
        
        if sender.state == .began{
            CameraStart = Camera.xScale
        }
        camera?.setScale(CameraStart * 1 / sender.scale)
        
        
    }
    
    
    
    override func didSimulatePhysics() {
        if let body = ArrowArray[ArrowN].physicsBody {
            if (body.velocity.speed() > 0.01) {
                ArrowArray[ArrowN].zRotation = body.velocity.angle() - offset
            }
        }
    }
    
    func Otptions(){
        options = true
        let pos = Title.position
        
        Title.position = Options.position
        Options.position = pos
        if zoom == true {
            Title.text = "Zoom on Launch: True"
        }
        else {
            Title.text = "Zoom on Launch: False"
        }
        if music == true {
            NewGame.text = "Music: True"
        }
        else{
            NewGame.text = "Music: False"
        }
        
        
        Options.text = "Main Menu"
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let position = touches.first?.location(in:self) else{
            return
        }
        
        //If in the main menu
        
        
        
        TouchBegin = position
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
        //Check if not in main menu
        guard Menu == true else{
            return
        }
        
        guard let position = touches.first?.location(in:self) else{
            return
        }
        //Get touch positions
        var x: Int = Int(TouchBegin.x - position.x)
        var y: Int = Int(TouchBegin.y - position.y)
        //Power limit
        
        guard moveCam == false else {
            
            
            Cam.position.x += TouchBegin.x - position.x
            Cam.position.y += TouchBegin.y - position.y
            
            
            
            return
        }
        
        
        
        
        let limit = 100
        
        //Get Power Values
        if x > limit{
            x = limit
        }
        if y > limit {
            y = limit
        }
        if y < -limit {
            y = -limit
        }
        
        
        
        //Display the Power values on screen
        TextPower.fontColor = SKColor.black
        TextPower.text = "(\(x) , \(y))"
        TextPower.fontSize = 35 * Cam.xScale
        TextPower.position = TouchBegin
        
        if TextPow == true {
            addChild(TextPower)
            TextPow = false
        }
        
        
        
        
    }
    
    
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with even:UIEvent?){
        
        
        
        
        //check to see if arrow is not already in air
        guard (Launched == false) else {
            return
        }
        
        guard Menu == true else{
            
            guard let position = touches.first?.location(in:self) else{
                return
            }
            
            let nodesArray = self.nodes(at: position)
            
            
            
            //if in options menue
            guard options == false else{
                if nodesArray.first?.position == Title.position {
                    guard zoom == false else {
                        zoom = false
                        Title.text = "Zooom on Launch: False"
                        return
                    }
                    zoom = true
                    Title.text = "Zoom on Launch: True"
                }
                if nodesArray.first?.position == NewGame.position{
                    guard music == false else {
                        music = false
                        NewGame.text = "Music: False"
                        return
                    }
                    music = true
                    NewGame.text = "Music: True"
                }
                else if nodesArray.first?.position == Options.position{
                    options = false
                    Mainmenu()
                }
                return
            }
            
            
            
            
            guard won == false else{
                //end menu
                
                if nodesArray.first?.position == NewGame.position {
                    reset()
                }
                else if nodesArray.first?.position == Options.position {
                    Mainmenu()
                    
                }
                return
            }
            
            //main menu
            if nodesArray.first?.position == NewGame.position {
                
                reset()
            }
            if nodesArray.first?.position == Options.position {
                Otptions()
            }
            
            return
            
        }
        
        guard let postionRelative = touches.first?.location(in: self.Cam) else {
            return
        }
        
        if postionRelative.x < rect.maxX   && postionRelative.y > rect.minY && postionRelative.x > rect.minX  && postionRelative.y < rect.maxY  {
            if moveCam == false{
                moveCam = true
                framee.backgroundColor = UIColor.blue
                return
            }
            
            if moveCam == true {
                moveCam = false
                framee.backgroundColor = UIColor.black
                return
            }
            
            return
        }
        
        
        guard moveCam == false else {
            return
            
        }
        
        
        
        guard moveCam == false else {
            return
            
        }
        
        
        
        
        TextPower.removeFromParent()
        TextPow = true
        
        //Create forces to apply
        var ForceApplyX: CGFloat = 0
        var ForceApplyY: CGFloat = 0
        
        //get touch position
        guard let position = touches.first?.location(in:self) else{
            return
        }
        
        //setup arrow physicsbody
        ArrowArray[ArrowN].physicsBody = SKPhysicsBody(rectangleOf: ArrowArray[ArrowN].size)
        ArrowArray[ArrowN].physicsBody?.velocity = self.physicsBody!.velocity
        ArrowArray[ArrowN].physicsBody?.categoryBitMask = PhysicsCatrgory.Arrow
        ArrowArray[ArrowN].physicsBody?.contactTestBitMask = PhysicsCatrgory.Legs
        ArrowArray[ArrowN].physicsBody?.collisionBitMask = PhysicsCatrgory.none
        ArrowArray[ArrowN].physicsBody?.isDynamic = true
        
        //calculate force of arrow
        let ForceX = TouchBegin.x - position.x
        let ForceY = TouchBegin.y - position.y
        //force limit
        let limit:CGFloat = 100
        
        //limit the force ifneed be
        if ForceX > limit {
            ForceApplyX = limit
        }
        else{
            ForceApplyX = ForceX
        }
        
        if ForceY > limit{
            ForceApplyY = limit
        }
        else if ForceY < -limit {
            ForceApplyY = -limit
        }
        else {
            ForceApplyY = ForceY
        }
        
        //half it
        ForceApplyX = ForceApplyX * 0.5
        ForceApplyY = ForceApplyY * 0.5
        
        
        
        //apply force to arrow
        ArrowArray[ArrowN].physicsBody?.applyImpulse(CGVector(dx: ForceApplyX, dy: ForceApplyY))
        Launched = true
    }
    
    func ResetArrow() {
        
        //Tell the game we are on the next arrow in the arry
        let PlusOne = ArrowN + 1
        
        //if three arrows have been shot then end the game
        guard PlusOne < 3 else {
            ArrowArray[ArrowN].physicsBody?.isDynamic = false
            
            End()
            return
        }
        
        //Stop the current arrow from moving and reset the camera position
        ArrowArray[ArrowN].physicsBody?.isDynamic = false
        if zoom == true {
            Cam.position = Player.position
        }
        
        
        //add the next arrow to the scene
        ArrowN = ArrowN + 1
        addChild(ArrowArray[ArrowN])
        Launched = false
        
        
    }
    
    func reset (){
        
        Menu = true
        Title.removeFromParent()
        NewGame.removeFromParent()
        Options.removeFromParent()
        
        won = false
        
        //reset camera and score
        Cam.position = Player.position
        Score = 0
        
        // reset the arrows to the original values
        for i in (0...2){
            ArrowArray[i].position = CGPoint (x: size.width * 0.105, y: size.height * 0.367)
            ArrowArray[i].physicsBody?.isDynamic = false
            ArrowArray[i].zRotation = AngleStart
            
        }
        //check to see which arrows need to be removed
        switch ArrowN{
        case 1:
            ArrowArray[1].removeFromParent()
            ResetValue()
            
        case 2:
            ArrowArray[1].removeFromParent()
            ArrowArray[2].removeFromParent()
            ResetValue()
        default:
            ResetValue()
            return
        }
        
    }
    
    func ResetValue(){
        ArrowN = 0
        Launched = false
    }
    
    
    override func update(_ currentTime: TimeInterval){
        
        //check to see if game is over or not
        guard won == false else{
            Cam.position = CGPoint (x:0, y: -500)
            Cam.setScale(CamStart)
            return
        }
        
        guard Menu == true else {
            
            return
        }
        
        
        //check to see if arrow is touching floor
        if (ArrowArray[ArrowN].position.y < Floor.position.y + (size.height * 0.010)){
            ResetArrow()
            
        }
        
        
        //Limit the amount you can mvoe the camera
        guard Launched == true else {
            let limit :CGFloat = 600
            
            if Cam.position.y > limit{
                Cam.position.y = limit
            }
            if Cam.position.y < -limit {
                Cam.position.y = -limit
            }
            if Cam.position.x > limit * 8 {
                Cam.position.x = limit * 8
            }
            if Cam.position.x < -limit {
                Cam.position.x = -limit
            }
            
            //dont allow to zoom out too far
            if Cam.xScale > 5.5 {
                self.camera?.setScale(5)
                
            }
            
            return
        }
        //if launched is true then follow the arrow with the camera
        if zoom == true {
            Cam.position = ArrowArray[ArrowN].position
            //self.GameViewControllerV.startGyro()
            Cam.setScale(CamStart)
        }
        
    }
    
   
    func Collision (Arrow: SKSpriteNode, Body: SKSpriteNode){
        print("Hit")
        ResetArrow()
    }
    
    func AddScore(ScoreP: Int){
        Score = Score + ScoreP
    }
    
}



extension GameScene: SKPhysicsContactDelegate {
    
    
    func didBegin(_ contact: SKPhysicsContact){
        var Body1: SKPhysicsBody
        var Body2: SKPhysicsBody
        let score = 100
        
        //check to see if the arrow collided with anyting
        guard (contact.bodyA.categoryBitMask == PhysicsCatrgory.Arrow || contact.bodyB.categoryBitMask == PhysicsCatrgory.Arrow) else{
            return
        }
        
        //set the arrow as body1
        if contact.bodyA.categoryBitMask == PhysicsCatrgory.Arrow {
            Body1 = contact.bodyA
            Body2 = contact.bodyB
        }
        else {
            Body1 = contact.bodyB
            Body2 = contact.bodyA
        }
        
        //check which bodypart collided
        if ((Body1.categoryBitMask & PhysicsCatrgory.Arrow != 0)){
            
            switch (Body2)  {
                
            //addscore based on bodypart
            case let Body2 where Body2.categoryBitMask == PhysicsCatrgory.Legs :
                AddScore(ScoreP: score)
                
            case let Body2 where Body2.categoryBitMask == PhysicsCatrgory.Body :
                AddScore(ScoreP: score + 100)
                
            case let Body2 where Body2.categoryBitMask == PhysicsCatrgory.Head :
                AddScore(ScoreP: score + 200)
                
            default: break
                
            }
            //call coliision with the parts that collidede∫
            if let ArrowP = Body1.node as? SKSpriteNode, let BodyP = Body2.node as? SKSpriteNode{
                Collision(Arrow: ArrowP, Body: BodyP)
            }
            
        }
    }
    
}
