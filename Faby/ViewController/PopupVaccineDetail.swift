
import UIKit

class VaccinePopupViewController: UIViewController {
    
    var selectedVaccines: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Create the popup container
        let popupView = UIView()
        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 12
        view.addSubview(popupView)
        popupView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Auto Layout constraints for the popup
        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            popupView.heightAnchor.constraint(equalToConstant: 300)
        ])
        
        // Add a label to show selected vaccines
        let label = UILabel()
        label.text = "Selected Vaccines"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        popupView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: popupView.centerXAnchor)
        ])
        
        // Add a text view for vaccine list
        let vaccineListView = UITextView()
        vaccineListView.text = selectedVaccines.joined(separator: "\n")
        vaccineListView.font = UIFont.systemFont(ofSize: 16)
        vaccineListView.isEditable = false
        popupView.addSubview(vaccineListView)
        vaccineListView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vaccineListView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            vaccineListView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16),
            vaccineListView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -16),
            vaccineListView.heightAnchor.constraint(equalToConstant: 150)
        ])
        
        // Add a Proceed button
        let proceedButton = UIButton(type: .system)
        proceedButton.setTitle("Proceed", for: .normal)
        proceedButton.setTitleColor(.white, for: .normal)
        proceedButton.backgroundColor = .systemBlue
        proceedButton.layer.cornerRadius = 10
        proceedButton.addTarget(self, action: #selector(proceedTapped), for: .touchUpInside)
        popupView.addSubview(proceedButton)
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            proceedButton.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -16),
            proceedButton.centerXAnchor.constraint(equalTo: popupView.centerXAnchor),
            proceedButton.widthAnchor.constraint(equalToConstant: 120),
            proceedButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func proceedTapped() {
        // Dismiss the popup and notify the parent controller
        dismiss(animated: true) {
            // Optionally notify the parent that the user tapped Proceed
            NotificationCenter.default.post(name: .popupProceedTapped, object: nil)
        }
    }
}

// Add a notification for the Proceed action
extension Notification.Name {
    static let popupProceedTapped = Notification.Name("popupProceedTapped")
}
