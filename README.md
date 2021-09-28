# Navigator 2.0 example

Navigator 2.0 Pages API example and Router example.

The main point of these examples is to show how to show how navigation can be separated from UI layer into `Navigation` calass . 

## Navigator 2.0 components
  * `Page` — an immutable object used to set the navigator’s history stack.
  * `Router` — configures the list of pages to be displayed by the Navigator. Usually this list of pages changes based on the underlying platform, or on the state of the app changing.
  * `RouteInformationParser`, which takes the RouteInformation from RouteInformationProvider and parses it into a user-defined data type.
  * `RouterDelegate` — defines app-specific behavior of how the Router learns about changes in app state and how it responds to them. Its job is to listen to the `RouteInformationParser` and the app state and build the Navigator with the current list of Pages.
  * `BackButtonDispatcher` — reports back button presses to the Router.


## Existing solutions
  * [auto_route](https://pub.dev/packages/auto_route)
  * [beamer](https://pub.dev/packages/beamer)
  * [flouter](https://pub.dev/packages/flouter)
  * [flit_router](https://pub.dev/packages/flit_router)
  * [vrouter](https://pub.dev/packages/vrouter)

## Problems with existing solutions
  * Navigation is distributed throughout the application.
  * It is difficult to track the navigation stack when you have complex navigation.
  * Bottom and AppBar navigation not supported from the box (auto_route suports).
  * Dependence on Context.
  * How to save navigation stack when navigating between pages.

## Solution
<img width="973" alt="schematic1" src="https://user-images.githubusercontent.com/15017625/135136240-d1bd3235-c1d1-46c2-bc2d-db6d3cf96056.png">

## Scheme of application
<p float="left">
  <img src="https://user-images.githubusercontent.com/15017625/135136400-0c2a6e08-5693-4570-b092-0fa71a3d900f.png" width="75%" />
  <img src="https://user-images.githubusercontent.com/15017625/135137567-aedae08b-f62e-4186-8b80-7c6f661e6f67.png" width="20%" /> 
</p>

## How to test deeplinks

## Tools for invoking links

If you register a schema, say `unilink`, you could use these cli tools:

### Android

You could do below tasks within [Android Studio](https://developer.android.com/studio/write/app-link-indexing#testindent).

Assuming you've installed Android Studio (with the SDK platform tools):

```sh
adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "navigator://deeplinks/home"'
```

If you don't have [`adb`](https://developer.android.com/studio/command-line/adb)
in your path, but have `$ANDROID_HOME` env variable then use
`"$ANDROID_HOME"/platform-tools/adb ...`.

Note: Alternatively you could simply enter an `adb shell` and run the
[`am`](https://developer.android.com/studio/command-line/adb#am) commands in it.

Note: I use single quotes, because what follows the `shell` command is what will
run in the emulator (or device) and shell metacharacters, such as question marks
(`?`) and ampersands (`&`), usually mean something different to your own shell.

`adb shell` communicates with the only available device (or emulator), so if
you've got multiple devices you have to specify which one you want to run the
shell in via:

  * The _only_ USB connected device - `adb -d shell '...'`
  * The _only_ emulated device - `adb -e shell '...'`

You could use `adb devices` to list currently available devices (similarly
`flutter devices` does the same job).

### iOS

Assuming you've got Xcode already installed:

```sh
xcrun simctl openurl booted navigator://deeplinks/home 
```

If you've got `xcrun` (or `simctl`) in your path, you could invoke it directly.

The flag `booted` assumes an open simulator (you can start it via
`open -a Simulator`) with a booted device. You could target specific device by
specifying its UUID (found via `xcrun simctl list` or `flutter devices`),
replacing the `booted` flag.

## Useful links
  * [Flutter Router Package Comparative Analysis](https://github.com/flutter/uxr/blob/master/nav2-usability/comparative-analysis/README.md)
  * [Navigator 2.0 API Usability Research](https://github.com/flutter/uxr/wiki/Navigator-2.0-API-Usability-Research#3-api-usage-walkthrough-study)
  * [Navigator 2.0 and Router](https://docs.google.com/document/d/1Q0jx0l4-xymph9O6zLaOY4d_f7YFpNWX_eGbzYxr9wY/edit)

