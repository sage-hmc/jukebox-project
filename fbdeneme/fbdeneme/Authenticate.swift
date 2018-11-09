//
//  Authenticate.swift
//  fbdeneme
//
//  Created by Hakan Alpan on 11/8/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit
import Firebase

class Authenticate: UIViewController {
    @IBOutlet weak var username: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "anan"{
            let ref = Database.database().reference()
            let users = ref.child("Users")
            print("eHEREEE")
            users.observeSingleEvent(of: .value, with:{ (snapshot) in
                print("HEREEE")
                if(snapshot.hasChild("\(self.username.text!)")){
                    print("Welcome back!")
                    SharedStuff.shared.user = self.username.text!
                } else {
                    users.child("\(self.username.text!)").setValue("\(self.username.text!)")
                    SharedStuff.shared.user = self.username.text!
                }
            })
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
