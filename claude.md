# SugarCounter iOS App

## Project Overview
A simple, streamlined Swift Native iOS app for tracking daily refined sugar intake.

## Target
- **Price**: $0.99 on App Store
- **Initial Release**: TestFlight
- **Platform**: iOS 17.0+ (Swift Native)

## Core Features

### Daily Tracking
- Direct numeric keypad entry (no sliders, no barcode scanning)
- Auto-naming entries as "Item 1", "Item 2", "Item 3", etc.
- Daily goal: 30g with color-coded feedback
  - Green: 0-20g (safe zone)
  - Yellow: 21-30g (caution)
  - Red: 31g+ (over limit)
- Circular progress ring visualization
- Swipe-to-delete entries

### Charts
- Bar graph with period selector (Week, 2 Weeks, 3 Weeks, Month)
- Color-coded bars showing daily status
- 30g goal reference line
- Summary stats (average, days over, days in green)

### Calendar History
- Month view with navigation
- Color-coded dots per day
- Tap to view day details
- Legend for color meanings

### Design Principles
- Minimalist and streamlined UI
- Haptic feedback on interactions
- System adaptive light/dark mode
- 100% local storage (no cloud)

## Technical Stack
- Swift 5.9+ / SwiftUI
- SwiftData for persistence
- Swift Charts for visualization
- MVVM architecture

## Project Structure
```
SugarCounter/
├── SugarCounterApp.swift          # App entry point
├── Models/
│   ├── SugarEntry.swift           # SwiftData model
│   └── SugarConstants.swift       # Goal/threshold constants
├── Views/
│   ├── ContentView.swift          # Tab container
│   ├── DailyView.swift            # Main daily tracking
│   ├── EntryKeypadView.swift      # Numeric input
│   ├── ChartView.swift            # Bar chart view
│   └── CalendarView.swift         # Historical calendar
├── Components/
│   ├── ProgressRingView.swift     # Circular progress
│   └── EntryRowView.swift         # Entry list item
└── Assets.xcassets/               # App icon, colors
```

## Setup Instructions

### Option 1: Using XcodeGen (Recommended)
1. Install XcodeGen: `brew install xcodegen`
2. Navigate to project folder: `cd /path/to/SugarCounter`
3. Generate project: `xcodegen generate`
4. Open `SugarCounter.xcodeproj` in Xcode

### Option 2: Manual Xcode Setup
1. Open Xcode → File → New → Project
2. Choose "App" under iOS
3. Configure:
   - Product Name: SugarCounter
   - Interface: SwiftUI
   - Storage: SwiftData
   - Minimum Deployment: iOS 17.0
4. Delete the default ContentView.swift and SugarCounterApp.swift
5. Drag all files from `SugarCounter/` folder into the project
6. Ensure "Copy items if needed" is unchecked (files already in place)

### Before Building
1. Update bundle identifier in project settings
2. Select your development team
3. Add a 1024x1024 app icon to Assets.xcassets/AppIcon.appiconset

## Status
- [x] Planning phase
- [x] Project setup (source files created)
- [x] Core data model (SugarEntry + Constants)
- [x] Entry screen (DailyView + Keypad)
- [x] Daily summary view (Progress ring)
- [x] Bar chart visualization (ChartView)
- [x] Calendar history view (CalendarView)
- [ ] Xcode project generation
- [ ] App icon design
- [ ] TestFlight deployment
- [ ] App Store submission

## TestFlight Checklist
- [ ] Create App Store Connect app record
- [ ] Configure signing certificates
- [ ] Build and archive
- [ ] Upload to App Store Connect
- [ ] Add TestFlight testers

## App Store Submission Checklist
- [ ] App icon (1024x1024)
- [ ] Screenshots for all required device sizes
- [ ] App description and keywords
- [ ] Privacy policy URL
- [ ] Set price to $0.99
- [ ] Submit for review
