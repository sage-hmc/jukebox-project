//
//  model.swift
//  fbdeneme
//
//  Created by Hakan Alpan on 11/1/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

// This is the array that holds all the song info
// Any firebase updates are changed locally here
var songs : [song] = []

// This is the databse of songs
var dbSongs : [dbSong] = []

var player: AVPlayer!

// This class holds the root firebase reference and the user
class SharedStuff{
    
    static let shared = SharedStuff()
    var ref = Database.database().reference()
    var user : String?
 

}

/*
 The song class. It's data members are:
 Url: This currently holds the name of the song but it is supposed to
      have the spotify url
 Score: The score of the song (Upvotes-downvotes)
 Voters: Users who voted for this song (Currently not implemented)
 User: The user who added the song
 Reference: The firebase reference to this song so that it can be updated easily
 
 */

func sortByScore(){
    
    if songs.count == 0 {
        return
    }
    
    if let ind = songs.firstIndex(where: {$0.info["title"] == currentlyPlayingTitle}) {
        // do something with foo

        songs.swapAt(ind, 0)
        let topSong = songs[0]
        songs.remove(at: 0)
        
        songs = songs.sorted(by: { ($0.upvotescore - $0.downvotescore) > ($1.upvotescore - $1.downvotescore)})
        
        songs.insert(topSong, at: 0)
    }
    
}


class song {
    let url: String
    var info: [String:String] //Members are title, artist, album image url
    var upvotescore: Int
    var downvotescore: Int
    var voters: [String:String] = [:]
    let user: String
    let reference: DatabaseReference
    
    // This created the song in a list from a song in the database.
    // Not sure how real this will be when apple music is integrated
    init(db: dbSong) {
        self.url = db.url
        self.info = db.info
        self.upvotescore = 1
        self.downvotescore = 0
        self.user = SharedStuff.shared.user!
        self.reference = SharedStuff.shared.ref.child("Songsv2").childByAutoId()
        self.voters = [self.user : "up"]
        
        self.reference.child("url").setValue(self.url)
        self.reference.child("info").setValue(self.info)
        self.reference.child("up-vote score").setValue(self.upvotescore)
        self.reference.child("down-vote score").setValue(self.downvotescore)
        self.reference.child("user").setValue(self.user)
        self.reference.child("voters").setValue(self.voters)
    }
    
    // This takes the firebase data and creates a local song from it
    // Used to populate the array from firebase.
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let url = value["url"] as? String,
            let upvotescore = value["up-vote score"] as? Int,
            let downvotescore = value["down-vote score"] as? Int,
            let voters = value["voters"] as? [String: String],
            let user = value["user"] as? String,
            let info = value["info"] as? [String:String] else{
            return nil
        }

        
        self.url = url
        self.info = info
        self.upvotescore = upvotescore
        self.downvotescore = downvotescore
        self.voters = voters
        self.user = user
        self.reference = snapshot.ref
    }
    
    // This updates the score in firebase.
    // If upvote is true, score += 1, and score -= 1 otherwise
    func updateScore(upvote: Bool){
        reference.observeSingleEvent(of: .value) { (snapshot) in
            //print("Here comes sc's")
            guard
                let value = snapshot.value as? NSDictionary,
                var dict = value["voters"] as? [String:String],
                var up = value["up-vote score"] as? Int,
                var down = value["down-vote score"] as? Int else{
                    return
            }
            // If the user already voted and changes their vote, user's vote changes
            
            // If the user previously upvoted the song and then downvotes the song
            if let val = dict[SharedStuff.shared.user!] {
                if(val == "up" && !upvote){
                    dict[SharedStuff.shared.user!] = "down"
                    down += 1
                    up -= 1
                    self.downvotescore+=1
                    self.upvotescore-=1
                    
                } // If the user previously downvoted the song and then upvotes the song
                else if(val == "down" && upvote){
                    dict[SharedStuff.shared.user!] = "up"
                    down -= 1
                    up += 1
                    self.downvotescore -= 1
                    self.upvotescore += 1
                }
            } // If the user has not voted
            else {
                
                if(upvote){
                    dict[SharedStuff.shared.user!] = "up"
                    up += 1
                    self.upvotescore += 1
                } else {
                    dict[SharedStuff.shared.user!] = "down"
                    down += 1
                    self.downvotescore += 1
                }
                
            }
            sortByScore()
            self.reference.child("up-vote score").setValue(up)
            self.reference.child("down-vote score").setValue(down)
            self.reference.child("voters").setValue(dict)
            
            
            /*if(upvote){
                song
                up += 1
                self.reference.child("up-vote score").setValue(up)
            } else{
                down += 1
                self.reference.child("down-vote score").setValue(down)

            }*/

        }
    }
            
        
}


class dbSong{
    let url: String
    let info: [String:String]
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let url = value["url"] as? String,
            let info = value["info"] as? [String:String] else {
                return nil
        }
        
        
        self.url = url
        self.info = info
    }
}

func removeSong(_ songToRemove: song){
    songToRemove.reference.removeValue()
}

func refreshModel(){
    
    let db = Database.database().reference()
    db.child("curtitle").observeSingleEvent(of: .value) { (snapshot) in
        currentlyPlayingTitle = snapshot.value as? String
    }
    db.child("Songsv2").observeSingleEvent(of: .value, with: {(snapshot) in
        // This might not scale well. Maybe implement a more legit update?
        songs.removeAll()
        for child in snapshot.children {
            let a = child as! DataSnapshot
            songs.append(song(snapshot: a)!)
            print(songs[songs.count-1].url)
        }
        print(songs.count-1)
        sortByScore()
        print(songs.count-1)


    })

    print("end of refersh model")
    
}

func addCurrentPlaying(_ title: String){
    currentlyPlayingTitle = title
    SharedStuff.shared.ref.child("curtitle").setValue(title)
}
