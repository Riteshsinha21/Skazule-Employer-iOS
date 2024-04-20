//
//  SenderImageCell.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 07/06/23.
//

import UIKit

class SenderImageCell: UITableViewCell {
    
    var message: Message2?{
        didSet{
            
            guard let message = self.message else { return }
            if message.timestamp != nil {
                let timeStamp = Date(timeIntervalSince1970: TimeInterval(message.timestamp!)! / 1000)
                self.lblTime.text = timeStamp.convertTimeInterval()
                self.lblDate.text = timeStamp.convertTimeInterval(format: "MMM d, yyyy")
            }
            let url = message.content ?? ""
            // DOWNLOAD_IMAGE_BASE_URL +
            if url != ""
            {
                self.Images.sd_setImage(with: URL(string:  url ), placeholderImage: UIImage(named: "gallery"))
            }
        }
    }
    
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var Images: UIImageView!
    
    @IBOutlet weak var userPhotoImgView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imageBtn: UIButton!
    
    
//    @IBOutlet weak var lblTime: UILabel!
//    @IBOutlet weak var lblDate: UILabel!
//    @IBOutlet weak var lblMessage: UILabel!
//    @IBOutlet weak var messageView: UIView!
//    @IBOutlet weak var Images: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.roundRadius(options: [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], cornerRadius: 30)
        Images.roundRadius(options: [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner], cornerRadius: 30)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
