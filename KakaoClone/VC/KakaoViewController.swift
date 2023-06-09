import UIKit
import PhotosUI
import Alamofire

class KakaoViewController: UIViewController {
    
    static let kc = KakaoViewController()
    
    var opponentID: Int = 1
    
    var dialogDataManager = DialogDataManager()
    var userDataManager = UserDataManager()
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
    
    func setUpGestureRecognizer(willTapView: UIView) { //didTapAnyView메스드를 이용해 텍스트뷰를 편집종료 상태로 만들어 키보드 숨김
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
            askToGPT(QuestionContent: text)
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

/*
 api통신정리
 url리퀘스트를 만들어서 url, header, body, apikey, method등등 을 추가해서 urlsession의 dataTask함수에 담아서 보낸다.
 응답이 오면 completionhandler가 data?, response?, error? 를 가져오는데 response의 스테이터스코드로 통신 결과도
 확인 할 수 있고 한 모양이다. 여긴 더 알아보고 data에 응답데이터가 담겨있는데 이걸 받아와서 원하는 타입으로 캐스팅 해주면 끝.
 error는 어떻게 써야 할 지 알아봐야 한다. 비동기로 처리되고 시간이 좀 걸리다보니 데이터를 받아온 시점을 알기위해서 result타입을 사용했다.
 
 1. 리퀘스트 생성 및 세팅
 2. dataTask실행해서 리스폰스랑 에러를 넘겨주고 result에 데이터나 에러를 담아서 탈출
 3. result에 있는 데이터를 바인딩 하고 에러처리
 4. 테이블뷰에 뿌려주기.
 
 바인딩 하는 부분을 따로 빼려고 했지만 여기서 에러처리 하면 안된다고 에러나서 보류. 재시도 해봐야 함.
 */
extension KakaoViewController {
    // traillingclosure에 성공시 데이터바인딩
    // 결국 뷰컨에... 다른 클래스에서 할 수 있는 방법 마저 알아보기
    // 다음작업: 강제추출 제거. 통신부분 다 고치고 감 잡고 전체적인 리팩토링 ㄱㄱ
    func askToGPT(QuestionContent: String) {
        let request: URLRequest = ApiService.shared.makeRequest(requestType: .chatGpt(QuestionContent))
        ApiService.shared.getResponseValue(request: request){ result in
            switch result {
            case .success(let data):
                do {
                    let responseJson = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                    guard let choices = responseJson?["choices"] as? [[String: Any]],
                          let message = choices.first?["message"] as? [String: Any],
                          let content = message["content"] as? String else { return }
                    print("returnMessage = \(content)")
                    self.reloadTeableView(returnText: content)
                } catch {
                    print("Error: \(error)")
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    // api통신 결과를 가지고 테이블뷰에 추가. 메인쓰레드에서 실행되어야 한다는 경고문이 떠서 dispatchqueue 사용.
    func reloadTeableView(returnText: String) {
        DispatchQueue.main.async {
            self.dialogDataManager.addGPTTextDialog(returnText)
            self.dialogTableView.reloadData()
            self.initBottomInputView()
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
        }
        self.view.layoutIfNeeded() // UI를 업데이트 하라는 queue에 뒷쪽에 넣는것이 아니라, 맨 앞쪽에 넣어서 곧바로 UI가 변경되기를 기대할수있는 메소드.
    }
    
    @objc
    func didTapAnyView() { // 여기도 다시 봐야 한다.
        if textView.isFirstResponder { //첫번째 응답자라면(입력가능한 상태)
            textView.resignFirstResponder() // 첫번째 응답자 상태 사임(입력 불가능한 상태)
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
