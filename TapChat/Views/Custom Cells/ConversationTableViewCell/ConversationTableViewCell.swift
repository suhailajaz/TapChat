//
//  ConversationTableViewCell.swift
//  TapChat
//
//  Created by suhail on 09/11/23.
//

import UIKit
import SDWebImage
 
class ConversationTableViewCell: UITableViewCell {
    static let identifier = "ConversationTableViewCell"
    static let nib = UINib(nibName: "ConversationTableViewCell", bundle: nil)
    
    @IBOutlet var imgUserProfilePic: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblUserMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with model: Conversation){
        lblUserName.text = model.name
        lblUserMessage.text = model.latestMessage.text
        //let safeOtherUserEmail = DatabaseManager.shared.getSafeEmail(mail: model.otherUserEmail)
    
        let path = "images/\(model.otherUserEmail)-profile-picture.png"
        
        StorageManager.shared.downloadURL(for: path) {[weak self] result in
            switch result{
            case .success(let url):
                DispatchQueue.main.async{
                    self?.imgUserProfilePic.sd_setImage(with: url)
                }
            case .failure(let error):
                print("Failed to get image url: \(error)")
            }
        }
        
    }
}
