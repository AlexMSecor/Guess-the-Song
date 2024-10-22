import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var durationLabel: UILabel!
    @IBAction func quitButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedDuration = UserDefaults.standard.value(forKey: "selectedDuration") as? Int {
            durationLabel.text = "\(savedDuration) second(s)"
        }
        else {
            durationLabel.text = "? second(s)"
        }
    }
}
