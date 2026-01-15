# SugarCounter iOS App

## Project Overview
A comprehensive Swift Native iOS app for tracking daily refined sugar intake with educational content, personalized insights, and gamification features.

## Target
- **Price**: Free on App Store
- **Initial Release**: TestFlight
- **Platform**: iOS 17.0+ (Swift Native)

## Core Features

### Daily Tracking
- Direct numeric keypad entry (no sliders, no barcode scanning)
- Auto-naming entries as "Item 1", "Item 2", "Item 3", etc.
- **Rename entries**: Long-press on item name to rename (e.g., "Coffee", "Cereal")
- **Edit grams**: Long-press on grams value to modify
- **Customizable daily goal** with color-coded feedback
  - Green: Safe zone (under caution threshold)
  - Yellow: Caution zone
  - Red: Over limit
- Circular progress ring visualization (tap to change goal)
- **Smart Daily Insight Card**: Personalized insights based on user patterns
  - Weekly comparison ("3g better than last week!")
  - Time-of-day patterns ("Evening is your peak sugar time")
  - Weekday vs weekend analysis
  - Pace projections ("At this pace, you'll hit ~28g today")
  - Streak encouragement
- Swipe-to-delete entries
- Context menu with Rename, Edit Grams, Delete options

### Customizable Goals
- **Goal Presets**:
  - WHO Recommended (25g daily, 15g caution)
  - AHA Women (25g daily, 15g caution)
  - AHA Men (36g daily, 24g caution)
  - Low Sugar (15g daily, 10g caution)
  - Custom (user-defined)
- Visual preview of goal zones
- Tap progress ring to access goal settings

### Date Navigation
- Back/forward arrows to navigate between days
- "Back to Today" quick link when viewing past dates
- **Retrospective data entry**: Add entries to any past date
- Works in both Daily view and Calendar day detail view

### Insights & Gamification
- **Current Streak**: Consecutive days under goal
- **Longest Streak**: Personal best record
- **Statistics**:
  - Total days tracked
  - Success rate (% of days under goal)
  - Daily average
  - Best day
- **Pattern Analysis**:
  - Weekday vs weekend comparison
  - Trend insights
- **Weekly Trend Comparison**:
  - This week vs last week averages
  - Trend direction indicator (improving/stable/declining)
  - Percentage change visualization
- **Time-of-Day Analysis**:
  - Morning/Afternoon/Evening/Night breakdown
  - Average grams per time period
  - Peak sugar time identification
  - Visual percentage bars
- **Achievements System**:
  - First Step (1 day tracked)
  - Week Warrior (7 days tracked)
  - Monthly Master (30 days tracked)
  - On Fire (3-day streak)
  - Unstoppable (7-day streak)
  - Sugar Master (14-day streak)
  - Perfect Week
  - Goal Getter (10 days under goal)
  - Sugar Champion (30 days under goal)

### Charts
- Bar graph with period selector (Week, 2 Weeks, 3 Weeks, Month)
- Color-coded bars showing daily status
- Dynamic goal reference line
- Summary stats (average, days over, days in green)

### Calendar History
- Month view with navigation
- Color-coded dots per day (green/yellow/red/gray)
- Tap any date to view/add entries (future dates disabled)
- Date navigation within day detail sheet
- Dynamic legend based on current goal
- Info button for quick access to About page
- Export button for quick CSV export

### Learn (Educational Content)
- **Understanding Sugar**: What is refined sugar, why track it
- **Sugar in Common Foods**: Searchable database with 80+ items
  - Categories: Beverages, Breakfast, Snacks, Desserts, Condiments, Dairy, Fast Food
  - Search and filter functionality
  - Color-coded sugar amounts
- **Hidden Sugars**: Surprising sources of sugar in everyday foods
- **Health Tips**: Practical strategies to reduce sugar intake
- **Official Guidelines**: WHO and AHA recommendations explained
- Info button for quick access to About page

### About & Export
- About page accessible via info button (top left)
- App information and developer credits
- Medical disclaimer
- **CSV Export**: Export all data as CSV file (Date DD/MM/YYYY, Total Sugar)
- Share via email, AirDrop, or save to Files

