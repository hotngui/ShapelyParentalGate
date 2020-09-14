//  
// Created by Joey Jarosz on 9/9/20.
// Copyright © 2020 hot-n-GUI, LLC. All rights reserved.
//

import UIKit
import SpriteKit

///
protocol ShapelySceneDelegate: class {
    func shapelyScene(_ scene: ShapelyScene, dropped shape: ShapelyScene.Shape?) -> Bool
}

/// This class uses _SpriteKit_ to generate a bunch of shapes that bounce around randomly. It allows the user to grab one of the shapes with their finger and drag
/// it to the square target at the bottom of the screen. It then communicates to the delegate what shape was dropped over the target. The delegate then notifies this
/// object whether or not the shape matched the one that was being looked for. If the dropped shape was incorrect it continues to bounce around the view.
///
/// - Note: Since we use phsyics to do much of the work there is not much needed in this class beyond created and adding the nodes. The exception is that we want
/// to allow the user to grab a shape and drag it, so we need to handle those touch events ourselves.
///
class ShapelyScene: SKScene {
    private enum Constants {
        static let shapeSize = CGSize(width: 88, height: 88)
        static let targetSize = CGSize(width: 120, height: 120)
        static let shapeCategory: UInt32 = 0x1 << 0
        static let edgeCategory: UInt32 = 0x1 << 1
    }

    private var isFingerOnShape = false
    private var grabbedShape: SKShapeNode?
    private var grabbedPhysicsBody: SKPhysicsBody?

    enum Shape: String, CaseIterable {
        case circle = "Circle"
        case square = "Square"
        case triangle = "Triangle"
        case pentagon = "Pentagon"
    }

    var shapelySceneDelegate: ShapelySceneDelegate?
    var numberOfEachShape: Int = 1

    //MARK: - Scene Methods

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        backgroundColor = .clear

        // Create a physics body so that we have something to bounce the shapes off of.
        //
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        borderBody.categoryBitMask = Constants.edgeCategory

