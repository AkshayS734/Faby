import UIKit

class ToddlerTalkViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
        // Fetching card data from the provider
    let cardData = TopicsDataManager.shared.cardData
    var filteredCardData: [Topics] = []
    
    // Add a property to hold the comment data
    var comments: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially, show all the card data
        filteredCardData = cardData
        
        // Set the comments data
        comments = PostDataManager.getDemoComments()
        
        // Create a custom compositional layout with 2 items per row
        let layout = createCompositionalLayout()
        collectionView.collectionViewLayout = layout
        
        // Register the custom cell from the XIB file
        let nib = UINib(nibName: "cardDetailsCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cardDetailsCollectionViewCell")
        
        // Set the delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Set the search bar delegate
        searchBar.delegate = self
        searchBar.placeholder = "Search Topics ...."
    }
    
    // MARK: - UICollectionView DataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCardData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Dequeue the custom cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardDetailsCollectionViewCell", for: indexPath) as! cardDetailsCollectionViewCell
        
        // Configure the cell with the filtered card data
        let card = filteredCardData[indexPath.row]
        cell.title.text = card.title
        cell.imageView.image = UIImage(named: card.imageView)
       // cell.imageView.alpha = 0.7
      //  cell.subtitle.text = card.subtitle
        
        // Apply corner radius and shadow to the cell
        cell.layer.cornerRadius = 10
        applyAppleMusicEffect(to: cell.imageView)

//        cell.layer.masksToBounds = true
//        cell.layer.shadowColor = UIColor.black.cgColor
//        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
//        cell.layer.shadowRadius = 4
//        cell.layer.shadowOpacity = 0.1
        
        return cell
    }
    
//     MARK: - UICollectionView Delegate Method
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Get the selected card
        let selectedCard = filteredCardData[indexPath.row]
        
        // Instantiate NewViewController from the storyboard
        let storyboard = UIStoryboard(name: "ToddlerTalk", bundle: nil)
        if let newVC = storyboard.instantiateViewController(withIdentifier: "commentDetailsViewController") as? commentDetailsViewController {
            // Pass the title and subtitle to NewViewController
            newVC.passedTitle = selectedCard.title
            newVC.passedSubtitle = selectedCard.subtitle
            
            // Optionally pass the comments data to NewViewController
            newVC.comments = comments
            newVC.titleDetail = selectedCard.title
            // Navigate to NewViewController
            navigationController?.pushViewController(newVC, animated: true)
        }
    }
    
    // MARK: - UISearchBarDelegate Methods
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCardData = cardData
        } else {
            filteredCardData = cardData.filter { card in
                card.title.lowercased().contains(searchText.lowercased()) || card.subtitle.lowercased().contains(searchText.lowercased())
            }
        }
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filteredCardData = cardData
        collectionView.reloadData()
    }
    // MARK: -  SCROLLVIEW APPEAR ,DISAPPEAR
//        func scrollViewDidScroll(_ scrollView: UIScrollView) {
//               guard let navBarHeight = navigationController?.navigationBar.frame.height else { return }
//               let offset = scrollView.contentOffset.y
//
//               // Adjust the search bar's visibility based on scroll direction
//               if offset > navBarHeight {
//                   UIView.animate(withDuration: 0.3) {
//                       self.searchBar.alpha = 0
//                   }
//               } else {
//                   UIView.animate(withDuration: 0.3) {
//                       self.searchBar.alpha = 1
//                   }
//               }
//           }
    
    // MARK: - Create Compositional Layout for 2 Items Per Row
    
    func createCompositionalLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0)
        group.interItemSpacing = .fixed(8.0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        return UICollectionViewCompositionalLayout(section: section)
    }
}
func applyAppleMusicEffect(to imageView: UIImageView) {
    guard let image = imageView.image else { return }

    // 1. Add Subtle Blur Effect
    let blurEffect = UIBlurEffect(style: .regular) // Use .regular for a lighter blur
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = imageView.bounds
    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    blurView.alpha = 0.01 // Adjust blur intensity (lower alpha for less blur)
    imageView.addSubview(blurView)

    // 2. Extract Dominant Color
    if let dominantColor = image.dominantColor() {
        let colorOverlay = UIView(frame: imageView.bounds)
        colorOverlay.backgroundColor = dominantColor.withAlphaComponent(0.05) // Lower alpha to keep the image visible
        colorOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.addSubview(colorOverlay)
    }
}


extension UIImage {
    func dominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }

        let width = 1
        let height = 1
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var pixelData: [UInt8] = [0, 0, 0, 0]

        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else { return nil }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let red = CGFloat(pixelData[0]) / 255.0
        let green = CGFloat(pixelData[1]) / 255.0
        let blue = CGFloat(pixelData[2]) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
