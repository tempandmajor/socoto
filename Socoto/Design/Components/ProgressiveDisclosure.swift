//
//  ProgressiveDisclosure.swift
//  Socoto
//
//  Progressive disclosure components for revealing information gradually
//

import SwiftUI

// MARK: - Expandable Section

/// Collapsible section with smooth animation
struct ExpandableSection<Header: View, Content: View>: View {
    let header: Header
    let content: Content

    @State private var isExpanded: Bool

    init(
        isExpanded: Bool = false,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self._isExpanded = State(initialValue: isExpanded)
        self.header = header()
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header (always visible)
            Button {
                withAnimation(DesignTokens.Animation.smoothSpring) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    header

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignTokens.Colors.inkTertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Content (disclosed progressively)
            if isExpanded {
                content
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
    }
}

// MARK: - Accordion

/// Accordion component (only one section expanded at a time)
struct Accordion: View {
    let sections: [AccordionSection]

    @State private var expandedIndex: Int?

    struct AccordionSection: Identifiable {
        let id = UUID()
        let title: String
        let content: AnyView

        init<Content: View>(title: String, @ViewBuilder content: () -> Content) {
            self.title = title
            self.content = AnyView(content())
        }
    }

    var body: some View {
        VStack(spacing: 1) {
            ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                VStack(spacing: 0) {
                    // Header
                    Button {
                        withAnimation(DesignTokens.Animation.smoothSpring) {
                            expandedIndex = expandedIndex == index ? nil : index
                        }
                    } label: {
                        HStack {
                            Text(section.title)
                                .bodyLarge()
                                .foregroundColor(DesignTokens.Colors.inkPrimary)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(DesignTokens.Colors.inkTertiary)
                                .rotationEffect(.degrees(expandedIndex == index ? 180 : 0))
                        }
                        .padding(DesignTokens.Spacing.medium)
                        .background(DesignTokens.Colors.surfaceElevated)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    // Content
                    if expandedIndex == index {
                        section.content
                            .padding(DesignTokens.Spacing.medium)
                            .background(DesignTokens.Colors.surface)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity.combined(with: .move(edge: .top))
                            ))
                    }

                    // Divider
                    if index < sections.count - 1 {
                        Divider()
                            .background(DesignTokens.Colors.border)
                    }
                }
            }
        }
        .background(DesignTokens.Colors.surfaceElevated)
        .cornerRadius(DesignTokens.Radius.medium)
        .shadow(DesignTokens.Shadow.soft)
    }
}

// MARK: - Show More/Less

/// Show more/less text component for long content
struct ShowMoreText: View {
    let text: String
    let lineLimit: Int

    @State private var isExpanded = false
    @State private var isTruncated = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
            Text(text)
                .bodyMedium()
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(
                    GeometryReader { geometry in
                        Color.clear.onAppear {
                            // Check if text is truncated
                            let size = (text as NSString).boundingRect(
                                with: CGSize(width: geometry.size.width, height: .greatestFiniteMagnitude),
                                options: .usesLineFragmentOrigin,
                                attributes: [.font: UIFont.systemFont(ofSize: 16)],
                                context: nil
                            )
                            isTruncated = size.height > geometry.size.height
                        }
                    }
                )

            if isTruncated {
                Button {
                    withAnimation(DesignTokens.Animation.medium) {
                        isExpanded.toggle()
                    }
                } label: {
                    Text(isExpanded ? "Show Less" : "Show More")
                        .labelLarge(color: DesignTokens.Colors.brandPrimary)
                }
            }
        }
    }
}

// MARK: - Tabs

/// Tab navigation component
struct TabContainer: View {
    let tabs: [Tab]
    @State private var selectedTab: Int = 0

    struct Tab: Identifiable {
        let id = UUID()
        let title: String
        let icon: String?
        let content: AnyView

