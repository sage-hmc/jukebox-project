//
//  model.swift
//  fbdeneme
//
//  Created by Hakan Alpan on 11/1/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import Foundation
import Firebase

// This is the array that holds all the song info
// Any firebase updates are changed locally here
var songs : [song] = []


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
    songs = songs.sorted(by: { ($0.upvotescore - $0.downvotescore) > ($1.upvotescore - $1.downvotescore)})
    
}


class song {
    let url: String
    var upvotescore: Int
    var downvotescore: Int
    var voters: [String:String] = [:]
    let user: String
    let reference: DatabaseReference
    
    // This creates a new song from scratch. Should only be used
    // when adding a new song
    init(url: String) {
        self.url = url
        self.upvotescore = 1
        self.downvotescore = 0
        self.user = SharedStuff.shared.user!
        self.reference = SharedStuff.shared.ref.child("Songs").child(url)
        self.voters = [self.user : "up"]
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
            let user = value["user"] as? String else {
            return nil
        }

        
        self.url = url
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


