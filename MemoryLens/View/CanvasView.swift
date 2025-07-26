//
//  CanvasView.swift
//  MemoryLens
//
//  Created by GH on 7/26/25.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct CanvasView: View {
    @Bindable private var boxManager = BoxManager.shared
    @State private var recognizer = SpeechRecognizer()
    @State private var silence: Timer?

    var body: some View {
        ZStack {
            Canvas { context, size in
                if let box = boxManager.box {
                    let rect = CGRect(x: box.x, y: box.y, width: box.width, height: box.height)
                    context.stroke(Path(rect), with: .color(.white), lineWidth: 6)
                }
            }
            
            VStack(spacing: 10) {
                Button {
                    boxManager.addRandomBox()
                } label: {
                    Circle()
                        .fill(Material.thin)
                        .frame(height: 44)
                        .overlay {
                            Image(systemName: "pencil.line")
                        }
                }
                .buttonStyle(.plain)
                
                Button {
                    boxManager.addRandomBox()
                } label: {
                    Circle()
                        .fill(Material.thin)
                        .frame(height: 44)
                        .overlay {
                            Image(systemName: "pencil.line")
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(8)
            .glassBackgroundEffect()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(recognizer.recognizedText)
        }
        .onAppear {
            recognizer.start()
            startSilence()
        }
        .onDisappear {
            silence?.invalidate()
            recognizer.stop()
        }
    }
    
    func startSilence() {
        silence = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            silence?.invalidate()
            send()
        }
    }
    
    func send() {
        defer {
            recognizer.stop()
            silence?.invalidate()

        }
        guard let image = KeyFinder.keyBuffer else { return }
        guard let url = getImageURL(image: image) else { return }
        
        let workflow: Workflow = Workflow(
            workflowId: workflowId,
            parameters: Workflow.Parameters(
                blockId: blockId,
                chatId: chatId,
                image: url,
                input: recognizer.recognizedText
            )
        )
        
        let result = AF.request(
            cozeBaseURL + "/v1/workflows/runs",
            method: .post,
            parameters: workflow,
            encoder: JSONParameterEncoder(),
            headers: []
        )
        
        guard let data = result.data else { return }
        let json = try? JSON(data: data)
        
        
    }
    
    func getImageURL(image: String) -> String? {
        let result = AF.request(
            "\(imageServerURL)/getImageURL",
            method: .get,
            parameters: ["image": image],
            encoder: JSONParameterEncoder(),
        )
        
        guard let data = result.data else { return nil }
        let json = try? JSON(data: data)
        let url = json?["url"].string
        
        return url
    }
}

#Preview {
    CanvasView()
}

struct Workflow: Codable {
    let workflowId: String
    let parameters: Parameters
    
    enum CodingKeys: String, CodingKey {
        case workflowId = "workflow_id"
        case parameters
    }
    
    struct Parameters: Codable {
        let blockId: String
        let chatId: String
        let image: String
        let input: String
        
        enum CodingKeys: String, CodingKey {
            case blockId = "block_id"
            case chatId = "chat_id"
            case image
            case input
        }
    }
}
