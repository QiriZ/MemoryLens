//
//  BoxManager.swift
//  MemoryLens
//
//  Created by GH on 7/26/25.
//

import SwiftUI

@Observable
final class BoxManager {
    static let shared = BoxManager()
    
    private init() {}
    
    var box: BoundingBox? = nil
    
    func drawBox(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        box = BoundingBox(x: x, y: y, width: width, height: height)
    }
    
    func drawBox(box: BoundingBox) {
        self.box = box
    }
    
    func addRandomBox() {
        let x = CGFloat.random(in: 0...(1280-200))
        let y = CGFloat.random(in: 0...(720-150))
        let width = CGFloat.random(in: 100...200)
        let height = CGFloat.random(in: 80...150)
        drawBox(x: x, y: y, width: width, height: height)
    }
}
