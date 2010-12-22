// ArtnetToMidi - This application reads ArtNet and outputs Midi Notes
// Copyright (C) 2010  Rick Russell
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


#define MIDI_MESSAGE_LENGTH		3
#define ARTNET_PORT	6454
#define ARTNET_CHANNEL_BYTE_OFFSET 17
#define ARTNET_UNIVERSE_BYTE 14

#import <Cocoa/Cocoa.h>
#include <CoreMIDI/MIDIServices.h>

@class AsyncUDPSocket;

@interface ArtnetToMidiAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	// Midi stuff
	
	//unsigned char midimsg[MIDI_MESSAGE_LENGTH];
	MIDIClientRef midi_client;
	MIDIEndpointRef midi_source;
	
	AsyncUDPSocket *udpSocket; // Artnet Socket
	
	BOOL isRunning;
	int lastValue; //Hold the last DMX update value to compare for a change
	
	IBOutlet id midiChannelInput;
	IBOutlet id dmxChannelInput;
	IBOutlet id dmxUniverseInput;
	IBOutlet id lastDMXValue;
	IBOutlet id startStopButton;
	IBOutlet id dmxChannelStepper;
	IBOutlet id dmxUniverseStepper;
	IBOutlet id midiChannelStepper;
	
}

@property (assign) IBOutlet NSWindow *window;

//@property (assign,nonatomic) unsigned char midimsg;
@property (assign, nonatomic) MIDIClientRef midi_client;
@property (assign, nonatomic) MIDIEndpointRef midi_source;

- (IBAction)startStop:(id)sender;
- (IBAction)midiChannelStepperClicked:(id)sender;
- (IBAction)dmxChannelStepperClicked:(id)sender;
- (IBAction)dmxUniverseStepperClicked:(id)sender;
@end
