import UIKit
import PhotosUI

class KakaoViewController: UIViewController {
    
    var opponentID: Int = 1
    
    private var dialogDataManager = DialogDataManager()
    private var userDataManager = UserDataManager()
    private lazy var dialogDataSourceProvider = DialogDataSourceProvider(userDataManager: userDataManager, dialogDataManager: dialogDataManager)
    
    var searchBarButton: UIBarButtonItem?
    var cancelBarButton: UIBarButtonItem?
    var checkIndexPathBarButton: UIBarButtonItem?
    
    var filteredIndexPaths: [IndexPath] = []
    
    @IBOutlet weak var mainWrapperView: UIView!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var bottomInputView: UIView!
    
    @IBOutlet weak var dialogTableView: UITableView!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var hashTagButton: UIButton!
    
    @IBOutlet weak var addImageButton: UIButton!
    
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    override func loadView() {
        super.loadView()
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.dialogListgpt.rawValue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUser()
        
        textView.delegate = self
        dialogTableView.dataSource = dialogDataSourceProvider
        
        setUpBottomInputView()
        setUpTextView()
        
        setUpNavigationBarTitle()
        setUptBarButtonItems()
        
        registerCustomCell()
        
        addNotification()
        setUpGestureRecognizer(willTapView: dialogTableView)
        
        dialogDataManager.getDialogList()
        
        dialogTableView.contentInsetAdjustmentBehavior = .never
        
        scrollToBottomRow()
        
    }
    
    func setUser() {
        if opponentID == 1{
            dialogDataManager.userDefaultKey = .dialogList
        } else {
            dialogDataManager.userDefaultKey = .dialogListgpt
        }
    }
    

    func registerCustomCell() { // 커스텀셀을 등록하는 부분
        dialogTableView.register(UINib(nibName: "MyDialogTableViewCell", bundle: nil), forCellReuseIdentifier: "MyDialogTableViewCell") // 새 tableViewCell을 만드는데 사용할 클래스 등록
        dialogTableView.register(UINib(nibName: "OpponentDialogTableViewCell", bundle: nil), forCellReuseIdentifier: "OpponentDialogTableViewCell")
    }
    
    func addNotification() { // 노티피케이션센터에 옵저버를 추가해서 키보드 업다운을 비동기로 처리.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardToggleAnimate), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardToggleAnimate), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setUpGestureRecognizer(willTapView: UIView) { //탭제스처를 관리하는 부분인데 다시 찾아봐야 한다.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapAnyView))
        tapGestureRecognizer.cancelsTouchesInView = false
        willTapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func scrollToBottomRow() { //메세지를 담고있는 배열의 마지막 인덱스를 가져와서 맨 아래 인덱스로 스크롤 하는 부분
        let dialogCount = dialogDataSourceProvider.getDialogCount()
        let endIndex = IndexPath(row: dialogCount - 1, section: 0)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) { [weak self] in
            self?.dialogTableView.scrollToRow(at: endIndex, at: .bottom, animated: false)
        }
    }
    deinit {
        print("deinit finish")
    }
}

extension KakaoViewController: UISearchBarDelegate {
    
    func initBottomInputView() { // 텍스트뷰 내용 없애고 보내기버튼 활성화세팅하고 바텀으로 스크롤하고, 컨테이너인셋 세팅해주고 높이 잡아주고.
        textView.text = ""
        toggleSubmitButton()
        scrollToBottomRow()
        setUpTextView()
        bottomViewHeightConstraint.constant = CGFloat(Constraint.BOTTOM_VIEW_INIT_HEIGHT)
    }
    
