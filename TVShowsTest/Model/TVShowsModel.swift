//
//  TVShowsModel.swift
//  TVShowsTest
//
//  Created by Abel Lazaro on 08/08/23.
//

import Foundation

struct TVShowsModel: Codable {
    var show: Show?
    public init() {
    }
}
struct Show: Codable {
    var name: String?
    var genres: [String]?
    var runtime: Int?
    var image: Image?
    var externals: Externals?
    var summary: String?
    public init() {
    }
}

struct Image: Codable {
    var medium: String?
    public init() {
    }
}

struct Externals: Codable {
    var imdb: String?
    public init() {
    }
}
