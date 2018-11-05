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

class song {
    let url: String
    let score: Int
    var voters = ["anan", "baban"]
    
    init(url: String) {
        self.url = url
        self.score = 0
    }
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let url = value["url"] as? String,
            let score = value["score"] as? Int,
            let voters = value["voters"] as? [String] else {
            return nil
        }

        
        self.url = url
        self.score = score
        self.voters = voters
    }
}
