//
//  Room.m
//  MapEditor
//
//  Created by graham on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Room.h"
#import "XPathQuery.h"
#import "Utils.h"

@implementation Room

/**
 * Initializers/destructors
 **/
- (id)init
{
	NSMutableDictionary *initialProperties = [NSMutableDictionary dictionary];

	// When first creating a new room, assign it a GUID
	[initialProperties setObject:[Utils newGUID] forKey:@"GUID"];
	[initialProperties setObject:[NSMutableArray array] forKey:@"monsters"];
	[initialProperties setObject:[NSMutableArray array] forKey:@"descriptions"];
	[initialProperties setObject:[NSMutableArray array] forKey:@"constants"];
	
	return [self initWithProperties:initialProperties withPosition:NSMakePoint(20,20)];
}

- (id)initWithProperties:(NSDictionary *)properties withPosition:(NSPoint)position
{
	self = [super initWithProperties:properties];
	
	[self setPosition:position];
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

/**
 * Instance methods
 **/
- (void)setPosition:(NSPoint)position
{
	_position = position;
	[self modified];
}

- (NSPoint)getPosition
{
	return _position;
}

- (void)modified
{
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ROOM_CHANGED object:nil userInfo:nil];	
}

/**
 * NSCoding protocol
 **/
- (void)encodeWithCoder:(NSCoder *)encoder
{
	[super encodeWithCoder:encoder];
	
	[encoder encodePoint:_position forKey:@"position"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	_position = [decoder decodePointForKey:@"position"];
	return self;
}



@end
