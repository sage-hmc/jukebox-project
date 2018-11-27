//
//  Authenticate.swift
//  fbdeneme
//
//  Created by Hakan Alpan on 11/8/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit
import Firebase

class Authenticate: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var connect: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.delegate = self
        //Disable the button at first
        connect.isEnabled = false
   
        // This makes it so that when the user taps outside the textfield while
        // editing it, the edit ends (So the keyboard disappears etc)
        // Not very useful right now but nice to add I guess
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = UserDefaults.standard.string(forKey: "user") {
            SharedStuff.shared.user = user
            print("here")
            performSegue(withIdentifier: "second", sender: nil)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        //or
        //self.view.endEditing(true)
        return true
    }
    
    /*
     This function is used to register the user in the database and locally
     before moving to the playlist screen
     
     ADD OPTIONAL CHECKING HERE
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Change this with a better id
        if segue.identifier == "anan"{
            let ref = Database.database().reference()
            let users = ref.child("Users")
            //print("eHEREEE")
            users.observeSingleEvent(of: .value, with:{ (snapshot) in
                //print("HEREEE")
                if(snapshot.hasChild("\(self.username.text!)")){
                   // print("Welcome back!")
                } else {
                    users.child("\(self.username.text!)").setValue("\(self.username.text!)")
                    
                }
                // cache the user here
                SharedStuff.shared.user = self.username.text!
                UserDefaults.standard.set(SharedStuff.shared.user, forKey: "user")
            })
        }
    }
    
    
    // This function is connected to the textfield in the storyboard by its
    // editing changed property.
    // It disables the button if there is no text
    
    @IBAction func textDidChange(_ sender: UITextField) {
        if username.text?.isEmpty == false {
            connect.isEnabled = true
        } else {
            connect.isEnabled = false
        }
    }
}


