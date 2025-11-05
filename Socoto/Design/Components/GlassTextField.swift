//
//  GlassTextField.swift
//  Socoto
//
//  Created by Emmanuel Akangbou on 11/5/25.
//

import SwiftUI

/// Glassmorphic text field with icon support
struct GlassTextField: View {
    enum FieldType {
        case text
        case email
        case password
        case number
        case phone
    }

    let placeholder: String
    let icon: String?
    let type: FieldType
    @Binding var text: String
    var errorMessage: String?
    var isDisabled: Bool = false

    @State private var isFocused = false
    @State private var isSecureTextVisible = false
    @FocusState private var fieldIsFocused: Bool

    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        type: FieldType = .text,
        errorMessage: String? = nil,
        isDisabled: Bool = false
    ) {
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.type = type
        self.errorMessage = errorMessage
        self.isDisabled = isDisabled
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            HStack(spacing: AppTheme.Spacing.small) {
                // Leading icon
                if let icon = icon {
                    Image(systemName: icon)
                        .font(AppTheme.Typography.bodyMedium)
                        .foregroundColor(iconColor)
                        .frame(width: 20)
                }

                // Text field based on type
                textFieldView
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .focused($fieldIsFocused)
                    .disabled(isDisabled)
                    .onChange(of: fieldIsFocused) { oldValue, newValue in
                        withAnimation(AppTheme.Animation.medium) {
                            isFocused = newValue
                        }
                    }

                // Trailing icon for password visibility toggle
                if type == .password {
                    Button(action: {
                        isSecureTextVisible.toggle()
                    }) {
                        Image(systemName: isSecureTextVisible ? "eye.slash" : "eye")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.vertical, AppTheme.Spacing.small + 2)
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                    .stroke(borderGradient, lineWidth: borderWidth)
            )
            .shadow(
                color: shadowColor,
                radius: 8,
                x: 0,
                y: 4
            )
            .animation(AppTheme.Animation.medium, value: isFocused)
            .animation(AppTheme.Animation.medium, value: errorMessage)

            // Error message
            if let errorMessage = errorMessage {
                HStack(spacing: AppTheme.Spacing.xxSmall) {
                    Image(systemName: "exclamationmark.circle")
                        .font(AppTheme.Typography.labelSmall)

                    Text(errorMessage)
                        .font(AppTheme.Typography.labelSmall)
                }
                .foregroundColor(AppTheme.Colors.error)
                .padding(.horizontal, AppTheme.Spacing.xSmall)
                .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private var textFieldView: some View {
        switch type {
        case .text:
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.sentences)

        case .email:
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()

        case .password:
            if isSecureTextVisible {
                TextField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } else {
                SecureField(placeholder, text: $text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }

        case .number:
            TextField(placeholder, text: $text)
                .keyboardType(.numberPad)

        case .phone:
            TextField(placeholder, text: $text)
                .keyboardType(.phonePad)
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        ZStack {
            Color.white.opacity(isFocused ? 0.12 : 0.08)
                .background(.ultraThinMaterial)

            LinearGradient(
                colors: [
                    Color.white.opacity(isFocused ? 0.12 : 0.08),
                    Color.white.opacity(isFocused ? 0.08 : 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var borderGradient: LinearGradient {
        if errorMessage != nil {
            return LinearGradient(
                colors: [
                    AppTheme.Colors.error.opacity(0.5),
                    AppTheme.Colors.error.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if isFocused {
            return LinearGradient(
                colors: [
                    AppTheme.Colors.accent.opacity(0.5),
                    AppTheme.Colors.accent.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var borderWidth: CGFloat {
        if errorMessage != nil || isFocused {
            return 1.5
        } else {
            return 1
        }
    }

    private var shadowColor: Color {
        if errorMessage != nil {
            return AppTheme.Colors.error.opacity(0.2)
        } else if isFocused {
            return AppTheme.Colors.accent.opacity(0.2)
        } else {
            return Color.black.opacity(0.1)
        }
    }

    private var iconColor: Color {
        if errorMessage != nil {
            return AppTheme.Colors.error
        } else if isFocused {
            return AppTheme.Colors.accent
        } else {
            return AppTheme.Colors.textSecondary
        }
    }
}

/// Glassmorphic text editor for multiline text
struct GlassTextEditor: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 120

    @FocusState private var isFocused: Bool

    init(
        _ placeholder: String,
        text: Binding<String>,
        minHeight: CGFloat = 120
    ) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Placeholder
            if text.isEmpty {
                Text(placeholder)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundColor(AppTheme.Colors.textTertiary)
                    .padding(.horizontal, AppTheme.Spacing.medium)
                    .padding(.vertical, AppTheme.Spacing.small + 8)
            }

            // Text editor
            TextEditor(text: $text)
                .font(AppTheme.Typography.bodyMedium)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .frame(minHeight: minHeight)
                .padding(.horizontal, AppTheme.Spacing.small)
                .padding(.vertical, AppTheme.Spacing.xxSmall)
        }
        .padding(AppTheme.Spacing.small)
        .background(backgroundView)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.medium)
                .stroke(borderGradient, lineWidth: isFocused ? 1.5 : 1)
        )
        .shadow(
            color: isFocused ? AppTheme.Colors.accent.opacity(0.2) : Color.black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        .animation(AppTheme.Animation.medium, value: isFocused)
    }

    @ViewBuilder
    private var backgroundView: some View {
        ZStack {
            Color.white.opacity(isFocused ? 0.12 : 0.08)
                .background(.ultraThinMaterial)

            LinearGradient(
                colors: [
                    Color.white.opacity(isFocused ? 0.12 : 0.08),
                    Color.white.opacity(isFocused ? 0.08 : 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var borderGradient: LinearGradient {
        if isFocused {
            return LinearGradient(
                colors: [
                    AppTheme.Colors.accent.opacity(0.5),
                    AppTheme.Colors.accent.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Previews
#Preview("Text Fields") {
    ZStack {
        AppTheme.Colors.background
            .ignoresSafeArea()

        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                GlassTextField(
                    "Email",
                    text: .constant(""),
                    icon: "envelope",
                    type: .email
                )

                GlassTextField(
                    "Password",
                    text: .constant(""),
                    icon: "lock",
                    type: .password
                )

                GlassTextField(
                    "Name",
                    text: .constant("John Doe"),
                    icon: "person"
                )

                GlassTextField(
                    "Phone",
                    text: .constant(""),
                    icon: "phone",
                    type: .phone
                )

                GlassTextField(
                    "Email with error",
                    text: .constant("invalid"),
                    icon: "envelope",
                    type: .email,
                    errorMessage: "Please enter a valid email address"
                )

                GlassTextEditor(
                    "Write something...",
                    text: .constant("")
                )
            }
            .padding()
        }
    }
}
