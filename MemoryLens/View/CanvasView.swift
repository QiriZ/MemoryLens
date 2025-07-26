//
//  CanvasView.swift
//  MemoryLens
//
//  Created by GH on 7/26/25.
//

import SwiftUI
import AVFoundation

// 音频播放器管理器类
class AudioPlayerManager: NSObject, AVAudioPlayerDelegate, ObservableObject {
    @Published var showVoiceResponse: Bool = false
    @Published var voiceResponseText: String = ""
    var onAudioFinished: (() -> Void)?
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // 隐藏字幕
        showVoiceResponse = false
        voiceResponseText = ""
        
        // 通知CanvasView音频播放结束
        onAudioFinished?()
        
        print("Audio finished playing")
    }
}

struct CanvasView: View {
    @StateObject private var boxManager = BoxManager.shared
    @State private var recognizer = SpeechRecognizer()
    @State private var silence: Timer?
    let onExitApp: () -> Void
    
    // UI状态管理
    @State private var selectedTab: Int = 0
    @State private var showMemoryBook: Bool = false
    @State private var showSettings: Bool = false
    @State private var audioLevel: CGFloat = 0.0
    @State private var isRecording: Bool = false
    @State private var waveOffset: CGFloat = 0.0
    @State private var dotPosition: CGFloat = 0.0
    @State private var recognizedText: String = ""
    
    // 设置相关状态
    @State private var voiceInteractionEnabled: Bool = true
    @State private var realTimeRecordingEnabled: Bool = true
    @State private var isRecordingIndicator: Bool = false
    @State private var recordingTimer: Timer?
    
    // 语音交互功能状态
    @StateObject private var audioManager = AudioPlayerManager()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var silenceTimer: Timer?
    
    // 物品记忆卡状态
    @State private var showItemMemoryCard: Bool = false
    @State private var selectedItem: MemoryItem?

