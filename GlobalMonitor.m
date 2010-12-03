//
//  GlobalMonitor.m
//  ModKeys
//
//  Created by Eric Nitardy on 12/2/10.
//  Copyright 2010 University of Washington. All rights reserved.
//

#import "GlobalMonitor.h"

@implementation GlobalMonitor

+(id) monitorEvery: (NSEventMask) eventMask performSelector: (SEL) aSelector target: (id) target {
	id myMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:eventMask handler:^(NSEvent *event) {
		NSLog(@"EveryMonitorEvent");
		[target performSelector: aSelector withObject: event];
		
	}];	
	return myMonitor;	
}

+(id) monitorEvery: (NSEventMask) eventMask ignoring: (NSEventMask) ignoreMask performSelector: (SEL) aSelector target: (id) target {
	id myMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:eventMask handler:^(NSEvent *event) {
		NSLog(@"EveryMonitorEvent");
		int typeMask = 1 << [event type];
		if ( !(typeMask & ignoreMask) ) {
			[target performSelector: aSelector withObject: event];
		}
	}];	
	return myMonitor;	
}	
	
+(id) monitorNext: (NSEventMask) eventMask performSelector: (SEL) aSelector target: (id) target {
	myNextMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:eventMask handler:^(NSEvent *event) {
		NSLog(@"NextMonitorEvent");
		[NSEvent removeMonitor: myNextMonitor];				
		[target performSelector: aSelector withObject: event];
		
	}];	
	return myNextMonitor;
}

+(void) removeMonitor: (id) monitor {	
	[NSEvent removeMonitor: monitor];	
}

@end
