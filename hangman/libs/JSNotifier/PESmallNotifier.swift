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
        
        super.init(frame: CGRectZero)
        
        txtLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        txtLabel.backgroundColor = UIColor.clearColor()
        txtLabel.textColor = UIColor.whiteColor()
        
        txtLabel.layer.shadowOffset = CGSize(width: 0, height: -0.5)
        txtLabel.layer.shadowColor = UIColor.blackColor().CGColor
        txtLabel.layer.shadowOpacity = 1
        txtLabel.layer.shadowRadius = 1
        txtLabel.layer.masksToBounds = false
        
        txtLabel.text = title
        
        backgroundColor = UIColor(white: 0, alpha: 0.6)
        
        addSubview(txtLabel)
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
        showFor(0)
    }
    
    func showFor(seconds: NSTimeInterval) {
        // Complete view initialization based on the current main view size
        let screenFrame = UIScreen.mainScreen().bounds
        frame = CGRectMake(0, screenFrame.size.height, screenFrame.size.width, 40)
        txtLabel.frame = CGRectMake(8, 12, screenFrame.size.width, 20)
        UIApplication.sharedApplication().keyWindow?.subviews[0].addSubview(self)
        
        UIView.animateWithDuration(0.3) {[weak self] () -> Void in
            guard let strongSelf = self else {
                return
            }
        
            var move = strongSelf.frame
            move.origin.y -= 40
            strongSelf.frame = move
            
            if seconds > 0 {
                strongSelf.hideIn(seconds)
            }
        }
    }
    
    private func hideIn(seconds: NSTimeInterval) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
            Int64(Double(NSEC_PER_SEC) * seconds)),
            dispatch_get_main_queue()) { [weak self] () -> Void in
                
                guard let strongSelf = self else {
                    print("strongSelf nil!")
                    return
                }
                
                strongSelf.hide()
        }
    }
    
    private func hide() {
        UIView.animateWithDuration(0.3,
            animations: { [weak self] () -> Void in
                guard let strongSelf = self else {
                    print("strongSelf nil!")
                    return
                }
            
                var move = strongSelf.frame
                move.origin.y += 40
                strongSelf.frame = move
            
            
            },
            completion: { [weak self] (success) -> Void in
                guard let strongSelf = self else {
                    print("strongSelf nil!")
                    return
                }
                strongSelf.removeFromSuperview()
        })
    }

}