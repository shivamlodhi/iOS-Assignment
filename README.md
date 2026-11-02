# iOS Assignment – Articles App

An iPhone and iPad app that loads articles from the mock API, shows them in a list or grid, and opens a detail screen for each one. Built for the Magycal iOS challenge.

## Requirements

- Xcode 26 (built and tested with Xcode 26.2)
- iOS 18.0 or later (iPhone and iPad)
- CocoaPods 1.16 or later

## Setup and run

```bash
git clone <repo-url>
cd iOS-Assignment/iOS-Assignment
pod install
open iOS-Assignment.xcworkspace
```

Pick the `iOS-Assignment` scheme, choose a simulator and press Run. Use the `.xcworkspace`, not the `.xcodeproj`.

If `pod install` fails with an encoding error, run `export LANG=en_US.UTF-8` first.

To run the unit tests press `Cmd + U`, or:

```bash
xcodebuild test -workspace iOS-Assignment.xcworkspace -scheme iOS-Assignment -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

## Features

- Article list with list and grid layouts, search (the search bar appears when the search icon is tapped) and pull to refresh
- Detail screen with title, time ago, image and content, plus a favourite button
- "Read Full Article" opens the link in `SFSafariViewController`
- iPad uses `UISplitViewController` with the list and detail side by side
- Offline support: the last loaded list is cached and shown when the device is offline or the request fails, with a toast. When there is nothing cached, an offline screen with a Retry button is shown
- The list refreshes on its own when the connection comes back
- Loading, empty, error, offline and "no results" states
- Dynamic Type on all screens. At accessibility sizes the grid switches to one column and the list card stacks the date and button
- Liquid Glass on iOS 26 for the detail back button and the Retry button, with a plain fallback on iOS 18–25
- Zoom transition from the tapped card to the detail screen on iPhone

## Architecture

UIKit with Storyboards and XIBs, following MVC. The folders follow the structure from the challenge:

| Folder | What is inside |
| --- | --- |
| `Models/Entities` | `Article`, `ArticleSource`, `ArticlesResponse` (Codable) |
| `Models/ProviderProtocols` | `ArticleProviderProtocol` |
| `Provider/Client` | `APIClient` (Alamofire), `APIError`, `APIEndpoint`, `ReachabilityService` |
| `Provider/Core` | `ArticleProvider`, the API implementation of the protocol |
| `Managers/Client` | `ArticleCache`, logger, colours, fonts, icons, date helper |
| `Managers/Core` | `ArticleManager` (network + cache), `FavoritesManager` |
| `ViewControllers/Client` | `AppRouter` (navigation), `ToastHelper` |
| `ViewControllers/Core` | `ArticleListViewController`, `ArticleDetailViewController` |
| `ViewControllers/Cells` | List and grid cells |
| `Views/XIBs` | Cell XIBs and the reusable `ArticleImageView` |
| `Views/Storyboards` | `Main.storyboard` |
| `Views/StateView.swift` | SwiftUI state view, embedded with `UIHostingController` |

- View controllers only talk to managers. `ArticleManager` talks to the provider through `ArticleProviderProtocol`, so the provider can be replaced or mocked (the unit tests do this).
- All dependencies are registered in `AppDelegate` with Swinject and passed into the view controllers. View controllers don't create their own services.
- `AppRouter` builds the detail screen and decides whether to push it (iPhone) or show it in the split view's detail column (iPad).

## Pods

Required pods:

- **Alamofire** – network requests
- **XCGLogger** – logging requests, responses and errors (debug level in debug builds, warnings and errors in release)
- **Swinject** – dependency injection
- **ReachabilitySwift** – connectivity changes
- **Kingfisher** – image loading and caching, with a placeholder when an image is missing or fails
- **Cache** – saving the last loaded articles to disk

Optional pods:

- **Loaf** – small toast messages, used for "You’re offline. Showing saved articles." It is light and doesn't block the screen like an alert would.

I didn't add the other optional pods. The system navigation bar and the zoom transition were enough, and the pull to refresh control and loading indicator already show when something is loading.

## Handling bad data

- Every field on `Article` is optional, so missing or null values don't break decoding
- A broken article is skipped instead of failing the whole list, and a missing `articles` key gives an empty list
- Articles with no title and no description are hidden
- Empty or missing image URLs show a placeholder
- Only `http` and `https` links open in Safari. The button is hidden when the link is invalid
- Missing title or content on the detail screen falls back to a short message

## Assumptions

- The system font (SF Pro) is used instead of the font in the Figma file, which is close enough and works well with Dynamic Type
- Favourites are only kept on the device (UserDefaults). There is no favourites screen because the design doesn't have one
- The design is light only, so the app uses fixed light colours
- On iPad the design was adapted: the list sits in the left column and the detail fills the right one
- The zoom transition is the system one (`preferredTransition = .zoom`). It looks a bit different on iOS 18 and iOS 26 because Apple changed it in iOS 26
- "Read Full Article" stays a solid blue button on iOS 26. With Liquid Glass the text was tinted and no longer matched the design

## Testing

Unit tests (XCTest) are in `iOS-AssignmentTests`:

- `ArticleDecodingTests` – valid JSON, broken articles, missing fields, invalid links
- `DateHelperTests` – date formatting and "time ago"
- `ArticleManagerTests` – fresh data, cache fallback and errors, using a mock provider

The manager tests skip themselves when the machine is offline, because the manager checks the real connection first.

To try offline mode in the simulator, turn off the Mac's Wi-Fi, then turn it back on to see the list refresh by itself.

## What I would improve with more time

- Put `ReachabilityService` behind a protocol so the offline path of `ArticleManager` can be unit tested too
- UI tests for the main flows (list → detail → Safari, search, offline)
- Snapshot tests for the screens at different text sizes
- A favourites screen
- Dark mode
- Pagination if the API grows
- Localisation of the user-facing strings
