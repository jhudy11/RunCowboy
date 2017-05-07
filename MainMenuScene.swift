//
//  MainMenuScene.swift
//  RunCowboy
//
//  Created by Joshua Hudson on 5/6/17.
//  Copyright © 2017 ParanoidPenguinProductions. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    var playBtn = SKSpriteNode()
    var scoreBtn = SKSpriteNode()
    
    var title = SKLabelNode()
    
    var scoreLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        initialize()
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveBackgroundsAndGrounds()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location) == playBtn {
                guard let gameplay = GameplayScene(fileNamed: "GameplayScene") else { return }
                gameplay.scaleMode = .aspectFill
                self.view?.presentScene(gameplay, transition: SKTransition.crossFade(withDuration: 1.0))
            }
            
            if atPoint(location) == scoreBtn {
                showScore()
            }
            
        }
        
    }
    
    func initialize() {
        createBackground()
        createGrounds()
        getButtons()
        getLabel()
        
    }
    
    func createBackground() {
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG")
            bg.name = "BG"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 0)
            bg.zPosition = 0
            self.addChild(bg)
        }
    }
    
    func createGrounds() {
        for i in 0...2 {
            let ground = SKSpriteNode(imageNamed: "Ground")
            ground.name = "Ground"
            ground.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ground.position = CGPoint(x: CGFloat(i) * ground.size.width, y: -(self.frame.size.height / 2))
            ground.zPosition = 3
            self.addChild(ground)
        }
    }
    
    func moveBackgroundsAndGrounds() {
        enumerateChildNodes(withName: "BG", using: ({
            (node, error) in
            
            node.position.x -= 6
            
            if node.position.x < -(self.frame.width) {
                node.position.x += self.frame.width * 3
            }
            
        }))
        
        enumerateChildNodes(withName: "Ground", using: ({
            (node, error) in
            
            node.position.x -= 3
            
            if node.position.x < -(self.frame.width) {
                node.position.x += self.frame.width * 3
            }
            
        }))
    }
    
    func getButtons() {
        playBtn = self.childNode(withName: "Play") as! SKSpriteNode
        scoreBtn = self.childNode(withName: "Score") as! SKSpriteNode
    }
    
    func getLabel() {
        title = self.childNode(withName: "Title") as! SKLabelNode
        
        title.fontName = "RosewoodStd-Regular"
        title.fontSize = 120
        title.text = "Run Cowboy"
        
        title.zPosition = 5
        
        let moveUp = SKAction.moveTo(y: title.position.y + 50, duration: TimeInterval(0.8))
        let moveDown = SKAction.moveTo(y: title.position.y - 50, duration: TimeInterval(0.8))
        
        let sequence = SKAction.sequence([moveUp, moveDown])
        
        title.run(SKAction.repeatForever(sequence))
    }
    
    func showScore() {
        scoreLabel.removeFromParent()
        
        scoreLabel = SKLabelNode(fontNamed: "RosewoodStd-Regular")
        scoreLabel.fontSize = 180
        scoreLabel.text = "\(UserDefaults.standard.integer(forKey: "HighScore"))"
        scoreLabel.position = CGPoint(x: 0, y: -200)
        scoreLabel.zPosition = 9
        self.addChild(scoreLabel)
    }
}





















