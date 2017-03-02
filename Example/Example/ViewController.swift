//
//  ViewController.swift
//  Example
//
//  Created by Micah Wilson on 3/1/17.
//  Copyright © 2017 Micah Wilson. All rights reserved.
//

import UIKit

struct User {
    let name: String
    let age: Int
}

extension User: Unwind {
    init(json: JSON) {
        name = json <- "name"
        age = json <- "age"
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let json = JSON(["someDate": "January 23, 1990",
                         "someString": "Hello World",
                         "someInt": 18,
                         "someStringInt": "21",
                         "user": ["name": "John", "age": "23"],
                         "settings": ["nightMode": true]])
        
        let date: Date = json <- "someDate"
        let str: String? = json <-? "someString"
        let num: Int = json <- "someInt"
        
        //Automatically detect type should be int and convert from string.
        let strInt: Int = json <- "someStringInt"
        
        
        let user: User = json <- "user"
        
        //Nested objects
        let method1: Bool = json <- "settings.nightMode"
        let method2: Bool = json <- ["settings", "nightMode"]
        
        
        print(date)
        print(str)
        print(num)
        print(strInt)
        print(user)
        print(method1)
        print(method2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

