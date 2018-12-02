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

var isPlaying = 0

class CurrentSongViewController: UIViewController {
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var songAlbum: UILabel!
    @IBOutlet weak var songCover: UIImageView!
    
    @IBOutlet weak var PopupView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        renderPauseButton()
        renderPlayButton()
        renderControls()
        
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
    
    func renderControls() {
        
        if (isPlaying == 1){
            PopupView.bringSubviewToFront(pauseButton)
            
        } else {
            PopupView.bringSubviewToFront(playButton)
        }
    }
    
    func renderPauseButton() {
    pauseButton.setBackgroundImage(UIImage(named:"pauseButton"), for: .normal)
        
    }
    
    func renderPlayButton() {
    playButton.setBackgroundImage(UIImage(named:"playButton"), for: .normal)
        
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
    
    @IBAction func PlayButtonPressed(_ sender: UIButton?) {
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
        
        // Setup listener for end of song TODO: make sure this works once skip function works
        NotificationCenter.default.addObserver(self, selector: "playerDidFinishPlaying:", name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    
        isPlaying = 1
        renderControls()
        
        // Then play
        player.play()
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        skipPressed(nil)
    }
    
    // Pause is simple
    @IBAction func PausePressed(_ sender: UIButton?) {
        if player != nil {
            player.pause()
        }
        
        isPlaying = 0
        renderControls()
        
    }
    
    @IBAction func skipPressed(_ sender: UIButton?) {
        
        var wasPlaying = 0
        
        // Step 0: pull firebase TODO!
        refreshModel()
        
        // Step 1: pause current song
        if player != nil {
            wasPlaying = 1
            player.pause()
        }
        
        // Step 2: remove currentlyPlayingSong from firebase and local array
        removeSong(songs[0])
        songs.remove(at: 0)
        
        // Step 3: repopulate currentlyPlayingSong from table
        
       // let topSong = songs.max { ($0.upvotescore - $0.downvotescore) > ($1.upvotescore - $1.downvotescore)}
        //for item in songs {
            
        //}
        currentlyPlayingTitle = songs[0].info["title"]
        
        // Step 4: optionally play new song
        if (wasPlaying == 1) {
            PlayButtonPressed(nil)
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
