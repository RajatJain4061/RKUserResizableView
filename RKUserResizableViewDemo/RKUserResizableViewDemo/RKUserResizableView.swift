//
//  RKUserResizableView.swift
//  RKUserResizableViewDemo
//
//  Created by Rajat Jain on 28/08/17.
//  Converted to Swift from https://github.com/spoletto/SPUserResizableView
//


import UIKit

struct RKUserResizableViewAnchorPoint {
    var adjustsX: CGFloat = 0.0
    var adjustsY: CGFloat = 0.0
    var adjustsH: CGFloat = 0.0
    var adjustsW: CGFloat = 0.0
}

struct RKUserResizableViewAnchorPointPair {
    var point: CGPoint = CGPoint.zero
    var anchorPoint: RKUserResizableViewAnchorPoint = RKUserResizableViewAnchorPoint()
}

protocol RKUserResizableViewDelegate: NSObjectProtocol {
    // Called when the resizable view receives touchesBegan: and activates the editing handles.
    func userResizableViewDidBeginEditing(_ userResizableView: RKUserResizableView)
    
    // Called when the resizable view receives touchesEnded: or touchesCancelled:
    func userResizableViewDidEndEditing(_ userResizableView: RKUserResizableView)
}


class RKUserResizableView:UIView {
    
    var borderView: GripViewBorderView?
    
    // Will be retained as a subview.
    var _contentView: UIView?
    
    var contentView:UIView? {
        set (newValue) {
            newValue?.removeFromSuperview()
            newValue?.frame = bounds.insetBy(dx: RKUserResizableViewGlobalInset + RKUserResizableViewInteractiveBorderSize / 2, dy: RKUserResizableViewGlobalInset + RKUserResizableViewInteractiveBorderSize / 2)
            addSubview(newValue!)
            // Ensure the border view is always on top by removing it and adding it to the end of the subview list.
            borderView?.removeFromSuperview()
            addSubview(borderView!)
            self._contentView = newValue
        }
        get {
            return self._contentView
        }
    }
    
    var touchStart = CGPoint.zero
    
    // Default is 48.0 for each.
    var minWidth: CGFloat = 48.0
    var minHeight: CGFloat = 48.0
    
    // Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.
    var anchorPoint = RKUserResizableViewAnchorPoint()
    
    weak var delegate: RKUserResizableViewDelegate?
    
    /* Let's inset everything that's drawn (the handles and the content view)
     so that users can trigger a resize from a few pixels outside of
     what they actually see as the bounding box. */
    let RKUserResizableViewGlobalInset:CGFloat = 5.0
    let RKUserResizableViewDefaultMinWidth:CGFloat = 48.0
    let RKUserResizableViewDefaultMinHeight:CGFloat = 48.0
    let RKUserResizableViewInteractiveBorderSize:CGFloat = 10.0
    
    // Defaults to YES. Disables the user from dragging the view outside the parent view's bounds.
    
    var isPreventsPositionOutsideSuperview: Bool = true
    
