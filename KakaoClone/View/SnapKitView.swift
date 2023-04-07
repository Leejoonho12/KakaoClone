import Foundation
import SnapKit
import Then
import SwiftUI

class MyView: UIView {
    
    public let myTableView = UITableView().then {
        $0.tag = 1
    }
    let myBottomView = UIView()
    let addImageButton = UIButton().then {
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
    }
    let bottomInputView = UIView().then {
        $0.backgroundColor = .lightGray
    }
    let inputTextView = UITextView().then {
        $0.backgroundColor = .lightGray
    }
    let addImojiButton = UIButton().then {
        $0.setImage(UIImage(systemName: "face.smiling"), for: .normal)
    }
    let btnStackView = UIStackView()
    let hashTagButton = UIButton().then {
        $0.setImage(UIImage(systemName: "number"), for: .normal)
    }
    let submitButton = UIButton().then {
        $0.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        subviewAdd()
        constraintsAdd()
    }
    
    func subviewAdd() {
        [myTableView,
        myBottomView].forEach(addSubview)
        
        [addImageButton,
        bottomInputView].forEach(myBottomView.addSubview)
        
        [inputTextView,
        addImojiButton,
        btnStackView].forEach(bottomInputView.addSubview)
        
        [hashTagButton,
         submitButton].forEach(btnStackView.addArrangedSubview)
    }
    
    func constraintsAdd() {
        myTableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(myBottomView.snp.top)
        }
        myBottomView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(42)
        }
        addImageButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(5)
            $0.bottom.equalToSuperview().inset(10)
            $0.trailing.equalTo(bottomInputView.snp.leading).inset(5)
        }
        bottomInputView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(5)
            $0.leading.equalToSuperview().inset(35)
            $0.trailing.equalToSuperview().inset(10)
        }
        inputTextView.snp.makeConstraints {
            $0.leading.bottom.top.equalToSuperview()
        }
        addImojiButton.snp.makeConstraints {
            $0.leading.equalTo(inputTextView.snp.trailing).inset(-5)
            $0.trailing.equalTo(btnStackView.snp.leading).inset(-5)
            $0.centerY.equalTo(addImageButton.snp.centerY)
        }
        btnStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(5)
            $0.centerY.equalTo(addImageButton.snp.centerY)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    struct MyViewController_PreViews: PreviewProvider {
//        static var previews: some View {
////            ViewController().toPreview()
//        }
//    }
}

