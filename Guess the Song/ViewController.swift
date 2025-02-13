import UIKit
import MediaPlayer
import CoreData

class ViewController: UIViewController {
    
    var fetchedSongs: [String] = []
    let songFuncs = SongFuncs()
    // Background view that will contain the falling notes
    private let backgroundView = UIView()
    // For the background
    let musicNotes = ["🎵", "🎶", "🎼", "?"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background of the main screen
        setupBackgroundView()
        startMusicNoteAnimation()
        
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

    func startMusicNoteAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            self.createFallingNote()
        }
    }

    private func setupBackgroundView() {
        // Creates a background that covers the entire view, is transparent, and is sent to the back
        backgroundView.frame = view.bounds
        backgroundView.backgroundColor = .clear
        view.addSubview(backgroundView)
        view.sendSubviewToBack(backgroundView)
    }
    
    func createFallingNote() {
        let screenWidth = UIScreen.main.bounds.width
        // Random X position
        let startX = CGFloat.random(in: 0...screenWidth)
        // Random music note
        let emoji = musicNotes.randomElement() ?? "🎵"
        
        // Assign a random font size
        let fontSize = CGFloat.random(in: 20...60)
        // Increase size to allow for rotation (otherwise the user will experience clipping)
        let labelSize = fontSize * 2
        
        let noteLabel = UILabel()
        noteLabel.text = emoji
        noteLabel.font = UIFont.systemFont(ofSize: fontSize)
        // Increase label frame size to accommodate rotation
        noteLabel.frame = CGRect(x: startX, y: -labelSize, width: labelSize, height: labelSize)
        // Center the emoji inside
        noteLabel.textAlignment = .center
        // No background (prevents visual artifacts)
        noteLabel.backgroundColor = .clear
        // Assign a random tilt (so they all won't look the same)
        noteLabel.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: -0.5...0.5))
        
        // Adding the note to the backgronudView
        backgroundView.addSubview(noteLabel)
        
        // Assign a random fall speed
        let duration = Double.random(in: 4...8)
        
        // Assign the falling animation
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
            // Move it down
            noteLabel.frame.origin.y = UIScreen.main.bounds.height + labelSize
        }, completion: { _ in
            // Remove it after animation completes
            noteLabel.removeFromSuperview()
        })
    }
}
