import UIKit

protocol ButtonsCollectionViewDelegate: AnyObject {
    func didSelectButton(withTitle title: String, inCollection collection: ButtonsCollectionView)
}

class ButtonsCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var collectionView: UICollectionView!
    private var buttonTitles: [String]
    private var buttonSize: CGSize
    private var minimumLineSpacing: CGFloat
    private var cornerRadius: CGFloat
    var selectedIndex: Int?
    var selectedCell: ButtonCollectionViewCell?
    private var defaultSelectedIndex: Int
    var categoryButtonTitles: [String]
    var categoryButtonImages: [UIImage]
    
    weak var delegate: ButtonsCollectionViewDelegate?
    
    init(buttonTitles: [String], categoryButtonTitles: [String], categoryButtonImages: [UIImage], buttonSize: CGSize, minimumLineSpacing: CGFloat, cornerRadius: CGFloat, defaultSelectedIndex: Int = 0) {
        self.buttonTitles = buttonTitles
        self.categoryButtonTitles = categoryButtonTitles
        self.categoryButtonImages = categoryButtonImages
        self.buttonSize = buttonSize
        self.minimumLineSpacing = minimumLineSpacing
        self.cornerRadius = cornerRadius
        self.defaultSelectedIndex = defaultSelectedIndex
        super.init(frame: .zero)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = minimumLineSpacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.identifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isUserInteractionEnabled = true
        collectionView.delaysContentTouches = false
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if let defaultIndex = self.selectedIndex {
                let defaultIndexPath = IndexPath(item: defaultIndex, section: 0)
                self.collectionView.selectItem(at: defaultIndexPath, animated: false, scrollPosition: .centeredHorizontally)
                if let defaultCell = self.collectionView.cellForItem(at: defaultIndexPath) as? ButtonCollectionViewCell {
                    defaultCell.isSelected = true
                    self.selectedCell = defaultCell
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCollectionViewCell.identifier, for: indexPath) as! ButtonCollectionViewCell
        let title = buttonTitles[indexPath.row]
        
        if categoryButtonTitles.contains(title) {
            if let imageIndex = categoryButtonTitles.firstIndex(of: title) {
                let image = categoryButtonImages[imageIndex]
                cell.configureCategoryButton(with: title, image: image)
            }
        } else {
            cell.configureMonthButton(with: title)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return buttonSize
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let newSelectedCell = collectionView.cellForItem(at: indexPath) as? ButtonCollectionViewCell {
            selectedCell?.isSelected = false
            newSelectedCell.isSelected = true
            selectedCell = newSelectedCell
            selectedIndex = indexPath.row
            delegate?.didSelectButton(withTitle: buttonTitles[indexPath.row], inCollection: self)
        }
    }
    
    func selectButton(at index: Int) {
        guard index >= 0 && index < buttonTitles.count else { return }
        selectedIndex = index
        let defaultIndexPath = IndexPath(item: index, section: 0)
        collectionView.selectItem(at: defaultIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        if let defaultCell = collectionView.cellForItem(at: defaultIndexPath) as? ButtonCollectionViewCell {
            defaultCell.isSelected = true
            selectedCell = defaultCell
        }
    }
}
