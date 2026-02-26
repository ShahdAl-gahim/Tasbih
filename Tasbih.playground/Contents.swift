import SwiftUI
import UIKit
import PlaygroundSupport

// Define custom maroon color (add this)
extension Color {
    static let maroon = Color(red: 0.5, green: 0.0, blue: 0.0)  // #800000 - deep maroon
}

// MARK: - Model
struct TasbeehEntry: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

// MARK: - Root Container
struct TasbeehAppView: View {
    @State private var selectedTab: Tab = .tasbeeh
    
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
        .accentColor(.maroon)
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
            .foregroundColor(selectedTab == tab ? .maroon : .gray)
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
                    .foregroundColor(.maroon)
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
        .background(LinearGradient(colors: [.white, Color.maroon.opacity(0.08)], startPoint: .top, endPoint: .bottom))
    }
}

// MARK: - Counter View
struct CounterView: View {
    @AppStorage("tasbeeh_currentCount") private var currentCount: Int = 0
    @AppStorage("tasbeeh_lastDate") private var lastDateString: String = ""
    
    let phrases = ["SubhanAllah", "Alhamdulillah", "Allahu Akbar"]
    @State private var currentPhraseIndex = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 60)
            
            ZStack {
                if let url = Bundle.main.url(forResource: "tasbih_beads", withExtension: "png"),
                   let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 580, height: 480)
                } else {
                    Text("Image load failed")
                        .foregroundColor(.red)
                }
                
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
                    }
                
                VStack(spacing: 8) {
                    Text("\(currentCount)")
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.maroon)
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
            }
            .font(.headline)
            .foregroundColor(.maroon.opacity(0.7))
            .padding(.top, 12)
            
            Spacer(minLength: 80)
        }
        .padding(.horizontal, 20)
        .background(LinearGradient(colors: [.white, Color.maroon.opacity(0.04)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .onAppear(perform: checkAndResetIfNewDay)
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
                    .foregroundColor(.maroon)
            }
            .padding(40)
            .background(Color.maroon.opacity(0.08))
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
