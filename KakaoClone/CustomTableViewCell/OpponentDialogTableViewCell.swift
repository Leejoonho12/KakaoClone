import UIKit

class OpponentDialogTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentWrapperView: UIView!
    
    var imageViewConstraint: NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                contentImageView.removeConstraint(oldValue!)
            }
            if imageViewConstraint != nil {
                contentImageView.addConstraint(imageViewConstraint!)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentWrapperView.layer.masksToBounds = true
        contentWrapperView.layer.cornerRadius = 15
        contentImageView.clipsToBounds = true
        contentImageView.layer.cornerRadius = 15
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentLabel.text = nil
        contentWrapperView.isHidden = false
        profileImageView.isHidden = false
        profileImageView.image = UIImage(named: "태연")
        nameLabel.isHidden = false
        contentImageView.isHidden = true
        self.layoutIfNeeded()
    }
    
    func setPostedImage(image: UIImage) {
        let aspect = image.size.width / image.size.height
        imageViewConstraint = NSLayoutConstraint(item: contentImageView!, attribute: .width, relatedBy: .equal, toItem: contentImageView, attribute: .height, multiplier: aspect, constant: 0.0)
        contentImageView.image = image
    }
    
    func configure(message: MessageContent, date: String) {
        let contentType = message.contentType
        
        switch contentType {
        case .text:
            contentLabel.text = message.textContent
            contentImageView.isHidden = true
        case .image:
            if let data = message.imageContent {
                let img = UIImage(data: data)!
                setPostedImage(image: img)
            }
            contentImageView.isHidden = false
            contentWrapperView.isHidden = true
        @unknown case _:
            print("ContentType에 추가 할 것 예) 동영상")
        }
        dateLabel.text = date
    }
}
