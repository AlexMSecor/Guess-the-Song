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
                // Check if the song is DRM-protected or a cloud item without being available locally
                if item.isCloudItem || item.hasProtectedAsset {
                    print("\(item.title ?? "Unknown Title") is DRM protected, skipping")
                    continue
                }
                
                // Ensure the item has a valid URL
                guard let url = item.assetURL else {
                    continue
                }

                let title = item.title ?? "Unknown Title"
                
                // Skip songs with "Unknown Title"
                if title == "Unknown Title" {
                    continue
                }
                
                // Check if the song is already in Core Data
                if savedSongs.first(where: { $0.title == title }) != nil {
                    continue
                }
                
                // Proceed to save the song if it doesn't exist in Core Data and has a valid URL
                let artist = item.artist ?? "Unknown Artist"
                let artwork: UIImage? = item.artwork?.image(at: CGSize(width: 100, height: 100))
                
                // Create and save the song to Core Data
                let song = SongData(title: title, artist: artist, url: url, artwork: artwork)
                songFuncs.saveSongToCoreData(songData: song)
            }
        }
    }

}
