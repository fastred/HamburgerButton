//
//  ViewController.swift
//  HamburgerButton
//
//  Created by Arkadiusz on 14-07-14.
//  Copyright (c) 2014 Arkadiusz Holko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    @IBOutlet var button: HamburgerButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.button.addTarget(self, action: "toggle:", forControlEvents:.TouchUpInside)
        self.button.transform = CGAffineTransformMakeScale(2.0, 2.0)
    }

    func toggle(sender: AnyObject!) {
        self.button.showsMenu = !self.button.showsMenu
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

