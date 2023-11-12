//
//  NewConversationTableViewCell.swift
//  TapChat
//
//  Created by suhail on 12/11/23.
//

import UIKit

class NewConversationTableViewCell: UITableViewCell {
    
    static let identifier = "NewConversationTableViewCell"
    static let nib = UINib(nibName: "NewConversationTableViewCell", bundle: nil)
    
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    public func configure(with model: SearchResult){
        lblUserName.text = model.name
        
        let path = "images/\(model.email)-profile-picture.png"
        StorageManager.shared.downloadURL(for: path) {[weak self] result in
            switch result{
            case .success(let url):
                DispatchQueue.main.async{
                    self?.imgUser.sd_setImage(with: url)
                }
            case .failure(let error):
                print("Failed to get image url: \(error)")
            }
        }
    }
    
}
