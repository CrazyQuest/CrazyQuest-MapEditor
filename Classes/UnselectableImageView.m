//
//  UnselectableImageView.m
//  medit
//
//  Created by graham on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "UnselectableImageView.h"


@implementation UnselectableImageView

/**
 * Overloaded methods
 **/
- (NSView *)hitTest:(NSPoint)aPoint
{
	return nil;
}

@end
