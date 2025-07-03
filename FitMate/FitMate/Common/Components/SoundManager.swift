//
//  SoundManage.swift
//  FitMate
//
//  Created by 김은서 on 6/27/25.
//
import AudioToolbox
import AVFoundation

class SoundManage {
    static let shared = SoundManage()
    private var audioPlayer: AVAudioPlayer?
    
    var isSoundEnabled: Bool {
        get {
            UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "soundEnabled")
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {}
    
    func initializeSoundSetting() {
        if let saved = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool {
            isSoundEnabled = saved
        } else {
            isSoundEnabled = true
        }
    }

    func coinSound() {
        guard isSoundEnabled else { return }
        guard let url = Bundle.main.url(forResource: "coin", withExtension: "wav") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("효과음 재생 실패: \(error)")
        }
    }
    
    func playInviteSound() {
        guard isSoundEnabled else { return }
        guard let url = Bundle.main.url(forResource: "fitme_invite", withExtension: "wav") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("효과음 재생 실패: \(error)")
        }
    }
    
    func playSuccess() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(SystemSoundID(1322))
    }
    
    func playFail() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(SystemSoundID(1053))
    }
}
