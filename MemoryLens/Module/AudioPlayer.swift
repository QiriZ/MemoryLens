//
//  AudioPlayer.swift
//  MemoryLens
//
//  Created by 齐修远 on 2025/7/26.
//

import Foundation
import AVFoundation

class AudioPlayer {
    static let shared = AudioPlayer()

    private var player: AVPlayer?

    func play(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ 无效的 URL")
            return
        }

        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        player?.play()

        print("🔊 正在播放音频：\(url.lastPathComponent)")
    }

    func stop() {
        player?.pause()
        player = nil
    }
}
