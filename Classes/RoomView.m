//
//  RoomView.m
//  medit
//
//  Created by graham on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RoomView.h"
#import "RoomViewConnection.h"
#import "Utils.h"

@interface RoomView (Private)
- (void)setPosition:(NSPoint)pos;
- (void)draggingToPoint:(NSPoint)point;
- (void)handleDrag;
- (void)handleConnection:(BOOL)add;
@end

@implementation RoomView

@synthesize room;
@synthesize delegate;
@synthesize position;

/**
 * Initializers
 **/
- (id)initWithRoom:(Room *)aRoom selected:(BOOL)selected
{
	self = [super initWithFrame:NSMakeRect(0, 0, ROOMICON_SIDE_LENGTH, ROOMICON_SIDE_LENGTH)];

	[self setPosition:[aRoom getPosition]];
	
	// Bind the Room object to this RoomView
	[self setRoom:aRoom];

	roomIcon = [[UnselectableImageView alloc] initWithFrame:NSMakeRect(0, 0, ROOMICON_SIDE_LENGTH, ROOMICON_SIDE_LENGTH)];	
	[self setSelected:selected];
	
	[self addSubview:roomIcon];

	// Create the subviews and add them
	
	return self;	
}

- (void)dealloc
{
	[roomIcon release];
	[room release];
	[super dealloc];
}

/**
 * Overloaded methods
 */
- (void)mouseDown:(NSEvent *)theEvent {
	[delegate onRoomViewSelected:self];
	
	if (([theEvent modifierFlags] & NSCommandKeyMask) &&
		([theEvent modifierFlags] & NSShiftKeyMask))
	{
		[self handleConnection:NO];
	}
	else if ([theEvent modifierFlags] & NSCommandKeyMask)
	{
		[self handleConnection:YES];
	}
	else
	{
		[self handleDrag];
	}
	
    return;
}

/**
 * Public methods
 **/

- (void)setPosition:(NSPoint)pos
{
	position = pos;
	
	// Center the room icon on our position
	NSRect frame = [self frame];
	frame.origin.x = position.x - (ROOMICON_SIDE_LENGTH/2);
	frame.origin.y = position.y - (ROOMICON_SIDE_LENGTH/2);
	[self setFrame:frame];
}

- (void)setSelected:(BOOL)selected
{
	NSString *imgName = [NSString stringWithFormat:@"room_image_%@%@", 
						 selected ? @"selected" : @"unselected",
						 [room getProperty:@"link"] ? @"_link" : @""];
	
	[roomIcon setImage:[Utils loadImageForResource:imgName ofType:@"png"]];
}


/**
 * Private methods
 **/
- (void)handleDrag
{
	NSLog(@"handleDrag called");
	
    BOOL keepOn = YES;
    NSPoint mouseLoc;
	
	while (keepOn) 
	{
		NSEvent *theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        mouseLoc = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];		
				
        switch ([theEvent type]) {
            case NSLeftMouseDragged:
				
				[self draggingToPoint:mouseLoc];
				
				break;
            case NSLeftMouseUp:
				keepOn = NO;
				break;
            default:
				NSLog(@"default event");
				/* Ignore any other kind of event. */
				break;
        }
    }
	
//	NSLog(@"Setting the room's position to current position of RoomView");
//	NSLog(@"Previous: %@ %f, %f", room, [room getPosition].x, [room getPosition].y);
//	NSLog(@"Position: %f, %f", position.x, position.y);
	
	[delegate onRoomMoved:self toPoint:position];
}

- (void)handleConnection:(BOOL)add
{
    BOOL keepOn = YES;
    NSPoint mouseLocRelativeToMap = {0, 0};
	
	// Add a new RoomConnection view to the superview
	RoomViewConnection *connection = [[RoomViewConnection alloc] initWithOrigin:self withTarget:nil];
	[[self superview] addSubview:connection];
		
	while (keepOn) 
	{
		NSEvent *theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        
		// Figure out the mouse location in MapView coordinates
		mouseLocRelativeToMap = [[[self window] contentView] convertPoint:[theEvent locationInWindow] toView:[self superview]];		
				
		// Find the view under the current mouse location
		id view = [[[self window] contentView] hitTest:[theEvent locationInWindow]];

		RoomView *roomHit = nil;

		// Was it a room?
		if([view class] == [RoomView class])
		{
			roomHit = view;
		}
		
        switch ([theEvent type]) {
            case NSLeftMouseDragged:
				
				if(roomHit)
				{
					[connection setTargetRoomView:roomHit];
				}
				else
				{
					[connection setTarget:mouseLocRelativeToMap];
				}

				// Set the connection's target to the current mouse location
				[connection setNeedsDisplay:YES];

				break;
            case NSLeftMouseUp:
			{
				if(roomHit)
				{
					if(add)
					{
						NSLog(@"Connecting rooms");
						[delegate connectRoom:self toRoom:roomHit];
					}
					else 
					{
						NSLog(@"Disconnecting rooms");
						[delegate disconnectRoom:self fromRoom:roomHit];
					}

				}
				keepOn = NO;
			}
				break;
            default:
				/* Ignore any other kind of event. */
				break;
        }
    }
	
	// Remove the connection view
	[connection removeFromSuperview];
}

- (void)draggingToPoint:(NSPoint)point
{	
	NSRect parentFrame = [[self superview] frame];
	
	if(!NSPointInRect(point, parentFrame))
	{
		return;
	}

	[self setPosition:point];

	// Notify all listeners that a room is being dragged
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ROOM_DRAGGING object:nil userInfo:nil];	
}

@end