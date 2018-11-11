//
//  ViewController.swift
//  fbdeneme
//
//  Created by Hakan Alpan on 10/29/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit
import Firebase

var myIndex = 0

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var partyField: UITextField!
    @IBOutlet weak var songField: UITextField!
    @IBOutlet weak var table: UITableView!
    var refresh : UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Refresh the data in the table
        table.refreshControl = refresh
        refreshData()
        // Make the pull ot refresh functionality work
        refresh.addTarget(self, action: #selector(ViewController.refreshData), for: .valueChanged)
    }
    
    // This function completely refreshes the data by pulling all the songs again
    // and populating the songs array in the model (model.swift)
    @objc func refreshData(){
        partyField.delegate = self
        songField.delegate = self
        let db = Database.database().reference().child("Songs")
        db.observeSingleEvent(of: .value, with: {(snapshot) in
            songs.removeAll()
            for child in snapshot.children {
                let a = child as! DataSnapshot
                songs.append(song(snapshot: a)!)
                print(songs[songs.count-1].url)
            }
            self.table.reloadData()
            
        })
        refresh.endRefreshing()
    }
    
    // Will probably not be used
    @IBAction func createPlaylist(){
        let db = Database.database().reference()
        let parties = db.child("Parties")
        let newref  = parties.child("\(partyField.text!)")
        newref.setValue("ye")
    }
    
    // Adds a new song by first creating a local song
    // and then updating the database
    @IBAction func addSong(){
        let db = SharedStuff.shared.ref
        let parties = db.child("Songs")
        let cur = song(url:"\(songField.text!)")
        let newref  = parties.child("\(songField.text!)")
        newref.child("url").setValue(cur.url)
        newref.child("score").setValue(cur.score)
        newref.child("voters").setValue(cur.voters)
        newref.child("user").setValue(SharedStuff.shared.user)
        
        songs.append(cur)
        self.table.reloadData()
    }
    
    // Necessary for the tabele view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Indicates how many things should be listed in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(songs.count)
        return songs.count
    }
    
    // Indicates what should be output for each cell in the table.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = songs[indexPath.row].url
        return cell
        
    }
    
    /*func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let db = Database.database().reference()
            let songdb = db.child("Songs")
            print("\(songs[indexPath.row].url)")
            let cur = songdb.child("\(songs[indexPath.row].url)")
            cur.removeValue()
            songs.remove(at: indexPath.row)
            self.table.reloadData()
            
        }
    }*/
    
    // Implements swipe to upvote by updating the local song and calling
    // the updatescore function in the model
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let upvote = UIContextualAction(style: .normal, title: "Upvote") { (action, view, done) in
            songs[indexPath.row].score += 1;
            songs[indexPath.row].updateScore(upvote: true)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [upvote])
    }
    
    // Implements swipe to downvote. Almost the same as swipe to upvote
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let downvote = UIContextualAction(style: .normal, title: "Downvote") { (action, view, done) in
            //print("INDExPAATH", "\(indexPath.row)")
            songs[indexPath.row].score -= 1;
            songs[indexPath.row].updateScore(upvote: false)
           // print("\(songs[indexPath.row].url)")
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [downvote])
    }
    
    //Function for handling song tap for non currently-playing songs
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        performSegue(withIdentifier: "SongInfoSeque", sender: self)
    }

}


// Some tutorial said this was useful.
extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

