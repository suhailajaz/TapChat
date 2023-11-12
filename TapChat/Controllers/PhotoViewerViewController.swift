//
//  PhotoViewerViewController.swift
//  TapChat
//
//  Created by suhail on 24/10/23.
//

import UIKit
import SDWebImage

class PhotoViewerViewController: UIViewController {

    @IBOutlet var imgFullSizePhoto: UIImageView!
    
     var url: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .black
        imgFullSizePhoto.sd_setImage(with: self.url)
    }
    
}
