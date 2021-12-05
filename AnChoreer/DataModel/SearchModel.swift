//
//  SearchModel.swift
//  AnChoreer
//
//  Created by Kim dohyun on 2021/12/02.
//

import Foundation

struct SearchModel: Codable {
    var items: [SearchModelInfo]
}

struct SearchModelInfo: Codable {
    var title: String
    var actor: String
    var director: String
    var userRating: String
    var image: String
    var link: String
}

