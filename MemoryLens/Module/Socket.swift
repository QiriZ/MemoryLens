//
//  Socket.swift
//  MemoryLens
//
//  Created by 齐修远 on 2025/7/26.
//

import Starscream
import SwiftUI

@Observable
class Socket: WebSocketDelegate {
    static let shared = Socket()
    var connecting: Bool = false
    var socket: WebSocket!
    
    private init() {
        let socket = WebSocket(request: URLRequest(url: URL(string: "ws://172.20.10.2:8765/")!))
        self.socket.delegate = self
        
        connect()
    }
    
    func connect() {
        if !connecting {
            socket.connect()
        }
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let dictionary):
            print("connected")
            connecting = true
        case .disconnected(let string, let uInt16):
            print("disconnected | \(string) | \(uInt16)")
            connecting = false
            connect()
        case .text(let string):
            guard let data = string.data(using: .utf8) else { return }
            guard let image = UIImage(data: data) else { return }
            guard let boundingBox = KeyFinder().find(image: image) else { return }
            BoxManager.shared.drawBox(box: boundingBox)
            
        case .binary(let data):
            print("Received data: \(data.count)")
        case .pong(let data):
            print("pong")
        case .ping(let data):
            print("ping")
        case .error(let error):
            print(error?.localizedDescription)
        case .viabilityChanged(let bool):
            print("viabilityChanged: \(bool)")
        case .reconnectSuggested(let bool):
            print("reconnectSuggested: \(bool)")
        case .cancelled:
            print("cancelled")
        case .peerClosed:
            print("peerClosed")
        }
    }
}
