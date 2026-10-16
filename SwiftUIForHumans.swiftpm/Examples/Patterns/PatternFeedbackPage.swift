import SwiftUI

extension ComponentPage {
    static let patternFeedback = ComponentPage(
        id: "feedback",
        title: "Feedback",
        summary: "Tell people what happened, with an interruption that matches how much it matters.",
        category: .patterns,
        kind: .concept,
        symbol: "bubble.left.and.exclamationmark.bubble.right",
        availability: ["iOS 17.0+"],
        docsURL: "https://developer.apple.com/documentation/swiftui/view/sensoryfeedback(_:trigger:)",
        higURL: "https://developer.apple.com/design/human-interface-guidelines/feedback",
        aliases: ["toast", "snackbar", "banner", "flash message", "error message", "success message", "validation message", "status message", "notification", "inline error", "alert vs toast", "haptic"],
        related: ["haptics", "alert", "confirmation-dialog", "text-field", "entering-data", "undo-redo"],
        notes: [
            "**Toasts are up to you.** For a web-style toast or snackbar, show a small banner with `.safeAreaInset`, or put the status in the toolbar.",
            "**Feedback has to reach everyone.** Pair color with words or a symbol, so it still works with the sound off, eyes elsewhere, or VoiceOver on.",
        ],
        api: [
            APIItem("`.sensoryFeedback(_:trigger:)`", "Plays a haptic when a value changes."),
            APIItem("`.alert(_:isPresented:)`", "Interrupts for critical, actionable news."),
            APIItem("`.safeAreaInset(edge:)`", "Pins a banner above or below content."),
            APIItem("`ToolbarItem(placement: .status)`", "Quiet status text in the toolbar."),
            APIItem("`ContentUnavailableView`", "A whole screen that couldn't load."),
        ],
        guidelines: [
            Guideline(
                "Match the interruption to the importance.",
                "Status and minor problems belong in the screen, near what they describe. Save alerts for things people must act on.",
                good: "A quiet banner while showing saved data.",
                bad: "An alert with nothing to do but OK."
            ) {
                FeedbackOfflineBanner()
                    .frame(maxWidth: 240)
            } bad: {
                PatternMockAlert(title: "No Internet Connection", message: "You are offline.", buttons: ["OK"], boldIndex: 0)
            },
            Guideline(
                "Say what happened and what to do next.",
                "A specific title and a way forward help people recover. “Error” or a code number helps no one.",
                good: "Specific, with a next step.",
                bad: "Vague, with a code."
            ) {
                PatternMockAlert(title: "Couldn't Send Message", message: "Check your connection and try again.", buttons: ["Cancel", "Try Again"], boldIndex: 1)
            } bad: {
                PatternMockAlert(title: "Error", message: "Error 329347 occurred.", buttons: ["OK"], boldIndex: 0)
            },
            Guideline(
                "Don't rely on color alone.",
                "Add a symbol and a short message to the red, so the problem is clear to everyone.",
                good: "Color, a symbol, and words.",
                bad: "Only a red outline."
            ) {
                FeedbackFieldMock(showsMessage: true)
            } bad: {
                FeedbackFieldMock(showsMessage: false)
            },
            Guideline(
                "Don't warn about what people expect.",
                "Deleting an email is what someone asked for, so it needs no alert, especially if they can [undo](catalog://undo-redo). Warn only before loss that's unexpected and can't be undone."
            ),
            Guideline(
                "Confirm only what matters.",
                "People assume things worked. Confirm big moments, like a payment, and always tell people when something failed and why."
            ),
            Guideline(
                "Use haptics for their meaning, alongside the visuals.",
                "`.success` means success everywhere. A haptic backs up what's on screen; it's never the only signal. See [Haptics](catalog://haptics)."
            ),
        ],
        sources: [
            "https://developer.apple.com/design/human-interface-guidelines/feedback",
            "https://developer.apple.com/design/human-interface-guidelines/alerts",
            "https://developer.apple.com/design/human-interface-guidelines/playing-haptics",
            "https://developer.apple.com/documentation/swiftui/view/sensoryfeedback(_:trigger:)",
            "https://developer.apple.com/documentation/swiftui/toolbaritemplacement/status",
        ],
        reviewed: "October 2026"
    ) {
        FeedbackThumbnail()
    } content: { page in
        FeedbackArticle(page: page)
    }
}

// MARK: - Article

