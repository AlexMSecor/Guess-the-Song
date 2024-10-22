import UIKit
import MediaPlayer

class ViewController: UIViewController, UITableViewDataSource {

    // TODO: Save these songs
    struct Song {
        let title: String
        let artist: String
        let url: URL?
        let artwork: UIImage?
    }
    
    var fetchedSongTitles: [String] = []
    
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
    
    private var fetchedSongs = [Song]()

    private func fetchMusic() {
        let query = MPMediaQuery.songs()
        if let items = query.items {
            for item in items {
                let title = item.title ?? "Unknown Title"
                let artist = item.artist ?? "Unknown Artist"
                let url = item.assetURL
                let artwork: UIImage? = item.artwork?.image(at: CGSize(width: 100, height: 100))

                // Create a Song struct with the fetched data
                let song = Song(title: title, artist: artist, url: url, artwork: artwork)

                // Append the Song struct to the fetchedSongs array
                self.fetchedSongs.append(song)
            }
        }
    }
    
    // TODO: Move this (kept it so I could reference it for later)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedSongTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = fetchedSongTitles[indexPath.row] // Set the song title
        return cell
    }
}
