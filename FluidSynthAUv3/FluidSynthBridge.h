// Copyright © 2023 Brad Howes. All rights reserved.

#pragma once

#include <Foundation/Foundation.h>
#include <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PresetInfo : NSObject
@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) int bank;
@property (nonatomic, readonly) int program;

- (id)init:(NSString*)name inBank:(int)bank atProgram:(int)program;

@end

/**
 Objective-C wrapper for the C++ Engine class in SF2Lib.
 */
@interface FluidSynthBridge : NSObject

/// @returns maximum number of voices that can play simultaneously
@property (nonatomic, readonly) int voiceCount;

/// @returns number of voices that are currently generating audio
@property (nonatomic, readonly) int activeVoiceCount;

/// @returns number of presets in the loaded soundfont file
@property (nonatomic, readonly) int presetCount;

/// @returns URL of the currently-loaded file
@property (nonatomic, readonly, nullable) NSURL* url;

/// @returns the name of the current preset
@property (nonatomic, readonly) NSString* presetName;

@property (nonatomic, assign) int channel;

@property (nonatomic, readonly) NSArray<PresetInfo*>* presets;

/**
 Constructor.
 */
- (instancetype)init;

/**
 Set the rendering parameters prior to starting the audio unit graph.

 @param format the format of the output to generate, including the sample rate
 @param maxFramesToRender the maximum number of frames to expect in a render call from CoreAudio.
 */
- (void)setRenderingFormat:(NSInteger)busCount format: (AVAudioFormat*)format
         maxFramesToRender:(AUAudioFrameCount)maxFramesToRender;

/**
 Notification that rendering is done.
 */
- (void)renderingStopped;

/**
 Load a soundfont file.

 @param url the location of the file to load
 */
- (BOOL)load:(NSURL*)url;

/**
 Set the active preset.

 @param index the index of the preset to use
 */
- (BOOL)selectPreset:(int)index;

/**
 Set the active preset.

 @param bank the bank holding the preset to load
 @param program the program ID for the preset to load
 */
- (void)selectBank:(int)bank program:(int)program;

/**
 Stop playing all notes
 */
- (void)stopAllNotes;

/**
 Stop playing the given MIDI key

 @param note the MIDI key to stop
 @param velocity the velocity for the event
 */
- (void)stopNote:(UInt8)note velocity:(UInt8)velocity;

/**
 Start playing the given MIDI key

 @param note the MIDI key to play
 @param velocity the velocity for the event
 */
- (void)startNote:(UInt8)note velocity:(UInt8)velocity;

/// @returns the internal render block used to generate samples
- (AUInternalRenderBlock)internalRenderBlock;

@end

NS_ASSUME_NONNULL_END
