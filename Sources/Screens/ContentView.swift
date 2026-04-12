import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: StoreKitManager
    @State private var showPaywall = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Hello, App Factory!")
                    .font(.largeTitle.bold())
                
                if store.isPremium {
                    Label("Premium Active", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                } else {
                    Text("Free trial active")
                        .foregroundStyle(.secondary)
                }
                
                Button("Unlock Premium") {
                    showPaywall = true
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
                    .environmentObject(store)
            }
        }
    }
}
