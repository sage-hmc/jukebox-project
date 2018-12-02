//
//  SongInfoViewController.swift
//  fbdeneme
//
//  Created by Roman Rosenast on 11/9/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit

class SongInfoViewController: UIViewController {

    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var songAlbum: UILabel!
    @IBOutlet weak var songCover: UIImageView!
    
    @IBOutlet weak var SongScoreLabel: UILabel!
    @IBOutlet weak var QueuerLabel: UILabel!
    @IBOutlet weak var PopupView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        songTitle.text = songs[myIndex].info["title"]
        songArtist.text = songs[myIndex].info["artist"]
        songAlbum.text = songs[myIndex].info["album"]
        
        QueuerLabel.text = "Queuer: " + songs[myIndex].user
        
        if let url = URL(string: songs[myIndex].info["imageurl"] ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/12in-Vinyl-LP-Record-Angle.jpg/440px-12in-Vinyl-LP-Record-Angle.jpg") {
            songCover.contentMode = .scaleAspectFit
            downloadImage(from: url)
        }
        
        let totalscore = songs[myIndex].upvotescore - songs[myIndex].downvotescore
        SongScoreLabel.text = "Score: " + "\(totalscore)"
        
        // Made the styling for the background view programatic so NOTE that its styling does not show up on the storyboard.
        PopupView.layer.cornerRadius = 8.0
        PopupView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.songCover.image = UIImage(data: data)
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using .destination.
        // Pass the selected object to the new view controller.
    }
    */

}
