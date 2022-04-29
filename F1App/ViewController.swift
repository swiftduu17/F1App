//
//  ViewController.swift
//  F1App
//
//  Created by Arman Husic on 3/23/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    
    
    let f1routes = F1ApiRoutes()
    
    var decodedJSONObject:String = ""
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup aft

        f1routes.allConstructors()

        
        
    }
    
    

    @IBAction func enterApp(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            self.performSegue(withIdentifier: "enterTransition", sender: self)

        }
    }
    
    
    
    
    
    

}

