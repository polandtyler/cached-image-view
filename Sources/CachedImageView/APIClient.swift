//
//  File.swift
//  
//
//  Created by Tyler Poland on 9/2/21.
//

import Foundation

public protocol CachedImageAPIProvider {
    var session: URLSession { get set }
    func getImageData(_ request: URLRequest,
                      completion: @escaping (Data?, URLResponse?, Error?) -> Void)
}

internal class ConcreteCachedImageAPIProvider: CachedImageAPIProvider {
    var session: URLSession = URLSession.shared
    
    func getImageData(_ request: URLRequest,
                                    completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        session.dataTask(with: request, completionHandler: completion).resume()
    }
}
