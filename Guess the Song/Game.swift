import UIKit
import CoreData

class GameViewController: UIViewController, UITableViewDataSource {
    
    var fetchedSongs: [SongData] = []
    let songFuncs = SongFuncs()
    
    @IBAction func quitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let savedDuration = UserDefaults.standard.value(forKey: "selectedDuration")
        fetchedSongs = songFuncs.fetchSongsFromCoreData()
        tableView.dataSource = self
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
