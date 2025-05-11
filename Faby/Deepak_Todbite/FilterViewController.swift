import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didApplyFilters(continent: ContinentType, country: CountryType, region: RegionType, ageGroup: AgeGroup)
}

class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    private let continents: [ContinentType] = ContinentType.allCases
    private let countries: [CountryType] = CountryType.allCases
    private let regions: [RegionType] = RegionType.allCases
    private let ageGroups: [AgeGroup] = [.months12to15, .months15to18, .months18to21, .months21to24, .months24to30, .months30to36]
    
    private var selectedContinent: ContinentType?
    private var selectedCountry: CountryType?
    private var selectedRegion: RegionType?
    private var selectedAgeGroup: AgeGroup?
    
    private let continentButton = UIButton(type: .system)
    private let countryButton = UIButton(type: .system)
    private let regionButton = UIButton(type: .system)
    private let ageButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Filter Meals"
        setupUI()
        setDefaultSelections()
        // ✅ Load previously selected region
            if let savedRegion = UserDefaults.standard.string(forKey: "SelectedRegion"),
               let regions = RegionType(rawValue: savedRegion) {
                self.selectedRegion = regions
                self.regionButton.setTitle(regions.rawValue, for: .normal)
            }
    }
    
    private func setupUI() {
        // Continent Selection
        let continentLabel = UILabel()
        continentLabel.text = "Select Continent"
        continentLabel.font = .boldSystemFont(ofSize: 16)
        
        continentButton.setTitle("Choose Continent", for: .normal)
        continentButton.setTitleColor(.black, for: .normal)
        continentButton.layer.cornerRadius = 10
        continentButton.layer.borderWidth = 1
        continentButton.layer.borderColor = UIColor.lightGray.cgColor
        continentButton.addTarget(self, action: #selector(selectContinent), for: .touchUpInside)
        
        // Country Selection
        let countryLabel = UILabel()
        countryLabel.text = "Select Country"
        countryLabel.font = .boldSystemFont(ofSize: 16)
        
        countryButton.setTitle("Choose Country", for: .normal)
        countryButton.setTitleColor(.black, for: .normal)
        countryButton.layer.cornerRadius = 10
        countryButton.layer.borderWidth = 1
        countryButton.layer.borderColor = UIColor.lightGray.cgColor
        countryButton.addTarget(self, action: #selector(selectCountry), for: .touchUpInside)

        // Region Selection
        let regionLabel = UILabel()
        regionLabel.text = "Select Region"
        regionLabel.font = .boldSystemFont(ofSize: 16)
        
        regionButton.setTitle("Choose Region", for: .normal)
        regionButton.setTitleColor(.black, for: .normal)
        regionButton.layer.cornerRadius = 10
        regionButton.layer.borderWidth = 1
        regionButton.layer.borderColor = UIColor.lightGray.cgColor
        regionButton.addTarget(self, action: #selector(selectRegion), for: .touchUpInside)

        // Age Group Selection
        let ageLabel = UILabel()
        ageLabel.text = "Select Age Group"
        ageLabel.font = .boldSystemFont(ofSize: 16)

        ageButton.setTitle("Choose Age Group", for: .normal)
        ageButton.setTitleColor(.black, for: .normal)
        ageButton.layer.cornerRadius = 10
        ageButton.layer.borderWidth = 1
        ageButton.layer.borderColor = UIColor.lightGray.cgColor
        ageButton.addTarget(self, action: #selector(selectAgeGroup), for: .touchUpInside)

        // Apply Button
        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Apply Filters", for: .normal)
        applyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        applyButton.backgroundColor = .systemBlue
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 10
        applyButton.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)

        // Stack View
        let stackView = UIStackView(arrangedSubviews: [
            continentLabel, continentButton,
            countryLabel, countryButton,
            regionLabel, regionButton,
            ageLabel, ageButton,
            applyButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            continentButton.heightAnchor.constraint(equalToConstant: 45),
            countryButton.heightAnchor.constraint(equalToConstant: 45),
            regionButton.heightAnchor.constraint(equalToConstant: 45),
            ageButton.heightAnchor.constraint(equalToConstant: 45),
            applyButton.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    private func setDefaultSelections() {
        // Set Asia as default continent
        selectedContinent = .asia
        continentButton.setTitle("Asia", for: .normal)
        
        // Set India as default country
        selectedCountry = .india
        countryButton.setTitle("India", for: .normal)
        
        // Set East as default region
        selectedRegion = regions.first
        regionButton.setTitle(regions.first?.rawValue, for: .normal)
        
        // Set first age group as default
        selectedAgeGroup = ageGroups.first
        ageButton.setTitle(ageGroups.first?.rawValue, for: .normal)
    }

    @objc private func selectContinent() {
        let alert = UIAlertController(title: "Select Continent", message: nil, preferredStyle: .actionSheet)
        
        for continent in continents {
            alert.addAction(UIAlertAction(title: continent.rawValue, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.selectedContinent = continent
                self.continentButton.setTitle(continent.rawValue, for: .normal)
                
                // Reset country and region if they don't match the selected continent
                self.updateCountryAfterContinentChange()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func selectCountry() {
        guard let selectedContinent = selectedContinent else {
            showAlert(message: "Please select a continent first")
            return
        }
        
        // Filter countries by selected continent
        let filteredCountries = countries.filter { $0.continent == selectedContinent }
        
        if filteredCountries.isEmpty {
            showAlert(message: "No countries available for \(selectedContinent.rawValue)")
            return
        }
        
        let alert = UIAlertController(title: "Select Country", message: nil, preferredStyle: .actionSheet)
        
        for country in filteredCountries {
            alert.addAction(UIAlertAction(title: country.rawValue, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.selectedCountry = country
                self.countryButton.setTitle(country.rawValue, for: .normal)
                
                // Reset region if it doesn't match the selected country
                self.updateRegionAfterCountryChange()
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func selectRegion() {
        guard let selectedCountry = selectedCountry else {
            showAlert(message: "Please select a country first")
            return
        }
        
        // Filter regions by selected country
        let filteredRegions = regions.filter { $0.country == selectedCountry }
        
        if filteredRegions.isEmpty {
            showAlert(message: "No regions available for \(selectedCountry.rawValue)")
            return
        }
        
        let alert = UIAlertController(title: "Select Region", message: nil, preferredStyle: .actionSheet)
        
        for region in filteredRegions {
            alert.addAction(UIAlertAction(title: region.rawValue, style: .default, handler: { [weak self] _ in
                self?.selectedRegion = region
                self?.regionButton.setTitle(region.rawValue, for: .normal)

                // ✅ Save to UserDefaults
                UserDefaults.standard.set(region.rawValue, forKey: "SelectedRegion")
            }))
        }

        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func selectAgeGroup() {
        let alert = UIAlertController(title: "Select Age Group", message: nil, preferredStyle: .actionSheet)
        
        for ageGroup in ageGroups {
            alert.addAction(UIAlertAction(title: ageGroup.rawValue, style: .default, handler: { [weak self] _ in
                self?.selectedAgeGroup = ageGroup
                self?.ageButton.setTitle(ageGroup.rawValue, for: .normal)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    private func updateCountryAfterContinentChange() {
        // If the current country doesn't match the selected continent, reset it
        if let country = selectedCountry, country.continent != selectedContinent {
            // Find the first country in the selected continent
            if let newCountry = countries.first(where: { $0.continent == selectedContinent }) {
                selectedCountry = newCountry
                countryButton.setTitle(newCountry.rawValue, for: .normal)
            } else {
                selectedCountry = nil
                countryButton.setTitle("Choose Country", for: .normal)
            }
            
            // Also update the region
            updateRegionAfterCountryChange()
        }
    }
    
    private func updateRegionAfterCountryChange() {
        // If the current region doesn't match the selected country, reset it
        if let region = selectedRegion, region.country != selectedCountry {
            // Find the first region in the selected country
            if let newRegion = regions.first(where: { $0.country == selectedCountry }) {
                selectedRegion = newRegion
                regionButton.setTitle(newRegion.rawValue, for: .normal)
            } else {
                selectedRegion = nil
                regionButton.setTitle("Choose Region", for: .normal)
            }
        }
    }

    @objc private func applyFilters() {
        guard let continent = selectedContinent,
              let country = selectedCountry,
              let region = selectedRegion,
              let ageGroup = selectedAgeGroup else {
            showAlert(message: "Please select all filter options")
            return
        }
        
        delegate?.didApplyFilters(continent: continent, country: country, region: region, ageGroup: ageGroup)
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Filter Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
