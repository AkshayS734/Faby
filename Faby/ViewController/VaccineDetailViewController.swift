//
//  VaccineDetailViewController 2.swift
//  Faby
//
//  Created by Adarsh Mishra on 23/01/25.
//


import UIKit
class VaccineDetailViewController: UIViewController {
    var vaccine: Vaccine? // Add this to store the selected vaccine data
    // UI Elements
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let vaccineNameLabel = UILabel()
    let vaccineDescriptionLabel = UILabel()
    let totalDosesLabel = UILabel()
    let durationLabel = UILabel()
    let importanceLabel = UILabel()
    let aboutLabel = UILabel()
    let transmissionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let vaccine = vaccine {
            vaccineNameLabel.text = vaccine.name
            vaccineDescriptionLabel.text = vaccine.description
            totalDosesLabel.text = vaccine.totalDoses
            durationLabel.text = vaccine.duration
            importanceLabel.text = vaccine.importance
            aboutLabel.text = vaccine.about
            transmissionLabel.text = vaccine.transmission
        }
        
        setupScrollView()
        setupUI()
    }
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func setupUI() {
        // Configure vaccineNameLabel
        vaccineNameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        vaccineNameLabel.textAlignment = .center
        vaccineNameLabel.numberOfLines = 0
        vaccineNameLabel.text = "Hepatitis B" // Placeholder
        contentView.addSubview(vaccineNameLabel)
        
        // Configure vaccineDescriptionLabel
        vaccineDescriptionLabel.font = UIFont.systemFont(ofSize: 16)
        vaccineDescriptionLabel.textAlignment = .center
        vaccineDescriptionLabel.numberOfLines = 0
        vaccineDescriptionLabel.text = "Hepatitis is an inflammation of the liver. The vaccine protects against severe complications."
        contentView.addSubview(vaccineDescriptionLabel)
        
        // Labels for other details
        let labels = [
            ("Total Doses", "3 doses"),
            ("Duration", "6–18 months"),
            ("Importance", "Prevents severe liver infections and cancer."),
            ("About", "Hepatitis B is caused by the hepatitis B virus (HBV), which is highly contagious. It attacks the liver, leading to inflammation and sometimes liver damage. It can be acute (short-term) or chronic (long-term). Chronic infection can lead to serious liver conditions, including cirrhosis (scarring of the liver) and liver cancer."),
            ("Transmission", "Hepatitis B is transmitted through contact with the blood or other bodily fluids of an infected person. Common modes of transmission include:\n\n• Sharing needles or other drug injection equipment\n• Receiving contaminated blood products or organ transplants\n• From an infected mother to her baby during birth (perinatal transmission)")
        ]
        
        var lastView: UIView = vaccineDescriptionLabel
        for (title, detail) in labels {
            let titleLabel = UILabel()
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.text = title
            contentView.addSubview(titleLabel)
            
            let detailLabel = UILabel()
            detailLabel.font = UIFont.systemFont(ofSize: 16)
            detailLabel.numberOfLines = 0
            detailLabel.text = detail
            contentView.addSubview(detailLabel)
            
            // Constraints
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            detailLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: lastView.bottomAnchor, constant: 16),
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
                detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            ])
            
            lastView = detailLabel
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedVaccine = vaccines[indexPath.row] // Select the vaccine from the array
            let detailVC = VaccineDetailViewController()
            detailVC.vaccine = selectedVaccine // Pass the selected vaccine to the detail view
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
        // Final constraint for the bottom of the content view
        NSLayoutConstraint.activate([
            lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
}

