import UIKit
import MediaPlayer

class ViewController: UIViewController {
    
    var fetchedSongs: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            for item in items {
                let title = item.title ?? "Unknown Title"
                let artist = item.artist ?? "Unknown Artist"
                let url = item.assetURL
                let artwork: UIImage? = item.artwork?.image(at: CGSize(width: 100, height: 100))

                // Create a Song struct with the fetched data
                let song = SongData(title: title, artist: artist, url: url, artwork: artwork)
                
                saveSongToCoreData(songData: song)
            }
        }
    }
    
    func saveSongToCoreData(songData: SongData) {
        let context = (UIApplication.shared.delegate as! AppDelegate).musicPersistentContainer.viewContext
        let song = SongEntity(context: context)
        
        song.title = songData.title
        song.artist = songData.artist
        song.url = songData.url?.absoluteString
        if let artwork = songData.artwork {
            song.imageData = artwork.pngData()
        }

        do {
            try context.save()
            print("Song saved successfully!")
        } catch {
            print("Failed to save song: \(error)")
        }
    }
}
