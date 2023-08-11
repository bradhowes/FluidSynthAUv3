// Copyright © 2023 Brad Howes. All rights reserved.

#import <CoreAudioKit/CoreAudioKit.h>
#import <os/log.h>
#import <FluidSynth/FluidSynth.h>

#import "FluidSynthBridge.h"

@implementation PresetInfo

- (id)init:(NSString*)name inBank:(int)bank atProgram:(int)program
{
  if (self = [super init]) {
    self->_name = name;
    self->_bank = bank;
    self->_program = program;
  }

  return self;
}

@end

NSComparator presetInfoComparison = ^NSComparisonResult(PresetInfo*  _Nonnull obj1, PresetInfo*  _Nonnull obj2) {
  if (obj1.bank < obj2.bank) return NSOrderedAscending;
  if (obj1.bank == obj2.bank) {
    if (obj1.program < obj2.program) return NSOrderedAscending;
    if (obj1.program == obj2.program) return NSOrderedSame;
    return NSOrderedDescending;
  }
  return NSOrderedDescending;
};

@implementation FluidSynthBridge {
  fluid_settings_t* settings_;
  fluid_synth_t* synth_;
  NSURL* url_;
  int sfont_id_;
  NSUInteger activePreset_;
}

- (instancetype)init {
  if (self = [super init]) {
    settings_ = new_fluid_settings();
    fluid_settings_setnum(settings_, "synth.sample-rate", 48000.0);
    synth_ = new_fluid_synth(settings_);
    url_ = nullptr;
    sfont_id_ = FLUID_FAILED;
    activePreset_ = 0;
  }

  return self;
}

- (nullable NSURL*)url { return url_; }

- (NSString*)presetName {
  if (self.presets == nullptr || activePreset_ == self.presets.count) return [NSString stringWithUTF8String:""];
  return [self.presets objectAtIndex:activePreset_].name;
}

- (void)setRenderingFormat:(NSInteger)busCount format:(AVAudioFormat*)format
         maxFramesToRender:(AUAudioFrameCount)maxFramesToRender {
  if (synth_) {
    delete_fluid_synth(synth_);
    synth_ = nullptr;
  }

  double sampleRate = [format sampleRate];
  fluid_settings_setnum(settings_, "synth.sample-rate", sampleRate);
  synth_ = new_fluid_synth(settings_);
}

- (void)renderingStopped {
  fluid_synth_all_notes_off(synth_, _channel);
}

- (bool)load:(NSURL*)url {
  _presets = nullptr;
  activePreset_ = -1;

  if (sfont_id_ != -1) {
    fluid_synth_sfunload(synth_, sfont_id_, false);
    sfont_id_ = -1;
  }

  const char* path = [[url path] cStringUsingEncoding:NSUTF8StringEncoding];
  sfont_id_ = fluid_synth_sfload(synth_, path, true);
  if (sfont_id_ == FLUID_FAILED) {
    return false;
  }

  if (fluid_synth_sfont_select(synth_, self.channel, sfont_id_) == FLUID_FAILED) return false;

  fluid_sfont_t* font = fluid_synth_get_sfont(synth_, 0);
  if (font == nullptr) return false;

  fluid_sfont_iteration_start(font);
  NSMutableArray<PresetInfo*>* presets = [[NSMutableArray<PresetInfo*> alloc] initWithCapacity:256];
  while (fluid_preset_t* preset = fluid_sfont_iteration_next(font)) {
    NSString* name = [NSString stringWithUTF8String: fluid_preset_get_name(preset)];
    int bank = fluid_preset_get_banknum(preset);
    int program = fluid_preset_get_num(preset);
    PresetInfo* presetInfo = [[PresetInfo alloc] init:name inBank:bank atProgram:program];
    [presets addObject:presetInfo];
  }

  // Sort the presets by increasing bank/program numbers.
  [presets sortUsingComparator:presetInfoComparison];
  _presets = presets;

  return true;
}

- (bool)selectPreset:(int)index {
  activePreset_ = -1;
  if (index < 0 || index >= _presets.count) return false;
  PresetInfo* presetInfo = [_presets objectAtIndex:index];
  if (presetInfo == nullptr) return false;

  if (fluid_synth_program_select(synth_, self.channel, sfont_id_, presetInfo.bank, presetInfo.program) != FLUID_OK)
    return false;
  activePreset_ = index;

  return true;
}

- (void)selectBank:(int)bank program:(int)program {
  id searchObject = [[PresetInfo alloc] init:@"" inBank:bank atProgram:program];
  NSRange searchRange = NSMakeRange(0, self.presets.count);
  NSUInteger findIndex = [_presets indexOfObject:searchObject
                                   inSortedRange:searchRange
                                         options:NSBinarySearchingFirstEqual
                                 usingComparator:presetInfoComparison];
  if (findIndex == self.presets.count) return;

  activePreset_ = findIndex;
  fluid_synth_program_select(synth_, self.channel, sfont_id_, bank, program);
}

- (int)presetCount { return int(self.presets.count); }

- (int)voiceCount { return 0; } // static_cast<int>(engine_->voiceCount()); }

- (int)activeVoiceCount { return 0; } // static_cast<int>(engine_->activeVoiceCount()); }

- (void)stopAllNotes {
  fluid_synth_all_notes_off(self->synth_, self.channel);
}

- (void)stopNote:(UInt8)key velocity:(UInt8)velocity {
  fluid_synth_noteoff(synth_, self.channel, key);
}

- (void)startNote:(UInt8)key velocity:(UInt8)velocity {
  fluid_synth_noteon(synth_, self.channel, key, velocity);
}

- (AUInternalRenderBlock)internalRenderBlock {
  __block auto synth = self->synth_;
  return ^AUAudioUnitStatus(AudioUnitRenderActionFlags*, const AudioTimeStamp* timestamp,
                            AUAudioFrameCount frameCount, NSInteger, AudioBufferList* output,
                            const AURenderEvent* realtimeEventListHead, AURenderPullInputBlock pullInputBlock) {
    float* _Nullable left = static_cast<float*>(output->mBuffers[0].mData);
    float* _Nullable right = static_cast<float*>(output->mBuffers[1].mData);
    fluid_synth_write_float(synth, frameCount, left, 0, 1, right, 0, 1);
    return noErr;
  };
}

@end
