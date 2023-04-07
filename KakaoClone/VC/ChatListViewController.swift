import Foundation
import UIKit

class ChatListViewController: UITableViewController{
    
    let chatRoomList: [String] = ["여자", "GPT"]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "rootCell", for: indexPath) as? ChatViewCell else { return UITableViewCell() }
        cell.cellLabel.text = chatRoomList[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cell = sender as? ChatViewCell,
              let label = cell.cellLabel else { return }
        if segue.identifier == "chatSegue" {
            if let vc = segue.destination as? KakaoViewController {
                if label.text == "여자"{
                    vc.opponentID = 1
                } else {
                    vc.opponentID = 2
                }
                self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
            }
        }
    }
}

class ChatViewCell: UITableViewCell{
    
    @IBOutlet weak var cellLabel: UILabel!
    
}


