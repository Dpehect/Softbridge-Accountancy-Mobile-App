//
//  DashboardView.swift
//  Muhasebe
//
//  Created by Soft Bridge Solutions UI/UX on 27.06.2026.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var state: AppState
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Brand Header
                        HeaderView()
                        
                        // KPI horizontal strip
                        VStack(alignment: .leading, spacing: 12) {
                            Text("FINANCIAL OVERVIEW")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                                .tracking(1.5)
                                .padding(.horizontal, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(state.kpis) { kpi in
                                        KPICard(kpi: kpi)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 4)
                            }
                        }
                        
                        // Dual Concentric Budget Rings Widget
                        CircularBudgetWidget()
                            .padding(.horizontal, 16)
                        
                        // Action Items (Awaiting Approval)
                        VStack(alignment: .leading, spacing: 16) {
                            Text("AWAITING APPROVAL")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                                .tracking(1.5)
                                .padding(.horizontal, 16)
                            
                            if state.pendingTransactions.isEmpty {
                                NoPendingView()
                                    .padding(.horizontal, 16)
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(state.pendingTransactions) { tx in
                                        PendingTransactionRow(transaction: tx)
                                            .transition(.asymmetric(
                                                insertion: .opacity.combined(with: .move(edge: .leading)),
                                                removal: .opacity.combined(with: .scale(scale: 0.9))
                                            ))
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 12)
                }
                
                // State-of-the-art Biometric Overlay Screen
                if state.isBiometricallyLocked {
                    BiometricLockOverlay()
                        .transition(.opacity)
                        .zIndex(10)
                }
            }
            .hideNavigationBar()
        }
    }
}

// Subview for Brand Header
struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Soft Bridge Solutions")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.primary)
                    .tracking(1.0)
                
                Text("The Hub")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.85))
            }
            
            Spacer()
            
            // Profile indicator
            ZStack {
                Circle()
                    .fill(Theme.primary)
                    .frame(width: 44, height: 44)
                
                Text("SE")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
    }
}

// Subview for KPI Cards
struct KPICard: View {
    let kpi: KPIMetric
    
    var body: some View {
        PremiumCard(padding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Theme.primary.opacity(0.1))
                            .frame(width: 38, height: 38)
                        Image(systemName: kpi.iconName)
                            .foregroundColor(Theme.primary)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    Spacer()
                    
                    // Trend Pill
                    HStack(spacing: 4) {
                        Image(systemName: kpi.isPositive ? "arrow.up.right" : "arrow.down.right")
                        Text("\(String(format: "%.1f", abs(kpi.change)))%")
                            .font(.system(.caption2, design: .monospaced))
                            .bold()
                    }
                    .foregroundColor(kpi.isPositive ? Theme.statusApproved : Theme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(kpi.isPositive ? Theme.statusApprovedBg : Theme.statusPendingBg)
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(kpi.title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                    
                    Text(kpi.value)
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(Color.black.opacity(0.85))
                }
            }
            .frame(width: 170)
        }
        .glow(color: kpi.isPositive ? Theme.statusApproved : Theme.accent, radius: 8)
    }
}

// Subview for Pending Rows
struct PendingTransactionRow: View {
    @EnvironmentObject var state: AppState
    let transaction: Transaction
    
    var body: some View {
        PremiumCard(padding: 16) {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    VendorIcon(name: transaction.vendor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(transaction.vendor)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(Color.black.opacity(0.85))
                        
                        HStack(spacing: 8) {
                            Text(transaction.category)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                            
                            Circle()
                                .fill(Theme.border)
                                .frame(width: 4, height: 4)
                            
                            Text(transaction.formattedDate)
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    Text(state.formatCurrency(transaction.amount))
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color.black.opacity(0.85))
                }
                
                Divider()
                    .background(Theme.border)
                
                HStack(spacing: 12) {
                    Button(action: {
                        state.voidTransaction(transaction.id)
                    }) {
                        Text("Decline")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Theme.accent.opacity(0.08))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        state.approveTransaction(transaction.id)
                    }) {
                        Text("Approve")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Theme.primary)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
}

// Subview for empty pending items
struct NoPendingView: View {
    var body: some View {
        PremiumCard(padding: 24) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(Theme.primary.opacity(0.4))
                
                Text("All Caught Up")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color.black.opacity(0.85))
                
                Text("No pending transactions require review right now.")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(Theme.secondaryText)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// Subview for Biometric Authentication Shield
struct BiometricLockOverlay: View {
    @EnvironmentObject var state: AppState
    @State private var iconScale: CGFloat = 1.0
    @State private var isAuthenticating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            #if os(iOS)
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            #endif
            
            VStack(spacing: 28) {
                VStack(spacing: 24) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 40))
                        .foregroundColor(Theme.primary)
                        .padding(.top, 12)
                    
                    VStack(spacing: 8) {
                        Text("Soft Bridge Solutions")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.primary)
                            .tracking(1.5)
                        
                        Text("Secure Ledger Access")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color.black.opacity(0.85))
                        
                        Text("Please authenticate to view sensitive corporate accounts.")
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                    
                    Button(action: {
                        triggerUnlockSimulation()
                    }) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Theme.primary.opacity(0.08))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "faceid")
                                    .font(.system(size: 44))
                                    .foregroundColor(Theme.primary)
                                    .scaleEffect(iconScale)
                                    .rotationEffect(.degrees(isAuthenticating ? 360 : 0))
                            }
                            
                            Text(isAuthenticating ? "Authorizing..." : "Unlock with Face ID")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.primary)
                        }
                    }
                    .disabled(isAuthenticating)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 24)
                .background(Color.white.opacity(0.95))
                .cornerRadius(24)
                .frame(width: 300)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
            }
        }
    }
    
    private func triggerUnlockSimulation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isAuthenticating = true
            iconScale = 1.15
        }
        
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { _ in
            withAnimation(Theme.bouncySpring) {
                state.isBiometricallyLocked = false
                state.successHapticTrigger.toggle()
            }
        }
    }
}

// Subview for Concentric Budget Progress Ring Widget
struct CircularBudgetWidget: View {
    @EnvironmentObject var state: AppState
    
    var body: some View {
        PremiumCard(padding: 20) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Theme.border.opacity(0.5), lineWidth: 10)
                        .frame(width: 88, height: 88)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(state.monthlyBurn / 250000.0, 1.0)))
                        .stroke(Theme.primaryGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 88, height: 88)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.8), value: state.monthlyBurn)
                    
                    Circle()
                        .stroke(Theme.border.opacity(0.3), lineWidth: 6)
                        .frame(width: 62, height: 62)
                    
                    Circle()
                        .trim(from: 0.0, to: 0.65)
                        .stroke(Theme.accentGradient, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 62, height: 62)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("74%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Color.black.opacity(0.85))
                        Text("Safe")
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("BURNRATE CAPACITY")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.primary)
                        .tracking(1.0)
                    
                    Text("Daily Operating Limit")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.85))
                    
                    Text("Monthly Burn is \(Int((state.monthlyBurn / 250000.0)*100))% of the allocated ceiling.")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .lineLimit(2)
                }
            }
        }
    }
}

