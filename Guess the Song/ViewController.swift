import UIKit
import MediaPlayer
import CoreData

class ViewController: UIViewController {
    
    var fetchedSongs: [String] = []
    let songFuncs = SongFuncs()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // For testing purposes only
        //songFuncs.deleteAllSongs()
        
        // Load the songs
        importMusic()
    }
    
    private func importMusic() {
        let status = MPMediaLibrary.authorizationStatus()
        
        if status == .notDetermined {
            MPMediaLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    self.fetchMusic()
                }
            }
        }
        else if status == .authorized {
            fetchMusic()
        }
    }

    private func fetchMusic() {
        let query = MPMediaQuery.songs()
        if let items = query.items {
            let savedSongs = songFuncs.fetchSongsFromCoreData()
            for item in items {
                let title = item.title ?? "Unknown Title"
                
                // Check if the song is already in Core Data
                if savedSongs.first(where: { $0.title == title }) != nil {
                    continue
                }
                
                // Proceed to save the song if it doesn't exist in Core Data
                let artist = item.artist ?? "Unknown Artist"
                let url = item.assetURL
                let artwork: UIImage? = item.artwork?.image(at: CGSize(width: 100, height: 100))
                
                // Create and save the song to Core Data
                let song = SongData(title: title, artist: artist, url: url, artwork: artwork)
                songFuncs.saveSongToCoreData(songData: song)
            }
        }
    }
}
