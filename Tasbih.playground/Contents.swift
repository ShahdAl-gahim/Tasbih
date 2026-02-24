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
    @State private var selectedTab: Tab = .tasbeeh  // Start on main counter
    
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
                    .padding(.horizontal, 40)
                }
            }
        }
        .accentColor(.green)
        .preferredColorScheme(.light)
    }
    
    private var tabTitle: String {
        switch selectedTab {
        case .learn:    return "Learn About Tasbeeh"
        case .tasbeeh:  return "Tasbeeh"
        case .progress: return "Your Progress"
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

// ────────────────────────────────────────────────
// Education, Counter, Progress views (same as before, minor cleanups)
// ────────────────────────────────────────────────

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

struct CounterView: View {
    @AppStorage("tasbeeh_currentCount") private var currentCount: Int = 0
    @AppStorage("tasbeeh_lastDate") private var lastDateString: String = ""
    
    let phrases = ["SubhanAllah", "Alhamdulillah", "Allahu Akbar"]
    @State private var currentPhraseIndex = 0
    
    var body: some View {
        VStack(spacing: 40) {
            // Title moved to navigation bar
            ZStack {
                ForEach(0..<99) { index in
                    Circle()
                        .fill(index < currentCount ? Color.green.opacity(0.75) : Color.gray.opacity(0.25))
                        .frame(width: 20, height: 20)
                        .offset(
                            x: CGFloat(cos(Double(index) * .pi * 2 / 99)) * 130,
                            y: CGFloat(sin(Double(index) * .pi * 2 / 99)) * 130
                        )
                        .animation(.easeOut(duration: 0.25), value: currentCount)
                }
                
                VStack(spacing: 8) {
                    Text("\(currentCount)")
                        .font(.system(size: 90, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Text(phrases[currentPhraseIndex])
                        .font(.title2)
                        .foregroundColor(.primary.opacity(0.85))
                }
            }
            .frame(height: 320)
            
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.prepare()
                generator.impactOccurred()
                
                currentCount += 1
                
                if currentCount % 33 == 0 && currentCount > 0 {
                    currentPhraseIndex = (currentPhraseIndex + 1) % 3
                }
            }) {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 240, height: 240)
                    .overlay(
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.green)
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Text("Tap the circle to count")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Reset Today") {
                currentCount = 0
                currentPhraseIndex = 0
            }
            .font(.headline)
            .foregroundColor(.red.opacity(0.7))
            .padding(.top, 20)
        }
        .padding()
        .background(LinearGradient(colors: [.white, Color.green.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing))
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
    .ignoresSafeArea()
)

hosting.preferredContentSize = CGSize(width: 414, height: 896)  // iPhone size – change to 500x1000 if needed

PlaygroundPage.current.liveView = hosting
PlaygroundPage.current.needsIndefiniteExecution = true