    var body: some View {
        ZStack {
            // 背景Canvas - 用于绘制检测框
            Canvas { context, size in
                if let box = boxManager.box {
                    let rect = CGRect(x: box.x, y: box.y, width: box.width, height: box.height)
                    context.stroke(Path(rect), with: .color(.white), lineWidth: 6)
                }
            }
            
            // 1. 左侧五个功能按钮 - 紧贴左侧，高度与界面中间齐平
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    // 主页按钮
                    Button(action: { selectedTab = 0 }) {
                        Circle()
                            .fill(selectedTab == 0 ? Color.orange.opacity(0.8) : Color.orange.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    // 回忆簿按钮
                    Button(action: { 
                        selectedTab = 1
                        showMemoryBook.toggle()
                    }) {
                        Circle()
                            .fill(selectedTab == 1 ? Color.orange.opacity(0.8) : Color.orange.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    // 设置按钮
                    Button(action: { 
                        selectedTab = 2
                        showSettings.toggle()
                    }) {
                        Circle()
                            .fill(selectedTab == 2 ? Color.orange.opacity(0.8) : Color.orange.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "gearshape.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    // 退出应用按钮
                    Button(action: { 
                        selectedTab = 3
                        onExitApp()
                    }) {
                        Circle()
                            .fill(selectedTab == 3 ? Color.orange.opacity(0.8) : Color.orange.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "power")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                    }
                    .buttonStyle(.plain)
                    
                    // 用户按钮
                    Button(action: { selectedTab = 4 }) {
                        Circle()
                            .fill(selectedTab == 4 ? Color.orange.opacity(0.8) : Color.orange.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.leading, 10)
            
            // 2. 欢迎回家标识 - 紧贴按钮上方，继续增大padding
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "house.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 0, y: 1)
                
                Text("欢迎回家")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 2, x: 0, y: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 200)  // 从100增加到200
            .padding(.leading, 10)
            
            // 3. 老伴日常提醒 - 顶部中央，与欢迎回家同一高度，继续增大padding
            TopReminderView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 200)  // 从100增加到200
            
            // 4. 语音输入区域 - 底部中央，继续增大padding
            BottomVoiceInputView(
                audioLevel: $audioLevel,
                isRecording: $isRecording,
                waveOffset: $waveOffset,
                dotPosition: $dotPosition,
                recognizedText: $recognizedText,
                voiceInteractionEnabled: voiceInteractionEnabled,
                showVoiceResponse: $audioManager.showVoiceResponse,
                voiceResponseText: $audioManager.voiceResponseText,
                speechRecognizer: recognizer
            ) { searchText in
                handleSearchRequest(searchText)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 200)  // 从100增加到200
            .onChange(of: recognizer.recognizedText) { _, newValue in
                recognizedText = newValue
                handleVoiceRecognition(newValue)
            }
            
            // 右侧回忆簿面板 - 条件显示
            if showMemoryBook {
                HStack {
                    Spacer()
                    MemoryBookPanel { item in
                        handleItemSelected(item)
                    }
                    .padding(.trailing, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            
            // 物品记忆卡 - 叠加在回忆簿面板上
            if showItemMemoryCard, let item = selectedItem {
                HStack {
                    Spacer()
                    ItemMemoryCard(item: item) {
                        showItemMemoryCard = false
                        selectedItem = nil
                    }
                    .padding(.trailing, 50) // 稍微错开位置
                    .padding(.top, 20) // 稍微向下偏移
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            
            // 右侧设置面板 - 条件显示
            if showSettings {
                HStack {
                    Spacer()
                    SettingsPanel(
                        voiceInteractionEnabled: $voiceInteractionEnabled,
                        realTimeRecordingEnabled: $realTimeRecordingEnabled
                    ) {
                        showSettings = false
                    }
                    .padding(.trailing, 30)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            }
            
            // 录制指示器 - 右上角
            if isRecordingIndicator {
                VStack {
                    HStack {
                        Spacer()
                        RecordingIndicatorView()
                            .padding(.top, 200)  // 调整到与老伴提醒同高度
                            .padding(.trailing, 30)
                    }
                    Spacer()
                }
            }
            
            // 调试按钮 - 保留用于测试
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
            }
            .padding(8)
            .glassBackgroundEffect()
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 30)
        }
        .onAppear {
            recognizer.start()
            startSilence()
            startRealTimeRecording()
        }
        .onDisappear {
            silence?.invalidate()
            recognizer.stop()
            stopRealTimeRecording()
        }
        .onChange(of: realTimeRecordingEnabled) { _, newValue in
            if newValue {
                startRealTimeRecording()
            } else {
                stopRealTimeRecording()
            }
        }
        .onChange(of: voiceInteractionEnabled) { _, newValue in
            if newValue {
                recognizer.start()
            } else {
                recognizer.stop()
            }
        }
    }
    
    // 处理搜索请求
    func handleSearchRequest(_ searchText: String) {
        print("Search request: \(searchText)")
        // 这里可以添加搜索逻辑
        boxManager.addRandomBox() // 临时：添加随机框来测试
    }
    
    // 处理物品选择
    func handleItemSelected(_ item: MemoryItem) {
        print("Selected item: \(item.name)")
        
        // 显示物品记忆卡
        selectedItem = item
        showItemMemoryCard = true
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
        
        // 简化的发送逻辑，移除网络请求
        print("Sending recognized text: \(recognizer.recognizedText)")
        
        // 如果有图像缓冲区，打印它
        if let imageBuffer = KeyFinder.keyBuffer {
            print("Image buffer available: \(imageBuffer)")
        }
    }
    
    // 开始实时记录
    func startRealTimeRecording() {
        guard realTimeRecordingEnabled else { return }
        
        isRecordingIndicator = true
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            captureImage()
        }
    }
    
    // 停止实时记录
    func stopRealTimeRecording() {
        isRecordingIndicator = false
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    // 拍摄图片
    func captureImage() {
        print("Capturing image at \(Date())")
        // 这里可以添加实际的图片拍摄逻辑
        // 例如调用摄像头API或保存当前画面
    }
    
    // 处理语音识别
    func handleVoiceRecognition(_ text: String) {
        // 检查是否包含"我想你了"关键词
        if text.contains("我想你了") {
            // 重置静音定时器
            silenceTimer?.invalidate()
            
            // 播放思念回复音频和显示文字
            playMissingResponse()
            showMissingResponseText()
            return
        }
        
        // 检查是否包含物品名称
        let recognizedItems = MemoryItem.getAllItems().filter { item in
            text.contains(item.name)
        }
        
        if let firstItem = recognizedItems.first {
            // 重置静音定时器
            silenceTimer?.invalidate()
            
            // 立即播放音频和显示文字
            playVoiceResponse()
            showVoiceResponseText()
            
            // 显示物品记忆卡
            selectedItem = firstItem
            showItemMemoryCard = true
        }
        
        // 重置静音定时器
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            // 1秒后清空文字（仅在未播放音频时）
            if !self.audioManager.showVoiceResponse {
                self.recognizedText = ""
            }
        }
    }
    
    // 播放语音响应
    func playVoiceResponse() {
        guard let url = URL(string: "https://lf9-appstore-sign.oceancloudapi.com/ocean-cloud-tos/VolcanoUserVoice/speech_7426725529589547035_d50dadc7-1a35-40fb-91bb-d969a1eab6bd.mp3?lk3s=da27ec82&x-expires=1753815701&x-signature=BNlbHIiRTc14DZ5jQyIdneXbiFQ%3D") else {
            print("Error: Invalid URL")
            return
        }
        
        // 暂停语音识别
        if isRecording {
            recognizer.stop()
            isRecording = false
        }
        
        // 设置音频播放结束回调
        audioManager.onAudioFinished = {
            // 恢复语音识别
            if self.voiceInteractionEnabled {
                self.recognizer.start()
                self.isRecording = true
            }
            print("Voice recognition resumed")
        }
        
        // 下载并播放音频
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading audio: \(error)")
                // 如果下载失败，恢复语音识别
                DispatchQueue.main.async {
                    if self.voiceInteractionEnabled {
                        self.recognizer.start()
                        self.isRecording = true
                    }
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                // 如果没有数据，恢复语音识别
                DispatchQueue.main.async {
                    if self.voiceInteractionEnabled {
                        self.recognizer.start()
                        self.isRecording = true
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                do {
                    self.audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayer?.delegate = self.audioManager
                    self.audioPlayer?.play()
                    print("Playing audio response")
                } catch {
                    print("Error playing audio: \(error)")
                    // 如果播放失败，恢复语音识别
                    if self.voiceInteractionEnabled {
                        self.recognizer.start()
                        self.isRecording = true
                    }
                }
            }
        }.resume()
    }
    
    // 播放思念回复音频
    func playMissingResponse() {
        guard let url = URL(string: "https://lf3-appstore-sign.oceancloudapi.com/ocean-cloud-tos/VolcanoUserVoice/speech_7426725529589547035_859dfb66-f194-44f5-b643-4abfeed07939.mp3?lk3s=da27ec82&x-expires=1753818182&x-signature=CHJyUJ6XxXEIZe5a07vvEbCOQ4g%3D") else {
            print("Error: Invalid URL")
            return
        }
        
        // 暂停语音识别
        if isRecording {
            recognizer.stop()
            isRecording = false
        }
        
        // 设置音频播放结束回调
        audioManager.onAudioFinished = {
            // 恢复语音识别
            if self.voiceInteractionEnabled {
                self.recognizer.start()
                self.isRecording = true
            }
            print("Voice recognition resumed")
        }
        
        // 下载并播放音频
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading audio: \(error)")
                // 如果下载失败，恢复语音识别
                DispatchQueue.main.async {
                    if self.voiceInteractionEnabled {
                        self.recognizer.start()
                        self.isRecording = true
                    }
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                // 如果没有数据，恢复语音识别
                DispatchQueue.main.async {
                    if self.voiceInteractionEnabled {
                        self.recognizer.start()
                        self.isRecording = true
                    }
                }
                return
            }
            
            DispatchQueue.main.async {
                do {
                    self.audioPlayer = try AVAudioPlayer(data: data)
                    self.audioPlayer?.delegate = self.audioManager
                    self.audioPlayer?.play()
                    print("Playing missing response audio")
                } catch {
                    print("Error playing audio: \(error)")
                    // 如果播放失败，恢复语音识别
                    if self.voiceInteractionEnabled {
                        self.recognizer.start()
                        self.isRecording = true
                    }
                }
            }
        }.resume()
    }
    
    // 显示思念回复文字
    func showMissingResponseText() {
        audioManager.voiceResponseText = "我也想你，老头子，记得好好照顾自己。"
        audioManager.showVoiceResponse = true
        
        // 字幕将在音频播放结束后通过AVAudioPlayerDelegate隐藏
    }
    
    // 显示语音响应文字
    func showVoiceResponseText() {
        audioManager.voiceResponseText = "老头子，钥匙在白色桌子上，旁边有一个相框和两瓶饮料。"
        audioManager.showVoiceResponse = true
        
        // 字幕将在音频播放结束后通过AVAudioPlayerDelegate隐藏
    }
    

}


// 顶部日常提醒组件 - 黄绿配色，带打字机效果
struct TopReminderView: View {
    @State private var displayedText = ""
    @State private var fullText = "上午11:30,不要又忘记吃药了啊~"
    @State private var currentIndex = 0
    
    var body: some View {
        HStack(spacing: 15) {
            // 老伴头像
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 50, height: 50)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                
                // 老伴图标 - 使用眼镜和头发组合，改为黄绿色
                VStack(spacing: 2) {
                    Image(systemName: "eyeglasses")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color.yellow) // 黄色
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color.green) // 绿色
                }
            }
            
            // 提醒文字 - 黄绿配色背景框，带打字机效果，增加宽度
            Text(displayedText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.green]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ).opacity(0.9)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
                .frame(minWidth: 300)
        }
        .padding(.horizontal, 30)
        .onAppear {
            startTypewriter()
        }
    }
    
    func startTypewriter() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayedText += String(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}





// 中央内容区域
struct CentralContentArea: View {
    let selectedTab: Int
    let showMemoryBook: Bool
    
    var body: some View {
        VStack {
            if selectedTab == 0 { // 主页
                VStack(spacing: 30) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("欢迎回家")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("今天想找什么物品呢？")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                }
            } else if selectedTab == 1 { // 回忆簿
                VStack(spacing: 20) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("回忆簿")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("查看已记录的物品")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                }
            } else if selectedTab == 2 { // 设置
                VStack(spacing: 20) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("设置")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("个性化配置")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                }
            } else if selectedTab == 3 { // 退出
                VStack(spacing: 20) {
                    Image(systemName: "power")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("退出")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("关闭应用")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                }
            } else { // 用户
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("用户")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                    
                    Text("个人信息")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 1)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// 右侧回忆簿面板 - 保持背景框因为这是内容面板
struct MemoryBookPanel: View {
    let onItemSelected: (MemoryItem) -> Void
    
    let items: [MemoryItem] = MemoryItem.getAllItems()
    
    var body: some View {
        VStack(spacing: 15) {
            Text("已记录常用物品")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(items) { item in
                        MemoryItemCard(item: item)
                            .onTapGesture {
                                onItemSelected(item)
                            }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .frame(width: 320, height: 480)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                )
                .shadow(color: .white.opacity(0.3), radius: 5, x: 0, y: 0)
        )
    }
}

struct MemoryItem: Identifiable {
    let id = UUID()
    let icon: String
    let emoji: String
    let name: String
    let en: String
    let locations: String
}

struct MemoryItemCard: View {
    let item: MemoryItem
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 44, height: 44)
                Text(item.emoji)
                    .font(.system(size: 24))
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(item.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Text("(") + Text(item.en).font(.system(size: 12)).foregroundColor(.gray) + Text(")")
                }
                Text("常见位置：" + item.locations)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.85))
        )
    }
}

