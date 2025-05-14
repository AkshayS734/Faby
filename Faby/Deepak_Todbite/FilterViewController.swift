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
        // Title and subtitle
        let titleLabel = UILabel()
        titleLabel.text = "Filter Meals"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Customize your meal preferences"
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .gray
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subtitleLabel)
        
        // Continent Selection
        let continentIconView = createIconView(systemName: "globe")
        
        let continentLabel = UILabel()
        continentLabel.text = "Select Continent"
        continentLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        stylePillButton(continentButton)
        continentButton.addTarget(self, action: #selector(selectContinent), for: .touchUpInside)
        
        let continentStackView = createLabelRow(with: continentIconView, label: continentLabel)
        
        // Country Selection
        let countryIconView = createIconView(systemName: "mappin.and.ellipse")
        
        let countryLabel = UILabel()
        countryLabel.text = "Select Country"
        countryLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        stylePillButton(countryButton)
        countryButton.addTarget(self, action: #selector(selectCountry), for: .touchUpInside)
        
        let countryStackView = createLabelRow(with: countryIconView, label: countryLabel)

        // Region Selection
        let regionIconView = createIconView(systemName: "map")
        
        let regionLabel = UILabel()
        regionLabel.text = "Select Region"
        regionLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        stylePillButton(regionButton)
        regionButton.addTarget(self, action: #selector(selectRegion), for: .touchUpInside)
        
        let regionStackView = createLabelRow(with: regionIconView, label: regionLabel)

        // Age Group Selection
        let ageIconView = createIconView(systemName: "clock")
        
        let ageLabel = UILabel()
        ageLabel.text = "Select Age Group"
        ageLabel.font = .systemFont(ofSize: 18, weight: .semibold)

        stylePillButton(ageButton)
        ageButton.addTarget(self, action: #selector(selectAgeGroup), for: .touchUpInside)
        
        let ageStackView = createLabelRow(with: ageIconView, label: ageLabel)

        // Apply Button
        let applyButton = UIButton(type: .system)
        applyButton.setTitle("Apply Filters", for: .normal)
        applyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        applyButton.backgroundColor = .systemBlue
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.layer.cornerRadius = 20
        applyButton.translatesAutoresizingMaskIntoConstraints = false
        applyButton.addTarget(self, action: #selector(applyFilters), for: .touchUpInside)

        // Main Stack View
        let mainStackView = UIStackView(arrangedSubviews: [
            continentStackView, continentButton,
            countryStackView, countryButton,
            regionStackView, regionButton,
            ageStackView, ageButton,
            applyButton
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.setCustomSpacing(10, after: continentStackView)
        mainStackView.setCustomSpacing(10, after: countryStackView)
        mainStackView.setCustomSpacing(10, after: regionStackView)
        mainStackView.setCustomSpacing(10, after: ageStackView)
        mainStackView.setCustomSpacing(30, after: ageButton)
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            continentButton.heightAnchor.constraint(equalToConstant: 50),
            countryButton.heightAnchor.constraint(equalToConstant: 50),
            regionButton.heightAnchor.constraint(equalToConstant: 50),
            ageButton.heightAnchor.constraint(equalToConstant: 50),
            applyButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // Helper method to create the icon views
    private func createIconView(systemName: String) -> UIImageView {
        let iconView = UIImageView()
        iconView.image = UIImage(systemName: systemName)?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = .black
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        return iconView
    }
    
    // Helper method to create a row with icon and label
    private func createLabelRow(with iconView: UIImageView, label: UILabel) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [iconView, label])
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .center
        return stackView
    }
    
    // Helper method to style all buttons consistently
    private func stylePillButton(_ button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        button.layer.cornerRadius = 20
        button.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 1
        
        // Add chevron indicator
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .gray
        chevron.translatesAutoresizingMaskIntoConstraints = false
        button.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 20)
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