private struct FeedbackArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            Prose("Feedback tells people the status of something, whether an action worked, or that something needs their attention. The rule of thumb: the more it matters, the more it may interrupt. Most feedback should be quiet and sit right next to what it's about.")

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Which kind of feedback?")
                PatternDecisionTable(rows: [
                    PatternChoice(symbol: "text.below.photo", title: "Inline status", detail: "Ongoing state, like “Updated just now”. Put it near what it describes."),
                    PatternChoice(symbol: "exclamationmark.circle", title: "Inline message", detail: "A problem with one value. Show it under the field as soon as you spot it."),
                    PatternChoice(symbol: "rectangle.topthird.inset.filled", title: "Banner", detail: "A problem that doesn't block work, like being offline with saved data."),
                    PatternChoice(symbol: "checkmark.circle", title: "Confirmation", detail: "A significant task finished, like a payment. Most actions don't need one."),
                    PatternChoice(symbol: "exclamationmark.triangle", title: "Alert", detail: "Something critical that people must act on, like a save that failed."),
                    PatternChoice(symbol: "iphone.radiowaves.left.and.right", title: "Haptic", detail: "Backs up one of the above. Never the only signal."),
                ])
            }

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("In SwiftUI")

                ExampleCard(
                    title: "Inline validation",
                    caption: "Check a field when people leave it, and show the problem right under it with a symbol and words.",
                    code: """
                    @State private var email = ""
                    @FocusState private var isEditing: Bool

                    var isValid: Bool {
                        email.contains("@") && email.contains(".")
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .focused($isEditing)
                            .padding(10)
                            .background(.fill.tertiary, in: .rect(cornerRadius: 10))
                        if !isEditing && !email.isEmpty && !isValid {
                            Label("Enter a complete email address.", systemImage: "exclamationmark.circle")
                                .font(.footnote)
                                .foregroundStyle(.red)
                        }
                    }
                    """,
                    aside: Aside(.note, "Waiting until people leave the field avoids flagging an address they're still typing. See [Entering Data](catalog://entering-data).")
                ) {
                    FeedbackValidationExample()
                }

                ExampleCard(
                    title: "Success you can feel",
                    caption: "Swap the button's label when a big task finishes, and add `.sensoryFeedback(.success, trigger:)` to back it up.",
                    code: """
                    @State private var isPaid = false

                    Button {
                        isPaid = true
                    } label: {
                        Label(isPaid ? "Paid" : "Pay $24.00",
                              systemImage: isPaid ? "checkmark.circle.fill" : "creditcard")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isPaid ? .green : .accentColor)
                    .disabled(isPaid)
                    .sensoryFeedback(.success, trigger: isPaid)
                    """
                ) {
                    FeedbackSuccessExample()
                }

                ExampleCard(
                    title: "Banner for a problem that doesn't block",
                    caption: "Pin a short message with `.safeAreaInset(edge: .top)` and keep showing what you have.",
                    code: """
                    @State private var isOffline = true

                    List(["Groceries", "Errands", "Work"], id: \\.self) { list in
                        Text(list)
                    }
                    .safeAreaInset(edge: .top) {
                        if isOffline {
                            Label("You're offline. Showing saved lists.", systemImage: "wifi.slash")
                                .font(.subheadline)
                                .padding(10)
                                .frame(maxWidth: .infinity)
                                .background(.yellow.opacity(0.25))
                        }
                    }
                    """,
                    minHeight: 260
                ) {
                    FeedbackBannerExample()
                }

                ExampleCard(
                    title: "Alert for what can't wait",
                    caption: "Use `.alert` when people must decide something now. Name the problem and give a specific way out.",
                    code: """
                    @State private var saveFailed = false

                    Button("Save Draft") { saveFailed = true }
                        .alert("Couldn't Save Draft", isPresented: $saveFailed) {
                            Button("Cancel", role: .cancel) { }
                            Button("Try Again") { }
                        } message: {
                            Text("The server didn't respond. Your text is still here.")
                        }
                    """,
                    aside: Aside(.note, "Button titles say what happens, like Try Again or Delete. Use “OK” only in alerts that just inform. See [Alert](catalog://alert).")
                ) {
                    FeedbackAlertExample()
                }

                ExampleCard(
                    title: "Status in the toolbar",
                    caption: "Put ongoing status, like the last sync time, in a `ToolbarItem(placement: .status)` where people can check it.",
                    code: """
                    List(["Inbox", "Sent", "Archive"], id: \\.self) { box in
                        Text(box)
                    }
                    .navigationTitle("Mail")
                    .toolbar {
                        ToolbarItem(placement: .status) {
                            VStack {
                                Text("Updated Just Now").font(.caption)
                                Text("3 Unread").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                    """,
                    minHeight: 380
                ) {
                    PhoneScreen(height: 340) {
                        List(["Inbox", "Sent", "Archive"], id: \.self) { box in
                            Text(box)
                        }
                        .navigationTitle("Mail")
                        .toolbar {
                            ToolbarItem(placement: .status) {
                                VStack {
                                    Text("Updated Just Now").font(.caption)
                                    Text("3 Unread").font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Examples

private struct FeedbackValidationExample: View {
    @State private var email = "sam@example"
    @FocusState private var isEditing: Bool

    private var isValid: Bool { email.contains("@") && email.contains(".") }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .focused($isEditing)
                .padding(10)
                .background(.fill.tertiary, in: .rect(cornerRadius: 10))
            if !isEditing && !email.isEmpty && !isValid {
                Label("Enter a complete email address.", systemImage: "exclamationmark.circle")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: 300)
        .animation(.default, value: isEditing)
    }
}

private struct FeedbackSuccessExample: View {
    @State private var isPaid = false

    var body: some View {
        VStack(spacing: 14) {
            Button {
                isPaid = true
            } label: {
                Label(isPaid ? "Paid" : "Pay $24.00",
                      systemImage: isPaid ? "checkmark.circle.fill" : "creditcard")
                    .contentTransition(.symbolEffect(.replace))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(isPaid ? .green : .accentColor)
            .disabled(isPaid)
            .sensoryFeedback(.success, trigger: isPaid)
            .animation(.snappy, value: isPaid)

            Button("Reset") { isPaid = false }
                .font(.subheadline)
                .opacity(isPaid ? 1 : 0)
        }
        .frame(maxWidth: 280)
    }
}

private struct FeedbackBannerExample: View {
    @State private var isOffline = true

    var body: some View {
        VStack(spacing: 12) {
            List(["Groceries", "Errands", "Work"], id: \.self) { list in
                Text(list)
            }
            .scrollDisabled(true)
            .safeAreaInset(edge: .top) {
                if isOffline {
                    Label("You're offline. Showing saved lists.", systemImage: "wifi.slash")
                        .font(.subheadline)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(.yellow.opacity(0.25))
                }
            }
            .frame(height: 200)
            .clipShape(.rect(cornerRadius: 12))
            .animation(.default, value: isOffline)

            Toggle("Offline", isOn: $isOffline)
        }
        .frame(maxWidth: 320)
    }
}

private struct FeedbackAlertExample: View {
    @State private var saveFailed = false

    var body: some View {
        Button("Save Draft") { saveFailed = true }
            .buttonStyle(.bordered)
            .alert("Couldn't Save Draft", isPresented: $saveFailed) {
                Button("Cancel", role: .cancel) { }
                Button("Try Again") { }
            } message: {
                Text("The server didn't respond. Your text is still here.")
            }
    }
}

// MARK: - Do / Don't

private struct FeedbackOfflineBanner: View {
    var body: some View {
        VStack(spacing: 0) {
            Label("You're offline. Showing saved lists.", systemImage: "wifi.slash")
                .font(.caption)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(.yellow.opacity(0.25))
            VStack(alignment: .leading, spacing: 8) {
                ForEach(["Groceries", "Errands", "Work"], id: \.self) { Text($0).font(.subheadline) }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
        }
        .background(.background.secondary, in: .rect(cornerRadius: 10))
        .clipShape(.rect(cornerRadius: 10))
    }
}

private struct FeedbackFieldMock: View {
    let showsMessage: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("sam@example")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(.fill.tertiary, in: .rect(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10).strokeBorder(.red, lineWidth: 1.5)
                }
            if showsMessage {
                Label("Enter a complete email address.", systemImage: "exclamationmark.circle")
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        }
        .frame(maxWidth: 260)
    }
}

// MARK: - Thumbnail

private struct FeedbackThumbnail: View {
    var body: some View {
        VStack(spacing: 12) {
            Label("You're offline", systemImage: "wifi.slash")
                .font(.footnote.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.yellow.opacity(0.3), in: .capsule)
            Label("Paid", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .foregroundStyle(.white)
                .background(.green, in: .capsule)
        }
    }
}
