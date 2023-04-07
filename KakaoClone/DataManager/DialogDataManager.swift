import Foundation

let MY_ID = 1
let OPPONENT_ID = 2
let GPT_ID = 3

enum users {
    case myID
    case opponentID
    case gptID
}

public class DialogDataManager {
    public let myID: Int = MY_ID
    public var opponentID: Int = OPPONENT_ID
    public var gptID: Int = GPT_ID
    
    var userDefaultKey: UserDefaultsKey = .dialogList
    
    let userDefaults = UserDefaults.standard
    
    public var dialogList: [Dialog] = []
    
    lazy var opponentIndex = dialogList.firstIndex(where: {$0.opponent.id == opponentID}) ?? 0
    public lazy var dialog = dialogList [opponentIndex] {
        didSet {
            dialogList[opponentIndex] = dialog
        }
    }
    
    func saveDialog(_ dialogList: [Dialog]) {
        let encodeedData = dialogList.map{ try! JSONEncoder().encode($0) }
        userDefaults.set(encodeedData, forKey: userDefaultKey.rawValue)
    }
    
    func loadDialog() -> [Dialog] {
        guard let data = userDefaults.array(forKey: userDefaultKey.rawValue) as? [Data] else {
            if userDefaultKey == .dialogList{
                return [dummyDialogList2]
            } else {
                return [dummyDialogList3]
            }
        }
        let decodedData = data.map{ try! JSONDecoder().decode(Dialog.self, from: $0) }
        return decodedData
    }
    
    public func getDialogList() {
        dialogList = loadDialog()
    }
    
    public func getDialog() -> Dialog {
        return dialog
    }
    
    public func getDialogCount() -> Int {
        return dialog.messages.count
    }
    
    public func addTextDialog(_ message: String) {
        let content = MessageContent(senderID: myID, textContent: message)
        dialog.messages.append(content)
        saveDialog(dialogList)
    }
    
    public func addImageDialog(_ message: Data) {
        let content = MessageContent(senderID: myID, imageContent: message)
        dialog.messages.append(content)
        saveDialog(dialogList)
    }
    
    public func addGPTTextDialog(_ message: String) {
        let content = MessageContent(senderID: gptID, textContent: message)
        dialog.messages.append(content)
        saveDialog(dialogList)
    }
}
