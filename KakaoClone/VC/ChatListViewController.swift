import Foundation
import UIKit

class ChatListViewController: UITableViewController{
    
    var opid: Int = 0
    
    let chatRoomList: [String] = ["여자", "GPT"]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatRoomList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "rootCell", for: indexPath) as? ChatViewCell else { return UITableViewCell() }
        cell.cellLabel.text = chatRoomList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print(1)
        opid = indexPath.row
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(2)
        if segue.identifier == "chatSegue" {
            if let vc = segue.destination as? KakaoViewController {
                vc.opponentID = opid
            }
        }
    }
}

class ChatViewCell: UITableViewCell{
    
    @IBOutlet weak var cellLabel: UILabel!
    
}


