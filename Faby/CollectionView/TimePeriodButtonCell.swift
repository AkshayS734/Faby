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
        button.layer.cornerRadius = 11
        button.clipsToBounds = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
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
            subtitleLabel.topAnchor.constraint(equalTo: numberLabel.bottomAnchor, constant: 5)
        ])
    }
    
    // MARK: - Configuration
    func configure(with periodText: String) {
        if periodText == "Birth" {
            numberLabel.text = "Birth"
            numberLabel.font = .systemFont(ofSize: 20, weight: .regular)
            subtitleLabel.isHidden = true
            
            // Remove previous constraints that might be affecting layout
            for constraint in button.constraints {
                if constraint.firstItem === numberLabel && constraint.firstAttribute == .centerY {
                    constraint.isActive = false
                }
            }
            
            // Add new constraint to center the label
            numberLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        } else if periodText.contains("weeks") {
            let components = periodText.split(separator: " ")
            numberLabel.text = String(components[0])
            numberLabel.font = .systemFont(ofSize: 32, weight: .regular)
            subtitleLabel.text = "weeks"
            subtitleLabel.isHidden = false
            
            // Reset any custom constraints
            for constraint in button.constraints {
                if constraint.firstItem === numberLabel && constraint.firstAttribute == .centerY {
                    if constraint.constant == 0 {
                        constraint.isActive = false
                    }
                }
            }
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
            
            // Reset any custom constraints
            for constraint in button.constraints {
                if constraint.firstItem === numberLabel && constraint.firstAttribute == .centerY {
                    if constraint.constant == 0 {
                        constraint.isActive = false
                    }
                }
            }
        }
    }
    
    // MARK: - Selection State
    override var isSelected: Bool {
        didSet {
            if isSelected {
                button.backgroundColor = .systemBlue
                numberLabel.textColor = .white
                subtitleLabel.textColor = .white
                
                button.layer.shadowColor = UIColor.systemBlue.cgColor
                button.layer.shadowOpacity = 0.3
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
                button.layer.shadowRadius = 4
            } else {
                button.backgroundColor = .white
                numberLabel.textColor = .black
                subtitleLabel.textColor = .black
                
                button.layer.shadowOpacity = 0
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
    init(timePeriods: [String], itemSize: CGSize, lineSpacing: CGFloat = 10, cornerRadius: CGFloat = 11) {
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
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(TimePeriodButtonCell.self, forCellWithReuseIdentifier: TimePeriodButtonCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = true
        collectionView.delaysContentTouches = false
        
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
    
    // MARK: - UICollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return timePeriods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimePeriodButtonCell.identifier, for: indexPath) as? TimePeriodButtonCell else {
            return UICollectionViewCell()
        }
        
        let period = timePeriods[indexPath.item]
        cell.configure(with: period)
        
        // Set selection state if this is the currently selected index
        cell.isSelected = (indexPath.item == selectedIndex)
        if cell.isSelected {
            selectedCell = cell
        }
        
        return cell
    }
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let newSelectedCell = collectionView.cellForItem(at: indexPath) as? TimePeriodButtonCell {
            selectedCell?.isSelected = false
            newSelectedCell.isSelected = true
            selectedCell = newSelectedCell
            selectedIndex = indexPath.row
            delegate?.didSelectTimePeriod(timePeriods[indexPath.row])
            
            // Smoothly scroll to center the selected item
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
}
