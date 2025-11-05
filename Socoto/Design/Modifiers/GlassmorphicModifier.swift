//
//  GlassmorphicModifier.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

/// View modifier that applies glassmorphic effect to any view
struct GlassmorphicModifier: ViewModifier {
    var cornerRadius: CGFloat
    var blur: CGFloat
    var opacity: Double
    var borderOpacity: Double
    var shadowRadius: CGFloat
    var padding: CGFloat

    init(
        cornerRadius: CGFloat = AppTheme.CornerRadius.medium,
        blur: CGFloat = AppTheme.Blur.medium,
        opacity: Double = 0.1,
        borderOpacity: Double = 0.2,
        shadowRadius: CGFloat = 8,
        padding: CGFloat = AppTheme.Spacing.medium
    ) {
        self.cornerRadius = cornerRadius
        self.blur = blur
        self.opacity = opacity
        self.borderOpacity = borderOpacity
        self.shadowRadius = shadowRadius
        self.padding = padding
    }

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Base glass layer
                    Color.white.opacity(opacity)

                    // Subtle gradient overlay
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(borderOpacity),
                                Color.white.opacity(borderOpacity * 0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color.black.opacity(0.1),
                radius: shadowRadius,
                x: 0,
                y: 4
            )
    }
}

/// View extension for easy application of glassmorphic effect
extension View {
    func glassmorphic(
        cornerRadius: CGFloat = AppTheme.CornerRadius.medium,
        blur: CGFloat = AppTheme.Blur.medium,
        opacity: Double = 0.1,
        borderOpacity: Double = 0.2,
        shadowRadius: CGFloat = 8,
        padding: CGFloat = AppTheme.Spacing.medium
    ) -> some View {
        modifier(
            GlassmorphicModifier(
                cornerRadius: cornerRadius,
                blur: blur,
                opacity: opacity,
                borderOpacity: borderOpacity,
                shadowRadius: shadowRadius,
                padding: padding
            )
        )
    }
}

/// Animated glassmorphic modifier with hover/press effects
struct AnimatedGlassmorphicModifier: ViewModifier {
    @State private var isPressed = false

    var cornerRadius: CGFloat
    var animationEnabled: Bool

    init(
        cornerRadius: CGFloat = AppTheme.CornerRadius.medium,
        animationEnabled: Bool = true
    ) {
        self.cornerRadius = cornerRadius
        self.animationEnabled = animationEnabled
    }

    func body(content: Content) -> some View {
        content
            .glassmorphic(
                cornerRadius: cornerRadius,
                opacity: isPressed && animationEnabled ? 0.15 : 0.1,
                borderOpacity: isPressed && animationEnabled ? 0.3 : 0.2
            )
            .scaleEffect(isPressed && animationEnabled ? 0.98 : 1.0)
            .animation(AppTheme.Animation.spring, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if animationEnabled {
                            isPressed = true
                        }
                    }
                    .onEnded { _ in
                        if animationEnabled {
                            isPressed = false
                        }
                    }
            )
    }
}

extension View {
    func animatedGlassmorphic(
        cornerRadius: CGFloat = AppTheme.CornerRadius.medium,
        animationEnabled: Bool = true
    ) -> some View {
        modifier(
            AnimatedGlassmorphicModifier(
                cornerRadius: cornerRadius,
                animationEnabled: animationEnabled
            )
        )
    }
}
