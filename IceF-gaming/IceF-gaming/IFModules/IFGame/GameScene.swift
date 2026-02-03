import SpriteKit

final class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Callbacks to SwiftUI
    var onScore: ((Int) -> Void)?
    var onGameOver: ((Int) -> Void)?

    // MARK: - Sizes from your spec (points)
    private let wallWidth: CGFloat = 65
    private let ballSize: CGFloat = 55
    private let obstacleThickness: CGFloat = 22
    private var gapWidth: CGFloat { ballSize * 2 } // "ширина в два шара"

    // MARK: - Motion tuning
    private var directionX: CGFloat = 1 // 1 = right, -1 = left
    private var horizontalSpeed: CGFloat = 260
    private var verticalSpeed: CGFloat = 260
    private var speedGrowth: CGFloat = 0.03 // рост скорости по мере набора высоты

    // MARK: - World
    private let world = SKNode()
    private let cameraNode = SKCameraNode()

    // MARK: - Player
    private var ball = SKShapeNode()
    private var startY: CGFloat = 0

    // MARK: - Obstacles
    private var nextObstacleY: CGFloat = 0
    private let obstacleSpacing: CGFloat = 240

    // MARK: - Score
    private var bestY: CGFloat = 0
    private var isDead = false

    // MARK: - Physics categories
    private struct Cat {
        static let ball: UInt32      = 1 << 0
        static let wall: UInt32      = 1 << 1
        static let obstacle: UInt32  = 1 << 2
    }

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        backgroundColor = .black
        removeAllChildren()
        removeAllActions()
        isDead = false

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        addChild(world)

        setupCamera()
        setupWalls()
        setupBall()
        setupInitialObstacles()

        bestY = ball.position.y
        startY = ball.position.y
    }

    // MARK: - Setup
    private func setupCamera() {
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        camera = cameraNode
        addChild(cameraNode)
    }

    private func setupWalls() {
        // Левая и правая границы коридора (edge physics bodies)
        let leftX = wallWidth
        let rightX = size.width - wallWidth

        let minY: CGFloat = -10_000
        let maxY: CGFloat =  10_000

        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: leftX, y: minY),
                                             to: CGPoint(x: leftX, y: maxY))
        leftWall.physicsBody?.categoryBitMask = Cat.wall
        leftWall.physicsBody?.contactTestBitMask = Cat.ball
        leftWall.physicsBody?.collisionBitMask = Cat.ball
        world.addChild(leftWall)

        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: rightX, y: minY),
                                              to: CGPoint(x: rightX, y: maxY))
        rightWall.physicsBody?.categoryBitMask = Cat.wall
        rightWall.physicsBody?.contactTestBitMask = Cat.ball
        rightWall.physicsBody?.collisionBitMask = Cat.ball
        world.addChild(rightWall)

        // Визуальные стены (просто заливка по бокам)
        let leftVis = SKSpriteNode(color: .darkGray, size: CGSize(width: wallWidth, height: size.height * 3))
        leftVis.anchorPoint = CGPoint(x: 0, y: 0.5)
        leftVis.position = CGPoint(x: 0, y: size.height / 2)
        leftVis.zPosition = -1
        world.addChild(leftVis)

        let rightVis = SKSpriteNode(color: .darkGray, size: CGSize(width: wallWidth, height: size.height * 3))
        rightVis.anchorPoint = CGPoint(x: 1, y: 0.5)
        rightVis.position = CGPoint(x: size.width, y: size.height / 2)
        rightVis.zPosition = -1
        world.addChild(rightVis)
    }

    private func setupBall() {
        ball = SKShapeNode(circleOfRadius: ballSize / 2)
        ball.fillColor = .white
        ball.strokeColor = .clear
        ball.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        ball.zPosition = 10

        let body = SKPhysicsBody(circleOfRadius: ballSize / 2)
        body.affectedByGravity = false
        body.allowsRotation = false
        body.linearDamping = 0
        body.friction = 0
        body.restitution = 0
        body.usesPreciseCollisionDetection = true

        body.categoryBitMask = Cat.ball
        body.contactTestBitMask = Cat.wall | Cat.obstacle
        body.collisionBitMask = Cat.wall | Cat.obstacle

        ball.physicsBody = body
        world.addChild(ball)
    }

    private func setupInitialObstacles() {
        nextObstacleY = ball.position.y + size.height * 0.8
        for _ in 0..<8 {
            spawnObstacle(atY: nextObstacleY)
            nextObstacleY += obstacleSpacing
        }
    }

    // MARK: - Input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isDead else { return }
        // Тап: мгновенно меняем горизонтальное направление
        directionX *= -1
    }

    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        guard !isDead, let body = ball.physicsBody else { return }

        // Принудительно держим диагональную скорость (dx + dy)
        body.velocity = CGVector(dx: directionX * horizontalSpeed, dy: verticalSpeed)

        // Камера следует за шаром по Y, по X фиксирована по центру
        cameraNode.position = CGPoint(x: size.width / 2, y: ball.position.y + size.height * 0.2)

        // Счёт = пройденная высота
        if ball.position.y > bestY {
            bestY = ball.position.y
            let sc = Int((bestY - startY) / 10) // шаг 10pt = 1 очко (можешь поменять)
            onScore?(sc)

            // постепенное усложнение
            verticalSpeed = 260 + (bestY - startY) * speedGrowth
            horizontalSpeed = max(220, min(420, 260 + (bestY - startY) * 0.01))
        }

        // Догенерить препятствия впереди камеры
        let topEdge = cameraNode.position.y + size.height * 1.2
        while nextObstacleY < topEdge {
            spawnObstacle(atY: nextObstacleY)
            nextObstacleY += obstacleSpacing
        }

        // Чистка старых препятствий ниже камеры
        let bottomEdge = cameraNode.position.y - size.height * 1.5
        for node in world.children {
            if node.name == "obstacle" && node.position.y < bottomEdge {
                node.removeFromParent()
            }
        }
    }

    // MARK: - Obstacles
    private func spawnObstacle(atY y: CGFloat) {
        let corridorLeft = wallWidth
        let corridorRight = size.width - wallWidth
        let corridorWidth = corridorRight - corridorLeft

        // Центр "прохода" (gap)
        let gapCenterMin = corridorLeft + gapWidth / 2 + 10
        let gapCenterMax = corridorRight - gapWidth / 2 - 10
        let gapCenterX = CGFloat.random(in: gapCenterMin...gapCenterMax)

        let leftBarWidth = max(0, (gapCenterX - gapWidth / 2) - corridorLeft)
        let rightBarWidth = max(0, corridorRight - (gapCenterX + gapWidth / 2))

        let container = SKNode()
        container.name = "obstacle"
        container.position = CGPoint(x: 0, y: y)

        if leftBarWidth > 1 {
            let left = SKSpriteNode(color: .red, size: CGSize(width: leftBarWidth, height: obstacleThickness))
            left.anchorPoint = CGPoint(x: 0, y: 0.5)
            left.position = CGPoint(x: corridorLeft, y: 0)
            left.name = "bar"
            left.physicsBody = SKPhysicsBody(rectangleOf: left.size, center: CGPoint(x: left.size.width/2, y: 0))
            left.physicsBody?.isDynamic = false
            left.physicsBody?.categoryBitMask = Cat.obstacle
            left.physicsBody?.contactTestBitMask = Cat.ball
            left.physicsBody?.collisionBitMask = Cat.ball
            container.addChild(left)
        }

        if rightBarWidth > 1 {
            let right = SKSpriteNode(color: .red, size: CGSize(width: rightBarWidth, height: obstacleThickness))
            right.anchorPoint = CGPoint(x: 1, y: 0.5)
            right.position = CGPoint(x: corridorRight, y: 0)
            right.name = "bar"
            right.physicsBody = SKPhysicsBody(rectangleOf: right.size, center: CGPoint(x: -right.size.width/2, y: 0))
            right.physicsBody?.isDynamic = false
            right.physicsBody?.categoryBitMask = Cat.obstacle
            right.physicsBody?.contactTestBitMask = Cat.ball
            right.physicsBody?.collisionBitMask = Cat.ball
            container.addChild(right)
        }

        // С шансом делаем препятствие “движущимся” (влево-вправо)
        let movingChance: CGFloat = 0.35
        if CGFloat.random(in: 0...1) < movingChance {
            // Безопасный диапазон смещения, чтобы проход всегда оставался в коридоре
            let maxShiftLeft = corridorLeft - (gapCenterX - gapWidth/2) // отрицательное/нулевое
            let maxShiftRight = corridorRight - (gapCenterX + gapWidth/2) // положительное/нулевое

            // Берём амплитуду поменьше, чтобы было играбельно
            let amplitude = min(80, maxShiftRight, abs(maxShiftLeft))
            if amplitude > 10 {
                let duration = TimeInterval(CGFloat.random(in: 1.1...1.8))
                let move = SKAction.sequence([
                    SKAction.moveBy(x: amplitude, y: 0, duration: duration),
                    SKAction.moveBy(x: -amplitude, y: 0, duration: duration)
                ])
                container.run(SKAction.repeatForever(move))
            }
        }

        world.addChild(container)
    }

    // MARK: - Contacts
    func didBegin(_ contact: SKPhysicsContact) {
        guard !isDead else { return }

        let a = contact.bodyA.categoryBitMask
        let b = contact.bodyB.categoryBitMask

        let hitBall = (a == Cat.ball) || (b == Cat.ball)
        let hitWallOrObstacle = (a == Cat.wall || a == Cat.obstacle || b == Cat.wall || b == Cat.obstacle)

        if hitBall && hitWallOrObstacle {
            die()
        }
    }

    private func die() {
        isDead = true
        ball.physicsBody?.velocity = .zero
        isPaused = true

        let finalScore = Int((bestY - startY) / 10)
        onGameOver?(finalScore)
    }
}