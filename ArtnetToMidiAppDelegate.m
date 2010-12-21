//
//  ArtnetToMidiAppDelegate.m
//  ArtnetToMidi
//
//  Created by Rick Russell on 5/21/10.
//  Copyright 2010 All rights reserved.
//

#import "ArtnetToMidiAppDelegate.h"
#import <CoreMIDI/MIDIServices.h>
#import "AsyncUdpSocket.h"

@implementation ArtnetToMidiAppDelegate

@synthesize window, midi_client, midi_source;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	OSStatus status;
	lastValue = 0;
	
	status = MIDIClientCreate(CFSTR("ArtnetToMidi"), NULL, NULL, &midi_client);
	if(status != 0) {
		NSLog(@"ArtnetToMidi: Failed to create MIDI client!");
	}
	
	status = MIDISourceCreate(midi_client, CFSTR("ArtnetToMidi-out"), &midi_source);
	if(status != 0) {
		NSLog(@"ArtnetToMidi: Failed to create MIDI source!");
		MIDIClientDispose(midi_client);
	}
	
	
}

- (void) awakeFromNib 
{
	// Set all of the deligates to read any entered changes
	[midiChannelInput setDelegate:self];
	[dmxChannelInput setDelegate:self];
	[dmxUniverseInput setDelegate:self];
	
	// Initialize the default values of the controlls
	[midiChannelStepper setMinValue:1];
	[midiChannelStepper setMaxValue:16];
	[dmxChannelStepper setMinValue:1];
	[dmxChannelStepper setMaxValue:512];
	[dmxUniverseStepper setMinValue:1];
	[dmxUniverseStepper setMaxValue:16];

}

// Enable and Disable the Interface
- (void)interfaceEnabled:(BOOL)enabled
{
	[midiChannelInput setEnabled:enabled];
	[dmxChannelInput setEnabled:enabled];
	[dmxUniverseInput setEnabled:enabled];
	[dmxChannelStepper setEnabled:enabled];
	[dmxUniverseStepper setEnabled:enabled];
	[midiChannelStepper setEnabled:enabled];
}

- (IBAction)startStop:(id)sender {
	
	if(!isRunning)
	{
		
		NSError *error = nil;
		
		[udpSocket release];
		
		udpSocket = [[AsyncUdpSocket alloc] initWithDelegate:self];
		if (![udpSocket bindToPort:ARTNET_PORT error:&error])
		{
			NSLog(@"Error starting UDP server: %@", error);
			return;
		}
		[udpSocket receiveWithTimeout:-1 tag:0];
		NSLog(@"Echo server started on port %hu", [udpSocket localPort]);
		isRunning = YES;
		
		[self interfaceEnabled:NO];
		[startStopButton setTitle:@"Stop"];
		
	}
	else
	{

		[udpSocket close];
		
		NSLog(@"Stopped Artnet Receive");
		isRunning = NO;
		
		[self interfaceEnabled:YES];
		[startStopButton setTitle:@"Start"];
	}
}
	
- (void)sendMidi:(int)noteValue {
	
	if(noteValue > 127)
		noteValue = 127; // Make sure the note value is not greater then 127
	
	int midiChannel = [midiChannelInput intValue]; //Get the MIDI channel from the UI

	Byte noteOn[] = { 0x90 + (midiChannel - 1) , noteValue, 64};
	
	int length = 3;
	
	
	Byte buffer[64];
	MIDIPacketList *pktlist = (MIDIPacketList *)buffer;
	MIDIPacket *curPacket = MIDIPacketListInit(pktlist);
	
	curPacket = MIDIPacketListAdd(pktlist, sizeof(buffer), curPacket, 0, length, noteOn); 
	
	OSStatus status;
	status = MIDIReceived(midi_source, pktlist);
	
	if(status == 0) {
		NSLog(@"Packet Send was a success. Note: %hu, Channel: %x", noteValue, 0x90 + (midiChannel - 1));
	} else {
		NSLog(@"Failed sending the packet");
	}
	
}

- (void)midiChannelStepperClicked:(id)sender {
	[midiChannelInput setIntValue:[midiChannelStepper intValue]];	
}

- (void)dmxChannelStepperClicked:(id)sender {
	[dmxChannelInput setIntValue:[dmxChannelStepper intValue]];
}

- (void)dmxUniverseStepperClicked:(id)sender {
	[dmxUniverseInput setIntValue:[dmxUniverseStepper intValue]];
}


- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{

	unsigned char dmxBuffer[530]; // Get the DMX packet bytes

	int dmxChannel = [dmxChannelInput intValue];
	int dmxUniverse = [dmxUniverseInput	intValue];
	int channelValue = 0;
		
	[data getBytes:dmxBuffer];
	

	if(dmxBuffer[9] == 0x50 && dmxBuffer[10] == 0x00) //Is this a DMX packet?
	{	
		if (dmxBuffer[ARTNET_UNIVERSE_BYTE] == dmxUniverse - 1) { // Is this the selected Universe?
			channelValue = dmxBuffer[dmxChannel + ARTNET_CHANNEL_BYTE_OFFSET];
			
			// Make sure the channelValue is less then the max midi value of 127
			if (channelValue > 127)  
				channelValue = 127;
			
			if( channelValue != lastValue)  //Did the value change?
			{
		

			
				[self sendMidi:channelValue]; // Send the changed Midi value
				lastValue = channelValue; 
				// TODO: Set lastDMXValue when changed
			}
				   
		}
		//NSLog(@"Raw Data: %@", [data description]);
	
		
		[sock receiveWithTimeout:-1 tag:0];
		return YES;
	}
	return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
	NSLog(@"Error: %@", [error description]);
}

- (void)dealloc {
		
	MIDIEndpointDispose(midi_source);
	MIDIClientDispose(midi_client);
	
	[udpSocket release];
	
	[super dealloc];
	
}

// Stepper deligate

- (void)controlTextDidChange:(NSNotification *)aNotification {
    if ([[aNotification name] isEqualToString:@"NSControlTextDidChangeNotification"]) {
        if ( [aNotification object] == midiChannelInput ) {
            [midiChannelStepper setIntValue:[midiChannelInput intValue]];
        }
        if ( [aNotification object] == dmxChannelInput ) {
            [dmxChannelStepper setIntValue:[dmxChannelInput intValue]];
        }
        if ( [aNotification object] == dmxUniverseInput ) {
            [dmxUniverseStepper setIntValue:[dmxUniverseInput intValue]];
        }
    }
}


@end
