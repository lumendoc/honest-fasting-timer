import SwiftUI
import SwiftData

struct TimerView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var timerService: FastTimerService
    @StateObject private var purchaseService = PurchaseService()
    
    init() {
        _timerService = StateObject(wrappedValue: FastTimerService())
    }
    @State private var showPaywall = false
    @State private var selectedPreset: FastPreset = .sixteenEight
    @State private var showPresetPicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let fast = timerService.activeFast {
                    // Active fast UI
                    ActiveFastView(fast: fast, timerService: timerService)
                } else {
                    // No active fast UI
                    InactiveFastView(
                        selectedPreset: $selectedPreset,
                        showPresetPicker: $showPresetPicker,
                        onStart: { startFast() }
                    )
                }
            }
            .padding()
            .navigationTitle("Fasting Timer")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(purchaseService)
            }
            .sheet(isPresented: $showPresetPicker) {
                PresetPickerView(selectedPreset: $selectedPreset)
            }
        }
        .environmentObject(timerService)
        .environmentObject(purchaseService)
        .onAppear {
            timerService.setModelContext(modelContext)
        }
    }
    
    private func startFast() {
        // Free tier: only 16:8 preset
        if !purchaseService.isUnlocked && selectedPreset != .sixteenEight {
            showPaywall = true
            return
        }
        
        timerService.startFast(preset: selectedPreset)
    }
}

// MARK: - Active Fast View

struct ActiveFastView: View {
    let fast: ActiveFast
    @ObservedObject var timerService: FastTimerService
    @State private var showEndConfirmation = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Preset name
            Text(fast.presetName)
                .font(.title2)
                .foregroundStyle(.secondary)
            
            // Countdown
            Text(timerService.currentTime, style: .timer)
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .monospacedDigit()
                .overlay {
                    // Custom countdown display
                    Text(fast.formattedRemainingTime)
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .opacity(0) // Hidden but maintains layout
                }
            
            // Progress ring
            ProgressRing(progress: fast.progress)
                .frame(width: 200, height: 200)
            
            // Elapsed time
            Text("Elapsed: \(fast.formattedElapsedTime)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // End button
            Button {
                showEndConfirmation = true
            } label: {
                Label("End Fast", systemImage: "stop.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .confirmationDialog("End your fast?", isPresented: $showEndConfirmation) {
                Button("End Fast", role: .destructive) {
                    timerService.stopFast()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Your progress will be saved.")
            }
        }
    }
}

// MARK: - Inactive Fast View

struct InactiveFastView: View {
    @Binding var selectedPreset: FastPreset
    @Binding var showPresetPicker: Bool
    let onStart: () -> Void
    @EnvironmentObject var purchaseService: PurchaseService
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "timer")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor)
            
            Text("Ready to Fast?")
                .font(.title.bold())
            
            // Preset selector
            Button {
                showPresetPicker = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(selectedPreset.displayName)
                            .font(.headline)
                        Text(selectedPreset.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            
            // Premium badge for non-free presets
            if !purchaseService.isUnlocked && selectedPreset != .sixteenEight {
                HStack {
                    Image(systemName: "lock.fill")
                        .font(.caption)
                    Text("Premium preset - unlock to use")
                        .font(.caption)
                }
                .foregroundStyle(.orange)
            }
            
            Spacer()
            
            // Start button
            Button {
                onStart()
            } label: {
                Label("Start Fast", systemImage: "play.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

// MARK: - Preset Picker

struct PresetPickerView: View {
    @Binding var selectedPreset: FastPreset
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var purchaseService: PurchaseService
    
    var body: some View {
        NavigationStack {
            List(FastPreset.allCases) { preset in
                Button {
                    selectedPreset = preset
                    dismiss()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(preset.displayName)
                                .font(.headline)
                            Text(preset.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if preset == selectedPreset {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                        }
                        
                        if !purchaseService.isUnlocked && preset != .sixteenEight {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .navigationTitle("Select Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Progress Ring

struct ProgressRing: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [.accentColor, .green],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            VStack {
                Text("\(Int(progress * 100))%")
                    .font(.title2.bold())
                Text("Complete")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
