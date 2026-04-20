# iOS App Starter Template

See [BUILD.md](./BUILD.md) for the local-Mac iOS release policy for this repo.

This is the factory's default assembly-line template for iOS apps.
Use this as the foundation for every app Mario builds.

## What's Included

- **SwiftUI** app structure with `App` entry point
- **Apple StoreKit** payment integration (default). RevenueCat supported if API key available.
- **Onboarding flow** (3-5 screens, easy to customize)
- **Gemini Flash AI wrapper** (cheap, fast, good enough)
- **Free trial by default** (7 days — converts 6x better than hard paywalls)
- **Restore purchases** button
- **Dark mode support**

## How to Use

1. Copy this folder: `cp -R ~/workspace/app-factory/templates/ios-starter ~/workspace/app-factory/04-in-progress/{app-slug}/`
2. Update `AppConfig.swift` with the app's name, bundle ID, AI prompt, and the correct RevenueCat env var name for that app
3. Keep the actual RevenueCat key in `.env.local` or the runtime environment, never in source
4. Build the screens in `Screens/`
5. Run the quality gates

## Files

```
ios-starter/
├── Sources/
│   ├── App/
│   │   └── AppEntry.swift
│   ├── Config/
│   │   └── AppConfig.swift
│   ├── Payments/
│   │   ├── StoreKitManager.swift
│   │   └── PaywallView.swift
│   ├── AI/
│   │   └── GeminiWrapper.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   └── Screens/
│       └── ContentView.swift
└── Resources/
    └── Assets.xcassets/
```

## Rules

- **Always use StoreKit or RevenueCat for iOS.** Never Stripe for native mobile unless explicitly told otherwise.
- **Default to honest monetization.** If the app uses a one-time unlock, say so clearly in onboarding, paywall, and settings.
- **Keep AI calls cheap.** Gemini Flash is the default wrapper.
- **RevenueCat keys stay in env only.** `AppConfig.revenueCatAPIKey` reads from the runtime environment first, then `.env.local` for local starter-project setup.
