//
//  Theme.swift
//  Muhasebe
//
//  Created by Soft Bridge Solutions UI/UX on 27.06.2026.
//

import SwiftUI

enum Theme {
    // Premium Color System
    static let background = Color(hex: "F5F5F7")       // Apple Cream
    static let primary = Color(hex: "006D77")          // Deep Teal
    static let accent = Color(hex: "FF7F50")           // Coral Alert/Highlight
    static let cardBackground = Color.white            // Pure Card White
    static let border = Color(hex: "E2E8F0")           // Subtle divider/border
    static let secondaryText = Color(hex: "5A6E72")    // Muted Slate-Teal
    
    // Status Colors
    static let statusApproved = Color(hex: "2D6A4F")   // Elegant forest green
    static let statusPending = Color(hex: "FF7F50")    // Coral orange
    static let statusVoid = Color(hex: "8D99AE")       // Neutral gray-blue
    
    static let statusApprovedBg = Color(hex: "E8F5E9")
    static let statusPendingBg = Color(hex: "FFF3E0")
    static let statusVoidBg = Color(hex: "ECEFF1")
    
    // Layout Elements
    static let cornerRadius: CGFloat = 20
    
    // Soft drop shadows for the layered card hierarchy
    static func cardShadow() -> some ViewModifier {
        CardShadowModifier()
    }
    
    // Native spring animations
    static let fluidSpring = Animation.spring(response: 0.35, dampingFraction: 0.78, blendDuration: 0)
    static let bouncySpring = Animation.spring(response: 0.45, dampingFraction: 0.6, blendDuration: 0)
    
    // Vibrant Gradients for high-end visual aesthetics
    static var primaryGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "006D77"), Color(hex: "83C5BE")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var accentGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "FF7F50"), Color(hex: "FFB3A7")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var revenueGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "2D6A4F"), Color(hex: "52B788")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var saasGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "4361EE"), Color(hex: "4CC9F0")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var opsGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "7209B7"), Color(hex: "B5179E")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var marketingGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "FF7F50"), Color(hex: "FF9F1C")], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // Gradient backgrounds
    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [Color(hex: "F5F5F7"), Color(hex: "EAF4F4")], startPoint: .top, endPoint: .bottom)
    }
}

// Custom view modifier for cards
struct PremiumCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.cardBackground)
            .cornerRadius(Theme.cornerRadius)
            .modifier(CardShadowModifier())
    }
}

struct CardShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.015), radius: 2, x: 0, y: 1)
    }
}

struct GlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.15), radius: radius, x: 0, y: radius * 0.6)
    }
}

extension View {
    func premiumCard() -> some View {
        self.modifier(PremiumCardModifier())
    }
    
    func glow(color: Color, radius: CGFloat = 12) -> some View {
        self.modifier(GlowModifier(color: color, radius: radius))
    }
    
    @ViewBuilder
    func hideNavigationBar() -> some View {
        #if os(iOS)
        self.navigationBarHidden(true)
        #else
        self
        #endif
    }
    
    @ViewBuilder
    func sensoryFeedbackSuccess(trigger: Bool) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 17.0, macOS 14.0, *) {
            self.sensoryFeedback(.success, trigger: trigger)
        } else {
            self
        }
        #else
        self
        #endif
    }
    
    @ViewBuilder
    func sensoryFeedbackAlert(trigger: Bool) -> some View {
        #if os(iOS) || os(macOS)
        if #available(iOS 17.0, macOS 14.0, *) {
            self.sensoryFeedback(.error, trigger: trigger)
        } else {
            self
        }
        #else
        self
        #endif
    }
}

// Hex color parser for SwiftUI
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
