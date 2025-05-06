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
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
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
        // Add shadow to the content view for depth
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0
        contentView.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.layer.shadowRadius = 3
        
        contentView.addSubview(containerView)
        containerView.addSubview(numberLabel)
        containerView.addSubview(subtitleLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Container view fills the content view with padding
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            
            // Number label centered with slight offset for visual balance
            numberLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            numberLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -10),
            numberLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 4),
            numberLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -4),
            
            // Subtitle label positioned below number label
            subtitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: containerView.leadingAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -4),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Configuration
    func configure(with periodText: String) {
        if periodText == "Birth" {
            numberLabel.text = "Birth"
            numberLabel.font = .systemFont(ofSize: 22, weight: .bold)
            subtitleLabel.isHidden = true
            
            // Center the label vertically when there's no subtitle
            numberLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            
        } else if periodText.contains("weeks") {
            let components = periodText.split(separator: " ")
            numberLabel.text = String(components[0])
            numberLabel.font = .systemFont(ofSize: 30, weight: .bold)
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
            numberLabel.font = .systemFont(ofSize: 30, weight: .bold)
            subtitleLabel.text = "months"
            subtitleLabel.isHidden = false
        }
    }
    
    // MARK: - Selection State
    override var isSelected: Bool {
        didSet {
            if isSelected {
                // Selected state - iOS native blue with proper shadow
                containerView.backgroundColor = .systemBlue
                numberLabel.textColor = .white
                subtitleLabel.textColor = .white
                
                // Add subtle shadow for depth
                contentView.layer.shadowOpacity = 0.2
                containerView.layer.borderWidth = 0
            } else {
                // Unselected state - clean white with subtle border
                containerView.backgroundColor = .systemBackground
                numberLabel.textColor = .label
                subtitleLabel.textColor = .secondaryLabel
                
                // Remove shadow, add subtle border
                contentView.layer.shadowOpacity = 0
                containerView.layer.borderWidth = 0.5
                containerView.layer.borderColor = UIColor.systemGray4.cgColor
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        numberLabel.text = nil
        subtitleLabel.text = nil
        isSelected = false
    }
    
    // Add haptic feedback on touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        // Scale down slightly for touch feedback
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        // Return to original size
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        // Return to original size
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}


import UIKit

protocol TimePeriodCollectionViewDelegate: AnyObject {
    func didSelectTimePeriod(_ period: String)
}

class TimePeriodCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - Properties
    private var collectionView: UICollectionView!
    private let timePeriods: [String]
    private let itemSize: CGSize
    private let lineSpacing: CGFloat
    private let cornerRadius: CGFloat
    
    private(set) var selectedIndex: Int = 0
    private var selectedCell: TimePeriodButtonCell?
    
    weak var delegate: TimePeriodCollectionViewDelegate?
    
    // MARK: - Initialization
    init(timePeriods: [String], itemSize: CGSize, lineSpacing: CGFloat = 10, cornerRadius: CGFloat = 14) {
        self.timePeriods = timePeriods
        self.itemSize = itemSize
        self.lineSpacing = lineSpacing
        self.cornerRadius = cornerRadius
        
        super.init(frame: .zero)
        setupCollectionView()
        setupAccessibility()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = lineSpacing
        layout.minimumInteritemSpacing = lineSpacing
        
        // iOS-native section insets - start from left edge with proper padding
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TimePeriodButtonCell.self, forCellWithReuseIdentifier: TimePeriodButtonCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = true
        collectionView.delaysContentTouches = false
        collectionView.contentInsetAdjustmentBehavior = .always
        
        // Ensure collection view starts from the left
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
        
        addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        // Select first item by default after layout is complete
        DispatchQueue.main.async { [weak self] in
            self?.selectItem(at: 0)
        }
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
        
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        if let cell = collectionView.cellForItem(at: indexPath) as? TimePeriodButtonCell {
            selectedCell?.isSelected = false
            cell.isSelected = true
            selectedCell = cell
            delegate?.didSelectTimePeriod(timePeriods[index])
        }
        
        // Provide haptic feedback
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timePeriods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimePeriodButtonCell.identifier, for: indexPath) as? TimePeriodButtonCell else {
            return UICollectionViewCell()
        }
        
        let period = timePeriods[indexPath.item]
        cell.configure(with: period)
        cell.isSelected = indexPath.item == selectedIndex
        
        // Set accessibility
        cell.isAccessibilityElement = true
        cell.accessibilityLabel = period
        cell.accessibilityTraits = indexPath.item == selectedIndex ? [.selected, .button] : .button
        cell.accessibilityHint = "Double tap to select this time period"
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectItem(at: indexPath.item)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
}
