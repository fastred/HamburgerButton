//
//  HamburgerButton.swift
//  HamburgerButton
//
//  Created by Arkadiusz on 14-07-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

import CoreGraphics
import QuartzCore
import UIKit

class HamburgerButton: UIButton {

    let top: CAShapeLayer! = CAShapeLayer()
    let middle: CAShapeLayer! = CAShapeLayer()
    let bottom: CAShapeLayer! = CAShapeLayer()
    let width: Float = 18
    let height: Float = 16
    let topYPosition: Float = 2
    let middleYPosition: Float = 7
    let bottomYPosition: Float = 12

    init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        commonInit()
    }

    func commonInit() {
        let lineWidth: Float = 2
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: lineWidth/2, y: 0))
        path.addLineToPoint(CGPoint(x: width - lineWidth/2, y: 0))

        for shapeLayer in [top, middle, bottom] {
            shapeLayer.path = path.CGPath
            shapeLayer.lineWidth = 2
            shapeLayer.strokeColor = UIColor.whiteColor().CGColor

            // Disables implicit animations.
            shapeLayer.actions = [
                "strokeStart": NSNull(),
                "strokeEnd": NSNull(),
                "transform": NSNull(),
                "position": NSNull()
            ]

            let strokingPath = CGPathCreateCopyByStrokingPath(shapeLayer.path, nil, 2, kCGLineCapButt, kCGLineJoinMiter, 10)

            shapeLayer.bounds = CGPathGetPathBoundingBox(strokingPath)
            layer.addSublayer(shapeLayer)
        }

        top.position = CGPoint(x: width / 2, y: topYPosition)
        middle.position = CGPoint(x: width / 2, y: middleYPosition)
        bottom.position = CGPoint(x: width / 2, y: bottomYPosition)
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: width, height: height)
    }

    var showsBack: Bool = false {
        didSet {
            // There's many animations so it's easier to set up duration and timing function at once.
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.42)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.swiftOut())

            let middleRotation = CAKeyframeAnimation(keyPath: "transform")

            let middleTarget: CGFloat = showsBack ? CGFloat(M_PI) : CGFloat(-M_PI)

            middleRotation.values = [NSValue(CATransform3D: middle.transform),
                NSValue(CATransform3D: CATransform3DRotate(middle.transform, middleTarget / 2, 0, 0, 1)),
                NSValue(CATransform3D: CATransform3DRotate(middle.transform, middleTarget, 0, 0, 1))
            ]
            middle.ahk_applyKeyframeValuesAnimation(middleRotation)

            let wholeTopRotation: CGFloat = showsBack ? CGFloat(M_PI + M_PI_4) : CGFloat(-M_PI - M_PI_4)

            let topRotation = CAKeyframeAnimation(keyPath: "transform")
            topRotation.values = [NSValue(CATransform3D: top.transform),
                NSValue(CATransform3D: CATransform3DRotate(top.transform, wholeTopRotation / 3, 0, 0, 1)),
            NSValue(CATransform3D: CATransform3DRotate(top.transform, wholeTopRotation / 3 * 2, 0, 0, 1)),
            NSValue(CATransform3D: CATransform3DRotate(top.transform, wholeTopRotation, 0, 0, 1))
            ]

            // Used because it was hard to animate position of segments' such that their ends form the arrow's tip.
            topRotation.calculationMode = kCAAnimationCubic
            topRotation.keyTimes = [0.0, 0.33, 0.73, 1.0];

            top.ahk_applyKeyframeValuesAnimation(topRotation)

            let endPosition = CGPoint(x: width / 2, y: showsBack ? bottomYPosition : topYPosition)
            let halfCirclePath = UIBezierPath()
            halfCirclePath.moveToPoint(top.position)
            halfCirclePath.addQuadCurveToPoint(endPosition, controlPoint: CGPoint(x: width, y: middleYPosition - 1))

            let topPosition = CAKeyframeAnimation(keyPath: "position")
            topPosition.path = halfCirclePath.CGPath
            top.ahk_applyKeyframePathAnimation(topPosition, endValue: NSValue(CGPoint: endPosition))


            let topStrokeStart = CABasicAnimation(keyPath: "strokeStart")
            topStrokeStart.toValue = showsBack ? 0.3 : 0.0
            top.ahk_applyAnimation(topStrokeStart)


            let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
            strokeEnd.toValue = showsBack ? 0.85 : 1.0
            middle.ahk_applyAnimation(strokeEnd)


            let wholeBottomRotation: CGFloat = showsBack ? CGFloat(M_PI_2 + M_PI_4) : CGFloat(-M_PI_2 - M_PI_4)

            let bottomRotation = CAKeyframeAnimation(keyPath: "transform")
            bottomRotation.values = [NSValue(CATransform3D: bottom.transform),
                NSValue(CATransform3D: CATransform3DRotate(bottom.transform, wholeBottomRotation / 3, 0, 0, 1)),
                NSValue(CATransform3D: CATransform3DRotate(bottom.transform, wholeBottomRotation / 3 * 2, 0, 0, 1)),
                NSValue(CATransform3D: CATransform3DRotate(bottom.transform, wholeBottomRotation, 0, 0, 1))]
            bottom.ahk_applyKeyframeValuesAnimation(bottomRotation)

            let bottomStrokeStart = CABasicAnimation(keyPath: "strokeStart")
            bottomStrokeStart.toValue = showsBack ? 0.3 : 0.0
            bottom.ahk_applyAnimation(bottomStrokeStart)

            let bottomEndPosition = CGPoint(x: width / 2, y: showsBack ? topYPosition : bottomYPosition)
            let bottomCirclePath = UIBezierPath()
            bottomCirclePath.moveToPoint(bottom.position)
            bottomCirclePath.addQuadCurveToPoint(bottomEndPosition, controlPoint: CGPoint(x: 0, y: middleYPosition - 1))

            let bottomPosition = CAKeyframeAnimation(keyPath: "position")
            bottomPosition.path = bottomCirclePath.CGPath
            bottom.ahk_applyKeyframePathAnimation(bottomPosition, endValue: NSValue(CGPoint: bottomEndPosition))

            CATransaction.commit()
        }
    }
}

extension CALayer {
    func ahk_applyAnimation(animation: CABasicAnimation) {
        let copy = animation.copy() as CABasicAnimation
        if !copy.fromValue {
            copy.fromValue = self.presentationLayer().valueForKeyPath(copy.keyPath)
        }

        self.addAnimation(copy, forKey: copy.keyPath)
        self.setValue(copy.toValue, forKeyPath:copy.keyPath)
    }

    func ahk_applyKeyframeValuesAnimation(animation: CAKeyframeAnimation) {
        let copy = animation.copy() as CAKeyframeAnimation

        assert(!copy.values.isEmpty)

        self.addAnimation(copy, forKey: copy.keyPath)
        self.setValue(copy.values[copy.values.count - 1], forKeyPath:copy.keyPath)
    }

    func ahk_applyKeyframePathAnimation(animation: CAKeyframeAnimation, endValue: NSValue) {
        let copy = animation.copy() as CAKeyframeAnimation

        self.addAnimation(copy, forKey: copy.keyPath)
        self.setValue(endValue, forKeyPath:copy.keyPath)
    }
}

extension CAMediaTimingFunction {
    class func swiftOut() -> CAMediaTimingFunction {
        return CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0)
    }
}
