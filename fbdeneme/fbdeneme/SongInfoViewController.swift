//
//  SongInfoViewController.swift
//  fbdeneme
//
//  Created by Roman Rosenast on 11/9/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit
import MediaPlayer
class SongInfoViewController: UIViewController {
    var musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
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
        
        QueuerLabel.text = songs[myIndex].user
        
        let query = MPMediaQuery()
        let predicate = MPMediaPropertyPredicate(value: songTitle.text, forProperty: MPMediaItemPropertyTitle)
        query.addFilterPredicate(predicate)
        let currentSong = query.items?[0]
        
        songCover.contentMode = .scaleAspectFit
        let size = CGSize(width: 100, height: 100)
        
        self.songCover.image = currentSong?.artwork?.image(at: size)
        
        let totalscore = songs[myIndex].upvotescore - songs[myIndex].downvotescore
        SongScoreLabel.text = "\(totalscore)"
        
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
