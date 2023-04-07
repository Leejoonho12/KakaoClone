import UIKit

class MyDialogTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
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
        contentImageView.layer.masksToBounds = true
        contentImageView.layer.cornerRadius = 15
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentLabel.text = nil
        contentWrapperView.isHidden = false
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
            contentLabel.sizeToFit()
            contentImageView.isHidden = true
        case .image:
            if let data = message.imageContent {
                let img = UIImage(data: data)!
                setPostedImage(image: img)
            }
            contentWrapperView.isHidden = false
            contentLabel.isHidden = true
        @unknown case _:
            print("ContentType에 추가하기? 뭐 더 있을게 있나?")
        }
        dateLabel.text = date
    }
    
}