// 底部语音输入框 - 匹配图片样式
struct BottomVoiceInputView: View {
    @Binding var audioLevel: CGFloat
    @Binding var isRecording: Bool
    @Binding var waveOffset: CGFloat
    @Binding var dotPosition: CGFloat
    @Binding var recognizedText: String
    let voiceInteractionEnabled: Bool
    @Binding var showVoiceResponse: Bool
    @Binding var voiceResponseText: String
    let speechRecognizer: SpeechRecognizer
    let onSearchRequest: (String) -> Void
    
    // 动态音量历史
    @State private var volumeHistory: [CGFloat] = Array(repeating: 0.0, count: 50)
    @State private var animationTimer: Timer?
    @State private var textUpdateTimer: Timer?
    
    var body: some View {
        VStack(spacing: 10) {
            // 实时识别文字显示区域
            if voiceInteractionEnabled && !recognizedText.isEmpty {
                VStack(spacing: 5) {
                    Text(recognizedText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    if isRecording {
                        Text("正在录音...")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.orange.opacity(0.8))
                )
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            
            // 语音响应文字显示区域
            if showVoiceResponse && !voiceResponseText.isEmpty {
                VStack(spacing: 5) {
                    Text(voiceResponseText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue.opacity(0.8))
                )
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            
            // 圆角矩形背景容器
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 50)
                .overlay {
                    HStack(spacing: 15) {
                        // 动态波纹区域
                        ZStack {
                            // 橙色波形
                            OrangeWaveform(volumeHistory: volumeHistory)
                                .frame(height: 30)
                                .padding(.horizontal, 20)
                            
                            // 移动的小圆点
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 6, height: 6)
                                .offset(x: dotPosition)
                                .padding(.horizontal, 20)
                        }
                        .frame(height: 30)
                        
                        Spacer()
                        
                        // 橙色麦克风按钮
                        Button(action: {
                            if voiceInteractionEnabled {
                                if isRecording {
                                    // 停止录音
                                    speechRecognizer.stop()
                                    isRecording = false
                                    // 如果有识别结果，触发搜索
                                    if !recognizedText.isEmpty {
                                        onSearchRequest(recognizedText)
                                    }
                                } else {
                                    // 开始录音
                                    speechRecognizer.start()
                                    isRecording = true
                                }
                            }
                        }) {
                            Circle()
                                .fill(voiceInteractionEnabled ? (isRecording ? Color.red : Color.orange) : Color.gray)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.white)
                                }
                        }
                        .buttonStyle(.plain)
                        .disabled(!voiceInteractionEnabled)
                    }
                    .padding(.horizontal, 15)
                }
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 30)
        .onAppear {
            startWaveAnimation()
        }
        .onDisappear {
            animationTimer?.invalidate()
            textUpdateTimer?.invalidate()
        }
        .onChange(of: voiceInteractionEnabled) { _, newValue in
            if newValue {
                // 语音交互启用时，不需要模拟文字更新
            } else {
                textUpdateTimer?.invalidate()
                recognizedText = ""
                isRecording = false
                speechRecognizer.stop()
            }
        }
    }
    
    // 启动波纹动画
    func startWaveAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // 更新音量历史
            let newVolume = CGFloat.random(in: 0.1...1.0)
            volumeHistory.removeFirst()
            volumeHistory.append(newVolume)
            
            // 更新圆点位置
            dotPosition = CGFloat.random(in: -100...100)
        }
    }
    

}

