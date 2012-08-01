//
//  Sprite.m
//  MapEditor
//
//  Created by graham on 4/29/11.
//  Copyright 2011 Rocket Mobile, Inc. All rights reserved.
//

#import "Sprite.h"
#import "Utils.h"

@implementation Sprite

@synthesize position;

- (id)initWithImageData:(NSData *)imageData
{
	self = [super init];
	
	// Only loading the image here ot retrieve the width/height and other relevant data
	NSImage *img = [[[NSImage alloc] initWithData:imageData] autorelease];

	[self setProperty:[Utils newGUID] forKey:@"GUID"];
	[self setProperty:[NSNumber numberWithFloat:[img size].width] forKey:@"width"];
	[self setProperty:[NSNumber numberWithFloat:[img size].height] forKey:@"height"];
	[self setProperty:imageData forKey:@"imageData"];
	
	return self;
}

- (void)setPosition:(NSPoint)p
{
	position = p;
	[self modified];
}

- (NSRect)frame
{
	NSRect f;
	f.origin.x = position.x;
	f.origin.y = position.y;
	f.size.width = [[self getProperty:@"width"] floatValue];
	f.size.height = [[self getProperty:@"height"] floatValue];
	
	return f;
}

- (void)modified
{
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SPRITE_CHANGED object:nil userInfo:nil];	
}

/**
 * NSCoding protocol
 **/
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodePoint:position forKey:@"position"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	position = [decoder decodePointForKey:@"position"];

	return self;
}

@end
