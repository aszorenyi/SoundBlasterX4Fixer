# Sound Blaster X4 Fixer
A simple workaround service to fix distorted notification and system sounds on Sound Blaster X3 and X4 USB sound cards.

## Why is this needed?
There is a bug in Creative drivers which causes distortion on notification and system sounds on certain events (like opening the volume panel on the taskbar on Windows 11 or running the default Voice Recorder on Windows 10).

The following Reddit thread by u/kujuXI contains details: <br />
[Creative Sound Blaster X4 Sound problems](https://www.reddit.com/r/SoundBlasterOfficial/comments/vebgwu/creative_sound_blaster_x4_sound_problems/)

He recorded a short video about the issue: <br />
[Creative Sound Blaster X4 metallic resonating sound on any notifications in windows](https://www.youtube.com/shorts/IHd4-958HWk)

## How does this work?
The issue is not present if any sound is playing on the device, this simple software plays an inaudible wave file on every Sound Blaster X4 playback device in a loop and runs as a Windows Service in the background.

## Installation

Download and install the latest version from the [Releases page](https://github.com/aszorenyi/SoundBlasterX4Fixer/releases).

In order to run the application you need to have .NET Runtime 6.0 installed. If it's not installed, the setup downloads and installs it automatically.

## License
This software is released under the MIT license.

Refer to the [LICENSE](https://github.com/aszorenyi/SoundBlasterX4Fixer/blob/main/LICENSE) file for details.