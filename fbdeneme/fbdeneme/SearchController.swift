//
//  SearchController.swift
//  fbdeneme
//
//  Created by Hakan Alpan on 11/15/18.
//  Copyright © 2018 Hakan Alpan. All rights reserved.
//
import UIKit

class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var PopupView: UIView!
    
    var searchSongs : [dbSong] = []
    

    @IBOutlet weak var table: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        PopupView.layer.cornerRadius = 8.0
        PopupView.backgroundColor = UIColor(red:0.92, green:0.92, blue:0.92, alpha:1.0)
    
        // Do any additional setup after loading the view.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchSongs = dbSongs.filter({ dbSong -> Bool in
            if let text = searchBar.text?.lowercased() {
                return dbSong.info["title"]!.lowercased().contains(text)
            } else {
                return false
            }
        })
        table.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSongs.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let curSong = searchSongs[indexPath.row]
        
        // Before you add song, make sure it is not already in Queue.
        for song in songs {
            if (song.info["title"] == curSong.info["title"]){
                let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                performSegue(withIdentifier: "backToMain", sender: self)
                return
            }
        }
        
        let cur = song(db: curSong)
        songs.append(cur)
        performSegue(withIdentifier: "backToMain", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "search", for: indexPath)
        cell.textLabel?.text = searchSongs[indexPath.row].info["title"]
        return cell
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
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

// Some tutorial said this was useful.
extension SearchController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
