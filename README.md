# iOS Assignment – Articles App

An iPhone and iPad app that loads articles from the mock API, shows them in a list or grid, and opens a detail screen for each one. Built for the Magycal iOS challenge.

## Summary

All required parts of the challenge are done:
- List and detail screens matching the Figma design.
- Grid layout, search and pull to refresh.
- Offline support with cached articles.
- Liquid Glass on iOS 26 with a fallback for iOS 18–25.
- Dynamic Type and an iPad split view.
- A SwiftUI state view embedded in UIKit.
- Handling of bad API data.

Every required pod is used. Dependencies are wired with Swinject, and there are 18 unit tests.

## Requirements

- Xcode 26 (built and tested with Xcode 26.2)
- iOS 18.0 or later (iPhone and iPad)
- CocoaPods 1.16 or later

## Setup and run

```bash
git clone https://github.com/shivamlodhi/iOS-Assignment.git
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
| `Models/ProviderProtocols` | `ArticleProviderProtocol`, `ReachabilityProtocol` |
| `Provider/Client` | `APIClient` (Alamofire), `APIError`, `APIEndpoint`, `ReachabilityService` |
| `Provider/Core` | `ArticleProvider`, the API implementation of the protocol |
| `Managers/Client` | `ArticleCache`, logger, date helper, constants (`AppColors`, `AppFonts`, `AppIcons`, `AppStrings`), small UIKit helpers |
| `Managers/Core` | `ArticleManager` (network + cache), `FavoritesManager` |
| `ViewControllers/Client` | `AppRouter` (navigation), `ToastHelper` |
| `ViewControllers/Core` | `ArticleListViewController`, `ArticleDetailViewController` |
| `ViewControllers/Cells` | List and grid cells |
| `Views/XIBs` | Cell XIBs and the reusable `ArticleImageView` |
| `Views/Storyboards` | `Main.storyboard` |
| `Views/StateView.swift` | SwiftUI state view, embedded with `UIHostingController` |

- View controllers only talk to managers. `ArticleManager` talks to the provider through `ArticleProviderProtocol`, so the provider can be replaced or mocked. Reachability sits behind `ReachabilityProtocol` for the same reason, and the unit tests mock both.
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
- The zoom transition is the system one (`preferredTransition = .zoom`). It looks a bit different on iOS 18 and iOS 26 because Apple changed it in iOS 26. I kept the system one on purpose instead of a custom animator; a custom transition can be added if needed
- "Read Full Article" stays a solid blue button on iOS 26. With Liquid Glass the text was tinted and no longer matched the design

## Testing

Unit tests (XCTest) are in `iOS-AssignmentTests`:

- `ArticleDecodingTests` – valid JSON, broken articles, missing fields, invalid links
- `ArticleManagerTests` – fresh data, cache fallback, offline, errors, and an empty response keeping the saved articles
- `ArticleTests` – search matching and allowed links
- `DateHelperTests` – date formatting, fractional seconds and "time ago"
- `FavoritesManagerTests` – saving, removing, and articles without a link

`MockArticleProvider` and `MockReachability` replace the network and the connection, so the tests are fast and also run offline.

To try offline mode in the simulator, turn off the Mac's Wi-Fi, then turn it back on to see the list refresh by itself.

## Known limitations

- The list-to-detail transition is the system zoom, not a custom animator
- There is no favourites screen, because the design doesn't have one
- Light mode only, because the design is light only
- User-facing text is in `AppStrings` but not localised yet
- Keeping the open article when an iPad window becomes narrow (Split View or Slide Over) was not tested, because the simulator can't resize the window
- The optional `Externals/` and `Assets/` folders are empty, so git doesn't include them

## What I would improve with more time

- UI tests for the main flows (list → detail → Safari, search, offline)
- Snapshot tests for the screens at different text sizes
- A custom card-to-detail transition (`UIViewControllerAnimatedTransitioning`) if the system zoom isn't enough
- A favourites screen
- Dark mode
- Pagination if the API grows
- Localisation of the user-facing strings
