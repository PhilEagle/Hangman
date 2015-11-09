//
//  PESmallNotifier.swift
//  Swift Hangman
//
//  Created by philippe eggel on 09/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import UIKit

class PESmallNotifier: UIView {
    var title: String {
        didSet {
            txtLabel.text = title
        }
    }
    private var txtLabel: UILabel
    
    init(title: String) {
        self.title = title
        self.txtLabel = UILabel()
        
        let screenFrame = UIScreen.mainScreen().bounds
        super.init(frame: CGRectMake(0, screenFrame.size.height, screenFrame.size.width, 40))
        
        txtLabel.frame = CGRectMake(8, 12, frame.size.width, 20)
        txtLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        txtLabel.backgroundColor = UIColor.clearColor()
        txtLabel.textColor = UIColor.whiteColor()
        
        txtLabel.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        txtLabel.layer.shadowColor = UIColor.blackColor().CGColor
        txtLabel.layer.shadowOpacity = 1
        txtLabel.layer.shadowRadius = 1
        txtLabel.layer.masksToBounds = false
        
        addSubview(txtLabel)
        
        //UIApplication.sharedApplication().delegate?.window??.window?.addSubview(self)
        
        // ajout de la vue à la hierarchie
        UIApplication.sharedApplication().keyWindow?.subviews[0].addSubview(self)

    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        //Background color
        let rectangle = CGRectMake(0, 4, 320, 36)
        CGContextAddRect(context, rectangle)
        CGContextSetFillColorWithColor(context, UIColor(red: 0, green: 0, blue: 0, alpha: 0).CGColor)
        CGContextFillRect(context, rectangle)
        
        
        //First whiteColor
        CGContextSetLineWidth(context, 1.0)
        let componentsWhiteLine: [CGFloat] = [1.0, 1.0, 1.0, 0.35]
        let Whitecolor = CGColorCreate(colorspace, componentsWhiteLine)
        CGContextSetStrokeColorWithColor(context, Whitecolor)
        
        CGContextMoveToPoint(context, 0, 4.5)
        CGContextAddLineToPoint(context, 320, 4.5)
        
        CGContextStrokePath(context)
        
        
        //First whiteColor
        CGContextSetLineWidth(context, 1.0)
        let componentsBlackLine: [CGFloat] = [0.0, 0.0, 0.0, 1.0]
        let Blackcolor = CGColorCreate(colorspace, componentsBlackLine);
        CGContextSetStrokeColorWithColor(context, Blackcolor);
        
        CGContextMoveToPoint(context, 0, 3.5);
        CGContextAddLineToPoint(context, 320, 3.5);
        
        CGContextStrokePath(context);
        
        //Draw Shadow
        let imageBounds = CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, 3)
        let bounds = CGRectMake(0, 0, 320, 3);
        
