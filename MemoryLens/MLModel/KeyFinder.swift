//
//  KeyFinder.swift
//  MemoryLens
//
//  Created by 齐修远 on 2025/7/26.
//

import SwiftUI

struct KeyFinder {
    static let finder = try? KeyDetection()
    static var keyBuffer: String? = nil {
        didSet {
            if keyBuffer != nil {
                
            }
        }
    }
    
    func find(image: UIImage) -> BoundingBox? {
        guard let cgImage = image.cgImage else { return nil }
        guard let finder = KeyFinder.finder else { return nil }
        
        do {
            let input = try KeyDetectionInput(imageWith: cgImage)
            
            let output = try finder.prediction(input: input)
            
            let result = output.coordinates
            
            let boundingBox = BoundingBox(
                x: CGFloat(truncating: result[0]),
                y: CGFloat(truncating: result[1]),
                width: CGFloat(truncating: result[2]),
                height: CGFloat(truncating: result[3])
            )
            
            return boundingBox
        } catch {
            print(error.localizedDescription)
        }
        
        return nil
    }
}

