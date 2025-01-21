import UIKit

class VaccineDetailViewController: UIViewController {
    // A label to display the vaccine name
    @IBOutlet weak var vaccineNameLabel: UILabel!
    
    var vaccineName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the label to display the vaccine name if it's passed
        if let name = vaccineName {
            vaccineNameLabel.text = name
        }
    }
}
