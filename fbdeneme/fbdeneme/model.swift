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

class song {
    let url: String
    var score: Int
    var voters = ["anan", "baban"]
    let user: String
    let reference: DatabaseReference
    
    // This creates a new song from scratch. Should only be used
    // when adding a new song
    init(url: String) {
        self.url = url
        self.score = 0
        self.user = SharedStuff.shared.user!
        self.reference = SharedStuff.shared.ref.child("Songs").child(url)
    }
    
    // This takes the firebase data and creates a local song from it
    // Used to populate the array from firebase.
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let url = value["url"] as? String,
            let score = value["score"] as? Int,
            let voters = value["voters"] as? [String],
            let user = value["user"] as? String else {
            return nil
        }

        
        self.url = url
        self.score = score
        self.voters = voters
        self.user = user
        self.reference = snapshot.ref
    }
    
    // This updates the score in firebase.
    // If upvote is true, score += 1, and score -= 1 otherwise
    func updateScore(upvote: Bool){
        reference.observeSingleEvent(of: .value) { (snapshot) in
            print("Here comes sc's")
            guard
                let value = snapshot.value as? NSDictionary,
                var sc = value["score"] as? Int else{
                    return
            }
            
            //print(sc)
            
            if(upvote){
                sc += 1
            } else{
                sc -= 1
            }
            //print(sc)
            self.reference.child("score").setValue(sc)
        }
    }
            
        
}


