import SwiftUI

/// A drawing of a Mac window around live content: title bar, the three
/// window buttons, and an optional toolbar. Use it for inline previews of
/// anything that lives in a window. A real `NavigationSplitView` or
/// `.toolbar` inside a page would take over this app's own window toolbar,
/// so open those with `OpenDemoWindowButton` instead, and draw them here.
///
/// ```swift
/// MacWindowFrame(title: "Library") {
///     Text("Content")
/// } toolbar: {
///     Image(systemName: "plus")
/// }
/// ```
struct MacWindowFrame<Content: View, Toolbar: View>: View {
    var title: String = ""
    var width: CGFloat? = nil
    var height: CGFloat = 260
    @ViewBuilder let content: Content
    @ViewBuilder let toolbar: Toolbar

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                WindowButtons()
                if !title.isEmpty {
                    Text(title)
                        .font(.headline)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                HStack(spacing: 14) {
                    toolbar
                }
                .foregroundStyle(.secondary)
                .imageScale(.large)
            }
            .padding(.horizontal, 14)
            .frame(height: 44)
            .background(.bar)
            Divider()
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: width, height: height)
        .frame(maxWidth: width == nil ? .infinity : nil)
        .background(.background)
        .clipShape(.rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(.separator)
        }
        .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
    }
}

extension MacWindowFrame where Toolbar == EmptyView {
    init(title: String = "", width: CGFloat? = nil, height: CGFloat = 260, @ViewBuilder content: () -> Content) {
        self.title = title
        self.width = width
        self.height = height
        self.content = content()
        self.toolbar = EmptyView()
    }
}

/// Close, minimize, and zoom, drawn in their usual colors.
private struct WindowButtons: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach([Color.red, .yellow, .green], id: \.self) { color in
                Circle()
                    .fill(color.gradient)
                    .frame(width: 12, height: 12)
                    .overlay(Circle().strokeBorder(.black.opacity(0.12)))
            }
        }
        .accessibilityHidden(true)
    }
}
