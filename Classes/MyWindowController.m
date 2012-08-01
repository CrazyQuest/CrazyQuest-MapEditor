//
//  MyWindowController.m
//  MapEditor
//
//  Created by graham on 2/18/11.
//  Copyright 2011 Rocket Mobile, Inc. All rights reserved.
//

#import "MyWindowController.h"


@implementation MyWindowController

- (void)windowDidLoad
{
#if 0
	NSString *x_key = [NSString stringWithFormat:@"%@-x", [[self class] description]];
	NSString *y_key = [NSString stringWithFormat:@"%@-y", [[self class] description]];
	float x, y;
	
	x = [[NSUserDefaults standardUserDefaults] floatForKey:x_key];
	y = [[NSUserDefaults standardUserDefaults] floatForKey:y_key];
	
	NSLog(@"windowDidLoad - %@", [[self class] description]);
	NSLog(@"x, y = (%f,%f)",x,y); 
	
	NSRect frame = [[self window] frame];
	NSLog(@"window frame: x,y,dx,dy = (%f,%f,%f,%f)", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
	
	if(x != 0 && y != 0)
	{
		NSPoint point;
		point.x = x;
		point.y = y;

		[[self window] setFrameOrigin:point];				
	}
	else 
	{
		NSPoint origin = [[self window] frame].origin;
		[[NSUserDefaults standardUserDefaults] setFloat:origin.x forKey:x_key];
		[[NSUserDefaults standardUserDefaults] setFloat:origin.y forKey:y_key];
	}
	
#endif //0

}
@end
