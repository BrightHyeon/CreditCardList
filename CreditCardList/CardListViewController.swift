//
//  CardListViewController.swift
//  CreditCardList
//
//  Created by HyeonSoo Kim on 2022/01/19.
//

import UIKit
import Kingfisher
import FirebaseDatabase

class CardListViewController: UITableViewController {
    var creditCardList: [CreditCard] = []
    var reference: DatabaseReference!   //Firebase Realtime Database
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //UITableView Cell Register
        let nibName = UINib(nibName: "CardListCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CardListCell")
        
        //Database 참조
        reference = Database.database().reference()
        //Database의 value변화를 관찰. 초기 데이터 및 value의 업데이트와 함께 블록이 호출됨.
        reference.observe(.value) { snapshot in //데이터는 FIRDataSnapshot객체 형태로 전달됨.
                                                //자료구조 데이터타입 정확히 명시해야함. 아니면 nil반환.
            guard let value = snapshot.value as? [String: [String: Any]] else { return }
            //오류 내포하기에 do-try-catch구문사용
            do {
                //snapshot객체의 value를 => json형태로
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                //jsondata => decoding하여 이용가능하도록.
                let cardData = try JSONDecoder().decode([String: CreditCard].self, from: jsonData)
                //item0, item1...등 key 제외한 value만 배열로 추출 후 정렬하고 할당.
                let cardList = Array(cardData.values)
                self.creditCardList = cardList.sorted { $0.rank < $1.rank }
                //리로드는 UI를 움직이게하기에 디스패치큐의 메인쓰레드에 해당액션을 넣어줌.
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print("ERROR JSON parsing \(error.localizedDescription)")
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditCardList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardListCell", for: indexPath) as? CardListCell else { return UITableViewCell() }
        cell.rankLabel.text = "\(creditCardList[indexPath.row].rank)위"
        cell.promotionLabel.text = "\(creditCardList[indexPath.row].promotionDetail.amount)만원 증정"
        cell.cardNameLabel.text = "\(creditCardList[indexPath.row].name)"
        
        let imageURL = URL(string: creditCardList[indexPath.row].cardImageURL)
        //Kingfisher이용하여 이미지뷰에 URL통해 가져온 이미지 세팅
        cell.cardImageView.kf.setImage(with: imageURL)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //상세화면 전달
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController else { return }
        
        detailViewController.promotionDetail = creditCardList[indexPath.row].promotionDetail
        //accessory action으로 연결해서 show?
        self.show(detailViewController, sender: nil)
        
        
        //database에 경로업데이트 가능.
        //child메서드 사용. 슬래쉬(/)로 하위경로접근 후 setValue 이용.
        //Option1(key값에 쉽게 접근가능할 때)
        let cardID = creditCardList[indexPath.row].id
//        reference.child("Item\(cardID)/isSelected").setValue(true)
        
        //Option2(key값을 알기힘들때 하위정보를 이용해 key에 접근)
        reference.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) {[weak self] snapshot in
            guard let self = self,
                  let value = snapshot.value as? [String: [String: Any]],
                  let key = value.keys.first else { return }
            
            self.reference.child("\(key)/isSelected").setValue(true)
        }
        
    }
    //
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Option1
            let cardID = creditCardList[indexPath.row].id
            reference.child("Item\(cardID)").removeValue()
            
            //Option2
//            reference.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) {[weak self] snapshot in
//                guard let self = self,
//                      let value = snapshot.value as? [String: [String: Any]],
//                      //하나의 인덱스를 가진 배열형태가 오기에 형태상 keys.first로 접근.
//                      let key = value.keys.first else { return }
//
//                self.reference.child(key).removeValue()
//            }
        }
    }
    
}
