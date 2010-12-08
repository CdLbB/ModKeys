//
//  MyNSEvent.h
//  ModKeys
//
//  Created by Eric Nitardy on 12/3/10.
//  Copyright 2010 University of Washington. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyNSEvent : NSEvent 

+(int) clickAtLocation: (NSPoint) pt;

@end
