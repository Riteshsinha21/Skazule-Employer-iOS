//
//  ReceiverImageCell.swift
//  Skazule
//
//  Created by CTS-Jay Gupta on 07/06/23.
//

import UIKit

class ReceiverImageCell: UITableViewCell {
    
    var message: Message2?{
        didSet{
            
            guard let message = self.message else { return }
            if message.timestamp != nil {
                let timeStamp = Date(timeIntervalSince1970: TimeInterval(message.timestamp!)! / 1000)
                self.lblTime.text = timeStamp.convertTimeInterval()
                self.lblDate.text = timeStamp.convertTimeInterval(format: "MMM d, yyyy")
            }
            // self.lblMessage.text = message.content
//            //   DOWNLOAD_IMAGE_BASE_URL +
            let url = message.content ?? ""
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

    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.roundRadius(options: [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], cornerRadius: 30)
        Images.roundRadius(options: [.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner], cornerRadius: 30)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
