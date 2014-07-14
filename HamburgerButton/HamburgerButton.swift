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

    init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 1, y: 0))
        path.addLineToPoint(CGPoint(x: width - 1, y: 0))

        for shapeLayer in [top, middle, bottom] {
            shapeLayer.path = path.CGPath
            shapeLayer.lineWidth = 2
            shapeLayer.strokeColor = UIColor.whiteColor().CGColor
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

        top.position = CGPoint(x: width / 2, y: 2)
        middle.position = CGPoint(x: width / 2, y: 7)
        bottom.position = CGPoint(x: width / 2, y: 12)
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: width, height: height)
    }

    var showsBack: Bool = false {
        didSet {
            let duration = 0.42

            let middleRotation = CAKeyframeAnimation(keyPath: "transform")

            let middleTarget: CGFloat = showsBack ? CGFloat(M_PI) : CGFloat(-M_PI)

            middleRotation.values = [NSValue(CATransform3D: middle.transform),
                NSValue(CATransform3D: CATransform3DRotate(middle.transform, middleTarget / 2, 0, 0, 1)),
                NSValue(CATransform3D: CATransform3DRotate(middle.transform, middleTarget, 0, 0, 1))
            ]

            middleRotation.timingFunction = CAMediaTimingFunction.swiftOut()
            middleRotation.duration = duration
            middle.ahk_applyKeyframeValuesAnimation(middleRotation)

            let wholeTopRotation: CGFloat = showsBack ? CGFloat(M_PI + M_PI_4) : CGFloat(-M_PI - M_PI_4)

            let topRotation = CAKeyframeAnimation(keyPath: "transform")
            topRotation.values = [NSValue(CATransform3D: top.transform),
                NSValue(CATransform3D: CATransform3DRotate(top.transform, wholeTopRotation / 3, 0, 0, 1)),
            NSValue(CATransform3D: CATransform3DRotate(top.transform, wholeTopRotation / 3 * 2, 0, 0, 1)),
            NSValue(CATransform3D: CATransform3DRotate(top.transform, wholeTopRotation, 0, 0, 1))
            ]
            topRotation.calculationMode = kCAAnimationCubic
            topRotation.keyTimes = [0.0, 0.33, 0.73, 1.0];

            topRotation.duration = duration
            topRotation.timingFunction = CAMediaTimingFunction.swiftOut()

            top.ahk_applyKeyframeValuesAnimation(topRotation)

            let endPosition = showsBack ? CGPoint(x: width / 2, y: 12) : CGPoint(x: width / 2, y: 2)
            let halfCirclePath = UIBezierPath()
            halfCirclePath.moveToPoint(top.position)
            halfCirclePath.addQuadCurveToPoint(endPosition, controlPoint: CGPoint(x: width, y: 6))

            let topPosition = CAKeyframeAnimation(keyPath: "position")
            topPosition.path = halfCirclePath.CGPath
            topPosition.duration = duration
            topPosition.timingFunction = CAMediaTimingFunction.swiftOut()
            top.ahk_applyKeyframePathAnimation(topPosition, endValue: NSValue(CGPoint: endPosition))


            let topStrokeStart = CABasicAnimation(keyPath: "strokeStart")
            topStrokeStart.toValue = showsBack ? 0.3 : 0.0
            topStrokeStart.duration = duration
            topStrokeStart.timingFunction = CAMediaTimingFunction.swiftOut()
            top.ahk_applyAnimation(topStrokeStart)


            let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
            strokeEnd.toValue = showsBack ? 0.85 : 1.0
            strokeEnd.duration = duration
            strokeEnd.timingFunction = CAMediaTimingFunction.swiftOut()
            middle.ahk_applyAnimation(strokeEnd)


            let wholeBottomRotation: CGFloat = showsBack ? CGFloat(M_PI_2 + M_PI_4) : CGFloat(-M_PI_2 - M_PI_4)

            let bottomRotation = CAKeyframeAnimation(keyPath: "transform")
            bottomRotation.values = [NSValue(CATransform3D: bottom.transform),
                NSValue(CATransform3D: CATransform3DRotate(bottom.transform, wholeBottomRotation / 3, 0, 0, 1)),
                NSValue(CATransform3D: CATransform3DRotate(bottom.transform, wholeBottomRotation / 3 * 2, 0, 0, 1)),
                NSValue(CATransform3D: CATransform3DRotate(bottom.transform, wholeBottomRotation, 0, 0, 1))]
            bottomRotation.duration = duration
            bottomRotation.timingFunction = CAMediaTimingFunction.swiftOut()
            bottom.ahk_applyKeyframeValuesAnimation(bottomRotation)

            let bottomStrokeStart = CABasicAnimation(keyPath: "strokeStart")
            bottomStrokeStart.toValue = showsBack ? 0.3 : 0.0
            bottomStrokeStart.duration = duration
            bottomStrokeStart.timingFunction = CAMediaTimingFunction.swiftOut()
            bottom.ahk_applyAnimation(bottomStrokeStart)

            let bottomEndPosition = showsBack ? CGPoint(x: width / 2, y: 2) : CGPoint(x: width / 2, y: 12)
            let bottomCirclePath = UIBezierPath()
            bottomCirclePath.moveToPoint(bottom.position)
            bottomCirclePath.addQuadCurveToPoint(bottomEndPosition, controlPoint: CGPoint(x: 0, y: 6))

            let bottomPosition = CAKeyframeAnimation(keyPath: "position")
            bottomPosition.path = bottomCirclePath.CGPath
            bottomPosition.duration = duration
            bottomPosition.timingFunction = CAMediaTimingFunction.swiftOut()
            bottom.ahk_applyKeyframePathAnimation(bottomPosition, endValue: NSValue(CGPoint: bottomEndPosition))
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
