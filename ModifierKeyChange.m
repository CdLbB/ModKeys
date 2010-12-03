//
//  ModifierKeyChange.m
//  ModKeys
//
//  Created by Eric Nitardy on 12/1/10.
//  Copyright 2010 University of Washington. All rights reserved.
//

#import "ModifierKeyChange.h"


@implementation ModifierKeyChange

+(void) changeKey: (CGKeyCode) key state: (bool) state {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	CGEventRef modKeyEvent = CGEventCreateKeyboardEvent( NULL, key, state);
	CGEventSetFlags(modKeyEvent, kCGEventFlagMaskShift);
	
	CGEventRef modKeyEvent1 = CGEventCreate(NULL);
	CGEventSetType(modKeyEvent1, kCGEventFlagsChanged);
	CGEventSetFlags(modKeyEvent1, kCGEventFlagMaskShift);
	
	CGEventPost (kCGHIDEventTap, modKeyEvent);
	CGEventPost (kCGHIDEventTap, modKeyEvent1);
	
	[pool release];	
}
@end
