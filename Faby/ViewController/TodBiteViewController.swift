//
//  TodBiteViewController.swift
//  Faby
//
//  Created by Batch - 1 on 13/01/25.
//

import UIKit

class TodBiteViewController: UIViewController {
    
    
    // MARK: - UI Components
    @IBOutlet weak var segmentedControl: UISegmentedControl! // Connect this in storyboard
    var collectionView: UICollectionView!
    var tableView: UITableView!
    
    // MARK: - Properties
    var selectedCategory: CategoryType? = nil
    var selectedRegion: RegionType = .East
    var selectedAgeGroup: AgeGroup = .months12to15
    
    // Items for MyBowl grouped by category
    var myBowlItemsDict: [CategoryType: [Item]] = [:]
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupTableView()
        
        @IBOutlet weak var segmentedControl: UISegmentedControl!
        @IBOutlet weak var CollectionView: UICollectionView!
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Do any additional setup after loading the view.
            let nib = UINib(nibName: "TodBitCollectionViewCell", bundle: nil)
            CollectionView.register(nib, forCellWithReuseIdentifier: "cell")
            
        }
        
        
        
        // MARK: - UI Setup
        private func setupCollectionView() {
            let layout = createCompositionalLayout()
            collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.register(UINib(nibName: "TodBiteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
            collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
            collectionView.dataSource = self
            collectionView.delegate = self
            view.addSubview(collectionView)
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        private func setupTableView() {
            tableView = UITableView(frame: .zero, style: .plain)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.register(TodBiteTableViewCell.self, forCellReuseIdentifier: "TableViewCell")
            tableView.dataSource = self
            tableView.delegate = self
            tableView.isHidden = true
            tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 100
            view.addSubview(tableView)
            
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        private func loadDefaultContent() {
            collectionView.isHidden = false
            tableView.isHidden = true
            collectionView.reloadData()
        }
        
        // MARK: - Actions
        
        @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
            let select = segmentedControl.selectedSegmentIndex
            switch select{
            case 0:
                
                collectionView.isHidden = false
                tableView.isHidden = true
                collectionView.reloadData()
            case 1:
                collectionView.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()
            default:
                break
                
                CollectionView.isHidden = false
            case 1:
                CollectionView.isHidden = true
            default :
                CollectionView.isHidden = false
                
            }
            
            
        }
        
        
        @objc private func createPlanButtonTapped() {
            let createPlanVC = CreatePlanViewController()
            createPlanVC.selectedItems = myBowlItemsDict.flatMap { $0.value }
            navigationController?.pushViewController(createPlanVC, animated: true)
        }
        
        private func updatePlaceholderVisibility() {
            let isMyBowlEmpty = myBowlItemsDict.isEmpty
            placeholderLabel.isHidden = !isMyBowlEmpty
            tableView.isHidden = isMyBowlEmpty
            createPlanButton.isHidden = isMyBowlEmpty
        }
        
        
        private func createCompositionalLayout() -> UICollectionViewLayout {
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 0)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .absolute(215)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(0)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            
            return UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
                return section
            }
        }
        
        internal func showToast(message: String) {
            let toastLabel = UILabel()
            toastLabel.text = message
            toastLabel.font = UIFont.systemFont(ofSize: 14)
            toastLabel.textColor = .white
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            toastLabel.textAlignment = .center
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10
            toastLabel.clipsToBounds = true
            
            let screenWidth = view.frame.size.width
            toastLabel.frame = CGRect(x: 16, y: view.frame.size.height - 120, width: screenWidth - 32, height: 40)
            
            view.addSubview(toastLabel)
            
            UIView.animate(withDuration: 2.0, delay: 0.5, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        }
        
        private func handleMoreOptions(for item: Item, in category: CategoryType, at indexPath: IndexPath) {
            let alert = UIAlertController(title: "Manage Item", message: "Choose an action for \(item.name)", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.myBowlItemsDict[category]?.remove(at: indexPath.row)
                if self.myBowlItemsDict[category]?.isEmpty == true {
                    self.myBowlItemsDict.removeValue(forKey: category)
                }
                self.tableView.reloadData()
            }))
            
            alert.addAction(UIAlertAction(title: "Add to Favorites", style: .default, handler: { _ in
                self.showToast(message: "\(item.name) added to favorites!")
            }))
            
            alert.addAction(UIAlertAction(title: "Add to Other Section", style: .default, handler: { _ in
                self.showToast(message: "Feature coming soon!")
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    extension TodBiteViewController: UICollectionViewDataSource {
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            guard segmentedControl.selectedSegmentIndex == 0 else { return 0 }
            return CategoryType.allCases.count
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            guard segmentedControl.selectedSegmentIndex == 0 else { return 0 }
            let category = CategoryType.allCases[section]
            return Todbite.shared.getItems(for: category, in: selectedRegion, for: selectedAgeGroup).count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TodBiteCollectionViewCell else {
                return UICollectionViewCell()
            }
            let category = CategoryType.allCases[indexPath.section]
            let items = Todbite.shared.getItems(for: category, in: selectedRegion, for: selectedAgeGroup)
            let item = items[indexPath.row]
            cell.configure(with: item, category: category)
            cell.delegate = self
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
            ) as? HeaderCollectionReusableView else {
                return UICollectionReusableView()
            }
            
            let sectionName = CategoryType.allCases[indexPath.section].rawValue
            let intervalText = "\(7 + indexPath.section):30 AM - \(8 + indexPath.section):00 AM"
            headerView.configure(with: sectionName, interval: intervalText)
            return headerView
        }
    }
    
    // MARK: - UICollectionViewDelegate
    extension TodBiteViewController: UICollectionViewDelegate {
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let category = CategoryType.allCases[indexPath.section]
            let items = Todbite.shared.getItems(for: category, in: selectedRegion, for: selectedAgeGroup)
            let selectedItem = items[indexPath.row]
            
            let detailVC = MealDetailViewController()
            detailVC.selectedItem = selectedItem
            detailVC.sectionItems = items
            
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    extension TodBiteViewController: UITableViewDataSource {
        func numberOfSections(in tableView: UITableView) -> Int {
            return segmentedControl.selectedSegmentIndex == 1 ? myBowlItemsDict.keys.count : 0
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            guard segmentedControl.selectedSegmentIndex == 1 else { return 0 }
            let category = Array(myBowlItemsDict.keys)[section]
            return myBowlItemsDict[category]?.count ?? 0
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard segmentedControl.selectedSegmentIndex == 1 else { return UITableViewCell() }
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TodBiteTableViewCell
            let category = Array(myBowlItemsDict.keys)[indexPath.section]
            let item = myBowlItemsDict[category]?[indexPath.row]
            cell.configure(with: item!)
            
            // Configure the more options button
            cell.moreOptionsButton.tag = indexPath.row
            cell.moreOptionsButton.addTarget(self, action: #selector(moreOptionsTapped(_:)), for: .touchUpInside)
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            guard segmentedControl.selectedSegmentIndex == 1 else { return nil }
            let category = Array(myBowlItemsDict.keys)[section]
            return category.rawValue
        }
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let category = Array(myBowlItemsDict.keys)[indexPath.section]
                myBowlItemsDict[category]?.remove(at: indexPath.row)
                if myBowlItemsDict[category]?.isEmpty == true {
                    myBowlItemsDict.removeValue(forKey: category)
                }
                tableView.reloadData()
            }
        }
        
        @objc private func moreOptionsTapped(_ sender: UIButton) {
            guard let cell = sender.superview?.superview as? TodBiteTableViewCell,
                  let indexPath = tableView.indexPath(for: cell) else { return }
            
            let category = Array(myBowlItemsDict.keys)[indexPath.section]
            let item = myBowlItemsDict[category]?[indexPath.row]
            handleMoreOptions(for: item!, in: category, at: indexPath)
        }
    }
    
    // MARK: - TodBiteCollectionViewCellDelegate
    extension TodBiteViewController: TodBiteCollectionViewCellDelegate {
        func didTapAddButton(for item: Item, in category: CategoryType) {
            if myBowlItemsDict[category] == nil {
                myBowlItemsDict[category] = []
            }
            myBowlItemsDict[category]?.append(item)
            
            showToast(message: "\"\(item.name)\" added to MyBowl!")
            
            if segmentedControl.selectedSegmentIndex == 1 {
                tableView.reloadData()
            }
        }
        
    }
}
