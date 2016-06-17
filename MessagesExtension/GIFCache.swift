//
//  GIFCache.swift
//  Giphy
//
//  Created by Stephen Radford on 16/06/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Foundation
import Messages


class GIFCache {
    
    static let cache = GIFCache()
    
    private let cacheURL: URL
    
    private let queue = OperationQueue()
    
    // Thanks Apple! This is lifted from their Ice Cream app example
    let placeholderSticker: MSSticker = {
        let bundle = Bundle.main()
        guard let placeholderURL = bundle.urlForResource("sticker_placeholder", withExtension: "png") else { fatalError("Unable to find placeholder sticker image") }
        
        do {
            let description = NSLocalizedString("An placeholder sticker", comment: "")
            return try MSSticker(contentsOfFileURL: placeholderURL, localizedDescription: description)
        }
        catch {
            fatalError("Failed to create placeholder sticker: \(error)")
        }
    }()
    
    init() {
        let fileManager = FileManager.default()
        let tempPath = NSTemporaryDirectory()
        let directoryName = UUID().uuidString
        
        do {
            try cacheURL = URL(fileURLWithPath: tempPath).appendingPathComponent(directoryName)
            try fileManager.createDirectory(at: cacheURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch {
            fatalError("Unable to create cache URL: \(error)")
        }
    }
    
    deinit {
        let fileManager = FileManager.default()
        do {
            try fileManager.removeItem(at: cacheURL)
        }
        catch {
            print("Unable to remove cache directory: \(error)")
        }
    }
    
    func sticker(for gif: GIF, completion: (sticker: MSSticker) -> Void) {
        
        guard let gifUrlString = gif.images[0].url, let id = gif.id else { return }
        
        let fileName = "GIF-" + id + ".gif"
        guard let url = try? cacheURL.appendingPathComponent(fileName) else { fatalError("Unable to create sticker URL") }
        
        
        
        let gifUrl = URL(string: gifUrlString)!
        let session = URLSession.shared()
        
        print("DOWNLOADING: \(gifUrl)")
        
        var request = URLRequest(url: gifUrl)
        request.httpMethod = "GET"
        
        
        session.dataTask(with: gifUrl) { data, response, error in
        
            let operation = BlockOperation {
                
                let fileManager = FileManager.default()
                guard !fileManager.fileExists(atPath: url.absoluteString!) else { return }
                
                do {
                    try data?.write(to: url, options: [.atomicWrite])
                } catch {
                    fatalError("Failed to write sticker image to cache: \(error)")
                }
                
            }
            
            operation.completionBlock = {
                do {
                    let sticker = try MSSticker(contentsOfFileURL: url, localizedDescription: "GIF")
                    completion(sticker: sticker)
                } catch {
                    print("Failed to write image to cache, error: \(error)")
                }
            }
            
            self.queue.addOperation(operation)
            
        }.resume()
    
        
    }
    
}
