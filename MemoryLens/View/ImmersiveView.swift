//
//  ImmersiveView.swift
//  MemoryLens
//
//  Created by 齐修远 on 2025/7/26.
//

import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @State private var headAnchor: AnchorEntity?
    let onExitApp: () -> Void
    
    var body: some View {
        RealityView { content, attachments in
            let anchor = AnchorEntity(.head)
            anchor.anchoring.trackingMode = .continuous
            content.add(anchor)
//            anchor.name = "Head Anchor"
            
            if let debugAttachment = attachments.entity(for: "canvas") {
                debugAttachment.position = [0, 0, -0.5]
                anchor.addChild(debugAttachment)
            }
            
            headAnchor = anchor
        } attachments: {
            Attachment(id: "canvas") {
                CanvasView(onExitApp: onExitApp)
            }
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView(onExitApp: {})
}

    //        let sphereMesh = MeshResource.generateSphere(radius: 0.3)
    //        // Red sphere for X
    //        let redMaterial = SimpleMaterial(color: .red, isMetallic: false)
    //        let redSphere = ModelEntity(mesh: sphereMesh, materials: [redMaterial])
    //        redSphere.position = [1, 0, 0]
    //
    //        // Green sphere for Y
    //        let greenMaterial = SimpleMaterial(color: .green, isMetallic: false)
    //        let greenSphere = ModelEntity(mesh: sphereMesh, materials: [greenMaterial])
    //        greenSphere.position = [0, 0, -1]
    //
    //        // Blue sphere for Z
    //        let blueMaterial = SimpleMaterial(color: .blue, isMetallic: false)
    //        let blueSphere = ModelEntity(mesh: sphereMesh, materials: [blueMaterial])
    //        blueSphere.position = [0, 1, 0]
    //
    //        boxEntity.addChild(redSphere)
    //        boxEntity.addChild(greenSphere)
    //        boxEntity.addChild(blueSphere)
