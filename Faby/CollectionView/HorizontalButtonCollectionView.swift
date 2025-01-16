import UIKit

protocol HorizontalButtonCollectionViewDelegate: AnyObject {
    func didSelectButton(at index: Int)
}

class HorizontalButtonCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    weak var buttonDelegate: HorizontalButtonCollectionViewDelegate?
    private var collectionView: UICollectionView!
    private var buttonTitles: [String]
    private var buttonSize: CGSize
    private var minimumLineSpacing: CGFloat
    private var cornerRadius: CGFloat
    private var selectedIndex: Int?
    
    init(buttonTitles: [String], buttonSize: CGSize, minimumLineSpacing: CGFloat, cornerRadius: CGFloat) {
        self.buttonTitles = buttonTitles
        self.buttonSize = buttonSize
        self.minimumLineSpacing = minimumLineSpacing
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = minimumLineSpacing // Apply minimum line spacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ButtonCollectionViewCell.self, forCellWithReuseIdentifier: ButtonCollectionViewCell.identifier)
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func updateData(_ newTitles: [String]) {
        self.buttonTitles = newTitles
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttonTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCollectionViewCell.identifier, for: indexPath) as? ButtonCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: buttonTitles[indexPath.item])
        let buttonTitle = buttonTitles[indexPath.item]
        cell.configure(with: buttonTitle)
        if indexPath.item == selectedIndex {
            cell.backgroundColor = .systemBlue
            cell.layer.borderWidth = 2
            cell.layer.borderColor = UIColor.white.cgColor
        } else {
            cell.backgroundColor = .clear
            cell.layer.borderWidth = 0
        }
        cell.updateCornerRadius(cornerRadius)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return buttonSize
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        buttonDelegate?.didSelectButton(at: indexPath.item)
    }
}
