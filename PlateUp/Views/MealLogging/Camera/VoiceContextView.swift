//
//  VoiceContextView.swift
//  PlateUp
//
//  Voice recording for meal context (12-second max)
//

import SwiftUI
import AVFoundation
import AVFAudio
import Speech

struct VoiceContextView: View {
    @Binding var voiceRecording: Data?
    @Binding var voiceTranscript: String
    let onComplete: () -> Void
    let onSkip: () -> Void
    
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var isRecording = false
    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var waveformAmplitudes: [CGFloat] = []
    
    private let maxRecordingTime: TimeInterval = 12.0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Add Context")
                    .font(PlateUpTypography.title2)
                    .foregroundColor(.plateUpPrimaryText)
                
                Text("Describe your meal in a few words")
                    .font(PlateUpTypography.subheadline)
                    .foregroundColor(.plateUpSecondaryText)
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            Spacer()
            
            // Recording Interface
            VStack(spacing: 30) {
                // Waveform visualization
                VoiceWaveformView(amplitudes: waveformAmplitudes, isRecording: isRecording)
                    .frame(height: 80)
                    .padding(.horizontal)
                
                // Timer
                Text(timeString)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundColor(isRecording ? .plateUpGreen : .plateUpPrimaryText)
                
                // Transcript preview
                if !voiceTranscript.isEmpty {
                    VStack(spacing: 8) {
                        Text("What I heard:")
                            .font(PlateUpTypography.caption1)
                            .foregroundColor(.plateUpSecondaryText)
                        
                        Text(voiceTranscript)
                            .font(PlateUpTypography.body)
                            .foregroundColor(.plateUpPrimaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .background(Color.plateUpCardBackground)
                            .cornerRadius(PlateUpComponentStyle.mediumRadius)
                    }
                    .padding(.horizontal)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            
            Spacer()
            
            // Controls
            VStack(spacing: 20) {
                // Recording button (push to talk)
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.plateUpError : Color.plateUpGreen)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(isRecording ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isRecording)
                .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                    if pressing {
                        startRecording()
                    } else {
                        stopRecording()
                    }
                }, perform: {})
                
                Text(isRecording ? "Release to stop" : "Hold to record")
                    .font(PlateUpTypography.caption1)
                    .foregroundColor(.plateUpSecondaryText)
                
                // Action buttons
                HStack(spacing: 20) {
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(PlateUpTypography.subheadline)
                            .foregroundColor(.plateUpTertiaryText)
                            .frame(width: 100, height: 44)
                            .background(Color.plateUpCardBackground)
                            .cornerRadius(PlateUpComponentStyle.mediumRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: PlateUpComponentStyle.mediumRadius)
                                    .stroke(Color.plateUpBorder, lineWidth: 0.5)
                            )
                    }
                    
                    Button(action: onComplete) {
                        Text("Continue")
                            .font(PlateUpTypography.headline)
                            .foregroundColor(.white)
                            .frame(width: 150, height: 44)
                            .background(Color.plateUpGreen)
                            .cornerRadius(PlateUpComponentStyle.mediumRadius)
                    }
                    .disabled(voiceTranscript.isEmpty)
                    .opacity(voiceTranscript.isEmpty ? 0.5 : 1.0)
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color.plateUpBackground)
        .onAppear {
            audioRecorder.requestPermissions()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var timeString: String {
        let minutes = Int(recordingTime) / 60
        let seconds = Int(recordingTime) % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
    
    private func startRecording() {
        guard audioRecorder.hasPermission else { return }
        
        isRecording = true
        recordingTime = 0
        waveformAmplitudes = []
        voiceTranscript = ""
        
        audioRecorder.startRecording()
        
        // Start timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingTime += 0.1
            
            // Update waveform
            if let amplitude = audioRecorder.currentAmplitude {
                waveformAmplitudes.append(amplitude)
                if waveformAmplitudes.count > 50 {
                    waveformAmplitudes.removeFirst()
                }
            }
            
            // Auto-stop at max time
            if recordingTime >= maxRecordingTime {
                stopRecording()
            }
        }
    }
    
    private func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        
        if let data = audioRecorder.stopRecording() {
            voiceRecording = data
            // Simulate transcription
            simulateTranscription()
        }
    }
    
    private func simulateTranscription() {
        // In real app, would use Speech framework or send to API
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                voiceTranscript = "Two grilled chicken tacos with salsa and guacamole"
            }
        }
    }
}

// MARK: - Waveform View
struct VoiceWaveformView: View {
    let amplitudes: [CGFloat]
    let isRecording: Bool
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 2) {
                ForEach(Array(amplitudes.enumerated()), id: \.offset) { index, amplitude in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(isRecording ? Color.plateUpGreen : Color.plateUpTertiaryText)
                        .frame(width: 3, height: max(4, amplitude * geometry.size.height))
                        .animation(.easeOut(duration: 0.1), value: amplitude)
                }
                
                if amplitudes.isEmpty {
                    // Show placeholder bars when not recording
                    ForEach(0..<30) { _ in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.plateUpTertiaryText.opacity(0.3))
                            .frame(width: 3, height: 4)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Audio Recorder
class AudioRecorder: NSObject, ObservableObject {
    @Published var hasPermission = false
    @Published var currentAmplitude: CGFloat?
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingSession: AVAudioSession?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
        } catch {
            print("Failed to set up recording session: \(error)")
        }
    }
    
    func requestPermissions() {
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    self?.hasPermission = allowed
                }
            }
        } else {
            recordingSession?.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    self?.hasPermission = allowed
                }
            }
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            // Update amplitude periodically
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.updateAmplitude()
            }
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() -> Data? {
        audioRecorder?.stop()
        audioRecorder = nil
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        return try? Data(contentsOf: audioFilename)
    }
    
    private func updateAmplitude() {
        guard let recorder = audioRecorder else { return }
        recorder.updateMeters()
        
        let amplitude = recorder.averagePower(forChannel: 0)
        let normalizedAmplitude = CGFloat(pow(10, amplitude / 20)) // Convert dB to linear
        currentAmplitude = min(max(normalizedAmplitude, 0), 1)
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

extension AudioRecorder: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}