// 橙色波形视图 - 匹配图片样式
struct OrangeWaveform: View {
    let volumeHistory: [CGFloat]
    
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width = geo.size.width
                let height = geo.size.height
                let midY = height / 2
                let step = width / CGFloat(max(volumeHistory.count - 1, 1))
                
                // 绘制平滑的橙色波形
                path.move(to: CGPoint(x: 0, y: midY))
                for (i, v) in volumeHistory.enumerated() {
                    let x = CGFloat(i) * step
                    let amp = v * (height / 2 - 2)
                    path.addLine(to: CGPoint(x: x, y: midY - amp))
                }
            }
            .stroke(Color.orange, lineWidth: 2)
        }
    }
}

// 扩展MemoryItem以支持静态方法
extension MemoryItem {
    static func getAllItems() -> [MemoryItem] {
        return [
            MemoryItem(icon: "tv", emoji: "📺", name: "遥控器", en: "remote control", locations: "茶几、沙发缝、电视柜"),
            MemoryItem(icon: "iphone", emoji: "📱", name: "手机", en: "cell phone", locations: "枕头边、桌面、沙发"),
            MemoryItem(icon: "key.fill", emoji: "🔑", name: "钥匙", en: "key", locations: "玄关、鞋柜、口袋"),
            MemoryItem(icon: "pills.fill", emoji: "💊", name: "药盒", en: "pill box / medicine", locations: "餐桌、床头、厨房"),
            MemoryItem(icon: "creditcard.fill", emoji: "👛", name: "钱包", en: "wallet / purse", locations: "餐桌、抽屉、玄关柜"),
            MemoryItem(icon: "shoeprints.fill", emoji: "🥿", name: "拖鞋", en: "slippers / shoes", locations: "门口、沙发下、床边"),
            MemoryItem(icon: "cup.and.saucer.fill", emoji: "☕", name: "杯子", en: "cup / mug", locations: "茶几、厨房、书桌"),
            MemoryItem(icon: "umbrella.fill", emoji: "☂️", name: "折叠伞", en: "umbrella", locations: "衣帽架、门口、包中"),
            MemoryItem(icon: "book.fill", emoji: "📰", name: "报纸/杂志", en: "book / magazine", locations: "沙发、床头、卫生间"),
            MemoryItem(icon: "waterbottle", emoji: "🫗", name: "水壶/保温杯", en: "bottle / thermos", locations: "茶几、厨房、床头柜")
        ]
    }
}

