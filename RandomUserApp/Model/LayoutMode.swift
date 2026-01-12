//
//  LayoutMode.swift
//  RandomUserApp
//
//  Created by JooYoung Kim on 1/12/26.
//

import Foundation

enum LayoutMode {
    case oneColumn
    case twoColumn
    
    mutating func toggle() {
        self = (self == .oneColumn) ? .twoColumn : .oneColumn
    }
    
    var iconName: String {
        switch self {
        case .oneColumn: return "square.grid.2x2"
        case .twoColumn: return "rectangle.grid.1x2"
        }
    }
}
