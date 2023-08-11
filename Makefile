CMAKE = /opt/homebrew/bin/cmake

PROJECT_DIR ?= $(PWD)
TOP = $(PROJECT_DIR)
BUILT_PRODUCTS_DIR ?= $(PROJECT_DIR)/libfluidsynth

# Install the FluidSynth.framework into a location that the test runner can find it
$(BUILT_PRODUCTS_DIR)/FluidSynth.framework: $(TOP)/libfluidsynth/Library/Frameworks/FluidSynth.framework
	mkdir -p $(BUILT_PRODUCTS_DIR)
	cp -r $(TOP)/libfluidsynth/Library/Frameworks/FluidSynth.framework $(BUILT_PRODUCTS_DIR)/FluidSynth.framework

# Build the FluidSynth.framework
$(TOP)/libfluidsynth/Library/Frameworks/FluidSynth.framework: $(TOP)/fluidsynth
	mkdir -p $(TOP)/libfluidsynth
	cd $(TOP)/libfluidsynth && \
		$(CMAKE) -G Xcode -Denable-sdl2=NO -Denable-readline=NO -Denable-dbus=NO -DCMAKE_INSTALL_PREFIX=./ ../fluidsynth && \
		xcodebuild -configuration Release -arch arm64 && \
		$(CMAKE) --install .

# Download the FluidSynth repo
$(TOP)/fluidsynth:
	cd $(TOP) && git clone https://github.com/bradhowes/fluidsynth.git

clean:
	rm -rf $(TOP)/libfluidsynth
