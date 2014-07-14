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
        path.moveToPoint(CGPoint(x: lineWidth / 2, y: 0))
        path.addLineToPoint(CGPoint(x: width - lineWidth / 2, y: 0))

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

            let strokingPath = CGPathCreateCopyByStrokingPath(shapeLayer.path, nil, shapeLayer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, shapeLayer.miterLimit)
            // Otherwise bounds will be equal to CGRectZero.
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

    var showsMenu: Bool = true {
        didSet {
            // There's many animations so it's easier to set up duration and timing function at once.
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.4)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.swiftOut())

            let strokeStartNewValue = showsMenu ? 0.0 : 0.3
            let positionPathControlPointY = bottomYPosition / 2

            let topRotation = CAKeyframeAnimation(keyPath: "transform")
            topRotation.values = rotationValuesFromTransform(top.transform,
                endValue: showsMenu ? CGFloat(-M_PI - M_PI_4) : CGFloat(M_PI + M_PI_4))
            // Kind of a workaround. Used because it was hard to animate positions of segments' such that their ends form the arrow's tip.
            topRotation.calculationMode = kCAAnimationCubic
            topRotation.keyTimes = [0.0, 0.33, 0.73, 1.0];
            top.ahk_applyKeyframeValuesAnimation(topRotation)

            let topPosition = CAKeyframeAnimation(keyPath: "position")
            let topPositionEndPoint = CGPoint(x: width / 2, y: showsMenu ? topYPosition : bottomYPosition)
            topPosition.path = quadBezierCurveFrom(top.position,
                toPoint: topPositionEndPoint,
                controlPoint: CGPoint(x: width, y: positionPathControlPointY)).CGPath
            top.ahk_applyKeyframePathAnimation(topPosition, endValue: NSValue(CGPoint: topPositionEndPoint))

            let topStrokeStart = CABasicAnimation(keyPath: "strokeStart")
            topStrokeStart.toValue = strokeStartNewValue
            top.ahk_applyAnimation(topStrokeStart)


            let middleRotation = CAKeyframeAnimation(keyPath: "transform")
            middleRotation.values = rotationValuesFromTransform(middle.transform,
                endValue: showsMenu ? CGFloat(-M_PI) : CGFloat(M_PI))
            middle.ahk_applyKeyframeValuesAnimation(middleRotation)

            let middleStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
            middleStrokeEnd.toValue = showsMenu ? 1.0 : 0.85
            middle.ahk_applyAnimation(middleStrokeEnd)


            let bottomRotation = CAKeyframeAnimation(keyPath: "transform")
            bottomRotation.values = rotationValuesFromTransform(bottom.transform,
                endValue: showsMenu ? CGFloat(-M_PI_2 - M_PI_4) : CGFloat(M_PI_2 + M_PI_4))
            bottom.ahk_applyKeyframeValuesAnimation(bottomRotation)

            let bottomPosition = CAKeyframeAnimation(keyPath: "position")
            let bottomPositionEndPoint = CGPoint(x: width / 2, y: showsMenu ? bottomYPosition : topYPosition)
            bottomPosition.path = quadBezierCurveFrom(bottom.position,
                toPoint: bottomPositionEndPoint,
                controlPoint: CGPoint(x: 0, y: positionPathControlPointY)).CGPath
            bottom.ahk_applyKeyframePathAnimation(bottomPosition, endValue: NSValue(CGPoint: bottomPositionEndPoint))

            let bottomStrokeStart = CABasicAnimation(keyPath: "strokeStart")
            bottomStrokeStart.toValue = strokeStartNewValue
            bottom.ahk_applyAnimation(bottomStrokeStart)


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

    // TODO: endValue could be removed from the definition, because it's possible to get it from the path (see: CGPathApply).
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

func rotationValuesFromTransform(transform: CATransform3D, #endValue: CGFloat) -> [NSValue] {
    // values at 0, 1/3, 2/3 and 1
    return [NSValue(CATransform3D: transform),
        NSValue(CATransform3D: CATransform3DRotate(transform, endValue / 3, 0, 0, 1)),
        NSValue(CATransform3D: CATransform3DRotate(transform, endValue / 3 * 2, 0, 0, 1)),
        NSValue(CATransform3D: CATransform3DRotate(transform, endValue, 0, 0, 1))
    ]
}

func quadBezierCurveFrom(startPoint: CGPoint, #toPoint: CGPoint, #controlPoint: CGPoint) -> UIBezierPath {
    let quadPath = UIBezierPath()
    quadPath.moveToPoint(startPoint)
    quadPath.addQuadCurveToPoint(toPoint, controlPoint: controlPoint)
    return quadPath
}