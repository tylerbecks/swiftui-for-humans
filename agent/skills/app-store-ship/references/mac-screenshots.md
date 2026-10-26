---
id: mac-screenshots
title: Screenshots & Metadata
platforms: [macOS]
docs: https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications
reviewed: October 2026
---

# Screenshots & Metadata

Mac screenshot sizes, app previews, and the text on your Mac product page.

Also called: screenshots, screenshot size, 1280x800, 1440x900, 2560x1600, 2880x1800, 16:10, app preview, video, product page.

## Rules

- **Show the app in use.** Guideline 2.3.3 asks for screenshots of the app doing its job, not just title art, a sign-in window, or a splash screen. Text and image overlays are allowed.
- **Use fictional data.** Guideline 2.3.9 asks for made-up account details in screenshots, never a real person's data, and you need the rights to everything shown.
- **Keep it suitable for everyone, and about this app.** Screenshots must suit a 4+ audience even if the app is rated higher (2.3.8), and can't show the names or imagery of other mobile platforms (2.3.10).

## Pitfalls

- **Mac screenshots don't come from iOS.** When you add the macOS platform, the description, promotional text, and screenshots start empty.
- **Promotional text changes without a review.** Use its 170 characters for news; it appears above the description.

## Guide

Screenshots are required for a Mac app. Upload at least one, and up to 10, as `.jpeg`, `.jpg`, or `.png`, in one of four sizes. Every size has a 16:10 aspect ratio.

### Accepted sizes

- Sizes, in pixels: 1280 × 800, 1440 × 900, 2560 × 1600, or 2880 × 1800.
- How many: At least one, up to 10.
- Scaling: If your interface is the same at every size, provide the highest resolution; App Store Connect scales it down.

**Important:** Screenshots can't have an alpha channel or transparency. Flatten them before you upload.

### App previews

- Optional: Up to three per language for each size.
- Size and length: 1920 × 1080 pixels (16:9), 15 to 30 seconds, and up to 500 MB.
- Orientation: Landscape only for Mac apps.
- Formats: `.mov`, `.m4v`, or `.mp4` with H.264, or `.mov` with ProRes 422 (HQ only).
- Order: Previews always show before screenshots. A preview with a different aspect ratio from your screenshots, like 16:9 next to 16:10, appears in the “A Closer Look” section instead.
- Content: Only video captured from the app itself (Guideline 2.3.4). Narration and text overlays are fine.

### The text on the page

- Name: Up to 30 characters (Guideline 2.3.7), with no prices or unrelated terms.
- Promotional text: Up to 170 characters. Change it any time without a new version.
- Description: Up to 4000 characters of plain text. Required.
- Keywords: Up to 100 bytes, each word longer than two characters. No other apps' or companies' names. Required.
- Support URL: Must lead to real contact information. Required.
- Copyright: The year and the owner, like “2026 Example, Inc.” Required.
- What's New: Required for every version after the first. Describe significant changes specifically (2.3.12).

## Related

[universal-purchase](universal-purchase.md), [pricing-category](pricing-category.md), [mac-app-review](mac-app-review.md), `app-icons` (apple-design skill)
