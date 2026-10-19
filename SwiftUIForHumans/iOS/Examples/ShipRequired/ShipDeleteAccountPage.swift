import StoreKit
import SwiftUI

extension ComponentPage {
    static let shipDeleteAccount = ComponentPage(
        id: "delete-account",
        title: "Delete Account",
        summary: "If people can create an account in your app, they must be able to delete it there too.",
        category: .requiredByApple,
        kind: .reference,
        symbol: "person.crop.circle.badge.xmark",
        availability: [],
        docsURL: nil,
        higURL: "https://developer.apple.com/design/human-interface-guidelines/managing-accounts",
        aliases: [
            "Guideline 5.1.1(v)", "5.1.1(v)", "account deletion", "delete my account", "remove account",
            "close account", "deactivate account", "right to be forgotten", "GDPR", "CCPA", "data deletion",
            "manageSubscriptionsSheet",
        ],
        related: ["settings-screen", "confirmation-dialog", "sign-in-with-apple", "paywall"],
        guidelines: [
            Guideline(
                "Put it where people look: account settings.",
                "Apple asks for a deletion option that's easy to find, typically in your account settings. Don't bury it in the privacy policy or terms.",
                good: "A Delete Account row in Account settings.",
                bad: "Hidden in a paragraph of the privacy policy."
            ) {
                ShipMiniScreen(title: "Account") {
                    ShipMiniGroup(rows: [
                        ShipMiniRow(title: "Email", value: "maya@example.com"),
                        ShipMiniRow(title: "Sign Out", tint: .accentColor),
                    ])
                    ShipMiniGroup(rows: [ShipMiniRow(title: "Delete Account", tint: .red)])
                }
            } bad: {
                ShipMiniScreen(title: "Privacy Policy") {
                    Text(verbatim: "7.3 Data retention. We keep your data while your account is active. To request deletion of your account, write to privacy@example.com with the subject line “Deletion Request” and…")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(10)
                        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 10))
                }
            },
            Guideline(
                "Delete the account, not just deactivate it.",
                "You can offer a pause too, but deactivating or disabling alone doesn't meet the rule.",
                good: "Deleting is an option.",
                bad: "Only a deactivate option."
            ) {
                ShipMiniScreen(title: "Account") {
                    ShipMiniGroup(rows: [
                        ShipMiniRow(title: "Pause Account", tint: .accentColor),
                        ShipMiniRow(title: "Delete Account", tint: .red),
                    ])
                }
            } bad: {
                ShipMiniScreen(title: "Account") {
                    ShipMiniGroup(rows: [ShipMiniRow(title: "Deactivate Account", tint: .red)], footer: "Your profile is hidden until you sign in again.")
                }
            },
            Guideline(
                "Don't send people to support.",
                "Unless your app is in a highly regulated field like banking or health, you can't require a call, an email, or a chat. Asking for a code sent to their email or phone is fine."
            ),
            Guideline(
                "Link straight to the web deletion page.",
                "If deletion finishes on your website, link to that exact page, not your home page. Apple rejects flows that make deletion unnecessarily hard."
            ),
            Guideline(
                "Say how long it takes, and confirm when it's done.",
                "Manual deletion that takes a while is allowed, as long as people know what to expect and hear back at the end."
            ),
        ],
        sources: [
            "https://developer.apple.com/app-store/review/guidelines/#data-collection-and-storage",
            "https://developer.apple.com/help/app-review/guideline-reference/5-1-1-account-deletion",
            "https://developer.apple.com/design/human-interface-guidelines/managing-accounts",
            "https://developer.apple.com/documentation/swiftui/view/managesubscriptionssheet(ispresented:)",
        ],
        reviewed: "October 2026"
    ) {
        DeleteAccountThumbnail()
    } content: { page in
        DeleteAccountArticle(page: page)
    }
}

// MARK: - Article

private struct DeleteAccountArticle: View {
    let page: ComponentPage

