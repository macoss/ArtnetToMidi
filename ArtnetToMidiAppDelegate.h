//
//  ArtnetToMidiAppDelegate.h
//  ArtnetToMidi
//
//  Created by Rick Russell on 5/21/10.
//  Copyright 2010 Sugar Creek Baptist Church. All rights reserved.
//

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
