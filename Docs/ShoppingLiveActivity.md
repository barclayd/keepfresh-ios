# Shopping Live Activity

Pressing Play in Start shop creates one ActivityKit activity for the current shopping session. It uses the same order as shopping mode: pantry, fridge, freezer, then other items, preserving the order inside each section.

The Lock Screen uses the approved Focus design: current item artwork, a prominent title, plain-text brand • amount, one 44-point pickup button, and a small next-item preview. A restrained storage-colour glow sits over dark charcoal. The progress count is centred below a five-point track. The next row disappears when there is no next item; there is no last-item narration. A small destination storage symbol appears only when the next item's category differs. Other items use a neutral accent.

The **checkmark** records `pendingCompletion` locally, preserves the proposed expiry date, and advances immediately without an API request. Corrections remain available in the app's basket; the Live Activity does not display a permanent Undo control. Repeated or outdated buttons cannot pick up another item; actions from an earlier session are ignored. Unsaved draft items must finish syncing before their button is enabled.

The final pickup shows **Basket ready** and a full progress bar. **Review basket** opens the app's existing basket sheet for expiry-date review and final saving. Saving or abandoning the shop ends the activity. Dismissing the Live Activity does not discard the basket and it is not automatically recreated until another shop starts. With Live Activities disabled in system settings, shopping mode continues normally.

The expanded Dynamic Island keeps its opaque black system background. Brand and amount sit in the leading camera-safe region, with an additional corner inset. The product image, title and action share one centred row below the camera; top and bottom content margins are both 14 points. Compact shows the item image and remaining count; minimal shows that count inside a progress ring. Reduced luminance removes the Lock Screen glow and desaturates artwork. Long titles can use two lines with bounded Dynamic Type growth, while VoiceOver retains the item label.

## Images and persistence

The app prepares 144-pixel PNG thumbnails using the existing `getGenmoji` image API and existing SwiftData image cache. The extension reads them from `group.dev.danbarclay.keepfresh`; it does not perform image network requests. Missing artwork falls back to the section's SF Symbol. Only image filenames and the current, next, and last-collected items are included in ActivityKit content, keeping the payload small regardless of list size.

`LiveActivityIntent` executes in the app process. Shopping cache writes are atomic and complete before the intent advances the activity. The running Shopping environment receives the persisted basket immediately; a relaunched app restores it from disk. Local shopping data and cached artwork use file protection until first authentication, so they remain available during the shopping session after the phone relocks. No push token or backend deployment is needed.

The shared Models package exposes its intents through `AppIntentsPackage`, included by both the app and extension. The Network package still exports its existing product, but its Swift module is now `KeepFreshNetwork`, avoiding a collision with Apple's Network framework imported by App Intents. Clean existing Xcode build products once after this rename if a cached `Network.swiftmodule` causes a dependency-cycle diagnostic.

## Validation

Run the KeepFresh scheme's PackageTests plan. Shopping Activity tests cover ordering, other items, repeated taps, stale sessions, deleted/unsaved items, Undo and expiry preservation, persistence after reload, empty/completed lists, and payload size. Existing inventory-completion tests also remain in the plan.

SwiftUI previews in `ShoppingLiveActivityLiveActivity.swift` cover storage palettes, same-category and cross-category next items, missing artwork, long names, the last item, completion, and expanded/compact/minimal Island presentations. Preview-only copies of the existing product artwork populate the same shared image cache; `DEVELOPMENT_ASSET_PATHS` excludes these fixtures from archive builds.

The native refresh was built successfully on 27 September 2026. All 38 package tests passed on the PR branch, covering shopping Activity and completion, account/cache refresh, authentication, and history refresh. This includes legacy activity payload decoding and the payload budget with full product metadata. Xcode previews were visually inspected for Lock Screen, expanded, compact and minimal layouts, final-item and completion states, and large Dynamic Type. Locked-device interaction and Always-On still need physical-device verification.

Before release, verify on an iPhone:

- Play creates the activity; in-app pickups and reorderings update it.
- Lock the phone, pick up an item, and reopen the app to confirm the same basket. Check that an accidental pickup can be corrected in the basket.
- Background or terminate the app, then pick up another item; check persistence after relaunch.
- With artwork cached, switch offline and continue picking up items.
- Check long product names, Larger Text, Always-On, and Reduce Transparency.
- Finish or abandon the shop and confirm the activity disappears.
- Disable Live Activities and verify shopping mode still works.

The content remains glanceable on the Lock Screen. iOS controls authentication for interactive buttons and can require Face ID or a passcode; the action itself does not open the app. See [Apple's interaction guidance](https://developer.apple.com/documentation/widgetkit/adding-interactivity-to-widgets-and-live-activities).
