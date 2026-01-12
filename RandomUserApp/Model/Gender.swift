//
//  Gender.swift
//  RandomUserApp
//
//  Created by JooYoung Kim on 1/12/26.
//

import Foundation

enum Gender: Int, CaseIterable {
    case male = 0
    case female = 1
    
    var title: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
}
