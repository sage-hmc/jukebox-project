//
//  CurrentSongViewController.swift
//  fbdeneme
//
//  Created by Roman Rosenast on 11/18/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//

import UIKit
import AVFoundation

class CurrentSongViewController: UIViewController {
    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    @IBOutlet weak var songAlbum: UILabel!
    @IBOutlet weak var songCover: UIImageView!
    
    @IBOutlet weak var PopupView: UIView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
    @IBAction func PlayButtonPressed(_ sender: UIButton) {
        let webUrl = URL.init(string: songs[myIndex].url)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let path = url.appendingPathComponent(webUrl!.lastPathComponent)
        if !FileManager.default.fileExists(atPath: path.path){
            return
        }
        if player == nil{
            player = AVPlayer.init(url: path)
        }
        
        player.play()
    }
    
    @IBAction func PausePressed(_ sender: UIButton) {
        if player != nil {
            player.pause()
        }
        
    }
    
    //taken from a tutorial
    func downloadFile(_ audioUrl: URL) {
        
    
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsDirectoryURL)
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
        print(destinationUrl)
        
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path")
            
            // if the file doesn't exist
        } else {
            
            // you can use NSURLSession.sharedSession to download the data asynchronously
            URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    print("File moved to documents folder")
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }).resume()
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
