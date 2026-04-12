import SwiftUI

struct ContentView: View {
    @StateObject private var purchaseService = PurchaseService()
    
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
    }
}
