import UIKit

class ToddlerTalkViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Initial loading indicator for topics data only
    private let topicsLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
//    // Search bar container to animate hiding/showing
//    private let searchBarContainer: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()

    // Original topics data from Supabase
    private var allTopics: [Topics] = []
    
    // Filtered topics for search
    var filteredCardData: [Topics] = []
    
    // Add a property to hold the comment data
    var comments: [Post] = []
    
    // Track topics loading state only
    private var isTopicsLoading = false {
        didSet {
            updateTopicsLoadingState()
        }
    }
    
    // Flag to indicate if topic data has been loaded
    private var isTopicDataLoaded = false

    // Dictionary to track which images are still loading
    private var loadingImages = [String: Bool]()
    
    // Image cache
    private let imageCache = NSCache<NSString, UIImage>()
    
    // URLSession for image loading
    private let imageSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache.shared
        return URLSession(configuration: config)
    }()
    
    // UserDefaults key for caching topics
    private let topicsCacheKey = "cachedTopics"
    
    // Search debounce timer
    private var searchTimer: Timer?
    
    // Refresh control
    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTopicsLoadingIndicator()
        isTopicsLoading = true
        loadCachedTopics()
        fetchTopicsFromSupabase() // Fetch fresh data from Supabase
    }
    
    private func setupTopicsLoadingIndicator() {
        // Add loading indicator to view
        view.addSubview(topicsLoadingIndicator)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            topicsLoadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            topicsLoadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupUI() {
        collectionView.delegate = self
        collectionView.dataSource = self
        searchBar.delegate = self
        searchBar.placeholder = "Search Topics ...."
        searchBar.showsCancelButton = false

        // Configure scroll behavior for large titles
      //  collectionView.contentInsetAdjustmentBehavior = .always

        let layout = createCompositionalLayout()
        collectionView.collectionViewLayout = layout

        let nib = UINib(nibName: "cardDetailsCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cardDetailsCollectionViewCell")
        
        // Add refresh control
        collectionView.refreshControl = refreshControl
        
        let historyButton = UIBarButtonItem(image: UIImage(systemName: "clock"), style: .plain, target: self, action: #selector(historyButtonTapped))
        navigationItem.rightBarButtonItem = historyButton
    }
    // MARK: - Caching Methods
    private func loadCachedTopics() {
        if let cachedData = UserDefaults.standard.data(forKey: topicsCacheKey),
           let topics = try? JSONDecoder().decode([Topics].self, from: cachedData) {
            self.allTopics = topics
            self.filteredCardData = topics
            self.collectionView.reloadData()
            print("✅ Loaded \(topics.count) topics from cache")
        } else {
            print("⚠️ No cached topics found")
        }
    }
    
    private func cacheTopics(_ topics: [Topics]) {
        if let encodedData = try? JSONEncoder().encode(topics) {
            UserDefaults.standard.set(encodedData, forKey: topicsCacheKey)
        }
    }
    
    // MARK: - Refresh Data
    @objc private func refreshData() {
        print("🔄 Refreshing data...")
        fetchTopicsFromSupabase()
    }
    // MARK: - Search Implementation with Debounce
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Cancel previous timer
        searchTimer?.invalidate()
        // Create new timer
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            if searchText.isEmpty {
                self.filteredCardData = self.allTopics
            } else {
                self.filteredCardData = self.allTopics.filter { topic in
                    topic.title.lowercased().contains(searchText.lowercased())
                }
            }
            self.collectionView.reloadData()
        }
    }
    // MARK: - Image Loading
    private func loadImage(from urlString: String, for cell: cardDetailsCollectionViewCell) {
        guard let url = URL(string: urlString) else {
            // Show placeholder for invalid URL
            cell.imageView.image = UIImage(systemName: "photo")
            cell.imageView.contentMode = .scaleAspectFit
            cell.imageView.tintColor = .gray
            cell.activityIndicator?.stopAnimating()
            return
        }
        
        // Show loading indicator
        cell.activityIndicator?.startAnimating()
        
        // Check memory cache first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            DispatchQueue.main.async {
                cell.imageView.image = cachedImage
                cell.imageView.contentMode = .scaleAspectFill
                cell.imageView.clipsToBounds = true
                cell.activityIndicator?.stopAnimating()
                self.loadingImages[urlString] = false
            }
            return
        }

        // Check disk cache
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage(data: cachedResponse.data) {
            imageCache.setObject(image, forKey: urlString as NSString)
            DispatchQueue.main.async {
                cell.imageView.image = image
                cell.imageView.contentMode = .scaleAspectFill
                cell.imageView.clipsToBounds = true
                cell.activityIndicator?.stopAnimating()
                self.loadingImages[urlString] = false
            }
            return
        }
        
        // Load from network
        let task = imageSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                // Handle error
                DispatchQueue.main.async {
                    cell.imageView.image = UIImage(systemName: "photo")
                    cell.imageView.contentMode = .scaleAspectFit
                    cell.imageView.tintColor = .gray
                    cell.activityIndicator?.stopAnimating()
                    self?.loadingImages[urlString] = false
                }
                return
            }
            
            // Cache the response
            if let response = response {
                let cachedResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
            }
            
            // Cache the image in memory
            self.imageCache.setObject(image, forKey: urlString as NSString)
            
            DispatchQueue.main.async {
                cell.imageView.image = image
                cell.imageView.contentMode = .scaleAspectFill
                cell.imageView.clipsToBounds = true
                cell.activityIndicator?.stopAnimating()
                self.loadingImages[urlString] = false
            }
        }
        task.resume()
    }
    
    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardDetailsCollectionViewCell", for: indexPath) as! cardDetailsCollectionViewCell
        
        let topic = filteredCardData[indexPath.row]
        
        // Configure cell
        cell.title.text = topic.title
        cell.imageView.image = nil // Clear previous image
        
        // Make sure cell has an activity indicator
        if cell.activityIndicator == nil {
            let indicator = UIActivityIndicatorView(style: .medium)
            indicator.hidesWhenStopped = true
            indicator.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(indicator)
            
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: cell.imageView.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: cell.imageView.centerYAnchor)
            ])
            
            cell.activityIndicator = indicator
        }
        
        // Start the activity indicator
        cell.activityIndicator?.startAnimating()
        
        // Load image using our custom method
        loadImage(from: topic.imageView, for: cell)
        
        // Configure cell appearance
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        cell.backgroundColor = .systemBackground
        
        // Add shadow
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.shadowRadius = 4
        cell.layer.shadowOpacity = 0.1
        
        // Configure image view
        cell.imageView.contentMode = .scaleAspectFill
        cell.imageView.clipsToBounds = true
        
        // Load image using our custom method
        loadImage(from: topic.imageView, for: cell)
        
        return cell
    }
    
    // MARK: - Fetch Topics from Supabase
    func fetchTopicsFromSupabase() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isTopicsLoading = true
            self.loadingImages.removeAll() // Reset loading images tracking
        }
        
        PostsSupabaseManager.shared.fetchTopics { [weak self] topics, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let topics = topics {
                    self.allTopics = topics
                    self.filteredCardData = topics
                    self.cacheTopics(topics)
                    self.isTopicDataLoaded = true
                    
                    // Mark all images as loading initially
                    for topic in topics {
                        self.loadingImages[topic.imageView] = true
                    }
                    
                    // Show collection view and search bar immediately
                    self.isTopicsLoading = false
                    self.collectionView.isHidden = false
                    self.searchBar.isHidden = false
                    self.collectionView.reloadData()
                    
                    // No need to prefetch all images, they'll load individually
                } else {
                    print("❌ Error fetching topics: \(error?.localizedDescription ?? "Unknown error")")
                    //  self.showError(message: "Failed to load topics. Please try again.")
                    self.isTopicsLoading = false
                }
                
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    // We don't need prefetching anymore as images will load individually
    
    @objc private func historyButtonTapped() {
        let storyboard = UIStoryboard(name: "ToddlerTalk", bundle: nil)
        if let historyVC = storyboard.instantiateViewController(withIdentifier: "UserPostListViewController") as? UserPostListViewController {
            if let navController = navigationController {
                navController.pushViewController(historyVC, animated: true)
            } else {
                print("❌ Error: No navigation controller found")
               
            }
        } else {
            print("❌ Error: Failed to instantiate UserPostListViewController")
            
        }
    }
    
    // We don't need this method anymore as we're using a simpler loading indicator
    
    private func updateTopicsLoadingState() {
        DispatchQueue.main.async {
            if self.isTopicsLoading {
                self.topicsLoadingIndicator.startAnimating()
                self.collectionView.isHidden = true
                self.searchBar.isHidden = true
            } else {
                self.topicsLoadingIndicator.stopAnimating()
                self.collectionView.isHidden = false
                self.searchBar.isHidden = false
            }
        }
    }
    


    // MARK: - UICollectionView DataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCardData.count
    }

    // MARK: - UICollectionView Delegate Method
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCard = filteredCardData[indexPath.row]

        let detailVC = ModernPostDetailViewController()
        detailVC.selectedTopicId = selectedCard.id
        detailVC.topicName = selectedCard.title
        detailVC.passedTitle = selectedCard.title
        
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: - UISearchBarDelegate Methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // Show cancel button with animation when user starts editing
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Hide cancel button when editing ends
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Clear search text
        searchBar.text = ""
        // Reset filtered data to show all topics
        filteredCardData = allTopics
        collectionView.reloadData()
        
        // End editing which will also hide the cancel button
        searchBar.endEditing(true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Dismiss keyboard when search button is tapped
        searchBar.resignFirstResponder()
    }

    // MARK: - Create Compositional Layout
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

// MARK: - Apple Music Effect for Images
func applyAppleMusicEffect(to imageView: UIImageView) {
    guard let image = imageView.image else { return }

    // Create a more subtle blur effect
    let blurEffect = UIBlurEffect(style: .regular)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = imageView.bounds
    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    blurView.alpha = 0.01 // Reduced opacity for less fading
    imageView.addSubview(blurView)

    // Add a subtle color overlay
    if let dominantColor = image.dominantColor() {
        let colorOverlay = UIView(frame: imageView.bounds)
        colorOverlay.backgroundColor = dominantColor.withAlphaComponent(0.01) // Reduced opacity
        colorOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.addSubview(colorOverlay)
    }
}

// MARK: - Image Dominant Color Extraction
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