    private var RKUserResizableViewNoResizeAnchorPoint = RKUserResizableViewAnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: 0.0)
    private var RKUserResizableViewUpperLeftAnchorPoint = RKUserResizableViewAnchorPoint(adjustsX: 1.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: 1.0)
    private var RKUserResizableViewMiddleLeftAnchorPoint = RKUserResizableViewAnchorPoint(adjustsX: 1.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: 1.0)
    private var RKUserResizableViewLowerLeftAnchorPoint = RKUserResizableViewAnchorPoint(adjustsX: 1.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: 1.0)
    private var RKUserResizableViewUpperMiddleAnchorPoint = RKUserResizableViewAnchorPoint(adjustsX: 0.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: 0.0)
    private var RKUserResizableViewUpperRightAnchorPoint = RKUserResizableViewAnchorPoint(adjustsX: 0.0, adjustsY: 1.0, adjustsH: -1.0, adjustsW: -1.0)
    private var RKUserResizableViewMiddleRightAnchorPoint = RKUserResizableViewAnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 0.0, adjustsW: -1.0)
    private var RKUserResizableViewLowerRightAnchorPoint = RKUserResizableViewAnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: -1.0)
    private var RKUserResizableViewLowerMiddleAnchorPoint = RKUserResizableViewAnchorPoint(adjustsX: 0.0, adjustsY: 0.0, adjustsH: 1.0, adjustsW: 0.0)
    
    func setupDefaultAttributes() {
        borderView = GripViewBorderView(frame: bounds.insetBy(dx: CGFloat(RKUserResizableViewGlobalInset), dy: CGFloat(RKUserResizableViewGlobalInset)))
        borderView?.isHidden = true
        self.addSubview(borderView!)
        minWidth = RKUserResizableViewDefaultMinWidth
        minHeight = RKUserResizableViewDefaultMinHeight
        isPreventsPositionOutsideSuperview = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDefaultAttributes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDefaultAttributes()
    }
    
    func setViewFrame(_ newFrame: CGRect) {
        self.frame = newFrame
        contentView?.frame = bounds.insetBy(dx: RKUserResizableViewGlobalInset + RKUserResizableViewInteractiveBorderSize / 2, dy: RKUserResizableViewGlobalInset + RKUserResizableViewInteractiveBorderSize / 2)
        borderView?.frame = bounds.insetBy(dx: RKUserResizableViewGlobalInset, dy: RKUserResizableViewGlobalInset)
        borderView?.setNeedsDisplay()
        
    }
    
    private func distanceBetweenTwoPoints(point1: CGPoint, point2: CGPoint) -> CGFloat {
        let dx: CGFloat = point2.x - point1.x
        let dy: CGFloat = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func anchorPoint(forTouchLocation touchPoint: CGPoint) -> RKUserResizableViewAnchorPoint {
        // (1) Calculate the positions of each of the anchor points.
        let upperLeft = RKUserResizableViewAnchorPointPair(point: CGPoint(x: 0.0, y: 0.0), anchorPoint: RKUserResizableViewUpperLeftAnchorPoint)
        
        let upperMiddle = RKUserResizableViewAnchorPointPair(point: CGPoint(x: bounds.size.width / 2, y: 0.0), anchorPoint: RKUserResizableViewUpperMiddleAnchorPoint)
        
        let upperRight = RKUserResizableViewAnchorPointPair(point: CGPoint(x: bounds.size.width, y: 0.0), anchorPoint: RKUserResizableViewUpperRightAnchorPoint)
        
        let middleRight = RKUserResizableViewAnchorPointPair(point: CGPoint(x: bounds.size.width, y: bounds.size.height / 2), anchorPoint: RKUserResizableViewMiddleRightAnchorPoint)
        
        let lowerRight = RKUserResizableViewAnchorPointPair(point: CGPoint(x: bounds.size.width, y: bounds.size.height), anchorPoint: RKUserResizableViewLowerRightAnchorPoint)
        
        let lowerMiddle = RKUserResizableViewAnchorPointPair(point: CGPoint(x: bounds.size.width / 2, y: bounds.size.height), anchorPoint: RKUserResizableViewLowerMiddleAnchorPoint)
        
        let lowerLeft = RKUserResizableViewAnchorPointPair(point: CGPoint(x: 0, y: bounds.size.height), anchorPoint: RKUserResizableViewLowerLeftAnchorPoint)
        
        let middleLeft = RKUserResizableViewAnchorPointPair(point: CGPoint(x: 0, y: bounds.size.height / 2), anchorPoint: RKUserResizableViewMiddleLeftAnchorPoint)
        
        let centerPoint = RKUserResizableViewAnchorPointPair(point: CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2), anchorPoint: RKUserResizableViewNoResizeAnchorPoint)
        
        // (2) Iterate over each of the anchor points and find the one closest to the user's touch.
        let allPoints: [RKUserResizableViewAnchorPointPair] = [upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight, centerPoint]
        var smallestDistance: CGFloat = CGFloat(MAXFLOAT)
        var closestPoint: RKUserResizableViewAnchorPointPair = centerPoint
        for i in 0..<9 {
            let distance: CGFloat = distanceBetweenTwoPoints(point1: touchPoint, point2: allPoints[i].point)
            if distance < smallestDistance {
                closestPoint = allPoints[i]
                smallestDistance = distance
            }
        }
        return closestPoint.anchorPoint
    }
    
    func isResizing() -> Bool {
        return (anchorPoint.adjustsH != 0 || anchorPoint.adjustsW != 0 || anchorPoint.adjustsX != 0 || anchorPoint.adjustsY != 0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Notify the delegate we've begun our editing session.
        //        if delegate?.responds(to: #selector(self.userResizableViewDidBeginEditing)) {
        delegate?.userResizableViewDidBeginEditing(self)
        //        }
        borderView?.isHidden = false
        
        if let touch = touches.first {
            anchorPoint = anchorPoint(forTouchLocation: touch.location(in: self))
            print(anchorPoint)
            // When resizing, all calculations are done in the superview's coordinate space.
            touchStart = touch.location(in: superview)
            if !isResizing() {
                // When translating, all calculations are done in the view's coordinate space.
                touchStart = touch.location(in: self)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Notify the delegate we've ended our editing session.
        delegate?.userResizableViewDidEndEditing(self)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Notify the delegate we've ended our editing session.
        delegate?.userResizableViewDidEndEditing(self)
    }
    
    func showEditingHandles() {
        borderView?.isHidden = false
    }
    
    func hideEditingHandles() {
        borderView?.isHidden = true
    }
    
    func resize(usingTouchLocation touchPoint: CGPoint) {
        // (1) Update the touch point if we're outside the superview.
        /* disabled by rajat jain on 2017-08-28
         if isPreventsPositionOutsideSuperview {
         let border: CGFloat = RKUserResizableViewGlobalInset + RKUserResizableViewInteractiveBorderSize / 2
         if touchPoint.x < border {
         touchPoint.x = border
         }
         if touchPoint.x > superview?.bounds.size.width - border {
         touchPoint.x = superview?.bounds.size.width - border
         }
         if touchPoint.y < border {
         touchPoint.y = border
         }
         if touchPoint.y > superview?.bounds.size.height - border {
         touchPoint.y = superview?.bounds.size.height - border
         }
         }
         */
        // (2) Calculate the deltas using the current anchor point.
        var deltaW: CGFloat = anchorPoint.adjustsW * (touchStart.x - touchPoint.x)
        let deltaX: CGFloat = anchorPoint.adjustsX * (-1.0 * deltaW)
        var deltaH: CGFloat = anchorPoint.adjustsH * (touchPoint.y - touchStart.y)
        let deltaY: CGFloat = anchorPoint.adjustsY * (-1.0 * deltaH)
        // (3) Calculate the new frame.
        var newX: CGFloat = frame.origin.x + deltaX
        var newY: CGFloat = frame.origin.y + deltaY
        var newWidth: CGFloat = frame.size.width + deltaW
        var newHeight: CGFloat = frame.size.height + deltaH
        // (4) If the new frame is too small, cancel the changes.
        if newWidth < minWidth {
            newWidth = frame.size.width
            newX = frame.origin.x
        }
        if newHeight < minHeight {
            newHeight = frame.size.height
            newY = frame.origin.y
        }
        
        // (5) Ensure the resize won't cause the view to move offscreen.
        if isPreventsPositionOutsideSuperview {
            if let superView = self.superview {
                if newX < superView.bounds.origin.x {
                    // Calculate how much to grow the width by such that the new X coordintae will align with the superview.
                    deltaW = self.frame.origin.x - superView.bounds.origin.x
                    newWidth = self.frame.size.width + deltaW
                    newX = superView.bounds.origin.x
                }
                
                if newX + newWidth > superView.bounds.origin.x + superView.bounds.size.width {
                    newWidth = superView.bounds.size.width - newX
                }
                
                if newY < superView.bounds.origin.y {
                    // Calculate how much to grow the height by such that the new Y coordintae will align with the superview.
                    deltaH = self.frame.origin.y - superView.bounds.origin.y
                    newHeight = self.frame.size.height + deltaH
                    newY = superView.bounds.origin.y
                }
                
                if newY + newHeight > superView.bounds.origin.y + superView.bounds.size.height {
                    newHeight = superView.bounds.size.height - newY
                }
                
            }
        }
        
        self.setViewFrame(CGRect(x: newX, y: newY, width: newWidth, height: newHeight))
        
        touchStart = touchPoint
    }
    
    func translate(usingTouchLocation touchPoint: CGPoint) {
        var newCenter = CGPoint(x: center.x + touchPoint.x - touchStart.x, y: center.y + touchPoint.y - touchStart.y)
        if isPreventsPositionOutsideSuperview {
            if let superView = self.superview {
                
                // Ensure the translation won't cause the view to move offscreen.
                let midPointX: CGFloat = bounds.midX
                if newCenter.x > superView.bounds.size.width - midPointX {
                    newCenter.x = superView.bounds.size.width - midPointX
                }
                if newCenter.x < midPointX {
                    newCenter.x = midPointX
                }
                let midPointY: CGFloat = bounds.midY
                if newCenter.y > superView.bounds.size.height - midPointY {
                    newCenter.y = superView.bounds.size.height - midPointY
                }
                if newCenter.y < midPointY {
                    newCenter.y = midPointY
                }
            }
        }
        center = newCenter
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isResizing() {
            if let superView = self.superview {
                resize(usingTouchLocation: (touches.first?.location(in: superView))!)
            }
        }
        else {
            translate(usingTouchLocation: (touches.first?.location(in: self))!)
        }
    }
    
    deinit {
        contentView?.removeFromSuperview()
    }
}


class GripViewBorderView: UIView {
    
    let RKUserResizableViewGlobalInset:CGFloat = 5.0
    let RKUserResizableViewDefaultMinWidth:CGFloat = 48.0
    let RKUserResizableViewDefaultMinHeight:CGFloat = 48.0
    let RKUserResizableViewInteractiveBorderSize:CGFloat = 10.0
    
    weak var delegate: RKUserResizableViewDelegate?
    // Will be retained as a subview.
    var contentView: UIView?
    // Default is 48.0 for each.
    var minWidth: CGFloat = 0.0
    var minHeight: CGFloat = 0.0
    // Defaults to YES. Disables the user from dragging the view outside the parent view's bounds.
    var isPreventsPositionOutsideSuperview: Bool = false
    
    var borderView: GripViewBorderView?
    var touchStart = CGPoint.zero
    // Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.
    var anchorPoint = RKUserResizableViewAnchorPoint()
    
    func hideEditingHandles() {
    }
    
    func showEditingHandles() {
    }
    
    override init(frame: CGRect) {
        // Clear background to ensure the content view shows through.
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context: CGContext? = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        // (1) Draw the bounding box.
        context?.setLineWidth(1.0)
        context?.setStrokeColor(UIColor.blue.cgColor)
        context?.addRect(bounds.insetBy(dx: RKUserResizableViewInteractiveBorderSize / 2, dy: RKUserResizableViewInteractiveBorderSize / 2))
        context?.strokePath()
        
        // (2) Calculate the bounding boxes for each of the anchor points.
        let upperLeft = CGRect(x: 0.0, y: 0.0, width: RKUserResizableViewInteractiveBorderSize, height: RKUserResizableViewInteractiveBorderSize)
        let upperRight = CGRect(x: bounds.size.width - RKUserResizableViewInteractiveBorderSize, y: 0.0, width: RKUserResizableViewInteractiveBorderSize, height: RKUserResizableViewInteractiveBorderSize)
        let lowerRight = CGRect(x: bounds.size.width - RKUserResizableViewInteractiveBorderSize, y: bounds.size.height - RKUserResizableViewInteractiveBorderSize, width: RKUserResizableViewInteractiveBorderSize, height: RKUserResizableViewInteractiveBorderSize)
        let lowerLeft = CGRect(x: 0.0, y: bounds.size.height - RKUserResizableViewInteractiveBorderSize, width: RKUserResizableViewInteractiveBorderSize, height: RKUserResizableViewInteractiveBorderSize)
        let upperMiddle = CGRect(x: (bounds.size.width - RKUserResizableViewInteractiveBorderSize) / 2, y: 0.0, width: RKUserResizableViewInteractiveBorderSize, height: RKUserResizableViewInteractiveBorderSize)
        let lowerMiddle = CGRect(x: (bounds.size.width - RKUserResizableViewInteractiveBorderSize) / 2, y: bounds.size.height - RKUserResizableViewInteractiveBorderSize, width: RKUserResizableViewInteractiveBorderSize, height: RKUserResizableViewInteractiveBorderSize)
        let middleLeft = CGRect(x: 0.0, y: (bounds.size.height - RKUserResizableViewInteractiveBorderSize) / 2, width: RKUserResizableViewInteractiveBorderSize, height: RKUserResizableViewInteractiveBorderSize)
        let middleRight = CGRect(x: bounds.size.width - RKUserResizableViewInteractiveBorderSize, y: (bounds.size.height - RKUserResizableViewInteractiveBorderSize) / 2, width: RKUserResizableViewInteractiveBorderSize, height: RKUserResizableViewInteractiveBorderSize)
        
        // (3) Create the gradient to paint the anchor points.
        let colors: [CGFloat] = [0.4, 0.8, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0]
        let baseSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        let gradient: CGGradient = CGGradient(colorSpace: baseSpace!, colorComponents: colors, locations: nil, count: 2)!
        
        // (4) Set up the stroke for drawing the border of each of the anchor points.
        context?.setLineWidth(2)
        context!.setShadow(offset: CGSize(width: 0.5, height: 0.5), blur: 1)
        context?.setStrokeColor(UIColor.white.cgColor)
        
        // (5) Fill each anchor point using the gradient, then stroke the border.
        let allPoints: [CGRect] = [upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight]
        for i in 0..<8 {
            let currPoint: CGRect = allPoints[i]
            context?.saveGState()
            //context?.addEllipse(in: currPoint)
            let currentPoint = CGRect(x: currPoint.origin.x, y: currPoint.origin.y, width: 10, height: 10);
            context?.addEllipse(in: currentPoint)
            context?.clip()
            let startPoint = CGPoint(x: currentPoint.midX, y: currentPoint.minY)
            let endPoint = CGPoint(x: currentPoint.midX, y: currentPoint.maxY)
            context?.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
            context?.restoreGState()
            context?.strokeEllipse(in: currentPoint.insetBy(dx: 1, dy: 1))
        }
        context?.restoreGState()
    }
}

