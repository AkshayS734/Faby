import UIKit

class UserDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var relationshipTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    let relationshipPicker = UIPickerView()
    let relationshipOptions = ["Father", "Mother", "Guardian"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRelationshipPicker()
    }
    
    func setupRelationshipPicker() {
        relationshipPicker.delegate = self
        relationshipPicker.dataSource = self
        relationshipTextField.inputView = relationshipPicker
        relationshipTextField.text = relationshipOptions[0]
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneRelationshipSelection))
        toolbar.setItems([doneButton], animated: true)
        relationshipTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneRelationshipSelection() {
        relationshipTextField.resignFirstResponder()
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let name = nameTextField.text, !name.isEmpty,
              let relationship = relationshipTextField.text, !relationship.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty,
              password == confirmPassword else {
            showAlert("Please fill all fields correctly.")
            return
        }
        if let parentVC = self.parent as? SignUpViewController {
            parentVC.userEmail = email
            parentVC.userName = name
            parentVC.userRelationship = relationship
            parentVC.userPassword = password
            parentVC.submitDataToSupabase()
        }
        print("User signed up with email: \(email)")
    }
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return relationshipOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return relationshipOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        relationshipTextField.text = relationshipOptions[row]
    }
}
