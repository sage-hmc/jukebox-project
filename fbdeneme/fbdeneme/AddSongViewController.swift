//
//  AddSongViewController.swift
//  fbdeneme
//
//  Created by Roman Rosenast on 11/14/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit

class AddSongViewController: UIViewController {
    
    @IBOutlet weak var PopupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PopupView.layer.cornerRadius = 8.0
        PopupView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
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
