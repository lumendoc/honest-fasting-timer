import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var page = 0
    
    private let pages = [
        OnboardingPage(
            title: "Honest Fasting Timer",
            description: "A simple, honest fasting tracker with no subscriptions. Pay once, use forever.",
            icon: "timer"
        ),
        OnboardingPage(
            title: "Track Your Fasts",
            description: "Choose from popular fasting schedules like 16:8, 18:6, and OMAD. Or create your own custom fast.",
            icon: "chart.bar"
        ),
        OnboardingPage(
            title: "Stay on Track",
            description: "Get notifications when your fast completes. View your history and build streaks.",
            icon: "bell"
        )
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: pages[page].icon)
                .font(.system(size: 80))
                .foregroundStyle(.accent)
            
            Text(pages[page].title)
                .font(.largeTitle.bold())
            
            Text(pages[page].description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<pages.count, id: \.self) { index in
                    Circle()
                        .fill(index == page ? Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            Button {
                if page < pages.count - 1 {
                    withAnimation { page += 1 }
                } else {
                    onComplete()
                }
            } label: {
                Text(page < pages.count - 1 ? "Next" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }
}

private struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
}
