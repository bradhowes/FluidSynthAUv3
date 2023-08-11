
libfluidsynth/Library/Frameworks/FluidSynth.framework: fluidsynth
	mkdir -p libfluidsynth
	cd libfluidsynth && \
		cmake -G Xcode -Denable-sdl2=NO -Denable-readline=NO -Denable-dbus=NO -DCMAKE_INSTALL_PREFIX=./ ../fluidsynth && \
		xcodebuild -configuration Release -arch arm64 && \
		cmake --install .

fluidsynth:
	git clone https://github.com/bradhowes/fluidsynth.git

clean:
	rm -rf libfluidsynth
