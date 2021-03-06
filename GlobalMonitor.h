//
//  GlobalMonitor.h
//  ModKeys
//
//  Created by Eric Nitardy on 12/2/10.
//  Copyright 2010 University of Washington. All rights reserved.
//

#import <Cocoa/Cocoa.h>

static id myNextMonitor;
@interface GlobalMonitor : NSObject 

+(id) monitorEvery: (NSEventMask) eventMask performSelector: (SEL) aSelector target: (id) target;

+(id) monitorNext: (NSEventMask) eventMask performSelector: (SEL) aSelector target: (id) target;

+(void) removeMonitor: (id) monitor;

@end
