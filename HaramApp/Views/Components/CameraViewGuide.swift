//
//  CameraViewGuide.swift
//  HaramApp
//
//  Created by Elvis on 21/06/25.
//
import SwiftUI

struct CameraViewGuide: View {
    var body: some View {
        VStack {
            HStack {
                Text("Point camera to ingredients")
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .foregroundColor(.black)
            .background(Color.white)
            .cornerRadius(40)
        }
        .padding(.vertical, 24)
    }
}
