// Prints whether the microphone or the camera is currently in use, as
// `microphone=<0|1> camera=<0|1>`.
//
// macOS only surfaces this in the native menu bar, which this configuration
// hides, so the information is recovered here from the same properties the
// system itself watches: `kAudioDevicePropertyDeviceIsRunningSomewhere` for
// audio input devices and `kCMIODevicePropertyDeviceIsRunningSomewhere` for
// video devices.
//
// Known platform limitation: Bluetooth microphones do not report their state
// through this property and always read as inactive.

#include <CoreAudio/CoreAudio.h>
#include <CoreMediaIO/CMIOHardware.h>
#include <stdio.h>
#include <stdlib.h>

static int microphone_in_use(void) {
  AudioObjectPropertyAddress devices_address = {
    kAudioHardwarePropertyDevices,
    kAudioObjectPropertyScopeGlobal,
    kAudioObjectPropertyElementMain
  };

  UInt32 size = 0;
  if (AudioObjectGetPropertyDataSize(kAudioObjectSystemObject,
                                     &devices_address,
                                     0, NULL, &size) != noErr) return 0;

  AudioDeviceID *devices = malloc(size);
  if (!devices) return 0;

  int in_use = 0;
  if (AudioObjectGetPropertyData(kAudioObjectSystemObject,
                                 &devices_address,
                                 0, NULL, &size, devices) == noErr) {
    UInt32 count = size / sizeof(AudioDeviceID);
    for (UInt32 index = 0; index < count && !in_use; index++) {
      // Only devices that actually have input streams are microphones.
      AudioObjectPropertyAddress streams_address = {
        kAudioDevicePropertyStreams,
        kAudioObjectPropertyScopeInput,
        kAudioObjectPropertyElementMain
      };

      UInt32 streams_size = 0;
      if (AudioObjectGetPropertyDataSize(devices[index], &streams_address,
                                         0, NULL, &streams_size) != noErr) continue;
      if (streams_size == 0) continue;

      AudioObjectPropertyAddress running_address = {
        kAudioDevicePropertyDeviceIsRunningSomewhere,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMain
      };

      UInt32 running = 0;
      UInt32 running_size = sizeof(running);
      if (AudioObjectGetPropertyData(devices[index], &running_address,
                                     0, NULL, &running_size, &running) != noErr) continue;
      if (running) in_use = 1;
    }
  }

  free(devices);
  return in_use;
}

static int camera_in_use(void) {
  CMIOObjectPropertyAddress devices_address = {
    kCMIOHardwarePropertyDevices,
    kCMIOObjectPropertyScopeGlobal,
    kCMIOObjectPropertyElementMain
  };

  UInt32 size = 0;
  if (CMIOObjectGetPropertyDataSize(kCMIOObjectSystemObject,
                                    &devices_address, 0, NULL, &size) != noErr) return 0;

  CMIOObjectID *devices = malloc(size);
  if (!devices) return 0;

  int in_use = 0;
  UInt32 used = 0;
  if (CMIOObjectGetPropertyData(kCMIOObjectSystemObject, &devices_address,
                                0, NULL, size, &used, devices) == noErr) {
    UInt32 count = used / sizeof(CMIOObjectID);
    for (UInt32 index = 0; index < count && !in_use; index++) {
      CMIOObjectPropertyAddress running_address = {
        kCMIODevicePropertyDeviceIsRunningSomewhere,
        kCMIOObjectPropertyScopeWildcard,
        kCMIOObjectPropertyElementWildcard
      };

      UInt32 running = 0;
      UInt32 running_used = 0;
      if (CMIOObjectGetPropertyData(devices[index], &running_address,
                                    0, NULL, sizeof(running),
                                    &running_used, &running) != noErr) continue;
      if (running) in_use = 1;
    }
  }

  free(devices);
  return in_use;
}

int main(void) {
  printf("microphone=%d camera=%d\n", microphone_in_use(), camera_in_use());
  return 0;
}
