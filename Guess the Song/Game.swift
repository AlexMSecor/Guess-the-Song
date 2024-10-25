import UIKit
import CoreData
import AVFoundation
import MediaPlayer

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var fetchedSongs: [SongData] = []
    let songFuncs = SongFuncs()
    var player: AVPlayer?
    var selectedSong: SongData?
    
    @IBAction func quitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var incorrectGuessLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let savedDuration = UserDefaults.standard.value(forKey: "selectedDuration")
        incorrectGuessLabel.text = ""
        fetchedSongs = songFuncs.fetchSongsFromCoreData()
        tableView.delegate = self
        tableView.dataSource = self
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to activate audio session: \(error.localizedDescription)")
        }
    }
    
    @IBAction func playButtonTouch(_ sender: Any) {
        playSong(url: (selectedSong?.url)!)
    }
    
    @IBAction func submitButtonTouch(_ sender: Any) {
        incorrectGuessLabel.text = (incorrectGuessLabel.text ?? "") + "❌ "
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected item
        selectedSong = fetchedSongs[indexPath.row]
        
        // For debugging
        print("Selected song: \(String(describing: selectedSong))")
        
        albumImageView.image = selectedSong?.artwork
        
        // Optionally, you can deselect the row after selection
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func playSong(url: URL) {
        player = AVPlayer(url: url)
        player?.play()
        
        print("Now playing: \(url)")
    }
}
