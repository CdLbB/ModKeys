//
//  BitCalculations.m
//  ModKeys
//
//  Created by Eric Nitardy on 12/1/10.
//  Copyright 2010 University of Washington. All rights reserved.
//

#import "BitCalculations.h"


@implementation BitCalculations

+(int) orBitsOf: (NSInteger) first with: (NSInteger) second {
	int oredResult = (first | second);
	return oredResult;
}

+(int) andBitsOf: (NSInteger) first with: (NSInteger) second {
	int andedResult = (first & second);
	return andedResult;
}

+(int) xorBitsOf: (NSInteger) first with: (NSInteger) second {
	int xoredResult = (first ^ second);
	return xoredResult;
}

+(int) deleteBitsOf: (NSInteger) first using: (NSInteger) second {
	int deletedResult = (first &  (~second));
	return deletedResult;
}

+(int) invertBitsOf: (NSInteger) first using: (NSInteger) second {
	int invertedResult = (first & ~second) | (~first & second);
	return invertedResult;
}
	
@end