// 设置面板组件
struct SettingsPanel: View {
    @Binding var voiceInteractionEnabled: Bool
    @Binding var realTimeRecordingEnabled: Bool
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题栏
            HStack {
                Text("设置")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.7))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            // 设置选项
            VStack(spacing: 25) {
                // 语音交互设置
                SettingToggleRow(
                    title: "语音交互",
                    subtitle: "启用设备麦克风进行语音识别",
                    icon: "mic.fill",
                    isEnabled: $voiceInteractionEnabled
                )
                
                // 实时记录设置
                SettingToggleRow(
                    title: "实时记录",
                    subtitle: "每5秒拍摄一张图片进行记录",
                    icon: "camera.fill",
                    isEnabled: $realTimeRecordingEnabled
                )
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .frame(width: 320, height: 480)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                )
                .shadow(color: .white.opacity(0.3), radius: 5, x: 0, y: 0)
        )
    }
}

// 设置开关行组件
struct SettingToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isEnabled: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            // 图标
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.orange)
            }
            
            // 文字信息
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // 开关
            Toggle("", isOn: $isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: .orange))
                .labelsHidden()
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// 录制指示器组件
struct RecordingIndicatorView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            // 录制圆点
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // 录制文字
            Text("录制中")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.red.opacity(0.8))
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// 物品记忆卡组件
struct ItemMemoryCard: View {
    let item: MemoryItem
    let onClose: () -> Void
    
