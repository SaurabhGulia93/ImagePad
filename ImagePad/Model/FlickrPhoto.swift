//
//  FlickrPhoto.swift
//  ImagePad
//
//  Created by Saurabh on 11/11/18.
//  Copyright © 2018 SaurabhGulia. All rights reserved.
//

import Foundation

struct FlickrPhoto {
    private struct Constants {
        static let id = "id"
        static let farm = "farm"
        static let server = "server"
        static let secret = "secret"
    }
    let photoID : String
    let server : String
    let secret : String
    let farm : Int
    
    init(data: [AnyHashable: Any]) throws {
        guard let photoID = data[Constants.id] as? String,
            let farm = data[Constants.farm] as? Int ,
            let server = data[Constants.server] as? String ,
            let secret = data[Constants.secret] as? String else {
                
                throw ParsingError.keyMissing
        }
        self.photoID = photoID
        self.server = server
        self.secret = secret
        self.farm = farm
    }
}

extension FlickrPhoto: Photo {
    var thumbnailURL: URL?{
        get{
            //q size suffix stands for large square 150x150 size image
            if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_q.jpg") {
                return url
            }
            return nil
        }
    }
    var highResPhotoURL: URL?{
        get{
            // b size suffix stands for a high resolution photo
            if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_b.jpg") {
                return url
            }
            return nil
        }
    }
}

enum ParsingError: Error {
    case keyMissing
}
