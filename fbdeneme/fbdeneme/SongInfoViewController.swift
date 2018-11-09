//
//  SongInfoViewController.swift
//  fbdeneme
//
//  Created by Roman Rosenast on 11/9/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit

class SongInfoViewController: UIViewController {

    @IBOutlet weak var SongTitleLabel: UILabel!
    @IBOutlet weak var SongScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SongTitleLabel.text = mySongArray[myIndex]
        SongScoreLabel.text = myScoreArray[myIndex]
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