### Design Principles
- Minimalist and streamlined UI
- Haptic feedback on all interactions
- System adaptive light/dark mode
- 100% local storage (no cloud)
- Educational focus for unique value

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
│   ├── SugarEntry.swift           # SwiftData model (with customName)
│   ├── SugarConstants.swift       # Goal/threshold constants (dynamic)
│   ├── UserSettings.swift         # User preferences & goals
│   └── InsightEngine.swift        # Smart insight generation & pattern analysis
├── Views/
│   ├── ContentView.swift          # Tab container (5 tabs)
│   ├── DailyView.swift            # Main daily tracking + date nav + insight card
│   ├── EntryKeypadView.swift      # Numeric input for new entries
│   ├── ChartView.swift            # Bar chart view
│   ├── CalendarView.swift         # Historical calendar + DayDetailView
│   ├── InsightsView.swift         # Streaks, stats, achievements, trends
│   ├── LearnView.swift            # Educational content hub
│   ├── CommonFoodsView.swift      # Sugar reference database
│   ├── GoalSettingsView.swift     # Goal customization
│   └── AboutView.swift            # About page + CSV export
├── Components/
│   ├── ProgressRingView.swift     # Circular progress
│   ├── EntryRowView.swift         # Entry list item (with long-press)
│   ├── SmartInsightCard.swift     # Personalized insight display
│   ├── TimeOfDayCard.swift        # Time-of-day consumption analysis
│   └── WeeklyTrendCard.swift      # Week-over-week comparison
└── Assets.xcassets/               # App icon, colors
```

## Data Model

### SugarEntry
- `id`: UUID
- `grams`: Double
- `itemNumber`: Int (auto-incremented per day)
- `timestamp`: Date
- `dayIdentifier`: String (yyyy-MM-dd)
- `customName`: String? (optional rename)
- `displayName`: Computed (customName ?? "Item X")

### UserSettings
- `id`: UUID
- `dailyGoal`: Double (customizable)
- `cautionThreshold`: Double (customizable)
- `selectedPreset`: String (GoalPreset enum)
- `streakStartDate`: Date?
- `longestStreak`: Int
- `totalDaysTracked`: Int
- `achievementsUnlocked`: [String]

## Setup Instructions

### Using XcodeGen
1. Install XcodeGen: `brew install xcodegen`
2. Navigate to project folder: `cd /path/to/SugarCounter`
3. Generate project: `xcodegen generate`
4. Open `SugarCounter.xcodeproj` in Xcode

### Before Building
1. Update bundle identifier in project settings
2. Select your development team
3. Add a 1024x1024 app icon to Assets.xcassets/AppIcon.appiconset

## Status
- [x] Planning phase
- [x] Project setup (source files created)
- [x] Xcode project generation
- [x] Core data model (SugarEntry + Constants)
- [x] Entry screen (DailyView + Keypad)
- [x] Daily summary view (Progress ring)
- [x] Bar chart visualization (ChartView)
- [x] Calendar history view (CalendarView)
- [x] Rename entries feature
- [x] Edit grams feature
- [x] Date navigation (back/forward)
- [x] Retrospective data entry
- [x] About page
- [x] CSV export
- [x] App icon added
- [x] **Customizable Goals** (with presets)
- [x] **Insights View** (streaks, stats)
- [x] **Achievements System** (9 achievements)
- [x] **Learn Tab** (educational content)
- [x] **Common Foods Database** (80+ items)
- [x] **Smart Daily Insights** (personalized pattern analysis)
- [x] **Time-of-Day Analysis** (consumption timing breakdown)
- [x] **Weekly Trend Comparison** (this week vs last week)
- [ ] TestFlight deployment
- [ ] App Store submission

## TestFlight Checklist
- [ ] Create App Store Connect app record
- [ ] Configure signing certificates
- [ ] Build and archive
- [ ] Upload to App Store Connect
- [ ] Add TestFlight testers

## App Store Submission Checklist
- [x] App icon (1024x1024)
- [ ] Screenshots for all required device sizes
- [ ] App description and keywords
- [ ] Privacy policy URL
- [ ] Set price to Free
- [ ] Submit for review

## App Store Differentiators
These features differentiate SugarCounter from simple template apps:
1. **Personalized Intelligence**: Smart insights on main screen analyzing individual user patterns
   - Dynamic messages based on actual consumption data
   - Weekly trend comparisons with specific numbers
   - Time-of-day pattern recognition
   - Pace projections and streak encouragement
2. **Time-Based Behavioral Analysis**: Breakdown of when sugar is consumed (morning/afternoon/evening/night)
3. **Weekly Trend Tracking**: Visual comparison of this week vs last week with improvement percentages
4. **Educational Content**: Curated information about sugar, health guidelines, and hidden sugars
5. **Common Foods Database**: 80+ items with sugar content, searchable and categorized
6. **Smart Pattern Recognition**: Weekday vs weekend analysis, streak tracking
7. **Gamification**: 9 unlockable achievements to encourage healthy habits
8. **Customizable Goals**: Multiple presets (WHO, AHA) plus custom option

### Why These Features Pass App Store Review (4.3a)
Template apps typically show raw data (today's total, goal). SugarCounter provides:
- **Personalized insights** based on individual user patterns (not generic tips)
- **Behavioral analysis** using timestamps that were stored but never analyzed
- **Comparative trends** with specific numbers (not just charts)
- **Predictive messaging** ("At this pace..." projections)
