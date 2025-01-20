import UIKit

class MeasurementDetailsViewController: UIViewController {
    var measurementType: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        print("\(measurementType!)")
        title = measurementType
        
    }

}
