import UIKit
import CoreData
import AVFoundation
import MediaPlayer

class GameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var fetchedSongs: [SongData] = []
    let songFuncs = SongFuncs()
    var player: AVAudioPlayer?
    var isPlaying = false
    var stopPlaybackWorkItem: DispatchWorkItem?
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
    var highScore: Int {
        // Retrieves the high score
        return UserDefaults.standard.integer(forKey: "highScore")
    }

    var score: Int = 0 {
        didSet {
            // Update the label whenever score changes
            if (score > highScore) {
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
    
    func getHighScore() -> Int {
        return UserDefaults.standard.integer(forKey: "highScore")
    }
    
    func saveHighScore() {
        // For debugging
        print("User's score: \(score)")
        print("High score: \(highScore)")
        
        if score > highScore {
            // Stores the high score
            UserDefaults.standard.set(score, forKey: "highScore")
        }
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
        confirmAction(title: "Quit Game", message: "Are you sure you want to quit the game?") { confirmed in
            if (confirmed) {
                print("User confirmed the action.")
                // Save the high score (if applicable)
                self.saveHighScore()
                self.quitGame()
            }
            else {
                print("User canceled the action.")
            }
        }
    }
    
    func confirmAction(title: String, message: String, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Yes", style: .default) { _ in
            completion(true)
        }
        
        let cancel = UIAlertAction(title: "No", style: .cancel) { _ in
            completion(false)
        }
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
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
        // Save the high score (if applicable)
        saveHighScore()
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
            // Stop current playback and cancel any previous stop action
            stopPlayback(cancelPendingStop: true)
            
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
            
            isPlaying = true
            
            // Start playing the song
            player?.play()
            
            // DispatchQueue.main.asyncAfter(...) schedules a task to run on the main thread after a delay, which prevents blocking the UI thread during playback
            // [weak self] creates a weak reference to self, helping prevent retain cycles in case the view controller is deallocated before this executes
            // Create a new DispatchWorkItem to schedule stop action
            let workItem = DispatchWorkItem { [weak self] in
                self?.stopPlayback()
            }
            stopPlaybackWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
        } catch {
            print("Error playing song: \(error.localizedDescription)")
        }
    }
        
    @objc func stopPlayback(cancelPendingStop: Bool = false) {
        // Cancel any previous stop task to prevent early stopping
        if cancelPendingStop {
            stopPlaybackWorkItem?.cancel()
            stopPlaybackWorkItem = nil
        }

        // Only stop the player if it's currently playing
        if isPlaying {
            player?.stop()
            isPlaying = false
        }
    }
}
