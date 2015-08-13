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

public class HamburgerButton: UIButton {

    public var color: UIColor = UIColor.whiteColor() {
    didSet {
        for shapeLayer in shapeLayers {
            shapeLayer.strokeColor = color.CGColor
        }
    }
    }

    private let top: CAShapeLayer = CAShapeLayer()
    private let middle: CAShapeLayer = CAShapeLayer()
    private let bottom: CAShapeLayer = CAShapeLayer()
    private let width: CGFloat = 18
    private let height: CGFloat = 16
    private let topYPosition: CGFloat = 2
    private let middleYPosition: CGFloat = 7
    private let bottomYPosition: CGFloat = 12

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0))
        path.addLineToPoint(CGPoint(x: width, y: 0))

        for shapeLayer in shapeLayers {
            shapeLayer.path = path.CGPath
            shapeLayer.lineWidth = 2
            shapeLayer.strokeColor = color.CGColor

            // Disables implicit animations.
            shapeLayer.actions = [
                "transform": NSNull(),
                "position": NSNull()
            ]

            let strokingPath = CGPathCreateCopyByStrokingPath(shapeLayer.path, nil, shapeLayer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, shapeLayer.miterLimit)
            // Otherwise bounds will be equal to CGRectZero.
            shapeLayer.bounds = CGPathGetPathBoundingBox(strokingPath)

            layer.addSublayer(shapeLayer)
        }

        let widthMiddle = width / 2
        top.position = CGPoint(x: widthMiddle, y: topYPosition)
        middle.position = CGPoint(x: widthMiddle, y: middleYPosition)
        bottom.position = CGPoint(x: widthMiddle, y: bottomYPosition)
    }

    override public func intrinsicContentSize() -> CGSize {
        return CGSize(width: width, height: height)
    }

    public var showsMenu: Bool = true {
        didSet {
            // There's many animations so it's easier to set up duration and timing function at once.
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.4)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.4, 0.0, 0.2, 1.0))

            let strokeStartNewValue: CGFloat = showsMenu ? 0.0 : 0.3
            let positionPathControlPointY = bottomYPosition / 2
            let verticalOffsetInRotatedState: CGFloat = 0.75


            let topRotation = CAKeyframeAnimation(keyPath: "transform")
            topRotation.values = rotationValuesFromTransform(top.transform,
                endValue: showsMenu ? CGFloat(-M_PI - M_PI_4) : CGFloat(M_PI + M_PI_4))
            // Kind of a workaround. Used because it was hard to animate positions of segments' such that their ends form the arrow's tip and don't cross each other.
            topRotation.calculationMode = kCAAnimationCubic
            topRotation.keyTimes = [0.0, 0.33, 0.73, 1.0]
            top.ahk_applyKeyframeValuesAnimation(topRotation)

            let topPosition = CAKeyframeAnimation(keyPath: "position")
            let topPositionEndPoint = CGPoint(x: width / 2, y: showsMenu ? topYPosition : bottomYPosition + verticalOffsetInRotatedState)
            topPosition.path = quadBezierCurveFromPoint(top.position,
                toPoint: topPositionEndPoint,
                controlPoint: CGPoint(x: width, y: positionPathControlPointY)).CGPath
            top.ahk_applyKeyframePathAnimation(topPosition, endValue: NSValue(CGPoint: topPositionEndPoint))

            top.strokeStart = strokeStartNewValue


            let middleRotation = CAKeyframeAnimation(keyPath: "transform")
            middleRotation.values = rotationValuesFromTransform(middle.transform,
                endValue: showsMenu ? CGFloat(-M_PI) : CGFloat(M_PI))
            middle.ahk_applyKeyframeValuesAnimation(middleRotation)

            middle.strokeEnd = showsMenu ? 1.0 : 0.85


            let bottomRotation = CAKeyframeAnimation(keyPath: "transform")
            bottomRotation.values = rotationValuesFromTransform(bottom.transform,
                endValue: showsMenu ? CGFloat(-M_PI_2 - M_PI_4) : CGFloat(M_PI_2 + M_PI_4))
            bottomRotation.calculationMode = kCAAnimationCubic
            bottomRotation.keyTimes = [0.0, 0.33, 0.63, 1.0]
            bottom.ahk_applyKeyframeValuesAnimation(bottomRotation)

            let bottomPosition = CAKeyframeAnimation(keyPath: "position")
            let bottomPositionEndPoint = CGPoint(x: width / 2, y: showsMenu ? bottomYPosition : topYPosition - verticalOffsetInRotatedState)
            bottomPosition.path = quadBezierCurveFromPoint(bottom.position,
                toPoint: bottomPositionEndPoint,
                controlPoint: CGPoint(x: 0, y: positionPathControlPointY)).CGPath
            bottom.ahk_applyKeyframePathAnimation(bottomPosition, endValue: NSValue(CGPoint: bottomPositionEndPoint))

            bottom.strokeStart = strokeStartNewValue


            CATransaction.commit()
        }
    }

    private var shapeLayers: [CAShapeLayer] {
        return [top, middle, bottom]
    }
}

extension CALayer {
    func ahk_applyKeyframeValuesAnimation(animation: CAKeyframeAnimation) {
        let copy = animation.copy() as! CAKeyframeAnimation

        assert(!copy.values.isEmpty)

        self.addAnimation(copy, forKey: copy.keyPath)
        self.setValue(copy.values[copy.values.count - 1], forKeyPath:copy.keyPath)
    }

    // Mark: TODO: endValue could be removed from the definition, because it's possible to get it from the path (see: CGPathApply).
    func ahk_applyKeyframePathAnimation(animation: CAKeyframeAnimation, endValue: NSValue) {
        let copy = animation.copy() as! CAKeyframeAnimation

        self.addAnimation(copy, forKey: copy.keyPath)
        self.setValue(endValue, forKeyPath:copy.keyPath)
    }
}

func rotationValuesFromTransform(transform: CATransform3D, #endValue: CGFloat) -> [NSValue] {
    let frames = 4

    // values at 0, 1/3, 2/3 and 1
    return (0..<frames).map { num in
        NSValue(CATransform3D: CATransform3DRotate(transform, endValue / CGFloat(frames - 1) * CGFloat(num), 0, 0, 1))
    }
}

func quadBezierCurveFromPoint(startPoint: CGPoint, #toPoint: CGPoint, #controlPoint: CGPoint) -> UIBezierPath {
    let quadPath = UIBezierPath()
    quadPath.moveToPoint(startPoint)
    quadPath.addQuadCurveToPoint(toPoint, controlPoint: controlPoint)
    return quadPath
}