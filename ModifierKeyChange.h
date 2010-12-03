//
//  ModifierKeyChange.h
//  ModKeys
//
//  Created by Eric Nitardy on 12/1/10.
//  Copyright 2010 University of Washington. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ModifierKeyChange : NSObject 

+(void) changeKey: (CGKeyCode) key state: (bool) state;

@end
