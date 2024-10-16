import UIKit
import MediaPlayer

class ViewController: UIViewController, UITableViewDataSource {

    // TODO: Create a settings page to adjust the seconds and begin the main screen.
    
    @IBOutlet weak var tableView: UITableView!
    var fetchedSongTitles: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
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
        } else if status == .authorized {
            fetchMusic()
        }
    }
    
    private func fetchMusic() {
        let query = MPMediaQuery.songs()
        if let items = query.items {
            for item in items {
                // TODO: Create a struct for this in the future.
                let title = item.title
                // TODO: Delete this later, just wanted to visibly see the songs.
                self.fetchedSongTitles.append(title ?? "")
                let artist = item.artist
                let url = item.assetURL
                if let artwork = item.artwork {
                            let image = artwork.image(at: CGSize(width: 100, height: 100))
                        }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedSongTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = fetchedSongTitles[indexPath.row] // Set the song title
        return cell
    }
}
