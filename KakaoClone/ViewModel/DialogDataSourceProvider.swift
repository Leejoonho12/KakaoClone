import Foundation
import UIKit

public class DialogDataSourceProvider: NSObject {
    private let userDataManager: UserDataManager
    private let dialogDataManager: DialogDataManager
    
    init(userDataManager: UserDataManager, dialogDataManager: DialogDataManager) {
        self.userDataManager = userDataManager
        self.dialogDataManager = dialogDataManager
    }
    
    func getHourAndMinutes(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    public func getOpponentName() -> String {
        let opponent = userDataManager.getUser(dialogDataManager.opponentID)
        return opponent.userName
    }
    
    public func getGPTName() -> String {
        let opponent = userDataManager.getUser(dialogDataManager.gptID)
        return opponent.userName
    }
    
    public func getDialogCount() -> Int {
        return dialogDataManager.getDialogCount()
    }
}

extension DialogDataSourceProvider: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogDataManager.getDialogCount()
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var previousID = 0
        let myDialog = dialogDataManager.dialog.messages
        if indexPath.row > 1 {
            let previousDialog = myDialog[indexPath.row - 1]
            previousID = previousDialog.senderID
        }
        let message = myDialog[indexPath.row]
        let date = getHourAndMinutes(message.inputDate)
        
        let sender = userDataManager.getUser(message.senderID)
        let profileImage = sender.profileImageURL
        
        switch message.senderID {
        case dialogDataManager.myID:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyDialogTableViewCell", for: indexPath) as? MyDialogTableViewCell else { return MyDialogTableViewCell() }
            cell.configure(message: message, date: date)
            return cell
        case dialogDataManager.opponentID:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OpponentDialogTableViewCell", for: indexPath) as? OpponentDialogTableViewCell else { return OpponentDialogTableViewCell() }
            cell.nameLabel.text = sender.userName
            cell.profileImageView.image = UIImage(named: profileImage)
            cell.configure(message: message, date: date)
            let isfirst = dialogDataManager.opponentID == previousID
            cell.nameLabel.isHidden = isfirst
            cell.profileImageView.isHidden = isfirst
            return cell
        case dialogDataManager.gptID:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "OpponentDialogTableViewCell", for: indexPath) as? OpponentDialogTableViewCell else { return OpponentDialogTableViewCell() }
            cell.nameLabel.text = sender.userName
            cell.profileImageView.image = UIImage(named: profileImage)
            cell.configure(message: message, date: date)
            cell.contentLabel.sizeToFit()
            return cell
        default:
            return UITableViewCell()
        }
    }
}
