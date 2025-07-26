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
        WindowGroup {
            // 空的窗口，因为我们直接进入沉浸式空间
            EmptyView()
        }
        .windowStyle(.volumetric)
        .windowResizability(.contentSize)
        .defaultSize(width: 800, height: 600)
        
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(
                onExitApp: {
                    exit(0)
                }
            )
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
