//
//  SecondViewController.swift
//  NevrLate
//
//  Created by Shawn Berg on 9/9/17.
//  Copyright © 2017 Shawn Berg. All rights reserved.
//

import UIKit
import EventKit

class SecondViewController: UIViewController {
    
    var testETA = TimeInterval();
    
    let relativeAlarm = EKAlarm(relativeOffset: TimeInterval())

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