        init<Content: View>(title: String, icon: String? = nil, @ViewBuilder content: () -> Content) {
            self.title = title
            self.icon = icon
            self.content = AnyView(content())
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab Bar
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                        Button {
                            withAnimation(DesignTokens.Animation.medium) {
                                selectedTab = index
                            }
                        } label: {
                            HStack(spacing: DesignTokens.Spacing.xxSmall) {
                                if let icon = tab.icon {
                                    Image(systemName: icon)
                                        .font(.system(size: 16))
                                }

                                Text(tab.title)
                                    .labelLarge()
                            }
                            .foregroundColor(
                                selectedTab == index
                                    ? DesignTokens.Colors.brandPrimary
                                    : DesignTokens.Colors.inkSecondary
                            )
                            .padding(.horizontal, DesignTokens.Spacing.medium)
                            .padding(.vertical, DesignTokens.Spacing.small)
                            .background(
                                VStack {
                                    Spacer()
                                    Rectangle()
                                        .fill(DesignTokens.Colors.brandPrimary)
                                        .frame(height: 2)
                                        .opacity(selectedTab == index ? 1 : 0)
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .background(DesignTokens.Colors.surfaceElevated)

            Divider()
                .background(DesignTokens.Colors.border)

            // Tab Content
            TabView(selection: $selectedTab) {
                ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                    tab.content
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

// MARK: - Stepped Disclosure (Wizard)

/// Multi-step wizard component
struct SteppedDisclosure: View {
    let steps: [Step]
    @State private var currentStep: Int = 0

    struct Step: Identifiable {
        let id = UUID()
        let title: String
        let content: AnyView

        init<Content: View>(title: String, @ViewBuilder content: () -> Content) {
            self.title = title
            self.content = AnyView(content())
        }
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.large) {
            // Progress Indicator
            HStack(spacing: DesignTokens.Spacing.xSmall) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: DesignTokens.Spacing.xSmall) {
                        // Step indicator
                        ZStack {
                            Circle()
                                .fill(
                                    index <= currentStep
                                        ? DesignTokens.Colors.brandPrimary
                                        : DesignTokens.Colors.border
                                )
                                .frame(width: 32, height: 32)

                            if index < currentStep {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(DesignTokens.Colors.inkContrast)
                            } else {
                                Text("\(index + 1)")
                                    .labelMedium(
                                        color: index == currentStep
                                            ? DesignTokens.Colors.inkContrast
                                            : DesignTokens.Colors.inkSecondary
                                    )
                            }
                        }

                        // Connector line
                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(
                                    index < currentStep
                                        ? DesignTokens.Colors.brandPrimary
                                        : DesignTokens.Colors.border
                                )
                                .frame(height: 2)
                        }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.medium)

            // Step Title
            Text(steps[currentStep].title)
                .headlineSmall()

            // Step Content
            steps[currentStep].content

            // Navigation Buttons
            HStack(spacing: DesignTokens.Spacing.medium) {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation(DesignTokens.Animation.medium) {
                            currentStep -= 1
                        }
                    }
                    .secondaryButton()
                }

                Button(currentStep < steps.count - 1 ? "Next" : "Finish") {
                    withAnimation(DesignTokens.Animation.medium) {
                        if currentStep < steps.count - 1 {
                            currentStep += 1
                        } else {
                            // Handle completion
                        }
                    }
                }
                .primaryButton()
            }
            .padding(.horizontal, DesignTokens.Spacing.medium)
        }
    }
}

// MARK: - Disclosure Group (Native-like)

/// System-style disclosure group
struct DisclosureCard<Label: View, Content: View>: View {
    let label: Label
    let content: Content

    @State private var isExpanded: Bool

    init(
        isExpanded: Bool = false,
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
        self._isExpanded = State(initialValue: isExpanded)
        self.label = label()
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(DesignTokens.Animation.smoothSpring) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    label

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignTokens.Colors.inkTertiary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(DesignTokens.Spacing.medium)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .background(DesignTokens.Colors.border)

                content
                    .padding(DesignTokens.Spacing.medium)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(DesignTokens.Colors.surfaceElevated)
        .cornerRadius(DesignTokens.Radius.medium)
        .shadow(DesignTokens.Shadow.soft)
    }
}

// MARK: - Preview

#Preview("Progressive Disclosure") {
    ScrollView {
        VStack(spacing: DesignTokens.Spacing.large) {
            Text("Progressive Disclosure")
                .headlineLarge()

            // Expandable Section
            SurfaceCard {
                ExpandableSection {
                    Text("Advanced Settings")
                        .bodyLarge()
                } content: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                        Text("Setting 1")
                        Text("Setting 2")
                        Text("Setting 3")
                    }
                    .bodyMedium()
                    .padding(.top, DesignTokens.Spacing.small)
                }
            }

            // Show More Text
            SurfaceCard {
                ShowMoreText(
                    text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
                    lineLimit: 2
                )
            }

            // Accordion
            Accordion(sections: [
                .init(title: "Section 1") {
                    Text("Content for section 1").bodyMedium()
                },
                .init(title: "Section 2") {
                    Text("Content for section 2").bodyMedium()
                },
                .init(title: "Section 3") {
                    Text("Content for section 3").bodyMedium()
                }
            ])

            // Disclosure Card
            DisclosureCard {
                Text("Details")
                    .bodyLarge()
            } content: {
                Text("Hidden content revealed progressively")
                    .bodyMedium()
            }
        }
        .padding(DesignTokens.Spacing.page)
    }
    .background(DesignTokens.Colors.surfacePage)
}
