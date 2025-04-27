//
//  VacciButtonCollectionView.swift
//  Faby
//
//  Created by Adarsh Mishra on 27/04/25.
//

import UIKit

class TimePeriodButtonCell: UICollectionViewCell {
    static let identifier = "TimePeriodButtonCell"
    
    // MARK: - UI Components
    private let button: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .regular)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupViews() {
        contentView.addSubview(button)
        button.addSubview(numberLabel)
        button.addSubview(subtitleLabel)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            
            numberLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: -10),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 0)
        ])
    }
    
    // MARK: - Configuration
    func configure(with periodText: String) {
        if periodText == "Birth" {
            numberLabel.text = "Birth"
            numberLabel.font = .systemFont(ofSize: 20, weight: .regular)
            subtitleLabel.isHidden = true
            numberLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        } else if periodText.contains("weeks") {
            let components = periodText.split(separator: " ")
            numberLabel.text = String(components[0])
            numberLabel.font = .systemFont(ofSize: 32, weight: .regular)
            subtitleLabel.text = "weeks"
            subtitleLabel.isHidden = false
        } else if periodText.contains("month") {
            if periodText.contains("-") {
                let range = periodText.split(separator: " ")[0]
                numberLabel.text = String(range)
            } else {
                let components = periodText.split(separator: " ")
                numberLabel.text = String(components[0])
            }
            numberLabel.font = .systemFont(ofSize: 32, weight: .regular)
            subtitleLabel.text = "months"
            subtitleLabel.isHidden = false
        }
    }
    
    // MARK: - Selection State
    override var isSelected: Bool {
        didSet {
            if isSelected {
                button.backgroundColor = .systemBlue
                numberLabel.textColor = .white
                subtitleLabel.textColor = .white
            } else {
                button.backgroundColor = .white
                numberLabel.textColor = .black
                subtitleLabel.textColor = .gray
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        numberLabel.text = nil
        subtitleLabel.text = nil
        isSelected = false
    }
}

protocol TimePeriodCollectionViewDelegate: AnyObject {
    func didSelectTimePeriod(_ period: String)
}

class TimePeriodCollectionView: UIView {
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private let timePeriods: [String]
    private let itemSize: CGSize
    private let lineSpacing: CGFloat
    private(set) var selectedIndex: Int = 0
    
    weak var delegate: TimePeriodCollectionViewDelegate?
    
    // MARK: - Initialization
    init(timePeriods: [String], itemSize: CGSize, lineSpacing: CGFloat = 10) {
        self.timePeriods = timePeriods
        self.itemSize = itemSize
        self.lineSpacing = lineSpacing
        
        super.init(frame: .zero)
        setupCollectionView()
        setupAccessibility()
        
        // Select first item by default
        selectItem(at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = itemSize
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = lineSpacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TimePeriodButtonCell.self, forCellWithReuseIdentifier: TimePeriodButtonCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Enable proper scrolling behavior
        collectionView.alwaysBounceHorizontal = true
        collectionView.decelerationRate = .fast
        
        // Add haptic feedback when scrolling between items
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.prepare()
        
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupAccessibility() {
        // Ensure the collection view is not an accessibility element itself
        collectionView.isAccessibilityElement = false
        collectionView.accessibilityLabel = "Time periods"
        collectionView.accessibilityHint = "Horizontal list of time periods"
    }
    
    // MARK: - Public Methods
    func selectItem(at index: Int) {
        guard index < timePeriods.count else { return }
        selectedIndex = index
        let indexPath = IndexPath(item: index, section: 0)
        
        // Check if this item is already selected to avoid unnecessary callbacks
        if let selectedItems = collectionView.indexPathsForSelectedItems,
           selectedItems.contains(indexPath) {
            print("Item at index \(index) is already selected, ignoring")
            return
        }
        
        // Use animation for better visual feedback
        UIView.animate(withDuration: 0.3) {
            self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            self.collectionView.delegate?.collectionView?(self.collectionView, didSelectItemAt: indexPath)
        }
        
        // Provide haptic feedback
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.item
        let selectedPeriod = timePeriods[indexPath.item]
        delegate?.didSelectTimePeriod(selectedPeriod)
        
        // Smoothly scroll to center the selected item
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension TimePeriodCollectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timePeriods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimePeriodButtonCell.identifier, for: indexPath) as? TimePeriodButtonCell else {
            return UICollectionViewCell()
        }
        
        let period = timePeriods[indexPath.item]
        cell.configure(with: period)
        
        return cell
    }
}



