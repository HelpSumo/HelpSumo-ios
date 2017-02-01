//
//  ViewController.swift
//  HelpSumoSDK
//
//  Created by Help Sumo on 01/21/2017.
//  Copyright (c) 2017 Help Sumo. All rights reserved.
//

import UIKit
import HelpSumoSDK

class ViewController: UIViewController {

    @IBAction func OnStartPressed(_ sender: UIButton) {

        let frameworkBundle = Bundle(for:  TicketHomeController.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent( "HelpSumoSDK.bundle")
        let resourceBundle = Bundle(url: bundleURL!)
        let storyboard = UIStoryboard(name: "Article", bundle: resourceBundle)
        let controller = storyboard.instantiateViewController(withIdentifier: "articleBoard") as UIViewController
        
        self.present(controller, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

