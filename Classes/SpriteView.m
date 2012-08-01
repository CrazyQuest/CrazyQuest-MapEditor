//
//  SpriteView.m
//  MapEditor
//
//  Created by graham on 4/29/11.
//  Copyright 2011 Rocket Mobile, Inc. All rights reserved.
//

#import "SpriteView.h"
#import "UnselectableImageView.h"


@interface SpriteView (Private)
- (void)setPosition:(NSPoint)pos;
- (void)draggingToPoint:(NSPoint)point;
- (void)handleDrag;
@end

@implementation SpriteView

@synthesize delegate;
@synthesize position;
@synthesize sprite;

/**
 * Initializers
 **/
- (id)initWithSprite:(Sprite *)aSprite selected:(BOOL)selected
{

	self = [super initWithFrame:[aSprite frame]];

	// Bind the Room object to this RoomView
	[self setSprite:aSprite];

	[self setPosition:[aSprite position]];
	

	NSData *imageData = [sprite getProperty:@"imageData"];
	
	NSImage *image = [[[NSImage alloc] initWithData:imageData] autorelease];
	
	spriteIcon = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, [sprite frame].size.width, [sprite frame].size.height)];
	[spriteIcon setImage:image];
	
	[self setSelected:selected];
	
	[self addSubview:spriteIcon];
	
	// Create the subviews and add them
	
	return self;	
}

- (void)dealloc
{
	[spriteIcon release];
	[sprite release];
	[super dealloc];
}

- (void)setPosition:(NSPoint)pos
{
	NSLog(@"setPosition called with : %f, %f", pos.x, pos.y);
	position = pos;
	
	// Center the sprite icon on our position
	NSRect frame = [self frame];
	frame.origin.x = position.x;
	frame.origin.y = position.y;
	[self setFrame:frame];
}

- (void)setSelected:(BOOL)selected
{
	NSLog(@"SpriteView selected");
}

/**
 * Overloaded methods
 */
- (void)mouseDown:(NSEvent *)theEvent {
	[delegate onSpriteSelected:self];
	
	[self handleDrag];
	
    return;
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
	
	//	NSLog(@"Previous: %@ %f, %f", sprite, [sprite getPosition].x, [sprite getPosition].y);
	//	NSLog(@"Position: %f, %f", position.x, position.y);
	
	[delegate onSpriteMoved:self toPoint:position];
}

- (void)draggingToPoint:(NSPoint)point
{	
	NSRect parentFrame = [[self superview] frame];
	
/*
	if(NSPointInRect(point, parentFrame))
	{
		return;
	}
*/
	[self setPosition:point];
	
	// Notify all listeners that a sprite is being dragged
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SPRITE_DRAGGING object:nil userInfo:nil];	
}

@end
