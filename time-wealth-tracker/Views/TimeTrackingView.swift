import SwiftUI

struct TimeTrackingView: View {
    @EnvironmentObject var store: TimeWealthStore
    @State private var isTracking = false
    @State private var selectedCategory: TimeCategory = .work
    @State private var note = ""
    @State private var startTime: Date?
    @State private var timer: Timer?
    @State private var elapsedSeconds = 0
    @State private var showingManualEntry = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                timerDisplay
                categorySelector
                noteInput
                controlButtons
                
                if isTracking {
                    Text("已记录 \(formattedTime)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    showingManualEntry = true
                }) {
                    Label("手动记录", systemImage: "plus.circle.fill")
                        .font(.headline)
                }
                .padding()
                .sheet(isPresented: $showingManualEntry) {
                    ManualEntryView()
                }
            }
            .padding()
            .navigationTitle("时间记录")
        }
    }
    
    private var timerDisplay: some View {
        VStack {
            Text(isTracking ? "正在记录..." : "准备开始")
                .font(.title2)
                .foregroundColor(isTracking ? .blue : .secondary)
            
            Text(formattedTime)
                .font(.system(size: 60, weight: .bold, design: .rounded))
                .monospacedDigit()
                .padding()
        }
    }
    
    private var categorySelector: some View {
        Picker("类别", selection: $selectedCategory) {
            ForEach(TimeCategory.allCases, id: \.self) { category in
                HStack {
                    Image(systemName: category.icon)
                    Text(category.rawValue)
                }
                .tag(category)
            }
        }
        .pickerStyle(.menu)
        .disabled(isTracking)
    }
    
    private var noteInput: some View {
        TextField("添加备注", text: $note)
            .textFieldStyle(.roundedBorder)
            .disabled(isTracking)
    }
    
    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button(action: toggleTracking) {
                Text(isTracking ? "停止" : "开始")
                    .font(.title3)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isTracking ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            if isTracking {
                Button(action: resetTimer) {
                    Text("重置")
                        .font(.title3)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private var formattedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    private func toggleTracking() {
        isTracking.toggle()
        
        if isTracking {
            startTime = Date()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                elapsedSeconds += 1
            }
        } else {
            timer?.invalidate()
            timer = nil
            
            if let start = startTime {
                let entry = TimeEntry(
                    startTime: start,
                    endTime: Date(),
                    category: selectedCategory,
                    note: note,
                    amount: Double(elapsedSeconds) / 60.0
                )
                store.saveTimeEntry(entry)
            }
            
            resetTimer()
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        timer = nil
        elapsedSeconds = 0
        isTracking = false
        startTime = nil
    }
}