    var body: some View {
        ArticlePage(page: page) {
            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("What Apple requires")
                Prose("As of 2026, App Review Guideline **5.1.1(v)** says that if your app supports account creation, people must be able to **start deleting their account from inside the app**. Deleting means removing the account and its personal data, except what you're legally required to keep.")
                Aside(.note, "This includes accounts your app creates automatically, like guest accounts, and accounts people create through a link to your website. Supporting deletion only where the law requires it (GDPR, CCPA) isn't enough: it has to work for everyone.")
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Why")
                Prose("People shared personal data with you to make the account. Letting them take it back, without hunting or emailing anyone, keeps that trust.")
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Try it")
                Prose("A complete flow: a row in Settings, a screen that says what happens, one confirmation, and a result. Tap **Delete Account** to walk through it.")
                DeleteAccountFlowDemo()
            }
            .id("playground")

            VStack(alignment: .leading, spacing: 28) {
                SectionTitle("In SwiftUI")

                ExampleCard(
                    title: "The Settings row",
                    caption: "Put a `NavigationLink` to the deletion screen in its own section at the bottom of your account settings.",
                    code: """
                    Form {
                        Section("Account") {
                            LabeledContent("Email", value: "maya@example.com")
                            Button("Sign Out") { signOut() }
                        }
                        Section {
                            NavigationLink("Delete Account") {
                                DeleteAccountView()
                            }
                            .foregroundStyle(.red)
                        }
                    }
                    .navigationTitle("Account")
                    """
                ) {
                    ShipMiniScreen(title: "Account", width: 280) {
                        ShipMiniGroup(header: "Account", rows: [
                            ShipMiniRow(title: "Email", value: "maya@example.com"),
                            ShipMiniRow(title: "Sign Out", tint: .accentColor),
                        ])
                        ShipMiniGroup(rows: [ShipMiniRow(title: "Delete Account", tint: .red, chevron: true)])
                    }
                }

                ExampleCard(
                    title: "The deletion screen",
                    caption: "Say what gets deleted, handle subscriptions, then confirm once with `.confirmationDialog`.",
                    code: """
                    import StoreKit

                    struct DeleteAccountView: View {
                        @State private var isConfirming = false
                        @State private var showsSubscriptions = false

                        var body: some View {
                            Form {
                                Section {
                                    Text("This permanently deletes your account, recipes, and comments.")
                                }
                                Section {
                                    Button("Manage Subscription") {
                                        showsSubscriptions = true
                                    }
                                } footer: {
                                    Text("Billing for Pro continues through Apple until you cancel it.")
                                }
                                Section {
                                    Button("Delete Account", role: .destructive) {
                                        isConfirming = true
                                    }
                                    .confirmationDialog("Delete your account?", isPresented: $isConfirming, titleVisibility: .visible) {
                                        Button("Delete Account", role: .destructive) {
                                            Task { await deleteAccount() }
                                        }
                                    } message: {
                                        Text("This can't be undone.")
                                    }
                                }
                            }
                            .navigationTitle("Delete Account")
                            .manageSubscriptionsSheet(isPresented: $showsSubscriptions)
                        }
                    }
                    """,
                    aside: Aside(.important, "Deleting the account doesn't cancel an App Store subscription. Apple asks you to tell people that billing continues through Apple and to have them cancel first; `manageSubscriptionsSheet` opens the system screen for that.")
                ) {
                    ShipMiniScreen(title: "Delete Account", width: 280) {
                        ShipMiniGroup(rows: [ShipMiniRow(title: "Deletes your account, recipes…")])
                        ShipMiniGroup(rows: [ShipMiniRow(title: "Manage Subscription", tint: .accentColor)], footer: "Billing for Pro continues through Apple until you cancel it.")
                        ShipMiniGroup(rows: [ShipMiniRow(title: "Delete Account", tint: .red)])
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("What to say")
                Prose("Keep each message short and specific:")
                VStack(alignment: .leading, spacing: 8) {
                    Prose("• **What goes:** the account and everything in it, including posts and photos other people can see.")
                    Prose("• **What stays:** anything the law makes you keep, and why.")
                    Prose("• **Subscriptions:** billing continues through Apple until people cancel.")
                    Prose("• **When:** how long it takes, and that you'll confirm when it's done.")
                }
                .padding(.leading, 8)
                Aside(.note, "You may offer to schedule deletion for when a subscription ends, as long as people can also delete right away.")
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionTitle("Before you submit")
                Checklist(pageID: page.id, items: [
                    ChecklistItem("in-app", "Deletion starts inside the app", "Usually a Delete Account row in account settings.", page: "settings-screen"),
                    ChecklistItem("whole-account", "It deletes, not deactivates", "The account and the personal data you don't have to keep."),
                    ChecklistItem("no-support", "No call, email, or chat needed", "Only highly regulated apps (5.1.1(ix)) may use a support flow."),
                    ChecklistItem("web-link", "Web flows get a direct link", "To the deletion page itself, not your home page or policy."),
                    ChecklistItem("ugc", "Shared content goes too", "Posts, photos, and reviews other people can see."),
                    ChecklistItem("subscriptions", "Subscriptions are explained", "Billing continues through Apple until people cancel.", page: "paywall"),
                    ChecklistItem("timing", "People know when it's done", "Say how long it takes, then confirm."),
                    ChecklistItem("siwa", "Sign in with Apple tokens are revoked", "With the Sign in with Apple REST API.", page: "sign-in-with-apple"),
                ])
            }
            .id("checklist")
        }
    }
}

// MARK: - Try it

private enum DeleteStep {
    case settings, explain, deleting, done
}

private struct DeleteAccountFlowDemo: View {
    @State private var step: DeleteStep = .settings
    @State private var isConfirming = false

