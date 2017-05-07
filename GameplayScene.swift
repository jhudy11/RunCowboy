//
//  GameplayScene.swift
//  RunCowboy
//
//  Created by Joshua Hudson on 5/4/17.
//  Copyright © 2017 ParanoidPenguinProductions. All rights reserved.
//

import SpriteKit

class GameplayScene: SKScene, SKPhysicsContactDelegate {
    
    var player = Player()
    
    var obstacles = [SKSpriteNode]()
    
    var canJump = false
    
    var movePlayer = false
    
    var playerOnObstacle = false
    
    var isAlive = false
    
    var spawner = Timer()
    var counter = Timer()
    
    var scoreLabel = SKLabelNode()
    
    var score = Int(0)
    
    var pausePanel = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        initialize()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if isAlive {
            moveBackgroundsAndGrounds()
        }
        
        if movePlayer {
            player.position.x -= 6.75
        }
        
        checkPlayersBounds()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            
            if atPoint(location).name == "Restart" {
                guard let gameplay = GameplayScene(fileNamed: "GameplayScene") else { return }
                gameplay.scaleMode = .aspectFill
                self.view?.presentScene(gameplay, transition: SKTransition.crossFade(withDuration: 1.0))
            }
            
            if atPoint(location).name == "Quit" {
                guard let mainMenu = MainMenuScene(fileNamed: "MainMenuScene") else { return }
                mainMenu.scaleMode = .aspectFill
                self.view?.presentScene(mainMenu, transition: SKTransition.crossFade(withDuration: 1.0))
            }
            
            if atPoint(location).name == "Pause" {
                createPausePanel()
            }
            
            if atPoint(location).name == "Resume" {
                pausePanel.removeFromParent()
                self.scene?.isPaused = false
                
                spawner = Timer.scheduledTimer(timeInterval: TimeInterval(randomBetweenNumbers(firstNumber: 1, secondNumber: 4.5)), target: self, selector: #selector(spawnObstacles), userInfo: nil, repeats: true)
                
                counter = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(incrementScore), userInfo: nil, repeats: true)
            }
            
        }
        
        if canJump {
            canJump = false
            player.jump()
        }
        
        if playerOnObstacle {
            player.jump()
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Ground" {
            canJump = true
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obstacle" {
            
            if !canJump {
                movePlayer = true
                playerOnObstacle = true
            }
            
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Cactus" {
            // Kill the player and prompt buttons
            playerDied()
        }
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "Player" {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obstacle" {
            
            movePlayer = false
            playerOnObstacle = false
            
        }
        
    }
    
    func initialize() {
        
        physicsWorld.contactDelegate = self
        
        isAlive = true
        
        createPlayer()
        createBackground()
        createGrounds()
        createObstacles()
        getLabel()
        
        spawner = Timer.scheduledTimer(timeInterval: TimeInterval(randomBetweenNumbers(firstNumber: 1, secondNumber: 4.5)), target: self, selector: #selector(spawnObstacles), userInfo: nil, repeats: true)
        
        counter = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(incrementScore), userInfo: nil, repeats: true)
    }
    
    func createPlayer() {
        player = Player(imageNamed: "Player 1")
        player.initialize()
        player.position = CGPoint(x: -10, y: 20)
        self.addChild(player)
        
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
            ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
            ground.physicsBody?.affectedByGravity = false
            ground.physicsBody?.isDynamic = false
            ground.physicsBody?.categoryBitMask = ColliderType.Ground
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
    
    func createObstacles() {
        
        for i in 0...5 {
            
            let obstacle = SKSpriteNode(imageNamed: "Obstacle \(i)")
            
            if i == 0 {
                
                obstacle.name = "Cactus"
                obstacle.setScale(0.4)
                
            } else {
                
                obstacle.name = "Obstacle"
                obstacle.setScale(0.5)
                
            }
            
            obstacle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            obstacle.zPosition = 1
            
            obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
            obstacle.physicsBody?.allowsRotation = false
            obstacle.physicsBody?.categoryBitMask = ColliderType.Obstacle
            
            obstacles.append(obstacle)
            
        }
        
    }
    
    func spawnObstacles() {
        
        let index = Int(arc4random_uniform(UInt32(obstacles.count)))
        
        // Avoids fatal crash when having more than one obstacle with a given index
        let obstacle = obstacles[index].copy() as! SKSpriteNode
        
        obstacle.position = CGPoint(x: self.frame.width + obstacle.size.width, y: 50)
        
        let move = SKAction.moveTo(x: -(self.frame.size.width * 2), duration: TimeInterval(10))
        
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([move, remove])
        
        obstacle.run(sequence)
        
        self.addChild(obstacle)
    }
    
    func randomBetweenNumbers(firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat {
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
        
    }
    
    func checkPlayersBounds() {
        if isAlive {
            if player.position.x < -(self.frame.size.width / 2) - 35 {
                playerDied()
            }
        }
    }
    
    func getLabel() {
        scoreLabel = self.childNode(withName: "ScoreLabel") as! SKLabelNode
        scoreLabel.text = "0M"
    }
    
    func incrementScore() {
        score += 1
        scoreLabel.text = "\(score)M"
    }
    
    func createPausePanel() {
        
        spawner.invalidate()
        counter.invalidate()
        
        self.scene?.isPaused = true
        
        pausePanel = SKSpriteNode(imageNamed: "Pause Panel")
        pausePanel.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pausePanel.position = CGPoint(x: 0, y: 0)
        pausePanel.zPosition = 10
        
        let resume = SKSpriteNode(imageNamed: "Play")
        let quit = SKSpriteNode(imageNamed: "Quit")
        
        resume.name = "Resume"
        resume.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        resume.position = CGPoint(x: -155, y: 0)
        resume.zPosition = 11
        resume.setScale(0.75)
        
        quit.name = "Quit"
        quit.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        quit.position = CGPoint(x: 155, y: 0)
        quit.zPosition = 11
        quit.setScale(0.75)
        
        pausePanel.addChild(resume)
        pausePanel.addChild(quit)
        
        self.addChild(pausePanel)
    }
    
    func playerDied() {
        
        let highScore = UserDefaults.standard.integer(forKey: "Highscore")
        
        if highScore < score {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
        
        player.removeFromParent()
        
        for child in children {
            if child.name == "Obstacle" || child.name == "Cactus" {
                child.removeFromParent()
            }
        }
        
        // Disable the creation of new obstacles
        spawner.invalidate()
        counter.invalidate()
        
        isAlive = false
        
        let restart = SKSpriteNode(imageNamed: "Restart")
        let quit = SKSpriteNode(imageNamed: "Quit")
        
        restart.name = "Restart"
        restart.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        restart.position = CGPoint(x: -200, y: -150)
        restart.zPosition = 10
        restart.setScale(0)
        
        quit.name = "Quit"
        quit.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        quit.position = CGPoint(x: 200, y: -150)
        quit.zPosition = 10
        quit.setScale(0)
        
        let scaleUp = SKAction.scale(to: 1, duration: TimeInterval(0.5))
        
        restart.run(scaleUp)
        quit.run(scaleUp)
        
        self.addChild(restart)
        self.addChild(quit)
        
    }
    
}


































