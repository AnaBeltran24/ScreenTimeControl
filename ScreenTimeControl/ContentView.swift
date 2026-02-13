//
//  ContentView.swift
//  ScreenTimeControl
//
//  Created by Ana Beltran on 12/02/26.
//
import SwiftUI

// MARK: - Mock Data Models

/// Represents an application that has been restricted.
struct BlockedApp: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
}

/// Represents a healthy alternative activity to replace screen time.
/// Conforms to `Equatable` so SwiftUI knows exactly when a specific row changes.
struct PremiumAlternative: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String // SFSymbol name
    let color: Color
}

// MARK: - Main View

struct DashboardView: View {
    // Controls the padlock toggle state at the top right
    @State private var isLocked: Bool = true
    
    // Triggers the initial cascading entry animation when the view loads
    @State private var appearAnimation: Bool = false
    
    // Tracks which premium alternative is currently selected by its unique ID
    @State private var selectedAlternativeID: UUID? = nil
    
    // MARK: Modal & Animation States
    
    // Toggles the visibility of the expanded Blocked Apps view
    @State private var showBlockedAppsModal: Bool = false
    
    // Namespace required for `matchedGeometryEffect` to smoothly morph
    // the small card into the large modal view
    @Namespace private var animation
    
    // MARK: Data Sources
    
    // Static mock data for the blocked applications
    let blockedApps: [BlockedApp] = [
        BlockedApp(name: "Instagram", color: .pink),
        BlockedApp(name: "TikTok", color: .black),
        BlockedApp(name: "Snapchat", color: .yellow),
        BlockedApp(name: "X (Twitter)", color: .blue),
        BlockedApp(name: "Facebook", color: .blue.opacity(0.7)),
        BlockedApp(name: "Reddit", color: .orange),
        BlockedApp(name: "YouTube", color: .red),
        BlockedApp(name: "Netflix", color: .red.opacity(0.8)),
        BlockedApp(name: "Games", color: .green)
    ]
    
    // The master pool of all available healthy habits
    let masterAlternatives: [PremiumAlternative] = [
        PremiumAlternative(title: "Lofi Music", subtitle: "App blocks and take a lofi break", iconName: "headphones", color: .purple),
        PremiumAlternative(title: "Nature Sounds", subtitle: "Relax with ambient forest audio", iconName: "leaf.fill", color: .green),
        PremiumAlternative(title: "Pomodoro Timer", subtitle: "Focus for 25 mins, then rest", iconName: "timer", color: .orange),
        PremiumAlternative(title: "Breathwork", subtitle: "Guided 5-minute breathing", iconName: "wind", color: .cyan),
        PremiumAlternative(title: "Reading Mode", subtitle: "Open your Kindle app instead", iconName: "book.fill", color: .blue),
        PremiumAlternative(title: "Sudoku Puzzle", subtitle: "Stimulate your brain with logic", iconName: "number.square.fill", color: .indigo),
        PremiumAlternative(title: "Stretching", subtitle: "Quick desk stretches for posture", iconName: "figure.walk", color: .yellow),
        PremiumAlternative(title: "Journaling", subtitle: "Write down your thoughts", iconName: "text.book.closed.fill", color: .mint)
    ]
    
    // The subset of 4 alternatives actively displayed on the screen
    @State private var currentAlternatives: [PremiumAlternative] = []
    