        let resolution: CGFloat = 0.5 * (bounds.size.width / imageBounds.size.width + bounds.size.height / imageBounds.size.height)
        
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, bounds.origin.x, bounds.origin.y);
        CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
        
        // Layer 1
        let alignStroke: CGFloat = 0
        let path = CGPathCreateMutable()
        var drawRect = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 3)
        drawRect.origin.x = (round(resolution * drawRect.origin.x + alignStroke) - alignStroke) / resolution
        drawRect.origin.y = (round(resolution * drawRect.origin.y + alignStroke) - alignStroke) / resolution;
        drawRect.size.width = round(resolution * drawRect.size.width) / resolution;
        drawRect.size.height = round(resolution * drawRect.size.height) / resolution;
        CGPathAddRect(path, nil, drawRect)
        
        let colors: CFArray = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).CGColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.18).CGColor
        ]
        let locations: [CGFloat] = [0, 1]
        let space = CGColorSpaceCreateDeviceRGB();
        let gradient = CGGradientCreateWithColors(space, colors, locations)
        
        CGContextAddPath(context, path)
        CGContextSaveGState(context)
        CGContextEOClip(context)
        transform = CGAffineTransformMakeRotation(-1.571)
        
        let tempPath = CGPathCreateMutable();
        CGPathAddPath(tempPath, &transform, path);
        let pathBounds = CGPathGetPathBoundingBox(tempPath);
        var point = pathBounds.origin;
        var point2 = CGPointMake(CGRectGetMaxX(pathBounds), CGRectGetMinY(pathBounds));
        transform = CGAffineTransformInvert(transform);
        point = CGPointApplyAffineTransform(point, transform);
        point2 = CGPointApplyAffineTransform(point2, transform);

        CGContextDrawLinearGradient(
            context,
            gradient,
            point,
            point2,
            [.DrawsBeforeStartLocation, .DrawsAfterEndLocation])
            
        CGContextRestoreGState(context);
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(title: String, animated: Bool) {

        if !animated {
            self.title = title
            return
        }
        
        UIView.animateWithDuration(0.5,
            animations: { [weak self] () -> Void in
                // hide old title
                self?.txtLabel.alpha = 0
            },
            completion: { [weak self] (success) -> Void in
                self?.title = title
                
                UIView.animateWithDuration(0.5,
                    animations: { () -> Void in
                        self?.txtLabel.alpha = 1
                    })
                
        })
    }
    
    func setAccessoryView(view: UIView?) {
        viewWithTag(1)?.removeFromSuperview()
        
        guard let accessoryView = view else {
            txtLabel.frame = CGRectMake(8, 12,
                frame.size.width - 8, 20)
            return
        }
        
        accessoryView.tag = 1
        accessoryView.frame = CGRectMake(12,
            (frame.size.height - accessoryView.frame.size.height) / 2 + 1,
            accessoryView.frame.size.width,
            accessoryView.frame.size.height)
        
        txtLabel.frame = CGRectMake(38, 12,
            frame.size.width - 38, 20)
        
        self.addSubview(accessoryView)
    }
    
    func setAccessoryView(view: UIView?, animated: Bool) {
        if !animated {
            setAccessoryView(view)
        }
        
        if let accessoryView = view {
            accessoryView.frame = CGRectMake(12,
                (frame.size.height - accessoryView.frame.size.height) / 2 + 1,
                accessoryView.frame.size.width,
                accessoryView.frame.size.height)
            
            accessoryView.alpha = 0
            
            addSubview(accessoryView)
        
            if viewWithTag(1) != nil {  // if an old accessoryView exist
                accessoryView.tag = 0
            } else {
                accessoryView.tag = 2
            }
        }
        
        UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
            if let oldView = self?.viewWithTag(1) {
                oldView.alpha = 0
            } else {
                view?.alpha = 1
            }
            
            }, completion: { [weak self] (success) -> Void in
                self?.viewWithTag(1)?.removeFromSuperview()
                
                // if accessoryView not nil
                if let accessoryView = view {
                    UIView.animateWithDuration(0.5,
                        animations: { accessoryView.alpha = 1},
                        completion: { (success) -> Void in accessoryView.tag = 1 })
                }
            })
        
        if view != nil {
            txtLabel.frame = CGRectMake(38, 12,
                frame.size.width - 38, 20)
        } else {
            txtLabel.frame = CGRectMake(8, 12,
                frame.size.width - 8, 20)
        }
        
    }
    
    func show() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        var move = frame
        move.origin.y -= 40
        frame = move
        
        UIView.commitAnimations()
    }
    
    func showFor(seconds: NSTimeInterval) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        
        var move = frame
        move.origin.y -= 40
        frame = move
        
        UIView.commitAnimations()
        
        hideIn(seconds)
    }
    
    private func hideIn(seconds: NSTimeInterval) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
            Int64(Double(NSEC_PER_SEC) * seconds)),
            dispatch_get_main_queue()) { [weak self] () -> Void in
                
                guard let strongSelf = self else {
                    return
                }
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(0.3)
                UIView.setAnimationDelegate(strongSelf)
                UIView.setAnimationDidStopSelector("removeFromSuperview")
                
                var move = strongSelf.frame
                move.origin.y += 40
                strongSelf.frame = move
                
                UIView.commitAnimations()
        }
    }
    
    private func hide() {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStopSelector("removeFromSuperview")
        
        var move = frame
        move.origin.y += 40
        frame = move
        
        UIView.commitAnimations()
    }
    
    
}