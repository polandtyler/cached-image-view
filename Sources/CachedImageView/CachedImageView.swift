import Combine
import UIKit
import SwiftUI

// TODO: figure out how to **properly** expose this class to SwiftUI
public struct CachedImageViewSwiftUI: UIViewRepresentable, View {
    public typealias UIViewType = CachedImageView
    var urlString: String? {
        didSet {
        }
    }
    
    public func makeUIView(context: Context) -> CachedImageView {
        let view = CachedImageView(frame: .zero)
        view.urlString = urlString
        return view
    }
    
    public init(with urlString: String) {
        self.urlString = urlString
    }
    
    public func updateUIView(_ uiView: CachedImageView, context: Context) {
        return
    }
    
}

/// A UIImageView subclass that handles its own data loading state and image fetching
public final class CachedImageView: UIImageView {
    private var subscriptions = Set<AnyCancellable>()
    public var urlString: String?
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        return indicatorView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentMode = .scaleAspectFill
        self.layer.masksToBounds = true
        setupActivityIndicator()
    }
    
    public init(urlString: String) {
        super.init(frame: .zero)
        self.urlString = urlString
    }
    
    public override func layoutSubviews() {
        self.layer.cornerRadius = self.bounds.width / 2
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func loadImage(from urlString: String) {
        self.urlString = urlString
        
        if let imageFromCache = UIImage.imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            setImage(imageFromCache)
            return
        }
        
        UIImage.cacheImage(from: urlString) { [weak self] image, _ in
            guard let self = self, let imageFromCache = image else { return }
            self.setImage(imageFromCache)
        }
    }
    
    private func setImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.image = image
            self.activityIndicatorView.stopAnimating()
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicatorView.removeFromSuperview()
        
        addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        if self.image == nil {
            activityIndicatorView.startAnimating()
        }
    }
}
