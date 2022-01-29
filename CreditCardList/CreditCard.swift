//
//  CreditCard.swift
//  CreditCardList
//
//  Created by HyeonSoo Kim on 2022/01/19.
//

import Foundation

struct CreditCard: Codable {
    let cardImageURL: String
    let id: Int
    let rank: Int
    let name: String
    let promotionDetail: PromotionDetail
    let isSelected: Bool? //추후에 사용자가 카드를 선택했을 때 사용될 것이고, 그 전까진 nil을 갖고있을 것이니 옵셔널 불값.
}

struct PromotionDetail: Codable {
    let companyName: String
    let amount: Int
    let period: String
    let benefitDate: String
    let benefitDetail: String
    let benefitCondition: String
    let condition: String
}
