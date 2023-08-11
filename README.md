# FluidSynthAUv3

[WIP] Provide FluidSynth as an AUv3 component

# Requirements

- [CMake](https://cmake.org/download/) -- or install via Brew
- [Xcode](https://developer.apple.com/develop/)

# Configuration

There is a `Makefile` that attempts to build the FluidSynth framework for use on macOS.
It is run by Xcode prior to building the AUv3 component (see the Build pre-actions in the
FluidSynthAUv3 scheme). It performs the following:

- Clones https://github.com/bradhowes/fluidsynth.git
- Creates libfluidsynth directory
- Uses CMake to generate FluidSynth.xcodeproj file
- Runs xcodebuild to generate binaries, including the FluidSynth.framework
- Uses CMake to install the framework into `libfluidsynth/Library/Frameworks`

Again, this should all _just work_, but at least you now know what is going
on behind the scenes if something fails. There might be a better way to integrate
two Xcode projects...
