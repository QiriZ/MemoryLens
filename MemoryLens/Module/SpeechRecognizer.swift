import Speech
import Observation
import AVFoundation

@MainActor @Observable
final class SpeechRecognizer {
    var recognizer: SFSpeechRecognizer?
    var audioEngine = AVAudioEngine()
    var recognitionTask: SFSpeechRecognitionTask?
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    var recognizedText = ""
    var available = false
    
    init() {
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-CN"))
        
        SFSpeechRecognizer.requestAuthorization { status in
            Task { @MainActor in
                self.available = status == .authorized
            }
        }
    }
    
    func start() {
        guard available else { return }
        
        recognizedText = ""
        
        defer {
            if !audioEngine.isRunning {
                audioEngine.inputNode.removeTap(onBus: 0)
                recognitionRequest?.endAudio()
                recognitionTask?.cancel()
                try? AVAudioSession.sharedInstance().setActive(false)
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.record)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest) { result, _ in
            Task { @MainActor in
                if let result {
                    let newText = result.bestTranscription.formattedString
                    self.recognizedText = newText
                }
            }
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return
        }
    }
    
    func stop() {
        defer {
            recognitionRequest = nil
            recognitionTask = nil
            try? AVAudioSession.sharedInstance().setActive(false)
        }
        
        recognizedText.removeAll()
        
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }
}
