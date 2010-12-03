//
//  BitCalculations.h
//  ModKeys
//
//  Created by Eric Nitardy on 12/1/10.
//  Copyright 2010 University of Washington. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface BitCalculations : NSObject 

+(int) orBitsOf: (NSInteger) first with: (NSInteger) second;

+(int) andBitsOf: (NSInteger) first with: (NSInteger) second;

+(int) xorBitsOf: (NSInteger) first with: (NSInteger) second;

+(int) deleteBitsOf: (NSInteger) first from: (NSInteger) second;

@end
