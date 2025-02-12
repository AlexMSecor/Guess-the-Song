import UIKit

class SettingsViewController: UIViewController {
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    @IBAction func resetHighScoreButtonTapped(_ sender: Any) {
        confirmAction(title: "Reset High Score", message: "Are you sure you want to reset your high score?") { confirmed in
            if (confirmed) {
                print("User confirmed the action.")
                self.resetHighScore()
            }
            else {
                print("User canceled the action.")
            }
        }
    }
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let selectedDuration = Int(sender.value)
        durationLabel.text = "\(selectedDuration) second(s)"
        // Stores the selected duration
        UserDefaults.standard.set(selectedDuration, forKey: "selectedDuration")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedDuration = UserDefaults.standard.value(forKey: "selectedDuration") as? Int {
            durationSlider.value = Float(savedDuration)
            durationLabel.text = "\(savedDuration) second(s)"
        }
        else {
            durationSlider.value = 1
            durationLabel.text = "1 second(s)"
        }
        
        setHighScoreLabel()
    }
    
    func resetHighScore() {
        UserDefaults.standard.set(0, forKey: "highScore")
        setHighScoreLabel()
    }
    
    func setHighScoreLabel() {
        let highScore = UserDefaults.standard.integer(forKey: "highScore")
        highScoreLabel.text = "Current high score: \(highScore)"
        
        if (highScore == 0) {
            highScoreLabel.text! += " ☹️"
        }
        else {
            highScoreLabel.text! += " 🏆"
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
}
