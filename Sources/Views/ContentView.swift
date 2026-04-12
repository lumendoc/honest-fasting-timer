import SwiftUI

struct ContentView: View {
    @StateObject private var purchaseService = PurchaseService()
    @State private var showSettings = false
    
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar")
                }
        }
        .environmentObject(purchaseService)
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(purchaseService)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showSettings = true
            } label: {
                Image(systemName: "gear")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .padding()
            }
        }
    }
}
