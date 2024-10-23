import UIKit
import CoreData

class GameViewController: UIViewController, UITableViewDataSource {
    
    var fetchedSongs: [SongData] = []
    
    @IBAction func quitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let savedDuration = UserDefaults.standard.value(forKey: "selectedDuration")
        fetchedSongs = fetchSongsFromCoreData()
        tableView.dataSource = self
    }
    
    func fetchSongsFromCoreData() -> [SongData] {
        let context = (UIApplication.shared.delegate as! AppDelegate).musicPersistentContainer.viewContext
        let fetchRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()

        do {
            let songs = try context.fetch(fetchRequest)
            return songs.map { song in
                // Construct and return SongData for each fetched song
                return SongData(
                    title: song.title ?? "Unknown",
                    artist: song.artist ?? "Unknown",
                    url: URL(string: song.url ?? "") ?? nil,
                    artwork: song.imageData != nil ? UIImage(data: song.imageData!) : nil
                )
            }
        } catch {
            print("Failed to fetch songs: \(error.localizedDescription)")
            return []
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedSongs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let song = tableView.dequeueReusableCell(withIdentifier: "Song", for: indexPath)
        // Set the song title
        song.textLabel?.text = fetchedSongs[indexPath.row].title
        return song
    }
}
