//
//  ViewController.swift
//  FacePhoto
//
//  Created by JLLJHD on 02/15/2023.
//  Copyright (c) 2023 JLLJHD. All rights reserved.
//

import UIKit
import FacePhoto

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func click(_ sender: Any) {
        present(HDFacePhotoViewController(), animated: true)
    }
}

