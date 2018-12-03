//
//  CurrentSongViewController.swift
//  fbdeneme
//
//  Created by Roman Rosenast on 11/18/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
/*
    This class is the view controller of the current song screen
    So, this class is responsible for playing and stopping the song
 
    This is done by the player global variable in model.
    It is an AVPlayer instance.
 
    The play and pause functions modify that variable.
 
 */

class CurrentSongViewController: UIViewController {
    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
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

        songCover.contentMode = .scaleAspectFit
        let size = CGSize(width: 100, height: 100)
        
        // FIXME
        self.songCover.image = musicPlayer.nowPlayingItem?.artwork?.image(at: size)
        
        PopupView.layer.cornerRadius = 8.0
        PopupView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
        
    }
    
    // This function and getData below this download an image and is not used
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
        print("Title: " , songs[myIndex].info["title"]!)
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                DispatchQueue.main.async {
                    self.playSong(title: songs[myIndex].info["title"]!)
                }
            }
            else{
                print("Could not play. Not authorized")
            }
        }
        //adfa
    }
    
    func playSong(title: String){
        print("Playing song...")
        if musicPlayer.nowPlayingItem?.title != title{
            let query = MPMediaQuery()
            let predicate = MPMediaPropertyPredicate(value: title, forProperty: MPMediaItemPropertyTitle)
            query.addFilterPredicate(predicate)
            
            musicPlayer.setQueue(with: query)
        }
        print("calling setPlaylist")
        //musicPlayer.play()
        setPlaylist()
        print("finished setPlaylist")
        musicPlayer.play()
        print("musicPlayer.indexOfNowPlayingItem: ",musicPlayer.indexOfNowPlayingItem)
        
    }
    
    @IBAction func skipPressed(_ sender: Any) {
        musicPlayer.skipToNextItem()
        print("musicPlayer.indexOfNowPlayingItem: ",musicPlayer.indexOfNowPlayingItem)
    }
    // Pause is simple
    @IBAction func pausePressed(_ sender: Any) {
        print(musicPlayer.playbackState.rawValue)
        //musicPlayer.stop()
    }
    @IBAction func populateLibrary(_ sender: Any) {
        let query = MPMediaQuery()
        print("query" , query)
    }
    
    func setPlaylist(){
        print("in setPlaylist")
        var query = MPMediaQuery()
        var predicate = MPMediaPropertyPredicate(value: songs[0].info["title"], forProperty: MPMediaItemPropertyTitle)
        query.addFilterPredicate(predicate)
        print("Query.items!", query.items!)
        var playlist = query.items!

        for song in songs{
            query = MPMediaQuery()
            predicate = MPMediaPropertyPredicate(value: song.info["title"], forProperty: MPMediaItemPropertyTitle)
            query.addFilterPredicate(predicate)
            if song !== songs[0]{
                playlist = playlist + query.items!
            }
        }
        
        print("Playlist is ")
        for song in playlist{
            let songTitle = song.title
            print("title: " , songTitle)
        }
        
        let collection = MPMediaItemCollection(items: playlist)
        print("queue is: ")
        for song in collection.items {
            print("song title: ", song.title)
        }
        
        musicPlayer.setQueue(with: collection)
        
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
