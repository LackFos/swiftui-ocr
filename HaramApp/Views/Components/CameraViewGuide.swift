//
//  CameraViewGuide.swift
//  HaramApp
//
//  Created by Elvis on 21/06/25.
//
import SwiftUI

struct CameraViewGuide: View {
    var type: CameraViewGuideType
    
    init(isIngredientDetected: Bool) {
        self.type = isIngredientDetected ? .ingredientDetected : .ingredientNotDetected
    }

    var body: some View {
        VStack {
            Text(type.label)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundColor(.black)
            .background(Color.white)
            .cornerRadius(40)
        }
        .padding(.vertical, 24)
    }
}

enum CameraViewGuideType {
    case ingredientDetected
    case ingredientNotDetected
    
    var label: String {
        switch self {
        case .ingredientDetected:
            return "Label ditemukan"
        case .ingredientNotDetected:
            return "Mencari label bahan baku"
        }
    }
}
