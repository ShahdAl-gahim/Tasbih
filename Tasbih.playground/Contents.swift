import SwiftUI
import UIKit
import PlaygroundSupport

// MARK: - Model
struct TasbeehEntry: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

// MARK: - Root Container
struct TasbeehAppView: View {
    @State private var selectedTab: Tab = .tasbeeh  // Start on Tasbeeh
    
    enum Tab {
        case learn, tasbeeh, progress
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch selectedTab {
                case .learn:
                    EducationView()
                case .tasbeeh:
                    CounterView()
                case .progress:
                    ProgressView()
                }
            }
            .navigationTitle(tabTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack(spacing: 0) {
                        tabButton(.learn, icon: "book.fill", label: "Learn")
                        Spacer()
                        tabButton(.tasbeeh, icon: "circle.grid.cross.fill", label: "Tasbeeh")
                        Spacer()
                        tabButton(.progress, icon: "chart.bar.fill", label: "Progress")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .accentColor(.green)
        .preferredColorScheme(.light)
    }
    
    private var tabTitle: String {
        switch selectedTab {
        case .learn:    "Learn About Tasbeeh"
        case .tasbeeh:  "Tasbeeh"
        case .progress: "Your Progress"
        }
    }
    
    @ViewBuilder
    private func tabButton(_ tab: Tab, icon: String, label: String) -> some View {
        Button {
            withAnimation(.easeInOut) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: selectedTab == tab ? .bold : .regular))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(selectedTab == tab ? .green : .gray)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Education View
struct EducationView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                Text("Tasbeeh App")
                    .font(.largeTitle.bold())
                    .foregroundColor(.green)
                    .padding(.top, 40)
                
                Text("What is Tasbeeh?")
                    .font(.title2.bold())
                
                Text("Tasbeeh (Tasbih) is a form of dhikr — remembrance of Allah — in Islam. It involves glorifying Allah by repeating phrases like “SubhanAllah” (Glory be to Allah).")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                
                Text("How is it traditionally done?")
                    .font(.title3.bold())
                    .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 14) {
                    Text("• Use prayer beads (misbaha) with 33, 99, or 100 beads.")
                    Text("• Move one bead per phrase with thumb and finger.")
                    Text("• Common after salah:")
                    Text("  - SubhanAllah ×33")
                    Text("  - Alhamdulillah ×33")
                    Text("  - Allahu Akbar ×34 (or 33 + 1 La ilaha illallah)")
                    Text("• Completes 100 glorifications.")
                }
                .font(.body)
                .padding(.horizontal, 24)
                
                Spacer(minLength: 60)
                
                Text("Always at your fingertips — zero excuses!")
                    .italic()
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
            }
            .padding(.horizontal)
        }
        .background(LinearGradient(colors: [.white, Color.green.opacity(0.08)], startPoint: .top, endPoint: .bottom))
    }
}

// MARK: - Counter View – larger tasbih_beads image
// MARK: - Counter View – saves to entries for ProgressView
struct CounterView: View {
    @AppStorage("tasbeeh_currentCount") private var currentCount: Int = 0
    @AppStorage("tasbeeh_lastDate") private var lastDateString: String = ""
    @AppStorage("tasbeeh_entries") private var entriesData: Data = Data()  // ← Add this to save here
    
    let phrases = ["SubhanAllah", "Alhamdulillah", "Allahu Akbar"]
    @State private var currentPhraseIndex = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 60)
            
            ZStack {
                // Your beads image – unchanged
                if let url = Bundle.main.url(forResource: "tasbih_beads", withExtension: "png"),
                   let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 580, height: 480)
                } else {
                    Text("Image load failed")
                        .foregroundColor(.red)
                }
                
                // Tappable overlay – unchanged
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 580, height: 480)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        currentCount += 1
                        
                        if currentCount % 33 == 0 && currentCount > 0 {
                            currentPhraseIndex = (currentPhraseIndex + 1) % 3
                        }
                        
                        saveCurrentCountToEntries()  // ← NEW: save every tap
                    }
                
                // Central count + phrase – unchanged
                VStack(spacing: 8) {
                    Text("\(currentCount)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                        .shadow(color: .black.opacity(0.3), radius: 4)
                    
                    Text(phrases[currentPhraseIndex])
                        .font(.title2)
                        .foregroundColor(.primary.opacity(0.9))
                        .shadow(color: .black.opacity(0.2), radius: 2)
                }
                .offset(y: -80)
            }
            .frame(height: 420)
            
            Text("Tap anywhere on the beads to count")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 16)
            
            Button("Reset Today") {
                currentCount = 0
                currentPhraseIndex = 0
                saveCurrentCountToEntries()  // Also save on reset
            }
            .font(.headline)
            .foregroundColor(.red.opacity(0.7))
            .padding(.top, 12)
            
            Spacer(minLength: 80)
        }
        .padding(.horizontal, 20)
        .background(LinearGradient(colors: [.white, Color.green.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .onAppear {
            checkAndResetIfNewDay()
            saveCurrentCountToEntries()  // Ensure sync when appearing
        }
        .onChange(of: currentCount) { _ in
            saveCurrentCountToEntries()  // Also save on any change
        }
    }
    
    private func checkAndResetIfNewDay() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let todayStr = formatter.string(from: Date())
        
        if lastDateString != todayStr {
            currentCount = 0
            currentPhraseIndex = 0
            lastDateString = todayStr
        }
    }
    
    // NEW: Save current count to persistent entries
    private func saveCurrentCountToEntries() {
        var entries: [TasbeehEntry] = []
        
        // Load existing entries
        if let decoded = try? JSONDecoder().decode([TasbeehEntry].self, from: entriesData) {
            entries = decoded
        }
        
        // Find today's entry or create new
        if let todayIndex = entries.firstIndex(where: { Calendar.current.isDateInToday($0.date) }) {
            entries[todayIndex] = TasbeehEntry(date: Date(), count: currentCount)
        } else {
            entries.append(TasbeehEntry(date: Date(), count: currentCount))
        }
        
        // Save back
        if let encoded = try? JSONEncoder().encode(entries) {
            entriesData = encoded
        }
    }
}

// MARK: - Progress View
struct ProgressView: View {
    @AppStorage("tasbeeh_entries") private var entriesData: Data = Data()
    
    private var entries: [TasbeehEntry] {
        (try? JSONDecoder().decode([TasbeehEntry].self, from: entriesData)) ?? []
    }
    
    private var todayCount: Int {
        entries.last { Calendar.current.isDateInToday($0.date) }?.count ?? 0
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 16) {
                Text("Today")
                    .font(.title2)
                Text("\(todayCount)")
                    .font(.system(size: 80, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            .padding(40)
            .background(Color.green.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Text("Keep going — consistency builds habits")
                .italic()
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
}

// ────────────────────────────────────────────────
// Launch in Playground
// ────────────────────────────────────────────────

let hosting = UIHostingController(rootView: TasbeehAppView()
    .ignoresSafeArea(edges: .bottom)
)

hosting.preferredContentSize = CGSize(width: 414, height: 896)

PlaygroundPage.current.liveView = hosting
PlaygroundPage.current.needsIndefiniteExecution = true
