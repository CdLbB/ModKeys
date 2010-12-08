//
//  MyNSEvent.m
//  ModKeys
//
//  Created by Eric Nitardy on 12/3/10.
//  Copyright 2010 University of Washington. All rights reserved.
//


#import "MyNSEvent.h"


@implementation MyNSEvent

+(int) clickAtLocation: (NSPoint) pt {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int x = pt.x;
	int y = pt.y;
	
	CGPoint ptCG;
	ptCG.x = x;
	ptCG.y = y;
	
	
	CGEventRef mouseDownEv = CGEventCreateMouseEvent(
													 NULL,kCGEventLeftMouseDown,ptCG,kCGMouseButtonLeft);
	
	CGEventRef mouseUpEv = CGEventCreateMouseEvent(
												   NULL,kCGEventLeftMouseUp,ptCG,kCGMouseButtonLeft);
	
	CGEventPost (kCGSessionEventTap, mouseDownEv);
	
	
	CGEventPost (kCGSessionEventTap, mouseUpEv );
	
	
	
	[pool release];
	return 0;	
	
}
@end
