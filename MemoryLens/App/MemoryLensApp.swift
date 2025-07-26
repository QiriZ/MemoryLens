//
//  MemoryLensApp.swift
//  MemoryLens
//
//  Created by 齐修远 on 2025/7/26.
//

import SwiftUI

@main
struct MemoryLensApp: App {
    
    init() {
//        _ = Socket.shared  // 自动调用 init() 并尝试连接
    }
    
    var body: some Scene {
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
