//
//  ContentView.swift
//  ScreenTimeControl
//
//  Created by Ana Beltran on 12/02/26.
//
import SwiftUI

/// A high-level dashboard screen displaying user metrics,
/// blocked app insights, and selectable premium alternatives.
///
/// `DashboardView` is composed of four primary sections:
/// - Header (user greeting + lock toggle)
/// - Top metrics (usage statistics + blocked apps summary)
/// - Alternatives header
/// - Animated list of premium alternatives
///
/// The view uses spring animations to provide smooth entrance
/// transitions and state-based UI updates.
struct DashboardView: View {
    
    /// Indicates whether the dashboard is currently in a locked state.
    /// Toggling this value updates the lock UI with animation.
    @State private var isLocked: Bool = true
    
    /// Controls the entrance animation of the main sections.
    /// Set to `true` inside `onAppear` to trigger animated transitions.
    @State private var appearAnimation: Bool = false
    
    /// The currently selected premium alternative index.
    /// Determines which `AlternativeRow` is displayed as active.
    @State private var selectedAlternativeIndex: Int = 2
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                // MARK: - Header
                headerSection
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : -20)
                
                // MARK: - Top Metrics
                metricsSection
                    .opacity(appearAnimation ? 1 : 0)
                    .offset(y: appearAnimation ? 0 : 20)
                
                // MARK: - Alternatives Section
                alternativesHeader
                    .opacity(appearAnimation ? 1 : 0)
                
                alternativesList
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .onAppear {
            // Triggers entrance animation for header and metrics
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appearAnimation = true
            }
        }
    }
}

// MARK: - Private Subviews
extension DashboardView {
    
    /// Header section containing:
    /// - Greeting text
    /// - Animated lock/unlock toggle button
    ///
    /// The lock button animates both symbol replacement and
    /// toggle indicator position using a spring animation.
    private var headerSection: some View {
        HStack(alignment: .top) {
            Text("Hi Anonymous\nChild")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isLocked.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                        .foregroundColor(isLocked ? .primary : .secondary)
                        .contentTransition(.symbolEffect(.replace))
                    
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
            .buttonStyle(.plain)
        }
        .padding(.top, 10)
    }
    
    /// Displays usage metrics and blocked apps summary.
    ///
    /// Layout:
    /// - Left column: two `MetricCard` views
    /// - Right column: `BlockedAppsCard`
    ///
    /// Each column expands to occupy 50% of available width.
    private var metricsSection: some View {
        HStack(spacing: 16) {
            VStack(spacing: 16) {
                MetricCard(title: "Daily usage", value: "5 hrs 24 mins")
                MetricCard(title: "Focus Time", value: "1 hrs 03 mins")
            }
            .frame(maxWidth: .infinity)
            
            BlockedAppsCard()
                .frame(maxWidth: .infinity)
        }
    }
    
    /// Header row for the Premium Alternatives section.
    ///
    /// Includes:
    /// - Section title
    /// - Shuffle button with haptic feedback
    private var alternativesHeader: some View {
        HStack {
            Text("Premium Alternatives")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }) {
                Image(systemName: "shuffle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.red.opacity(0.8))
            }
        }
        .padding(.top, 10)
    }
    
    /// Animated vertical list of premium alternatives.
    ///
    /// Each row:
    /// - Animates into view with a staggered delay
    /// - Updates selection with a spring animation
    /// - Highlights the active row with border + label
    private var alternativesList: some View {
        VStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                AlternativeRow(
                    isActive: index == selectedAlternativeIndex,
                    delay: Double(index) * 0.1
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedAlternativeIndex = index
                    }
                }
            }
        }
    }
}

// MARK: - Components

/// A reusable metric display card showing a title and value.
///
/// Used for daily usage and focus time statistics.
struct MetricCard: View {
    
    /// Metric title (e.g., "Daily usage")
    let title: String
    
    /// Metric value (e.g., "5 hrs 24 mins")
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
            
            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

/// A summary card displaying the number of blocked apps
/// and a stacked preview of app indicators.
///
/// Designed to visually balance alongside `MetricCard`.
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

/// A selectable row representing a premium alternative.
///
/// Features:
/// - Staggered entrance animation
/// - Active/inactive state styling
/// - Animated content transitions
/// - Spring-based tap selection animation
struct AlternativeRow: View {
    
    /// Indicates whether the row is currently active.
    let isActive: Bool
    
    /// Delay used to stagger the row entrance animation.
    let delay: Double
    
    /// Action triggered when the row is tapped.
    let action: () -> Void
    
    /// Controls the row’s entrance animation.
    @State private var isVisible: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(red: 0.85, green: 0.8, blue: 0.95))
                    .frame(width: 48, height: 48)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Lofi Music")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("App blocks and take a lofi break")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                }
                
                Spacer()
                
                ZStack {
                    if isActive {
                        Text("ACTIVE")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.purple)
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
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isActive ? Color.purple.opacity(0.8) : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
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