    func setUpBottomInputView() { // 텍스트뷰에 코너레디우스랑 보더 세팅
        bottomInputView.layer.cornerRadius = textView.bounds.height / 2
        bottomInputView.layer.borderWidth = 1
        bottomInputView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func setUpTextView() { //텍스트뷰에 엣지인셋 세팅.
        textView.textContainerInset = TextViewInset.initial
    }
    
    func setUpNavigationBarTitle() { // 상대방의 이름을 가져와서 네비게이션 타이틀에 띄워준다.
        let titleLabel = UILabel()
        titleLabel.text = dialogDataSourceProvider.getGPTName()
        titleLabel.sizeToFit()
        self.navigationItem.titleView = titleLabel
    }
    
    func setUptBarButtonItems() { //네비게이션 타이틀바 세팅 해주는 부분
        checkIndexPathBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(leftBarBtnTapped))
        searchBarButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(rightBarBtnTapped))
        cancelBarButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(rightBarBtnTapped))
        let backBarButton = UIBarButtonItem(title: "??", style: .plain, target: self, action: nil)
        checkIndexPathBarButton?.tintColor = .lightGray
        searchBarButton?.tintColor = .lightGray
        cancelBarButton?.tintColor = .lightGray
        self.navigationItem.backBarButtonItem = backBarButton
        self.navigationItem.setRightBarButton(searchBarButton, animated: true)
    }
    
    func setUpSearchBar() { 
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "메세지 입력"
        searchBar.showsCancelButton = false
        searchBar.becomeFirstResponder() // 이 개체를 해당 창의 첫번째 응답자로 만들도록 UIKit에 요청한다.
        navigationItem.titleView = searchBar
    }
    
    func setUpPHPicker() -> PHPickerConfiguration { //사진라이브러리에서 자산?을 선택하기 위한 사용자인터페이스 제공
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1 // 한개만 선택
        configuration.filter = .images // 기본적으로 이미지, 라이브포토, 비디오 등 모든 자산유형을 표시한다.
        return configuration
    }
    
    func changeTextViewHeight(_ textView: UITextView) {
        let currentLines = textView.numberOfLine()
        let maxHeightConstraint = CGFloat(Constraint.BOTTOM_VIEW_HEIGHT_PER_ROW * 5 + Constraint.TEXT_VIEW_TOP_INSET)
        let dynamicHeight = CGFloat(Constraint.BOTTOM_VIEW_HEIGHT_PER_ROW * currentLines + Constraint.TEXT_VIEW_TOP_INSET)
        
        switch currentLines {
        case 1:
            bottomViewHeightConstraint.constant = CGFloat(Constraint.BOTTOM_VIEW_INIT_HEIGHT)
            textView.textContainerInset = TextViewInset.initial
        case 2...4:
            bottomViewHeightConstraint.constant = dynamicHeight
            
            textView.textContainerInset = TextViewInset.increasing
        case 5 where bottomViewHeightConstraint.constant != maxHeightConstraint:
            bottomViewHeightConstraint.constant = dynamicHeight
            
            textView.textContainerInset = TextViewInset.maxHeight
        default :
            textView.textContainerInset = TextViewInset.maxHeight
            break
        }
        
        scrollToBottomRow()
    }
    
    func toggleSubmitButton() { // 텍스트뷰 내용에 따라 보내기버튼 활성화
        let toggle = textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        hashTagButton.isHidden = !toggle
        submitButton.isHidden = toggle
    }
    
    func barButtonAnimation(hide: Bool) {
        if hide {
            UIView.animate(withDuration: 0.05, delay: 0, animations: { [weak self] in
                guard let self = self else { return }
                self.bottomView.transform = CGAffineTransform(translationX: 0, y: self.bottomView.frame.height)
            })
        } else {
            UIView.animate(withDuration: 0.05, delay: 0, animations: { [weak self] in
                guard let self = self else { return }
                self.bottomView.transform = .identity
            })
        }
    }
}

extension KakaoViewController {
    @IBAction func submitButtonTapped(_ sender: Any) {
        guard let text = textView.text else { return }
        dialogDataManager.addTextDialog(text)
        dialogTableView.reloadData()
        scrollToBottomRow()
        initBottomInputView()
        if opponentID == 2{
            askToGPT(text)
        }
    }
    
    @IBAction func addImageButtonTapped(_ sender: Any) {
        let configuration = setUpPHPicker()
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
}

extension KakaoViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                guard let img = image as? UIImage else { return }
                let data = img.compress(to: ImageQuality.normal)
                self.dialogDataManager.addImageDialog(data)
                
                DispatchQueue.main.async {
                    self.dialogTableView.reloadData()
                    self.scrollToBottomRow()
                }
            }
        }
        
    }
}

