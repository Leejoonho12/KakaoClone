import Foundation
import UIKit

var man = User(id: 1, userName: "남자")
var woman =  User(id: 2, userName: "여자", profileImageURL: "태연")
var otherPeople = User(id: 3, userName: "ChatGPT", profileImageURL: "gpt")

var message1 = MessageContent(senderID: man.id, textContent: "안녕하세요. 저는 남자입니다.")
var message2 = MessageContent(senderID: man.id, textContent: "저기요?")

var message3 = MessageContent(senderID: woman.id, textContent: "응 말해.")
var message4 = MessageContent(senderID: woman.id, textContent: "말하하하하ㅏ하랄라ㅏ라라라라라고고고고ㅗ고고고")

var message5 = MessageContent(senderID: man.id, textContent: "안녕")
var message6 = MessageContent(senderID: otherPeople.id, textContent: "My name is ChatGPT! How can I help you?")

var img = UIImage(named: "태연")!.pngData()!
var image1 = MessageContent(senderID: woman.id, imageContent: img)

var dummyDialogList1 = Dialog(opponent: woman, messages: [message1, message2, message3, message4, image1])
var dummyDialogList2 = Dialog(opponent: otherPeople, messages: [message1, message2, message3, message4])
var dummyDialogList3 = Dialog(opponent: otherPeople, messages: [message6])
