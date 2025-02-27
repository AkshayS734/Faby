import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(region: RegionType, ageGroup: AgeGroup)
}

class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    
    private let regions: [RegionType] = [.east, .west, .north, .south]
    private let ageGroups: [AgeGroup] = [.months12to18, .months18to24]
    
    private var selectedRegion: RegionType?
    private var selectedAgeGroup: AgeGroup?

    private let regionButton = UIButton(type: .system)
    private let ageButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Filter Meals"
        
        setupUI()
        setDefaultSelections()
    }
    
    private func setupUI() {
        let regionLabel = UILabel()
        regionLabel.text = "Select Region"
        regionLabel.font = .boldSystemFont(ofSize: 16)
        
        regionButton.setTitle("Choose Region", for: .normal)
        regionButton.setTitleColor(.black, for: .normal)
        regionButton.layer.cornerRadius = 10
        regionButton.layer.borderWidth = 1
        regionButton.layer.borderColor = UIColor.lightGray.cgColor
        regionButton.addTarget(self, action: #selector(selectRegion), for: .touchUpInside)

        let ageLabel = UILabel()
        ageLabel.text = "Select Age Group"
        ageLabel.font = .boldSystemFont(ofSize: 16)

        ageButton.setTitle("Choose Age Group", for: .normal)
        ageButton.setTitleColor(.black, for: .normal)
        ageButton.layer.cornerRadius = 10
        ageButton.layer.borderWidth = 1
        ageButton.layer.borderColor = UIColor.lightGray.cgColor
        ageButton.addTarget(self, action: #selector(selectAgeGroup), for: .touchUpInside)

        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Apply Filters", for: .normal)
        applyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        applyButton.backgroundColor = .systemBlue
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 10
        applyButton.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [regionLabel, regionButton, ageLabel, ageButton, applyButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            regionButton.heightAnchor.constraint(equalToConstant: 45),
            ageButton.heightAnchor.constraint(equalToConstant: 45),
            applyButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    private func setDefaultSelections() {
        selectedRegion = regions.first
        selectedAgeGroup = ageGroups.first
        
        regionButton.setTitle(regions.first?.rawValue, for: .normal)
        ageButton.setTitle(ageGroups.first?.rawValue, for: .normal)
    }

    @objc private func selectRegion() {
        let alert = UIAlertController(title: "Select Region", message: nil, preferredStyle: .actionSheet)
        
        for region in regions {
            alert.addAction(UIAlertAction(title: region.rawValue, style: .default, handler: { _ in
                self.selectedRegion = region
                self.regionButton.setTitle(region.rawValue, for: .normal)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func selectAgeGroup() {
        let alert = UIAlertController(title: "Select Age Group", message: nil, preferredStyle: .actionSheet)
        
        for ageGroup in ageGroups {
            alert.addAction(UIAlertAction(title: ageGroup.rawValue, style: .default, handler: { _ in
                self.selectedAgeGroup = ageGroup
                self.ageButton.setTitle(ageGroup.rawValue, for: .normal)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func applyFilters() {
        guard let region = selectedRegion, let ageGroup = selectedAgeGroup else { return }
        delegate?.didApplyFilters(region: region, ageGroup: ageGroup)
        dismiss(animated: true)
    }
}