    var body: some View {
        ZStack {
            // MARK: Main Background
            // Using Apple's native grouped background color provides automatic
            // light/dark mode support and matches the iOS Settings app style.
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            // MARK: Main Scroll Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                        // Applies the slide-up and fade-in animation on launch
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : -20)
                    
                    metricsSection
                        .opacity(appearAnimation ? 1 : 0)
                        .offset(y: appearAnimation ? 0 : 20)
                    
                    alternativesHeader
                        .opacity(appearAnimation ? 1 : 0)
                    
                    alternativesList
                }
                .padding()
            }
            // Dims and blurs the underlying content when the modal pops open
            .blur(radius: showBlockedAppsModal ? 5 : 0)
            .opacity(showBlockedAppsModal ? 0.6 : 1)
            
            // MARK: Expanded Modal Overlay
            if showBlockedAppsModal {
                // An almost-invisible background layer that captures taps
                // to dismiss the modal when tapping outside the card
                Color.black.opacity(0.01)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeModal()
                    }
                
                BlockedAppsExpandedView(
                    apps: blockedApps,
                    namespace: animation,
                    onClose: closeModal
                )
                // zIndex ensures the modal animates OVER the scroll content
                .zIndex(1)
            }
        }
        .onAppear {
            // Initialize the list with the first 4 items from the master pool
            currentAlternatives = Array(masterAlternatives.prefix(4))
            
            // Pre-select the third item to match your original design requirement
            if let thirdItem = currentAlternatives.dropFirst(2).first {
                selectedAlternativeID = thirdItem.id
            }
            
            // Trigger the initial entry animations with a gentle spring
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }
    
    // MARK: - View Builders (Subviews)
    
    private var headerSection: some View {
        HStack(alignment: .top) {
            Text("Hi Anonymous\nChild")
                // `.design: .rounded` gives it a friendly, modern Apple feel
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Lock Toggle Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isLocked.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                        .foregroundColor(isLocked ? .primary : .secondary)
                        // Smoothly morphs the padlock icon from closed to open
                        .contentTransition(.symbolEffect(.replace))
                    
                    // The sliding "thumb" of the custom toggle switch
                    Circle()
                        .fill(isLocked ? Color.red.opacity(0.8) : Color.gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                        .offset(x: isLocked ? 12 : -12)
                }
                .padding(8)
                .frame(width: 65, height: 36)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .buttonStyle(.plain) // Prevents the whole button from flashing blue on tap
        }
        .padding(.top, 10)
    }
    
    private var metricsSection: some View {
        HStack(spacing: 16) {
            // Left column containing two stacked metrics
            VStack(spacing: 16) {
                MetricCard(title: "Daily usage", value: "5 hrs 24 mins")
                MetricCard(title: "Focus Time", value: "1 hrs 03 mins")
            }
            // `maxWidth: .infinity` allows this column to take up exactly 50% of the screen width
            .frame(maxWidth: .infinity)
            
            // Right column: The interactive Blocked Apps card
            if !showBlockedAppsModal {
                Button(action: {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
                        showBlockedAppsModal = true
                    }
                }) {
                    BlockedAppsCard()
                }
                .buttonStyle(.plain)
                // This ID must exactly match the ID in the ExpandedView for the morph to work
                .matchedGeometryEffect(id: "blockedAppsCard", in: animation)
                .frame(maxWidth: .infinity)
            } else {
                // When the modal opens, we leave a transparent placeholder here
                // so the left column doesn't snap to the center of the screen
                Color.clear
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var alternativesHeader: some View {
        HStack {
            Text("Premium Alternatives")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                shuffleAlternatives()
            }) {
                Image(systemName: "shuffle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.red.opacity(0.8))
            }
        }
        .padding(.top, 10)
    }
    
    private var alternativesList: some View {
        VStack(spacing: 12) {
            // Loop through our dynamically tracked current 4 alternatives
            ForEach(Array(currentAlternatives.enumerated()), id: \.element.id) { index, alt in
                AlternativeRow(
                    alternative: alt,
                    isActive: selectedAlternativeID == alt.id,
                    delay: Double(index) * 0.1 // Staggers the animation on load
                ) {
                    // Update selection with a bouncy animation
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedAlternativeID = alt.id
                    }
                }
                // Defines how rows enter and exit when the Shuffle button is pressed
                // They shrink to 90% scale and fade out/in
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
            }
        }
    }
    
    // MARK: - Actions
    
    /// Closes the blocked apps modal with a spring animation
    private func closeModal() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75)) {
            showBlockedAppsModal = false
        }
    }
    
    /// Shuffles the current alternatives pool to show 4 new options
    private func shuffleAlternatives() {
        // Triggers a light physical haptic tap on the device
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            // Shuffle the master list and grab the first 4
            let newSelection = masterAlternatives.shuffled().prefix(4)
            currentAlternatives = Array(newSelection)
            
            // Deselect everything when the list is refreshed
            selectedAlternativeID = nil
        }
    }
}

// MARK: - Reusable Components

/// A simple, reusable card for displaying a title and a value
struct MetricCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Pushes the text to the top
            Spacer(minLength: 0)
        }
        .padding()
        // Aligns content to the top-left of the card
        .frame(maxWidth: .infinity, alignment: .leading)
        // `.secondarySystemGroupedBackground` provides proper contrast against the main background
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

/// The unexpanded state of the blocked apps card
struct BlockedAppsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Blocked Apps")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("9 blocked")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer(minLength: 0)
            
            // Overlapping circles representation (Avatars)
            // Negative spacing makes the circles overlap like Apple Messages groups
            HStack(spacing: -12) {
                Circle().fill(Color.green.opacity(0.6)).frame(width: 36)
                Circle().fill(Color.blue.opacity(0.6)).frame(width: 36)
                Circle().fill(Color.yellow.opacity(0.6)).frame(width: 36)
                ZStack {
                    Circle().fill(Color.pink.opacity(0.6)).frame(width: 36)
                    Text("5+")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

/// The full-screen/modal state of the blocked apps list
struct BlockedAppsExpandedView: View {
    let apps: [BlockedApp]
    var namespace: Namespace.ID
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Modal Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Blocked Apps")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("\(apps.count) apps currently restricted")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Close button
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            .padding()
            .padding(.top, 8)
            
            // Scrollable list of individual apps
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(apps) { app in
                        HStack(spacing: 16) {
                            // Faux App Icon
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(app.color.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Image(systemName: "app.fill")
                                        .foregroundColor(app.color)
                                )
                            
                            Text(app.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Image(systemName: "lock.fill")
                                .foregroundColor(.red.opacity(0.8))
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                        
                        // Separator line native to iOS lists
                        Divider()
                            .padding(.leading, 76)
                    }
                }
                .padding(.bottom, 24)
            }
        }
        // Prevents the modal from stretching too wide on iPads, keeping it a nice floating card
        .frame(maxWidth: 500, maxHeight: 600)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .padding()
        // MAGIC: Links this large view to the small card for the morphing animation
        .matchedGeometryEffect(id: "blockedAppsCard", in: namespace)
    }
}

/// A row displaying a single premium alternative option
struct AlternativeRow: View {
    let alternative: PremiumAlternative
    let isActive: Bool
    let delay: Double
    let action: () -> Void
    
    // Controls the slide-in-from-left animation on initial load
    @State private var isVisible: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Dynamic Icon & Colored Background
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(alternative.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: alternative.iconName)
                            .foregroundColor(alternative.color)
                            .font(.system(size: 20, weight: .semibold))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(alternative.color.opacity(0.3), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(alternative.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(alternative.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        // Ensures the subtitle doesn't wrap weirdly on small iPhones (like the SE)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
                
                Spacer()
                
                // ZStack prevents layout jumps when switching between the Chevron and the "ACTIVE" text
                ZStack {
                    if isActive {
                        Text("ACTIVE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(alternative.color)
                            // Fades and scales in simultaneously
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            // Adds the colored border when active
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isActive ? alternative.color.opacity(0.8) : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        // Modifiers for the initial load slide-in animation
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    DashboardView()
}
