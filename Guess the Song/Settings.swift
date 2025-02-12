import UIKit

class SettingsViewController: UIViewController {
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var durationLabel: UILabel!
    
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
        
        // TODO: Add a "reset high score" option
    }
}
