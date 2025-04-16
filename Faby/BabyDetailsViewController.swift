import UIKit

class BabyDetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var babyNameTextField: UITextField!
    @IBOutlet weak var babyAgeTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var babyImageView: UIImageView!
    var selectedImage: UIImage?
    var hasUserSelectedImage = false
    let genderPicker = UIPickerView()
    let genderOptions = ["Male", "Female", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGenderPicker()
        setupBabyImageView()
    }
    func setupBabyImageView() {
        babyImageView.clipsToBounds = true
        babyImageView.contentMode = .scaleAspectFit
        
        let placeholderImage = UIImage(systemName: "person.crop.circle")?.withRenderingMode(.alwaysTemplate)
        babyImageView.image = placeholderImage
        babyImageView.tintColor = .black

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImageTapped))
        babyImageView.addGestureRecognizer(tapGesture)
        babyImageView.isUserInteractionEnabled = true
    }
    func setupGenderPicker() {
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderTextField.inputView = genderPicker
        genderTextField.text = genderOptions[0]
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneGenderSelection))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelGenderSelection))
        
        toolbar.setItems([cancelButton, space, doneButton], animated: true)
        genderTextField.inputAccessoryView = toolbar
    }
    
    @objc func doneGenderSelection() {
        genderTextField.resignFirstResponder()
    }
    
    @objc func cancelGenderSelection() {
        genderTextField.resignFirstResponder()
    }
    
    @objc func selectImageTapped() {
        let alert = UIAlertController(title: "Select Image", message: "Choose an option", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { _ in
            self.openPhotoLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert("Camera not available.")
        }
    }
    
    func openPhotoLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            babyImageView.image = image
            babyImageView.layer.cornerRadius = 10
            babyImageView.contentMode = .scaleAspectFill
            selectedImage = image
            hasUserSelectedImage = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueTapped(_ sender: UIButton) {
        guard let name = babyNameTextField.text, !name.isEmpty,
                let age = babyAgeTextField.text, !age.isEmpty,
                let gender = genderTextField.text, !gender.isEmpty else {
                showAlert("Please fill in all baby details.")
                return
        }

        if let parentVC = self.parent as? SignUpViewController {
            parentVC.babyName = name
            parentVC.babyAge = age
            parentVC.babyGender = gender
            parentVC.babyImage = hasUserSelectedImage ? selectedImage : nil
                
            parentVC.setViewControllers([parentVC.pages[1]], direction: .forward, animated: false, completion: nil)
//            parentVC.updateProgressBar(progress: 1.0)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genderOptions[row]
    }
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
