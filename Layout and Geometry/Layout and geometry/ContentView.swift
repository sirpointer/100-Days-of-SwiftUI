//
//  ContentView.swift
//  Layout and geometry
//
//  Created by Nikita Novikov on 04.10.2022.
//

import SwiftUI

struct ContentView: View {
    let rowHeight: CGFloat = 40.0
    
    private func scale(rowRect: CGRect, fullViewHeight: CGFloat) -> CGFloat {
        var scale: Double = rowRect.midY * 1.0 / fullViewHeight + 0.5
        
        if scale > 1.5 {
            scale = 1.5
        } else if scale < 0.5 {
            scale = 0.5
        }

        return scale
    }
    
    private func rowColor(rowRect: CGRect, fullViewHeight: CGFloat) -> Color {
        var hue: Double = rowRect.midY * 1.0 / fullViewHeight
        
        if hue > 1 {
            hue = 1
        } else if hue < 0 {
            hue = 0
        }
        
        return Color(hue: hue, saturation: 1, brightness: 1)
    }

    var body: some View {
        GeometryReader { fullView in
            ScrollView(.vertical) {
                ForEach(0..<50) { index in
                    GeometryReader { geo in
                        Text("Row #\(index)")
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .background(rowColor(rowRect: geo.frame(in: .global), fullViewHeight: fullView.size.height))
                            .rotation3DEffect(.degrees(geo.frame(in: .global).minY - fullView.size.height / 2) / 5, axis: (x: 0, y: 1, z: 0))
                            .opacity(geo.frame(in: .global).maxY / rowHeight - 4.0)
                            .scaleEffect(scale(rowRect: geo.frame(in: .global), fullViewHeight: fullView.size.height))
                    }
                    .frame(height: rowHeight)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
