//
//  RoomViewConnection.m
//  medit
//
//  Created by graham on 12/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RoomViewConnection.h"

@interface RoomViewConnection (Private)
- (void)adjustFrame;
@end

@implementation RoomViewConnection

@synthesize originRoom;
@synthesize targetRoom;

/**
 * Initializers
 **/
- (id)initWithOrigin:(RoomView *)r1 withTarget:(RoomView *)r2
{
	self = [super init];

	originRoom = r1;
	targetRoom = r2;
	target = [targetRoom position];
	
	[self adjustFrame];
		
	// Listen for when the map changes
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRoomDragged:) name:NOTIFICATION_ROOM_DRAGGING object:nil];
	
	return self;
}

/**
 * Overloaded methods
 **/
- (void)drawRect:(NSRect)rect
{   
	NSBezierPath* path = [NSBezierPath bezierPath];	
	
	[path setLineWidth:2];
	NSPoint localTarget = [[self superview] convertPoint:target toView:self];
	NSPoint localOrigin = [[self superview] convertPoint:[originRoom position] toView:self];
	
	[path moveToPoint:localOrigin];
	[path lineToPoint:localTarget];
	[path closePath];
	
	[[NSColor blackColor] set];
	[path stroke];
}

- (NSView *)hitTest:(NSPoint)aPoint
{
	return nil;
}


/**
 * Notification handlers
 **/
- (void)onRoomDragged:(NSNotification *)inNotification 
{	
	target = [targetRoom position];
	[self adjustFrame];
	[self setNeedsDisplay:YES];
}

/**
 * Public methods
 **/
- (void)setTarget:(NSPoint)point
{
	target = point;
	targetRoom = nil;
	[self adjustFrame];
}

- (void)setTargetRoomView:(RoomView *)room
{
	target = [room position];
	targetRoom = room;
	[self adjustFrame];
}

/**
 * Private methods
 **/
- (void)adjustFrame
{
	NSPoint origin = [originRoom position];
	
	CGFloat x = MIN(target.x, origin.x);
	CGFloat y = MIN(target.y, origin.y);
	CGFloat width = MAX(target.x, origin.x) - x;
	CGFloat height = MAX(target.y, origin.y) - y;
	
	[self setFrame:NSMakeRect(x, y, width, height)];	
}

@end
