//
//  IPImageCollectionViewCell.swift
//  ImagePad
//
//  Created by Saurabh on 11/11/18.
//  Copyright © 2018 SaurabhGulia. All rights reserved.
//

import UIKit

class IPImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: IPCachedImageView!
    var photo: Photo? = nil
    
    override func awakeFromNib() {
//        imageView.layer.borderWidth = 2
//        imageView.layer.borderColor = UIColor.MustardColor.cgColor
    }
    
    func fillData(_ data: Photo){
        photo = data
        guard let thumbnailURL = data.thumbnailURL else {
            return
        }
        self.imageView.loadImage(atURL: thumbnailURL)
    }
    
    override func prepareForReuse() {
        self.imageView.image = nil
    }
}

extension IPImageCollectionViewCell {
    func reducePriorityOfDownloadtaskForCell(){
        guard let photo = photo, let thumbnailURL = photo.thumbnailURL else {
            return
        }
        NetworkManager.shared.reducePriorityOfTask(withURL: thumbnailURL)
    }
}
