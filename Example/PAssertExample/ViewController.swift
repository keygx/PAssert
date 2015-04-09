//
//  ViewController.swift
//  PAssertExample
//
//  Created by xj on 2015/03/30.
//  Copyright (c) 2015年 keygx. All rights reserved.
//

import UIKit
import PAssert

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let num1 = 0
        let num2 = 10
        PAssert.assert(num1, >, num2)    // false
        PAssert.assert(num2, ==, 10)     // true
        
        var flag1 = true
        var flag2 = false
        PAssert.assert(flag1, ==, true)  // true
        PAssert.assert(flag1, ==, flag2) // false
        
        var name: String? = nil
        PAssert.assert(name, !=, nil)    // true
        
        let now1 = NSDate()
        let now2 = NSDate()
        PAssert.assert(now1, ==, now2)   // false
        PAssert.assert(now1, !=, now2)   // true
        
        let str = "hoge"
        PAssert.assert("hoge", ==, str)  // true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

