//
//  Giphy.swift
//  Giphy
//
//  Created by Stephen Radford on 16/06/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Foundation
import Messages

class Giphy {
    
    static var requests = 0
    
    static let APIKey = "dc6zaTOxFJmzC"
    
}

extension Giphy {

    
    
    /// Search Giphy for a specific keyword
    ///
    /// - parameter query:    The query to search
    /// - parameter callback: Called when results are found
    class func search(query: String, callback: @escaping ([MSSticker]) -> Void) {
        
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let session = URLSession.shared
        let params = "?q=" + searchQuery! + "&api_key=" + self.APIKey
        let url = URL(string: "http://api.giphy.com/v1/gifs/search" + params)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let data = data else {
                callback([])
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                guard let dict = json as? [String:AnyObject] else {
                    callback([])
                    return
                }
                
                let data = dict["data"] as! [[String:AnyObject]]
                let gifs: [GIF] = data.map { json in
                    var gif = GIF()
                    gif.id = json["id"] as? String
                    gif.bitlyURL = json["bitly_url"] as? String
                    gif.bitlyGIFURL = json["bitly_gif_url"] as? String
                    
                    if let images = json["images"] as? [String:AnyObject] {
                        
                        
                        if let image = images["downsized_medium"] as? [String:AnyObject] {
                            var img = GiphyImage()
                            if let height = image["height"] as? String {
                                img.height = Int(height)
                            } else if let height = image["height"] as? Int {
                                img.height = height
                            }
                            
                            if let width = image["width"] as? String {
                                img.width = Int(width)
                            } else if let width = image["width"] as? Int {
                                img.width = width
                            }
                            
                            img.url = image["url"] as? String
                            
                            gif.images = [img]
                            
                        }
                        
                    }
                    
                    
                    return gif
                }
                
                let filtered = gifs.filter { $0.images.count > 0 }
                Giphy.requests = filtered.count
                
                
                var stickers = [MSSticker]()
                
                for gif in filtered {
                    let cache = GIFCache.cache
                    cache.sticker(for: gif) { sticker in
                        Giphy.requests -= 1
                        stickers.append(sticker)
                        if Giphy.requests == 0 {
                            callback(stickers)
                        }
                    }
                }
                
                
            } catch {
                print(error)
                callback([])
            }
            
        }
        
        task.resume()
        
    }
    
    
    
}
