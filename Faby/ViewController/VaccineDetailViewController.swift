// VaccineDetailViewController.swift
import UIKit

class VaccineDetailViewController: UIViewController {
    var vaccine: Vaccine? // This will store the selected vaccine data
    
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

    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = UIColor(hex: "#f2f2f7")
//        if let vaccine = vaccine {
//            // Bind the vaccine data to the UI elements
//            vaccineNameLabel.text = vaccine.name
//            vaccineDescriptionLabel.text = vaccine.description
//            totalDosesLabel.text = vaccine.totalDoses
//            durationLabel.text = vaccine.duration
//            importanceLabel.text = vaccine.importance
//            aboutLabel.text = vaccine.about
//            transmissionLabel.text = vaccine.transmission
//        }
//        
//        setupScrollView()
//        setupUI()
//    }

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
        contentView.addSubview(vaccineNameLabel)

        // Configure vaccineDescriptionLabel
        vaccineDescriptionLabel.font = UIFont.systemFont(ofSize: 16)
        vaccineDescriptionLabel.textAlignment = .center
        vaccineDescriptionLabel.numberOfLines = 0
        contentView.addSubview(vaccineDescriptionLabel)
        
        let labels = [
            ("Total Doses", "3 doses"),
            ("Duration", "6–18 months"),
            ("Importance", "Prevents severe liver infections and cancer."),
            ("About", "Hepatitis B is caused by the hepatitis B virus (HBV), which is highly contagious."),
            ("Transmission", "Hepatitis B is transmitted through contact with the blood or other bodily fluids of an infected person.")
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

        // Final constraint for the bottom of the content view
        NSLayoutConstraint.activate([
            lastView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
}