        self.physicsBody = borderBody
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)

        // Create the shapes...
        //
        let width = view.bounds.width - Constants.shapeSize.width
        let height = view.bounds.height - Constants.shapeSize.height
        let yStart = Constants.shapeSize.height
        let xStart = Constants.shapeSize.width

        for _ in 0..<numberOfEachShape {
            let node = createCircleNode(color: randomColor())
            addChild(node)

            node.position = CGPoint(x: CGFloat.random(in: xStart..<width), y: CGFloat.random(in: yStart..<height))
            node.physicsBody?.applyImpulse(randomVector())
        }

        for _ in 0..<numberOfEachShape {
            let node = createTriangleNode(color: randomColor())
            addChild(node)

            node.position = CGPoint(x: CGFloat.random(in: xStart..<width), y: CGFloat.random(in: yStart..<height))
            node.physicsBody?.applyImpulse(randomVector())
        }

        for _ in 0..<numberOfEachShape {
            let node = createSquareNode(color: randomColor())
            addChild(node)

            node.position = CGPoint(x: CGFloat.random(in: xStart..<width), y: CGFloat.random(in: yStart..<height))
            node.physicsBody?.applyImpulse(randomVector())
        }

        for _ in 0..<numberOfEachShape {
            let node = createPentagonNode(color: randomColor())
            addChild(node)

            node.position = CGPoint(x: CGFloat.random(in: xStart..<width), y: CGFloat.random(in: yStart..<height))
            node.physicsBody?.applyImpulse(randomVector())
        }

        // Create the _target_ node which stays stationery in the corner of the scene's view. This is the node that the
        // user must drop the shape they grabbed over in order to succeed.
        //
        let targetNode = createTargetNode()

        targetNode.position = CGPoint(x: 20.0 + (Constants.targetSize.width / 2), y: 20.0 + (Constants.targetSize.height / 2))
        targetNode.zPosition = -1

        addChild(targetNode)
    }

    //MARK: - Touch Event Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let touchLocation = touch!.location(in: self)

        if let body = physicsWorld.body(at: touchLocation), let node = body.node as? SKShapeNode {
            if node.name != "Target" {
                isFingerOnShape = true
                grabbedShape = node
                grabbedPhysicsBody = node.physicsBody

                node.physicsBody = nil
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isFingerOnShape, let shape = self.grabbedShape {
            if let touch = touches.first {
                let touchLocation = touch.location(in: self)
                let previousLocation = touch.previousLocation(in: self)

                var shapeX = shape.position.x + (touchLocation.x - previousLocation.x)
                var shapeY = shape.position.y + (touchLocation.y - previousLocation.y)

                shapeX = max(shapeX, shape.frame.width/2)
                shapeX = min(shapeX, size.width - shape.frame.width/2)

                shapeY = max(shapeY, shape.frame.height/2)
                shapeY = min(shapeY, size.height - shape.frame.height/2)

                shape.position = CGPoint(x: shapeX, y: shapeY)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var success = false

        if let delegate = self.shapelySceneDelegate, let target = childNode(withName: "Target") as? SKShapeNode {
            if let grabbedShape = self.grabbedShape, let name = grabbedShape.name {
                if target.frame.contains(grabbedShape.frame) {
                    if delegate.shapelyScene(self, dropped: Shape(rawValue: name)) {
                        success = true
                    }
                }
            }
        }

        if success == false, let grabbedShape = self.grabbedShape {
            grabbedShape.physicsBody = grabbedPhysicsBody
            grabbedShape.physicsBody?.applyImpulse(randomVector())
        }

        isFingerOnShape = false
        grabbedShape = nil
        grabbedPhysicsBody = nil
    }

    //MARK: - Private Methods

    private func randomVector() -> CGVector {
        let xDirect = Int.random(in: 0...1) == 1 ? 1 : -1
        let yDirect = Int.random(in: 0...1) == 1 ? 1 : -1

        let dx = CGFloat.random(in: 1...2) * CGFloat(xDirect)
        let dy = CGFloat.random(in: 1...2) * CGFloat(yDirect)

        return CGVector(dx: dx, dy: dy)
    }

    private func randomColor() -> UIColor {
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemYellow, .systemIndigo, .systemPink, .systemPurple, .systemRed, .systemTeal]
        return colors[Int.random(in: 0..<colors.count)]
    }

    //MARK: - Node Factories

    ///
    private func createCircleNode(color: UIColor) -> SKShapeNode {
        let path = CGMutablePath()
        let radius = Constants.shapeSize.width / 2.0

        path.addArc(center: CGPoint.zero, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)

        let node = SKShapeNode(path: path)
        node.fillColor = color
        node.lineWidth = 0.0
        node.name = Shape.circle.rawValue

        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.frame.width, height: node.frame.height))
        node.physicsBody?.mass = 0.00893608666956425
        node.physicsBody?.linearDamping = 0.0
        node.physicsBody?.restitution = 1.0
        node.physicsBody?.friction = 0.0
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = Constants.shapeCategory
        node.physicsBody?.collisionBitMask = Constants.edgeCategory

        return node
    }

    ///
    private func createSquareNode(color: UIColor) -> SKShapeNode {
        let node = SKShapeNode(rectOf: Constants.shapeSize, cornerRadius: 6)

        node.fillColor = color
        node.lineWidth = 0.0
        node.name = Shape.square.rawValue

        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.frame.width, height: node.frame.height))
        node.physicsBody?.mass = 0.0079
        node.physicsBody?.linearDamping = 0.0
        node.physicsBody?.restitution = 1.0
        node.physicsBody?.friction = 0.0
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = Constants.shapeCategory
        node.physicsBody?.collisionBitMask = Constants.edgeCategory

        return node
    }

    ///
    private func createTriangleNode(color: UIColor) -> SKShapeNode {
        let path = CGMutablePath()

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: Constants.shapeSize.width, y: 0))
        path.addLine(to: CGPoint(x: Constants.shapeSize.width / 2.0, y: Constants.shapeSize.height))

        let node = SKShapeNode(path: path, centered: true)
        node.fillColor = color
        node.lineJoin = .round
        node.lineWidth = 0.0
        node.name = Shape.triangle.rawValue

        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.frame.width, height: node.frame.height))
        node.physicsBody?.mass = 0.0089
        node.physicsBody?.linearDamping = 0.0
        node.physicsBody?.restitution = 1.0
        node.physicsBody?.friction = 0.0
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = Constants.shapeCategory
        node.physicsBody?.collisionBitMask = Constants.edgeCategory

        return node
    }

    ///
    private func createPentagonNode(color: UIColor) -> SKShapeNode {
        let path = CGMutablePath()

        path.move(to: CGPoint(x: Constants.shapeSize.width / 2.0, y: Constants.shapeSize.height))
        path.addLine(to: CGPoint(x: Constants.shapeSize.width, y: Constants.shapeSize.height / 5.0 * 3.0))
        path.addLine(to: CGPoint(x: Constants.shapeSize.width / 5.0 * 4.0, y: 0))
        path.addLine(to: CGPoint(x: Constants.shapeSize.width / 5.0 * 1.0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: Constants.shapeSize.height / 5.0 * 3.0))

        let node = SKShapeNode(path: path, centered: true)
        node.fillColor = color
        node.lineJoin = .round
        node.lineWidth = 0.0
        node.name = Shape.pentagon.rawValue

        node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: node.frame.width, height: node.frame.height))
        node.physicsBody?.mass = 0.0069
        node.physicsBody?.linearDamping = 0.0
        node.physicsBody?.restitution = 1.0
        node.physicsBody?.friction = 0.0
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = Constants.shapeCategory
        node.physicsBody?.collisionBitMask = Constants.edgeCategory

        return node
    }

    ///
    private func createTargetNode() -> SKShapeNode {
        let node = SKShapeNode(rectOf: Constants.targetSize)

        node.fillColor = .systemGray2
        node.strokeColor = .systemGray4
        node.lineWidth = 2.0
        node.glowWidth = 2.0
        node.name = "Target"

        return node
    }
}
