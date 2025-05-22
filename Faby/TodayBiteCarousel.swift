import SwiftUI

// MARK: - TodayBite Carousel View
struct TodayBiteCarousel: View {
    @State private var activeIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    let bites: [TodayBite]
    let itemTapped: (TodayBite) -> Void
    
    // Timer for auto-scrolling
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 16) {
            // Carousel
            GeometryReader { geometry in
                let cardWidth = geometry.size.width - 40 // Full width with padding
                
                ZStack {
                    ForEach(Array(bites.enumerated()), id: \.element.hashValue) { index, bite in
                        TodayBiteCardView(bite: bite)
                            .scaleEffect(activeIndex == index ? 1.0 : 0.9)
                            .opacity(activeIndex == index ? 1.0 : 0.0) // Hide non-active cards
                            .offset(x: CGFloat(index - activeIndex) * cardWidth + dragOffset, y: 0)
                            .animation(.spring(), value: activeIndex)
                            .animation(.spring(), value: dragOffset)
                            .onTapGesture {
                                itemTapped(bite)
                            }
                    }
                }
                .frame(width: geometry.size.width, height: 200)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width
                        }
                        .onEnded { value in
                            let threshold = cardWidth * 0.2
                            if dragOffset > threshold && activeIndex > 0 {
                                activeIndex -= 1
                            } else if dragOffset < -threshold && activeIndex < bites.count - 1 {
                                activeIndex += 1
                            }
                            dragOffset = 0
                        }
                )
            }
            .frame(height: 200)
            .onReceive(timer) { _ in
                // Auto-scroll to next item every 5 seconds
                if !bites.isEmpty {
                    withAnimation {
                        activeIndex = (activeIndex + 1) % bites.count
                    }
                }
            }
            
            // Pagination dots
            HStack(spacing: 8) {
                ForEach(0..<bites.count, id: \.self) { index in
                    if activeIndex == index {
                        Capsule()
                            .fill(Color.purple) // Primary color
                            .frame(width: 24, height: 8)
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
            }
            .animation(.spring(), value: activeIndex)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - TodayBite Card View
struct TodayBiteCardView: View {
    let bite: TodayBite
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Food Image
            Group {
                if bite.imageName.hasPrefix("http") {
                    RemoteImage(url: bite.imageName, placeholder: Image(systemName: "photo"))
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(bite.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
            
            // Info overlay
            VStack(alignment: .leading, spacing: 4) {
                Text(bite.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                
                if let category = bite.category {
                    Text(category)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                Text(bite.time)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.7)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(width: 280, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Remote Image Support
struct RemoteImage: View {
    let url: String
    let placeholder: Image
    @State private var image: UIImage? = nil
    @State private var isLoading: Bool = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
                    .resizable()
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }
    
    private func loadImage() {
        guard let imageURL = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let data = data, let downloadedImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = downloadedImage
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

// MARK: - Make TodayBite Identifiable
extension TodayBite: Hashable {
    static func == (lhs: TodayBite, rhs: TodayBite) -> Bool {
        return lhs.title == rhs.title && 
               lhs.time == rhs.time && 
               lhs.imageName == rhs.imageName &&
               lhs.category == rhs.category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(time)
        hasher.combine(imageName)
        hasher.combine(category)
    }
} 