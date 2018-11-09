//
//  model.swift
//  fbdeneme
//
//  Created by Hakan Alpan on 11/1/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import Foundation
import Firebase

var songs : [song] = []


class SharedStuff{
    
    static let shared = SharedStuff()
    var ref = Database.database().reference()
    var user : String?

}

class song {
    let url: String
    var score: Int
    var voters = ["anan", "baban"]
    let user: String
    let reference: DatabaseReference
    
    init(url: String) {
        self.url = url
        self.score = 0
        self.user = SharedStuff.shared.user!
        self.reference = SharedStuff.shared.ref.child("Songs").child(url)
    }
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
    
    func updateScore(upvote: Bool){
        reference.observeSingleEvent(of: .value) { (snapshot) in
            print("Here comes sc's")
            guard
                let value = snapshot.value as? NSDictionary,
                var sc = value["score"] as? Int else{
                    return
            }
            
            print(sc)
            
            if(upvote){
                sc += 1
            } else{
                sc -= 1
            }
            print(sc)
            self.reference.child("score").setValue(sc)
        }
    }
            
        
}


