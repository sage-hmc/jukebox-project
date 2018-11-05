//
//  ViewController.swift
//  fbdeneme
//
//  Created by Hakan Alpan on 10/29/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var partyField: UITextField!
    @IBOutlet weak var songField: UITextField!
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        partyField.delegate = self
        songField.delegate = self
        let db = Database.database().reference().child("Songs")
        db.observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? NSDictionary else {
                print("anan")
                return
            }
            
            for val in value {
                let abc = val.value as! NSDictionary
                let name = abc["url"] as! String
                songs.append(song(url: name))
                print(songs[songs.count-1].url)
            }
            self.table.reloadData()
            
        })
    
    }
    
    @IBAction func createPlaylist(){
        let db = Database.database().reference()
        let parties = db.child("Parties")
        let newref  = parties.child("\(partyField.text!)")
        newref.setValue("ye")
    }
    
    @IBAction func addSong(){
        let db = Database.database().reference()
        let parties = db.child("Songs")
        let cur = song(url:"\(songField.text!)")
        let newref  = parties.child("\(songField.text!)")
        newref.child("url").setValue(cur.url)
        newref.child("score").setValue(cur.score)
        newref.child("voters").setValue(cur.voters)
        
        songs.append(cur)
        self.table.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(songs.count)
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = songs[indexPath.row].url
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let db = Database.database().reference()
            let songdb = db.child("Songs")
            print("\(songs[indexPath.row].url)")
            let cur = songdb.child("\(songs[indexPath.row].url)")
            cur.removeValue()
            songs.remove(at: indexPath.row)
            self.table.reloadData()
            
        }
    }

}

extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

