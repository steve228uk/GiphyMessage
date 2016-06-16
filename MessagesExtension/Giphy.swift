//
//  Giphy.swift
//  Giphy
//
//  Created by Stephen Radford on 16/06/2016.
//  Copyright © 2016 Cocoon Development Ltd. All rights reserved.
//

import Foundation

class Giphy {
    
    static let APIKey = "dc6zaTOxFJmzC"
    
}

extension Giphy {

    
    
    /// Search Giphy for a specific keyword
    ///
    /// - parameter query:    The query to search
    /// - parameter callback: Called when results are found
    class func search(query: String, callback: ([GIF]) -> Void) {
        
        let searchQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        let session = URLSession.shared()
        let params = "?q=" + searchQuery! + "&api_key=" + self.APIKey
        let url = URL(string: "http://api.giphy.com/v1/gifs/search" + params)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
//        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
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
                        
                        print(images)
                        
                        if let image = images["fixed_width_downsampled"] as? [String:AnyObject] {
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
                
                callback(gifs.filter { $0.images.count > 0 })
                
            } catch {
                print(error)
                callback([])
            }
            
        }
        
        task.resume()
        
    }
    
    
    
}
