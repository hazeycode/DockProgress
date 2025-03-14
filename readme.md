# DockProgress

> Show progress in your app's Dock icon

<img src="screenshot.gif" width="485">

This package is used in production by the [Gifski app](https://github.com/sindresorhus/Gifski). You might also like some of my [other apps](https://sindresorhus.com/apps).

## Requirements

macOS 10.15+

## Install

Add `https://github.com/sindresorhus/DockProgress` in the [“Swift Package Manager” tab in Xcode](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

*Latest version: 4.1.0*

## Usage

### Manually set the progress

```swift
import DockProgress

foo.onUpdate = { progress in
	DockProgress.progress = progress
}
```

### Specify a [`Progress` instance](https://developer.apple.com/documentation/foundation/progress)

```swift
import Foundation
import DockProgress

let progress = Progress(totalUnitCount: 1)
progress?.becomeCurrent(withPendingUnitCount: 1)

DockProgress.progressInstance = progress
```

The given `Progress` instance is weakly stored. It's up to you to retain it.

## Styles

It comes with five styles. PR welcome for more.

Check out the example app in the Xcode project.

You can also draw a custom progress with `.custom(drawHandler: (_ rect: CGRect) -> Void)`.

### Bar

![](screenshot-bar.gif)

```swift
import DockProgress

DockProgress.style = .bar
```

This is the default.

### Squircle

<img src="screenshot-squircle.gif" width="158" height="158">

```swift
import DockProgress

DockProgress.style = .squircle(color: .white.withAlphaComponent(0.5))
```

By default, it should perfectly fit a macOS 11 and later icon, but there is an `inset` parameter if you need to make any adjustments.

### Circle

![](screenshot-circle.gif)

```swift
import DockProgress

DockProgress.style = .circle(radius: 55, color: .systemBlue)
```

Make sure to set a `radius` that matches your app icon.

### Badge

![](screenshot-badge.gif)

```swift
import DockProgress

DockProgress.style = .badge(color: .systemBlue, badgeValue: { getDownloadCount() })
```

Large `badgeValue` numbers will be written in kilo short notation, for example, `1012` → `1k`.

**Note:** The `badgeValue` is not meant to be used as a numeric percentage. It's for things like count of downloads, number of files being converted, etc.

### Pie

<img src="screenshot-pie.gif" width="150" height="150">

```swift
import DockProgress

DockProgress.style = .pie(color: .systemBlue)
```

## Related

- [Defaults](https://github.com/sindresorhus/Defaults) - Swifty and modern UserDefaults
- [Preferences](https://github.com/sindresorhus/Preferences) - Add a preferences window to your macOS app in minutes
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Add user-customizable global keyboard shortcuts to your macOS app
- [LaunchAtLogin](https://github.com/sindresorhus/LaunchAtLogin) - Add "Launch at Login" functionality to your macOS app
- [Regex](https://github.com/sindresorhus/Regex) - Swifty regular expressions
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift)
