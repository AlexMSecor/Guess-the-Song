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
    var randomStartPoint: TimeInterval?
    var savedDuration: Float = 1
    var incorrectGuess: Int = 0 {
        didSet {
            // Update the label whenever the guess is incorrect
            incorrectGuessLabel.text = (incorrectGuessLabel.text ?? "") + "❌ "
        }
    }
    var highScore = "high score"
    var score: Int = 0 {
        didSet {
            // Update the label whenever score changes
            // TODO: Change this to be > highScore
            if (score > 0) {
                scoreLabel.text = "\(score) 🏆"
            }
            else {
                scoreLabel.text = "\(score) 🔥"
            }
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
        setupRound()
    }
    
    func resetGame() {
        incorrectGuess = 0
        incorrectGuessLabel.text = ""
        score = 0
    }
    
    func setupRound() {
        // Reset the user's selection
        albumImageView.image = UIImage (named: "Default Album Cover")
        selectedSong = nil
        
        // Reset the player
        player = nil
        
        // Reset the randomStartPoint
        randomStartPoint = nil
        
        // Get a random song
        currentSong = getRandomSong()
        // For debugging purposes
        print("Current song: " + (currentSong?.title ?? ""))
        if (currentSong == nil) {
            print("No songs available!")
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
        quitGame()
    }
    
    @IBAction func playButtonTouch(_ sender: Any) {
        playSong(duration: TimeInterval(savedDuration), url: currentSong?.url ?? silentAudioURL)
    }
    
    @IBAction func submitButtonTouch(_ sender: Any) {
        if (selectedSong != nil) {
            // Using this logic instead of url == url because some songs might be singles, compared to the songs on the album
            if (selectedSong?.title == currentSong?.title && selectedSong?.artist == currentSong?.artist) {
                userGuessed(isCorrect: true)
                setupRound()
            }
            else {
                userGuessed(isCorrect: false)
            }
        }
    }
    
    func userGuessed(isCorrect: Bool) {
        if (isCorrect) {
            score += 1
        } else {
            incorrectGuess += 1
            checkGameEnd()
        }
    }
    
    func checkGameEnd() {
        if incorrectGuess >= 3 {
            endGame()
        }
    }
    
    func endGame() {
        // Display the game over alert with the correct song, score, high score, and the option to replay or quit
        showGameOverAlert()
    }
    
    func showGameOverAlert() {
        let gameOverMessage = """
        The correct song was:
        \(currentSong?.title ?? "Error loading song title") by \(currentSong?.artist ?? "Error loading artist")

        Your score:
        \(score) 🔥
        
        High score:
        \(highScore) 🏆
        """
        
        let alert = UIAlertController(title: "Game Over", message: gameOverMessage, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
            self.playAgain()
        }))

        alert.addAction(UIAlertAction(title: "Quit", style: .destructive, handler: { _ in
            self.quitGame()
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    func playAgain() {
        resetGame()
        playGame()
    }
    
    func quitGame() {
        dismiss(animated: true, completion: nil)
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
            // Initialize the audio player with the song URL if it's not already initialized
            if player == nil {
                player = try AVAudioPlayer(contentsOf: url)
                // Prepare the audio player (needed to start playback from a specific position)
                player?.prepareToPlay()
            }
            
            // If randomStartPoint is not set, generate it
            if randomStartPoint == nil {
                let totalDuration = player?.duration ?? 0
                // Ensure the random start point + duration does not exceed total duration
                let maxStartPoint = max(0, totalDuration - duration)
                randomStartPoint = TimeInterval.random(in: 0..<maxStartPoint)
            }

            // Set the player's current time to the random start point
            player?.currentTime = randomStartPoint!
            
            // Start playing the song
            player?.play()
            
            // DispatchQueue.main.asyncAfter(...) schedules a task to run on the main thread after a delay, which prevents blocking the UI thread during playback
            // [weak self] creates a weak reference to self, helping prevent retain cycles in case the view controller is deallocated before this executes
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.stopPlayback()
            }
        } catch {
            print("Error playing song: \(error.localizedDescription)")
        }
    }
        
    @objc func stopPlayback() {
        player?.stop()
    }
}
