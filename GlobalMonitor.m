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
	
	
+(id) monitorNext: (NSEventMask) eventMask performSelector: (SEL) aSelector target: (id) target {
	myNextMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:eventMask handler:^(NSEvent *event) {
		NSLog(@"NextMonitorEvent");
		
		//CGRect winBounds;
		//winBounds = [[target performSelector: @selector(keyPanel)] frame];
		//CGPoint eventLocation;
		//eventLocation = [NSEvent mouseLocation];
		//NSLog(@"%1f %1f", eventLocation.x, eventLocation.y);
		//if (!CGRectContainsPoint(winBounds, eventLocation)) {

		    [NSEvent removeMonitor: myNextMonitor];				
		    [target performSelector: aSelector withObject: event];
			
		//}		
	}];	
	return myNextMonitor;
}

+(void) removeMonitor: (id) monitor {	
	[NSEvent removeMonitor: monitor];	
}

@end
