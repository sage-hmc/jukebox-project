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

    @IBOutlet weak var table: UITableView!
    var refresh : UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get the song database. This will be different when a music linrary is added
        getSongs()
        
        // Refresh the data in the table
        table.refreshControl = refresh
        refreshData()
        downloadSong()
        // Make the pull ot refresh functionality work
        refresh.addTarget(self, action: #selector(ViewController.refreshData), for: .valueChanged)
    }
    
    
    func getSongs(){
        let db = SharedStuff.shared.ref.child("Song Database")
        db.observeSingleEvent(of: .value) { (snapshot) in
            dbSongs.removeAll()
            for child in snapshot.children {
                let a = child as! DataSnapshot
                dbSongs.append(dbSong(snapshot: a)!)
            }
        }
        
    }
    
    func downloadSong(){
        if(songs.count == 0){
            return
        }
        // error checking?
        let audioUrl =  URL(string: songs[0].url)!
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectoryURL)
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        print(destinationUrl)
        
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path")
            
            // if the file doesn't exist
        } else {
            
            // you can use NSURLSession.sharedSession to download the data asynchronously
            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    print("File moved to documents folder")
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }).resume()
        }
    }

    // This function completely refreshes the data by pulling all the songs again
    // and populating the songs array in the model (model.swift)
    @objc func refreshData(){
        
        let db = Database.database().reference().child("Songsv2")
        db.observeSingleEvent(of: .value, with: {(snapshot) in
            // This might not scale well. Maybe implement a more legit update?
            songs.removeAll()
            for child in snapshot.children {
                let a = child as! DataSnapshot
                songs.append(song(snapshot: a)!)
                //print(songs[songs.count-1].url)
            }
            sortByScore()
            self.table.reloadData()
            
        })
        refresh.endRefreshing()
    }
    
    // Will probably not be used
    //@IBAction func createPlaylist(){
       // let db = Database.database().reference()
      //  let parties = db.child("Parties")
       // let newref  = parties.child("\(partyField.text!)")
      //  newref.setValue("ye")
    //}
    
    // Adds a new song by first creating a local song
    // and then updating the database
    
    // Necessary for the tabele view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Indicates how many things should be listed in the table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    // Indicates what should be output for each cell in the table.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = songs[indexPath.row].info["title"]! + " - " + songs[indexPath.row].info["artist"]! + " - " + songs[indexPath.row].info["album"]!
        
        
        cell.backgroundColor = UIColorFromHex(rgbValue: getMyBGColor( index: indexPath.row ), alpha: 0.75)
        return cell
        
    }
    
    // Function for getting cell color
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
    // Function for assigning cell color
    func getMyBGColor(index: Int)->UInt32 {
        
        // In the case that the hex gradient overflows
        if ((0xFFB372 - (0x10FBEC * index)) < 0x97C8EA ) {
            return UInt32(0x97C8EA - (0x110905 * (index-6)))
        }
        return UInt32(0xFFB372 - (0x10FBEC * index))
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
            //songs[indexPath.row].upvotescore += 1;
            songs[indexPath.row].updateScore(upvote: true)
            self.refreshData()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [upvote])
    }
    
    // Implements swipe to downvote. Almost the same as swipe to upvote
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let downvote = UIContextualAction(style: .normal, title: "Downvote") { (action, view, done) in
            //print("INDExPAATH", "\(indexPath.row)")
            //songs[indexPath.row].downvotescore += 1;
            songs[indexPath.row].updateScore(upvote: false)
           // print("\(songs[indexPath.row].url)")
            self.refreshData()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [downvote])
    }
    
    // Function for handling song tap for non currently-playing songs
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        
        if (myIndex == 0) {
            performSegue(withIdentifier: "CurrentSongSegue", sender: self)
        }
        
        else {
            performSegue(withIdentifier: "SongInfoSeque", sender: self)
        }
    }

}

// Some tutorial said this was useful.
extension ViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