    var body: some View {
        VStack(spacing: 0) {
            PreviewCard(minHeight: 560, isAttached: true) {
                VStack(spacing: 14) {
                    PhoneScreen(height: 500) {
                        screen
                    }
                    Button("Start Over", systemImage: "arrow.counterclockwise") {
                        withAnimation { step = .settings }
                    }
                    .buttonStyle(.bordered)
                    .disabled(step == .settings)
                }
            }
        }
        .cardStyle()
    }

    @ViewBuilder
    private var screen: some View {
        switch step {
        case .settings:
            Form {
                Section("Account") {
                    LabeledContent("Email", value: "maya@example.com")
                    LabeledContent("Plan", value: "Pro")
                    Button("Sign Out") {}
                }
                Section {
                    Button {
                        withAnimation { step = .explain }
                    } label: {
                        HStack {
                            Text("Delete Account").foregroundStyle(.red)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color(.tertiaryLabel))
                        }
                        .contentShape(.rect)
                    }
                }
            }
            .navigationTitle("Account")
        case .explain:
            Form {
                Section {
                    Text("This permanently deletes your account, recipes, and comments.")
                }
                Section {
                    Button("Manage Subscription") {}
                } footer: {
                    Text("Billing for Pro continues through Apple until you cancel it.")
                }
                Section {
                    Button("Delete Account", role: .destructive) {
                        isConfirming = true
                    }
                    .confirmationDialog("Delete your account?", isPresented: $isConfirming, titleVisibility: .visible) {
                        Button("Delete Account", role: .destructive) {
                            withAnimation { step = .deleting }
                            Task {
                                try? await Task.sleep(for: .seconds(1.5))
                                withAnimation { step = .done }
                            }
                        }
                    } message: {
                        Text("This can't be undone.")
                    }
                }
            }
            .navigationTitle("Delete Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back", systemImage: "chevron.left") {
                        withAnimation { step = .settings }
                    }
                }
            }
        case .deleting:
            VStack(spacing: 12) {
                ProgressView()
                Text("Deleting…")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("")
        case .done:
            ContentUnavailableView {
                Label("Account Deleted", systemImage: "checkmark.circle")
            } description: {
                Text("Your data is removed within 30 days. We'll email you when it's done.")
            }
            .navigationTitle("")
        }
    }
}

// MARK: - Thumbnail

private struct DeleteAccountThumbnail: View {
    var body: some View {
        VStack(spacing: 0) {
            ShipMiniRow(title: "Sign Out", tint: .accentColor)
            Divider()
            ShipMiniRow(title: "Delete Account", tint: .red, chevron: true)
        }
        .frame(width: 190)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 10))
        .padding(14)
        .background(Color(.systemGroupedBackground), in: .rect(cornerRadius: 16))
    }
}