    // 获取当前时间
    private var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d h:mma"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
    
    // 根据物品获取环境信息
    private func getEnvironmentInfo(for item: MemoryItem) -> String {
        switch item.name {
        case "钥匙":
            return "一张白色桌子上，一个相框和两瓶饮料的旁边"
        case "遥控器":
            return "客厅茶几上，电视遥控器旁边"
        case "手机":
            return "床头柜上，充电器旁边"
        case "药盒":
            return "餐桌上，水杯旁边"
        case "钱包":
            return "玄关柜上，钥匙旁边"
        case "拖鞋":
            return "门口鞋柜旁，地毯上"
        case "杯子":
            return "茶几上，遥控器旁边"
        case "折叠伞":
            return "衣帽架上，外套旁边"
        case "报纸/杂志":
            return "沙发上，靠垫旁边"
        case "水壶/保温杯":
            return "厨房台面上，电水壶旁边"
        default:
            return "常见位置：" + item.locations
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标签
            Text(item.name)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                )
                .padding(.top, 15)
            
            // 主要内容区域
            VStack(spacing: 15) {
                // 图片区域 - 渐变背景
                ZStack {
                    // 渐变背景
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.green]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 200)
                    
                    // 图片
                    Image("MemoryCard")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 180)
                        .clipped()
                        .cornerRadius(12)
                }
                
                // 信息区域
                VStack(spacing: 12) {
                    // 物品名称
                    HStack {
                        Text("物品名称：")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        Text("【\(item.name)】")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    // 环境信息
                    VStack(alignment: .leading, spacing: 4) {
                        Text("环境信息：")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        Text(getEnvironmentInfo(for: item))
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // 记录时间
                    HStack {
                        Text("记录时间：")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                        Text(currentTime)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
                .padding(.horizontal, 15)
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .frame(width: 300, height: 400)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .overlay(
            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
                Spacer()
            }
        )
    }
}

#Preview {
    CanvasView(onExitApp: {})
}

