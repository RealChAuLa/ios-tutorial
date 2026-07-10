//
//  MapView.swift
//  ios-tutorial
//
//  Created by Student3 on 2026-07-06.
//
import SwiftUI
import MapKit

// MARK: - Map / Game History Map
struct MapView: View {
    @AppStorage("locationEnabled") private var locationEnabled = false
    @StateObject private var viewModel = MapViewModel()
    @State private var mapPosition: MapCameraPosition = .automatic
    
    var body: some View {
        if !locationEnabled {
            MapPlaceholderView()
        } else {
            NavigationStack {
                ZStack(alignment: .top) {
                // Main Map
                Map(position: $mapPosition) {
                    // Show User Location if authorized
                    UserAnnotation()
                    
                    // Game Session Pins
                    ForEach(viewModel.filteredSessions) { session in
                        if let lat = session.latitude, let lon = session.longitude {
                            Annotation(viewModel.title(for: session.mode), coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)) {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                        viewModel.selectedSession = session
                                        mapPosition = .region(MKCoordinateRegion(
                                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        ))
                                    }
                                } label: {
                                    ZStack(alignment: .topTrailing) {
                                        // Pin Circle
                                        ZStack {
                                            Circle()
                                                .fill(LinearGradient(
                                                    colors: [viewModel.color(for: session.mode), viewModel.colorDark(for: session.mode)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ))
                                                .frame(width: 44, height: 44)
                                                .overlay(Circle().stroke(Color.white, lineWidth: 2.5))
                                                .shadow(color: viewModel.color(for: session.mode).opacity(0.5), radius: 6, x: 0, y: 3)
                                            
                                            Image(systemName: viewModel.icon(for: session.mode))
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        // High Score Crown Overlay
                                        if viewModel.highScoreIDs.contains(session.id) {
                                            Image(systemName: "crown.fill")
                                                .font(.system(size: 14, weight: .black))
                                                .foregroundColor(.appGold)
                                                .padding(4)
                                                .background(Circle().fill(Color.black.opacity(0.85)))
                                                .overlay(Circle().stroke(Color.appGold, lineWidth: 1.5))
                                                .offset(x: 6, y: -6)
                                        }
                                    }
                                    .scaleEffect(viewModel.selectedSession?.id == session.id ? 1.25 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.selectedSession?.id)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedSession = nil
                    }
                }
                .onAppear {
                    if let first = viewModel.locatedSessions.first, let lat = first.latitude, let lon = first.longitude {
                        mapPosition = .region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                        ))
                    } else if let userCoord = LocationManager.shared.currentLocation {
                        mapPosition = .region(MKCoordinateRegion(
                            center: userCoord,
                            span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
                        ))
                    }
                }
                
                // Top Overlay: Title & Filters
                VStack(spacing: 12) {
                    // Header Card
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Game Map")
                                .font(.appFont(26))
                                .foregroundColor(.primary)
                            Text("Explore your high score locations")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
                        // Total count pill
                        HStack(spacing: 5) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.appPurple)
                            Text("\(viewModel.locatedSessions.count) Games")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.appPurple.opacity(0.15))
                        .clipShape(Capsule())
                    }
                    .padding(16)
                    .glassCard(cornerRadius: 22)
                    
                    
                    // Filter Capsules Row
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterPill(title: "All", isSelected: viewModel.filterMode == "All", color: .appPurple) {
                                withAnimation(.easeInOut) { viewModel.filterMode = "All" }
                            }
                            FilterPill(title: "Tap Frenzy", isSelected: viewModel.filterMode == "TapFrenzy", color: .appBlue) {
                                withAnimation(.easeInOut) { viewModel.filterMode = "TapFrenzy" }
                            }
                            FilterPill(title: "Light It Up", isSelected: viewModel.filterMode == "LightItUp", color: .appGold) {
                                withAnimation(.easeInOut) { viewModel.filterMode = "LightItUp" }
                            }
                            FilterPill(title: "Quiz Rush", isSelected: viewModel.filterMode == "QuizRush", color: .appGreen) {
                                withAnimation(.easeInOut) { viewModel.filterMode = "QuizRush" }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .glassCard(cornerRadius: 22)
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
                
                // Bottom Overlay: Selected Session Card
                VStack {
                    Spacer()
                    if let session = viewModel.selectedSession {
                        SelectedSessionCard(session: session, viewModel: viewModel) {
                            withAnimation(.easeInOut) {
                                viewModel.selectedSession = nil
                            }
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Filter Pill
struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: isSelected ? .bold : .semibold, design: .rounded))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? color : Color.secondary.opacity(0.15))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.white.opacity(0.4) : Color.clear, lineWidth: 1)
                )
                .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Selected Session Card Popup
struct SelectedSessionCard: View {
    let session: GameSession
    @ObservedObject var viewModel: MapViewModel
    let onDismiss: () -> Void
    
    var isHighScore: Bool {
        viewModel.highScoreIDs.contains(session.id)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon Circle
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [viewModel.color(for: session.mode), viewModel.colorDark(for: session.mode)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 58, height: 58)
                    .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 2))
                    .shadow(color: viewModel.colorDark(for: session.mode).opacity(0.5), radius: 6, x: 0, y: 3)
                
                Image(systemName: viewModel.icon(for: session.mode))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Details Stack
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(viewModel.title(for: session.mode))
                        .font(.appFont(18))
                        .foregroundColor(.primary)
                    
                    if isHighScore {
                        HStack(spacing: 3) {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.appGold)
                            Text("HIGH SCORE")
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .foregroundColor(.appGold)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.appGold.opacity(0.15))
                        .clipShape(Capsule())
                    }
                }
                
                HStack(spacing: 6) {
                    Text("Score: \(session.score)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.color(for: session.mode))
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formatTimestamp(session.timestamp))
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                if let lat = session.latitude, let lon = session.longitude {
                    Text(String(format: "📍 %.4f, %.4f", lat, lon))
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundColor(.secondary.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Dismiss Button
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .glassCard(cornerRadius: 24, tint: viewModel.color(for: session.mode))
    }
}

// MARK: - Gated Map Placeholder View
struct MapPlaceholderView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.appPurple, .appBlue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 90, height: 90)
                            .shadow(color: .appPurple.opacity(0.4), radius: 12, x: 0, y: 6)
                        
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Location Disabled")
                            .font(.appFont(24))
                            .foregroundColor(.primary)
                        
                        Text("Turn on Location Tracking in Settings to explore where you've played each game and view high scores on the interactive map!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    Text("Go to Settings → Privacy / Location Tracking")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.appPurple)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.appPurple.opacity(0.15))
                        .clipShape(Capsule())
                }
                .padding(28)
                .glassCard(cornerRadius: 24)
                .padding(24)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    MapView()
}
