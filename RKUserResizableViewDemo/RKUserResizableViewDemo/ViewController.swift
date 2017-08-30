//
//  ViewController.swift
//  RKUserResizableViewDemo
//
//  Created by user on 30/08/17.
//  Copyright © 2017 rk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var currentlyEditingView:RKUserResizableView? = nil
    var lastEditedView:RKUserResizableView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // (1) Create a user resizable view with a simple red background content view.
        let gripFrame = CGRect(x: 50, y: 50, width: 200, height: 150)
        let userResizableView = RKUserResizableView(frame: gripFrame)
        userResizableView.delegate = self
        let contentView = UIView(frame: gripFrame)
        contentView.backgroundColor = UIColor.red
        userResizableView.contentView = contentView
        userResizableView.showEditingHandles()
        currentlyEditingView = userResizableView
        lastEditedView = userResizableView
        self.view.addSubview(userResizableView)
        
        // (2) Create a second resizable view with a UIImageView as the content.
        let imageFrame = CGRect(x: 50, y: 200, width: 200, height: 200)
        let imageResizableView = RKUserResizableView(frame: imageFrame)
        let imageView = UIImageView(image: UIImage(named: "smiley"))
        imageResizableView.contentView = imageView
        imageResizableView.delegate = self
        self.view.addSubview(imageResizableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController:RKUserResizableViewDelegate {
    func userResizableViewDidBeginEditing(_ userResizableView: RKUserResizableView) {
        currentlyEditingView?.hideEditingHandles()
        currentlyEditingView = userResizableView
    }
    
    func userResizableViewDidEndEditing(_ userResizableView: RKUserResizableView) {
        lastEditedView = userResizableView
    }
}

extension ViewController:UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if ((currentlyEditingView?.hitTest(touch.location(in: currentlyEditingView), with: nil)) != nil) {
            return false
        }
        return true
    }
    
    func hideEditingHandles() {
        // We only want the gesture recognizer to end the editing session on the last
        // edited view. We wouldn't want to dismiss an editing session in progress.
        lastEditedView?.hideEditingHandles()
    }
}

