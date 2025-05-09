import UIKit

class WalkthroughViewController: UIViewController {
    
    // MARK: - UI Elements
    private let pageControl = UIPageControl()
    private let scrollView = UIScrollView()
    private let nextButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system)
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Properties
    private let numberOfPages = 5
    private var currentPage = 0
    
    // Content for each page
    private let pageData: [(title: String, description: String, imageName: String)] = [
        (
            "Faby",
            "Parenting made the right way",
            "firstpic"
        ),
        (
            "Track Growth Easily",
            "Track your baby's height, weight and milestone as they grow",
            "secpic"
        ),
        (
            "Never Miss a Vaccine",
            "Get reminders and keep your baby's vaccinations on time with ease.",
            "thirpic"
        ),
        (
            "Plan Nutritious Meals",
            "Access daily meal suggestions and nutrition tips for every stage of growth.",
            "todbite"
        ),
        (
            "Connect with Parents",
            "Ask questions, share advice, and connect with real parents just like you.",
            "community"
        )
    ]
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGradientBackground()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
        
        // Update scrollView content size and page frames
        scrollView.contentSize = CGSize(
            width: view.frame.width * CGFloat(numberOfPages),
            height: scrollView.frame.height
        )
        
        // Update each page's frame
        for (index, subview) in scrollView.subviews.enumerated() {
            let xPosition = view.frame.width * CGFloat(index)
            subview.frame = CGRect(
                x: xPosition,
                y: 0,
                width: view.frame.width,
                height: scrollView.frame.height
            )
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white // Base background color
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        view.addSubview(scrollView)
        
        // Setup page control
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = numberOfPages
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .systemGray4
        pageControl.currentPageIndicatorTintColor = .systemBlue
        view.addSubview(pageControl)
        
        // Setup Next button with iOS-native elevated design and less vertical padding
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.setTitle("Next", for: .normal)
        nextButton.backgroundColor = .systemBlue
        nextButton.setTitleColor(.white, for: .normal)
        nextButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline) // Dynamic type support
        nextButton.layer.cornerRadius = 25 // Slightly less rounded for better proportions
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        // Enhanced shadow for elevated appearance - lighter shadow
        nextButton.layer.shadowColor = UIColor.black.cgColor
        nextButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        nextButton.layer.shadowOpacity = 0.12
        nextButton.layer.shadowRadius = 4
        view.addSubview(nextButton)
        
        // Setup Skip button with enhanced visibility - only visible on pages after the first
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.setTitle("Skip", for: .normal)
        skipButton.setTitleColor(.systemBlue, for: .normal)
        skipButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold) // Slightly larger and bolder
        skipButton.backgroundColor = .clear
        skipButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16) // Better tap target
        skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        skipButton.alpha = 0 // Hidden initially (first page)
        view.addSubview(skipButton)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: pageControl.topAnchor, constant: -30),
            
            // Page control constraints - positioned closer to button for visual cohesion
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -16),
            
            // Next button constraints - less vertical padding for more proportional look
            nextButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            nextButton.widthAnchor.constraint(equalToConstant: 220),
            nextButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Skip button constraints - iOS-native position at top right
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        // Add pages to scroll view
        setupPages()
    }
    
    private func setupGradientBackground() {
        // No gradient background - using plain white background
        // This method is kept empty but still called to maintain code structure
    }
    
    private func setupPages() {
        // Remove any existing subviews
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        
        // Add pages to scroll view
        for (index, pageContent) in pageData.enumerated() {
            let pageView = createPageView(
                title: pageContent.title,
                description: pageContent.description,
                imageName: pageContent.imageName,
                pageIndex: index
            )
            
            // Apply initial state for animation - start with opacity 0
            pageView.alpha = 0
            scrollView.addSubview(pageView)
            
            // Animate page view appearance with a subtle fade-in
            UIView.animate(withDuration: 0.4, delay: Double(index) * 0.1, options: .curveEaseInOut) {
                pageView.alpha = 1
            }
        }
        
        // Set scroll view content size
        scrollView.contentSize = CGSize(
            width: view.frame.width * CGFloat(numberOfPages),
            height: scrollView.frame.height
        )
        
        // Force layout to properly size everything
        view.layoutIfNeeded()
    }
    
    private func createPageView(title: String, description: String, imageName: String, pageIndex: Int) -> UIView {
        let pageView = UIView()
        pageView.backgroundColor = .systemBackground
        
        // Calculate page position
        let xPosition = view.frame.width * CGFloat(pageIndex)
        pageView.frame = CGRect(
            x: xPosition,
            y: 0,
            width: view.frame.width,
            height: scrollView.frame.height
        )
        
        // Container for elements - for better layout control
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        pageView.addSubview(containerView)
        
        // Check if this is the first page (Faby page) to apply special styling
        if pageIndex == 0 {
            // Create a vertical stack view for better organization and consistent margins
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 24 // Increased spacing between title and subtitle
            stackView.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            stackView.isLayoutMarginsRelativeArrangement = true
            containerView.addSubview(stackView)
            
            // Create title label with iOS-native styling for Faby
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = title
            titleLabel.textAlignment = .center
            // Slightly reduced font size but still bold and prominent
            let titleFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
            let titleSize = titleFontDescriptor.fontAttributes[.size] as? CGFloat ?? 34
            titleLabel.font = UIFont.systemFont(ofSize: titleSize + 8, weight: .bold) // Scaled from dynamic type
            titleLabel.textColor = .label // Use system label color for dark mode compatibility
            titleLabel.adjustsFontForContentSizeCategory = true // Support dynamic type
            
            // Create description label with iOS styling for tagline
            let descriptionLabel = UILabel()
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.text = description
            descriptionLabel.textAlignment = .center
            // Use preferred font with 20pt medium weight as per user preference
            descriptionLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            descriptionLabel.textColor = .secondaryLabel // iOS secondary text color
            descriptionLabel.numberOfLines = 0
            descriptionLabel.adjustsFontForContentSizeCategory = true // Support dynamic type
            
            // Add spacing view for better vertical distribution above title
            let topSpacerView = UIView()
            topSpacerView.translatesAutoresizingMaskIntoConstraints = false
            topSpacerView.heightAnchor.constraint(equalToConstant: 15).isActive = true
            
            // Add elements to stack view
            stackView.insertArrangedSubview(topSpacerView, at: 0) // Insert at top of stack
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(descriptionLabel)
            
            // Add spacing view between subtitle and illustration
            let bottomSpacerView = UIView()
            bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
            bottomSpacerView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            stackView.addArrangedSubview(bottomSpacerView)
            
            // Add a subtle gradient background for iOS feel
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor(red: 0.95, green: 0.98, blue: 1.0, alpha: 1.0).cgColor, // Light blue at top
                UIColor.white.cgColor // White at bottom
            ]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.frame = pageView.bounds
            pageView.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            // Create a vertical stack view for consistent layout across all pages
            let stackView = UIStackView()
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 20 // Consistent spacing between elements
            stackView.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
            stackView.isLayoutMarginsRelativeArrangement = true
            containerView.addSubview(stackView)
            
            // Create title label with dynamic type support
            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.text = title
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
            titleLabel.textColor = .label // System label color for dark mode compatibility
            titleLabel.adjustsFontForContentSizeCategory = true // Dynamic type support
            
            // Create description label with dynamic type support
            let descriptionLabel = UILabel()
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel.text = description
            descriptionLabel.textAlignment = .center
            descriptionLabel.font = UIFont.preferredFont(forTextStyle: .body)
            descriptionLabel.textColor = .secondaryLabel // Better contrast than gray
            descriptionLabel.numberOfLines = 0
            descriptionLabel.adjustsFontForContentSizeCategory = true // Dynamic type support
            
            // Add spacing view at top for better spacing
            let topSpacerView = UIView()
            topSpacerView.translatesAutoresizingMaskIntoConstraints = false
            topSpacerView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            // Add elements to stack view
            stackView.addArrangedSubview(topSpacerView)
            stackView.addArrangedSubview(titleLabel)
            stackView.addArrangedSubview(descriptionLabel)
            
            // Add spacing view between subtitle and illustration for visual balance
            let bottomSpacerView = UIView()
            bottomSpacerView.translatesAutoresizingMaskIntoConstraints = false
            bottomSpacerView.heightAnchor.constraint(equalToConstant: 30).isActive = true
            stackView.addArrangedSubview(bottomSpacerView)
        }
        
        // Create image view - placed below description
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: imageName)
        containerView.addSubview(imageView)
        
        // Container constraints - centered in page
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: pageView.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: pageView.centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: pageView.widthAnchor),
            containerView.heightAnchor.constraint(equalTo: pageView.heightAnchor, multiplier: 0.8)
        ])
        
        // Setup constraints based on page index
        if pageIndex == 0 {
            // For first page (Faby), use stack view for better layout
            let stackView = containerView.subviews.first as! UIStackView
            
            NSLayoutConstraint.activate([
                // Stack view constraints - positioned higher with adequate spacing
                stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
                
                // Image view - shifted upward for better vertical symmetry
                imageView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
                imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.9),
                imageView.heightAnchor.constraint(equalToConstant: 320)
            ])
        } else {
            // For other pages, use stack view for consistent layout
            let stackView = containerView.subviews.first as! UIStackView
            
            NSLayoutConstraint.activate([
                // Stack view constraints
                stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                
                // Image view - centered with proper spacing
                imageView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
                imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                imageView.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.85),
                imageView.heightAnchor.constraint(equalToConstant: 280)
            ])
        }
        
        return pageView
    }
    
    // MARK: - Actions
    @objc private func skipButtonTapped() {
        // Navigate to main app
        goToMainApp()
    }
    
    @objc private func nextButtonTapped() {
        if currentPage < numberOfPages - 1 {
            // Go to next page
            currentPage += 1
            let xOffset = view.frame.width * CGFloat(currentPage)
            scrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
            pageControl.currentPage = currentPage
            
            // Update button title on last page
            if currentPage == numberOfPages - 1 {
                nextButton.setTitle("Get Started", for: .normal)
            }
        } else {
            // On last page, go to main app
            goToMainApp()
        }
    }
    
    // Animate transition between pages for a smoother experience
    private func animatePageTransition(from fromPage: Int, to toPage: Int, direction: CGFloat) {
        // Get the views for animation if they exist
        guard fromPage >= 0, toPage >= 0,
              fromPage < scrollView.subviews.count, toPage < scrollView.subviews.count else {
            return
        }
        
        let fromView = scrollView.subviews[fromPage]
        let toView = scrollView.subviews[toPage]
        
        // Get image views from both pages for targeted animation
        if let fromContainer = fromView.subviews.first as? UIView,
           let toContainer = toView.subviews.first as? UIView {
            
            // Find image views within the container hierarchy
            let fromElements = fromContainer.subviews.filter { !($0 is UIStackView) }
            let toElements = toContainer.subviews.filter { !($0 is UIStackView) }
            
            // Animate content elements separately for a more polished effect
            if let fromImage = fromElements.first as? UIImageView,
               let toImage = toElements.first as? UIImageView {
                
                // Subtle scale and opacity changes during page transition
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    // Fade in the new image
                    toImage.alpha = 1.0
                    
                    // Subtle scale effect when transitioning between pages
                    fromImage.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                    toImage.transform = CGAffineTransform.identity
                } completion: { _ in
                    // Reset transform when animation completes
                    fromImage.transform = CGAffineTransform.identity
                }
            }
        }
    }
    
    private func goToMainApp() {
        // Save that onboarding has been completed
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        
        // Create the authentication screen
        let authViewController = AuthViewController()
        authViewController.modalPresentationStyle = .fullScreen
        
        // Use a more subtle fade-cross-dissolve transition that feels more iOS native
        UIView.animate(withDuration: 0.2, animations: {
            // Fade out the current view slightly
            self.view.alpha = 0.8
        }, completion: { _ in
            // Present the auth view controller
            authViewController.modalTransitionStyle = .crossDissolve
            self.present(authViewController, animated: true) {
                // Reset our view's alpha after transition completes
                self.view.alpha = 1.0
            }
        })
    }
}

// MARK: - UIScrollViewDelegate
extension WalkthroughViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.width
        let pageIndex = round(scrollView.contentOffset.x / pageWidth)
        let newPage = Int(pageIndex)
        
        // Only trigger animations when the page actually changes
        if newPage != currentPage {
            // Animate page transition
            let direction: CGFloat = newPage > currentPage ? 1 : -1
            animatePageTransition(from: currentPage, to: newPage, direction: direction)
        }
        
        // Update current page after checking for transition
        pageControl.currentPage = newPage
        currentPage = newPage
        
        // Show/hide Skip button based on page index (iOS-native behavior)
        // Skip button is only visible when not on the first page
        UIView.animate(withDuration: 0.3) {
            self.skipButton.alpha = (self.currentPage == 0) ? 0 : 1
        }
        
        // Update button title on last page
        if currentPage == numberOfPages - 1 {
            nextButton.setTitle("Get Started", for: .normal)
        } else {
            nextButton.setTitle("Next", for: .normal)
        }
    }
}
