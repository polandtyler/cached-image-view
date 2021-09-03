//
//  File.swift
//  
//
//  Created by Tyler Poland on 9/2/21.
//

import UIKit

extension UIImage {
    static let imageCache = NSCache<AnyObject, AnyObject>()
    
    static func cacheImage(from urlString: String,
                           completion: @escaping (UIImage?, Error?) -> Void) {
        
        guard let url = URL(string: urlString) else { completion(.none, InvalidURLError()); return }
        
        ConcreteCachedImageAPIProvider().getImageData(URLRequest(url: url)) { optionalData, optionalResponse, optionalError in
            
            guard optionalError == nil else {
                completion(.none, optionalError)
                return
            }
            
            guard let data = optionalData, let image = UIImage(data: data) else {
                completion(nil, MalformedImageDataError())
                return
            }
            
            DispatchQueue.main.async {
                imageCache.setObject(image, forKey: urlString as AnyObject)
            }
            
            completion(image, .none)
        }
    }
}

struct InvalidURLError: Error {}

struct MalformedImageDataError: Error {}
