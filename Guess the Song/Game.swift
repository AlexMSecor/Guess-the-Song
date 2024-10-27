import UIKit
import CoreData
import AVFoundation
import MediaPlayer

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var fetchedSongs: [SongData] = []
    let songFuncs = SongFuncs()
    var player: AVAudioPlayer?
    let silentAudioURL = URL(string: "https://example.com/silentAudio.m4a")!
    var selectedSong: SongData?
    var currentSong: SongData?
    var playbackTimer: Timer?
    var savedDuration: Float = 1
    var incorrectGuess: Int = 0
    var score: Int = 0 {
        didSet {
            // Update the label whenever score changes
            scoreLabel.text = "\(score) 🔥"
        }
    }
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var incorrectGuessLabel: UILabel!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savedDuration = UserDefaults.standard.value(forKey: "selectedDuration") as! Float
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
        
        playGame()
    }
    
    func playGame() {
        if (incorrectGuess != 3) {
            currentSong = getRandomSong()
            // For debugging purposes
            print("Current song: " + (currentSong?.title ?? ""))
            if (currentSong == nil) {
                print("No songs available!")
                // Bring up the start menu or force the user to the main screen
            }
        }
    }
    
    func getRandomSong() -> SongData? {
        guard !fetchedSongs.isEmpty else {
            return nil
        }
        
        // Pick a random song
        let randomIndex = Int.random(in: 0..<fetchedSongs.count)
        return fetchedSongs[randomIndex]
    }
    
    @IBAction func quitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonTouch(_ sender: Any) {
        playSong(duration: TimeInterval(savedDuration), url: currentSong?.url ?? silentAudioURL)
    }
    
    @IBAction func submitButtonTouch(_ sender: Any) {
        if (selectedSong != nil) {
            // Using this logic instead of url == url because some songs might be singles, compared to the songs on the album
            if (selectedSong?.title == currentSong?.title && selectedSong?.artist == currentSong?.artist) {
                score += 1
                playGame()
            }
            else {
                incorrectGuess += 1
                incorrectGuessLabel.text = (incorrectGuessLabel.text ?? "") + "❌ "
            }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected item
        selectedSong = fetchedSongs[indexPath.row]
        
        // For debugging
        print("Selected song: \(String(describing: selectedSong))")
        
        albumImageView.image = selectedSong?.artwork
        
        // Optionally, you can deselect the row after selection
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func playSong(duration: TimeInterval, url: URL) {
        do {
            // Initialize the audio player with the song URL
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()  // Start playing the song
            
            // Set up a timer to stop the playback after the specified duration
            playbackTimer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(stopPlayback), userInfo: nil, repeats: false)
        } catch {
            print("Error playing song: \(error.localizedDescription)")
        }
    }
        
    @objc func stopPlayback() {
        player?.stop()
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}
