//
//  CurrentSongViewController.swift
//  fbdeneme
//
//  Created by Roman Rosenast on 11/18/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit
import AVFoundation

/*
    This class is the view controller of the current song screen
    So, this class is responsible for playing and stopping the song
 
    This is done by the player global variable in model.
    It is an AVPlayer instance.
 
    The play and pause functions modify that variable.
 
 */

class CurrentSongViewController: UIViewController {
    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var songAlbum: UILabel!
    @IBOutlet weak var songCover: UIImageView!
    
    @IBOutlet weak var PopupView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display the song info
        songTitle.text = songs[myIndex].info["title"]
        songArtist.text = songs[myIndex].info["artist"]
        songAlbum.text = songs[myIndex].info["album"]
        
        if let url = URL(string: songs[myIndex].info["imageurl"] ?? "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/12in-Vinyl-LP-Record-Angle.jpg/440px-12in-Vinyl-LP-Record-Angle.jpg") {
            songCover.contentMode = .scaleAspectFit
            downloadImage(from: url)
        }
        
       // if let url = URL(string: songs[0].url) {
       //     downloadFile(url)
       //     print("audio downloaded?")
       // }
        
        PopupView.layer.cornerRadius = 8.0
        PopupView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        
    }
    
    // This function and getData below this download an image
    // They are used to fisplay the album cover.
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
    
    
    // Play button invokes this function
    // The song is only played when the file finishes downloading
    // The audio file is download at the original view controller
    
    @IBAction func PlayButtonPressed(_ sender: UIButton) {
        // Create the local filepath that the song is supposed to exist in
        let webUrl = URL.init(string: songs[myIndex].url)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = url.appendingPathComponent(webUrl!.lastPathComponent)
        // If the file is not there don't do anything
        if !FileManager.default.fileExists(atPath: path.path){
            return
        }
        // If it is there but the player was not initialized, init.
        if player == nil{
            player = AVPlayer.init(url: path)
        }
        
        // Then play
        player.play()
    }
    
    // Pause is simple
    @IBAction func PausePressed(_ sender: UIButton) {
        if player != nil {
            player.pause()
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}