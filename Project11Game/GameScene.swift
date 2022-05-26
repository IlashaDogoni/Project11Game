import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var challengeLabel: SKLabelNode!
    var ballLabel:SKLabelNode!
    var editLabel: SKLabelNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var balls = 10{
        didSet {
            ballLabel.text = "Balls: \(balls)"
        }
    }
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var challengeMode: Bool = false{
        didSet{
            if challengeMode {
                challengeLabel.text = "Freeride"
            } else {
                challengeLabel.text = "Challenge"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: K.background)
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        scoreLabel = SKLabelNode(fontNamed: K.font)
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: K.font)
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        challengeLabel = SKLabelNode(fontNamed: K.font)
        challengeLabel.text = "Challenge"
        challengeLabel.position = CGPoint(x: 256, y: 700)
        addChild(challengeLabel)
        
        ballLabel = SKLabelNode(fontNamed: K.font)
        ballLabel.text = "Balls: 0"
        ballLabel.horizontalAlignmentMode = .center
        ballLabel.position = CGPoint(x: 700, y: 700)
        addChild(ballLabel)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
        }
        
        if  contact.bodyA.node?.name == "box" {
            collisionBetween(ball: contact.bodyA.node!, object: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "box" {
            collisionBetween(ball: contact.bodyB.node!, object: contact.bodyA.node!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)
        
        if objects.contains(challengeLabel){
            challengeMode.toggle()
            balls = 10
            
            var eks: CGFloat = 128
            for _ in 1...4{
                var height : CGFloat = 128
                for _ in 1...5 {
                    makeBox(at: CGPoint(x: CGFloat.random(in: eks - 128...eks + 128 ), y: height))
                    height += 128
                }
                eks += 256
            }
        }
        
        if objects.contains(editLabel) {
            editingMode.toggle()
        } else {
            if editingMode {
                makeBox(at: location)
            } else {
                makeBall(at: location)
            }
        }
        
    }
    
    func makeBall(at position: CGPoint){
        let ball = SKSpriteNode(imageNamed: K.ballRed)
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2)
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
        ball.physicsBody?.restitution = 0.4
        ball.position = CGPoint(x: position.x, y: 650)
        ball.name = "ball"
        addChild(ball)
    }
    
    func makeBox(at position: CGPoint){
        let size = CGSize(width: Int.random(in: 64...160), height: 16)
        let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
        box.physicsBody?.contactTestBitMask = box.physicsBody!.collisionBitMask
        box.zRotation = CGFloat.random(in: 3...6)
        box.position = position
        
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        box.name = "box"
        addChild(box)
    }
    
    func makeBouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: K.bouncer)
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool){
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: K.slotBaseGood)
            slotGlow = SKSpriteNode(imageNamed: K.slotGlowGood)
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: K.slotBaseBad)
            slotGlow = SKSpriteNode(imageNamed: K.slotGlowBad)
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        slotGlow.position = position
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            balls += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
            balls -= 1
        } else if object.name == "box"{
            destroy(box: object)
        }
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: K.fireParticles) {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func destroy(box: SKNode){
        if let fireParticles = SKEmitterNode(fileNamed: K.fireParticles) {
            fireParticles.position = box.position
            addChild(fireParticles)
        }
        box.removeFromParent()
    }
    
    
}