extension KakaoViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        changeTextViewHeight(textView)
        toggleSubmitButton()
    }
}

extension KakaoViewController {
    func askToGPT(_ text: String) {
        print("before")
        var returnText = "baseText"
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
//        let apiKey = ApiKey.apiKey
        request.setValue("Bearer \(ApiKey.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let inputData = ["model": "gpt-3.5-turbo", "messages": [["role": "user", "content": text]]] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: inputData)
        request.httpBody = jsonData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else { return }
            guard (200...299).contains(httpResponse.statusCode) else { return }
            guard let data = data else { return }
            do {
                let responseJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let choices = responseJson?["choices"] as? [[String: Any]] {
                    for choice in choices {
                        if let message = choice["message"] as? [String: Any], let content = message["content"] as? String {
                            returnText = content
                            print("Response message: \(content)")
                        }
                    }
                }
            } catch {
                print("Error decoding JSON response: \(error)")
            }
        }
        task.resume()
        
        _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
            if task.state == .completed {
                print("returnText == \(returnText)")
                self.dialogDataManager.addGPTTextDialog(returnText)
                self.dialogTableView.reloadData()
                self.scrollToBottomRow()
                self.initBottomInputView()
                $0.invalidate()
            }
        }
    }
}

extension KakaoViewController {
    @objc
    func keyboardToggleAnimate(_ sender: Notification) { // 뷰들이 키보드만큼 올라가고 테이블뷰에 키보드만큼 탑인셋이 생김
        guard let keyboardFrame = sender.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let bottomSafeAreaInset = view.safeAreaInsets.bottom
        
        switch sender.name {
        case UIResponder.keyboardWillShowNotification:
            mainWrapperView.transform = CGAffineTransform(translationX: 0, y: -(keyboardHeight - bottomSafeAreaInset))
            dialogTableView.contentInset.top = keyboardHeight - bottomSafeAreaInset
        case UIResponder.keyboardWillHideNotification:
            mainWrapperView.transform = .identity
            dialogTableView.contentInset.top = .zero
        default:
            break
        } // MARK: layoutIfNeeded
        self.view.layoutIfNeeded()
    }
    
    @objc
    func didTapAnyView() { // 여기도 다시 봐야 한다.
        if textView.isFirstResponder { // MARK: isFirstResponder
            textView.resignFirstResponder()
        }
    }
    
    @objc
    private func rightBarBtnTapped() {
        let barButton = self.navigationItem.rightBarButtonItem
        switch barButton {
        case searchBarButton:
            self.navigationItem.setRightBarButton(cancelBarButton, animated: true)
            self.navigationItem.setLeftBarButton(checkIndexPathBarButton, animated: true)
            barButtonAnimation(hide: true)
            setUpSearchBar()
        case cancelBarButton:
            self.navigationItem.setRightBarButton(searchBarButton, animated: true)
            self.navigationItem.leftBarButtonItem = nil
            setUpNavigationBarTitle()
            barButtonAnimation(hide: false)
        default:
            break
        }
    }
    
    @objc
    private func leftBarBtnTapped() {
        print(filteredIndexPaths)
    }
}

extension KakaoViewController {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { // MARK: all in function
        searchBar.resignFirstResponder()
        
        let messages = dialogDataManager.getDialog().messages
        var filteredArr: [Int] = []
        var IndexPaths: [IndexPath] = []
        filteredIndexPaths = []
        
        guard let text = searchBar.text else { return }
        
        for i in 0 ..< messages.count {
            if messages[i].contentType == .text {
                if messages[i].textContent!.contains(text) {
                    filteredArr.append(i)
                }
            }
        }
        if !filteredArr.isEmpty {
            for i in 0 ..< filteredArr.count {
                let filteredIndex = IndexPath(row: filteredArr[i], section: 0)
                IndexPaths.append(filteredIndex)
            }
            filteredIndexPaths = IndexPaths
            let endIndex = filteredIndexPaths.endIndex - 1
            let endIndexPath = filteredIndexPaths[endIndex]
            
            dialogTableView.scrollToRow(at: endIndexPath, at: .bottom, animated: true)
        }
    }
}
