# FluidSynthAUv3

[WIP] Provide FluidSynth as an AUv3 component

# Requirements

- [CMake](https://cmake.org/download/) -- or install via Brew
- [Xcode](https://developer.apple.com/develop/)

# Building

Open the [FluidSynthAUv3.xcodproj](tree/main/FluidSynthAUv3.xcodeproj) file in Xcode and build.

## FluidSynth Build Integration

There is a [Makefile](tree/main/Makefile) that attempts to build the FluidSynth framework for use on macOS. It is run by
Xcode when it builds the `FluidSynth.framework` target so as to satisfy the framework dependency prior to linking the
AUv3 component. This script performs the following:

- Clones https://github.com/bradhowes/fluidsynth.git
- Creates libfluidsynth directory
- Uses CMake to generate FluidSynth.xcodeproj file
- Runs xcodebuild to generate binaries, including the FluidSynth.framework
- Uses CMake to install the framework into `libfluidsynth/Library/Frameworks`
- Copies the framework to the active built products directory so it is usable by the unit tests

Again, this should all _just work_, but at least you now know what is going
on behind the scenes if something fails. There might be a better way to integrate
two Xcode projects...
