//
//  CameraViewAction.swift
//  HaramApp
//
//  Created by Elvis on 21/06/25.
//
import SwiftUI

struct CameraViewAction: View {
    let onCapture: () -> Void
    
    init(onCapture: @escaping () -> Void) {
        self.onCapture = onCapture
    }
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "photo")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            .padding(.all, 16)
            .background(Color.white.opacity(0.1))
            .clipShape(Circle())
            
            Spacer()
            
            Button(action: onCapture) {
                Circle()
                    .fill(Color.white)
                    .frame(width: 80, height: 80)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            .padding(.all, 16)
            .background(Color.white.opacity(0.1))
            .clipShape(Circle())
        }.padding(.all, 24)
    }
}
