import SwiftUI

struct SoundSettingsView: View {
    @EnvironmentObject var audioService: AudioService
    @AppStorage("defaultVolume") private var defaultVolume: Double = 0.5
    @AppStorage("fadeOutDuration") private var fadeOutDuration: Double = 30.0
    @AppStorage("mixEnabled") private var mixEnabled = false
    @AppStorage("autoStopAfterSession") private var autoStopAfterSession = true
    @AppStorage("useHaptics") private var useHaptics = true
    
    let fadeOutOptions = [15.0, 30.0, 45.0, 60.0]
    
    var body: some View {
        List {
            Section(header: Text("Playback")) {
                VStack(alignment: .leading) {
                    Text("Default Volume")
                    HStack {
                        Image(systemName: "speaker.fill")
                            .foregroundColor(.gray)
                        Slider(value: $defaultVolume)
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
                
                Picker("Fade Out Duration", selection: $fadeOutDuration) {
                    ForEach(fadeOutOptions, id: \.self) { duration in
                        Text("\(Int(duration)) seconds").tag(duration)
                    }
                }
            }
            
            Section(header: Text("Sound Mixing")) {
                Toggle("Enable Sound Mixing", isOn: $mixEnabled)
                
                if mixEnabled {
                    Text("Mix up to 3 sounds simultaneously")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("Session Settings")) {
                Toggle("Auto-stop after session ends", isOn: $autoStopAfterSession)
                Toggle("Use Haptic Feedback", isOn: $useHaptics)
            }
            
            Section(header: Text("Audio Quality")) {
                NavigationLink(destination: AudioQualitySettingsView()) {
                    HStack {
                        Text("Audio Quality")
                        Spacer()
                        Text("High")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section(header: Text("Equalizer")) {
                NavigationLink(destination: EqualizerView()) {
                    Text("Equalizer Settings")
                }
            }
            
            Section(footer: Text("Higher audio quality may use more data when streaming sounds.")) {
                EmptyView()
            }
        }
        .navigationTitle("Sound Settings")
    }
}

struct AudioQualitySettingsView: View {
    @AppStorage("audioQuality") private var audioQuality = "high"
    
    var body: some View {
        List {
            Section(header: Text("Streaming Quality")) {
                Picker("Audio Quality", selection: $audioQuality) {
                    Text("Normal").tag("normal")
                    Text("High").tag("high")
                    Text("Very High").tag("very-high")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical)
            }
            
            Section(footer: Text("Higher quality uses more data when streaming. Downloads are always in high quality.")) {
                EmptyView()
            }
        }
        .navigationTitle("Audio Quality")
    }
}

struct EqualizerView: View {
    @State private var bass: Double = 0.5
    @State private var mid: Double = 0.5
    @State private var treble: Double = 0.5
    @State private var selectedPreset = "Custom"
    
    let presets = ["Flat", "Bass Boost", "Treble Boost", "Night Mode", "Custom"]
    
    var body: some View {
        List {
            Section(header: Text("Equalizer Preset")) {
                Picker("Preset", selection: $selectedPreset) {
                    ForEach(presets, id: \.self) { preset in
                        Text(preset).tag(preset)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedPreset) { newValue in
                    applyPreset(newValue)
                }
            }
            
            Section(header: Text("Custom Equalizer")) {
                VStack(alignment: .leading) {
                    Text("Bass")
                    Slider(value: $bass)
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading) {
                    Text("Mid")
                    Slider(value: $mid)
                }
                .padding(.vertical, 8)
                
                VStack(alignment: .leading) {
                    Text("Treble")
                    Slider(value: $treble)
                }
                .padding(.vertical, 8)
            }
            
            Section(footer: Text("Adjust the equalizer to customize your sound experience.")) {
                Button("Reset to Default") {
                    resetEqualizer()
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Equalizer")
    }
    
    private func applyPreset(_ preset: String) {
        switch preset {
        case "Flat":
            bass = 0.5
            mid = 0.5
            treble = 0.5
        case "Bass Boost":
            bass = 0.8
            mid = 0.5
            treble = 0.4
        case "Treble Boost":
            bass = 0.4
            mid = 0.5
            treble = 0.8
        case "Night Mode":
            bass = 0.6
            mid = 0.4
            treble = 0.3
        default:
            break
        }
    }
    
    private func resetEqualizer() {
        selectedPreset = "Flat"
        bass = 0.5
        mid = 0.5
        treble = 0.5
    }
}

#Preview {
    NavigationView {
        SoundSettingsView()
            .environmentObject(AudioService())
    }
}