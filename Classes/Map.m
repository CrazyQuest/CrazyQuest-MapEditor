//
//  Map.m
//  MapEditor
//
//  Created by graham on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Map.h"
#import "Utils.h"
#import "Monster.h"

@interface Map (Private)
- (void)modified;
- (BOOL)connectionExists:(Connection *)connection;
- (Room *)findRoomWithGUID:(NSString *)guid;
@end

@implementation Map

/**
 * Initializers/destructors
 **/
- (id)init
{
	NSMutableDictionary *props = [[NSMutableDictionary alloc] init];
	[props setObject:[Utils newGUID] forKey:@"GUID"];
	[props setObject:[NSNumber numberWithFloat:20] forKey:@"player_width"];
	[props setObject:[NSNumber numberWithFloat:20] forKey:@"player_height"];
	[props setObject:[NSNumber numberWithFloat:1] forKey:@"zoom_factor"];
	[props setObject:[NSNumber numberWithFloat:1] forKey:@"player_walk_speed"];
	
	[props setObject:[NSMutableArray array] forKey:@"rooms"];
	[props setObject:[NSMutableArray array] forKey:@"connections"];
	
	NSMutableDictionary *items = [NSMutableDictionary dictionary];
	[items setObject:[NSMutableArray array] forKey:@"weapons"];
	[items setObject:[NSMutableArray array] forKey:@"armor"];
	[items setObject:[NSMutableArray array] forKey:@"items"];
	[props setObject:items forKey:@"items"];
	[props setObject:[NSNumber numberWithBool:NO] forKey:@"is_dark"];

	[props setObject:[NSMutableArray array] forKey:@"sprites"];
	
	return [self initWithProperties:props];
}

/**
 * Instance methods
 **/
- (void)setImageData:(NSData *)data
{
	[self setProperty:data forKey:@"imageData"];

	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAP_IMAGE_CHANGED object:nil userInfo:nil];	
}

- (void)addRoom:(Room *)room andConnections:(NSMutableArray *)newConnections
{
	// Modify the rooms array
	[[self getProperty:@"rooms"] addObject:room];

	// Modify the connections array
	for(Connection *connection in newConnections)
	{
		[[self getProperty:@"connections"] addObject:connection];
	}

	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ROOM_ADDED object:nil userInfo:nil];	

	[self modified];
}

// Returns the connections that were deleted by removing this room
- (NSMutableArray *)removeRoom:(Room *)room
{
	NSString *guid = [room getProperty:@"GUID"];

	// Remove the room
	[[self getProperty:@"rooms"] removeObjectIdenticalTo:room];

	// Remove the connections to that room
	NSMutableArray *connections = [self getProperty:@"connections"];
	NSMutableArray *connectionsToDelete = [[NSMutableArray alloc] init];
	for(Connection *c in connections)
	{
		if([c appliesTo:guid])
			[connectionsToDelete addObject:c];
	}
	for(Connection *c in connectionsToDelete)
	{
		[connections removeObjectIdenticalTo:c];
	}
	[self setProperty:connections forKey:@"connections"];

	// If we deleted the selected room, mark no rooms as selected
	if(room == selectedMapObject)
	{
		selectedMapObject = nil;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ROOM_REMOVED object:nil userInfo:nil];	

	[self modified];
	
	return connectionsToDelete;
}

- (void)addSprite:(Sprite *)sprite
{
	NSMutableArray *spriteArray = [self getProperty:@"sprites"];
	if(!spriteArray)
	{
		[self setProperty:[NSMutableArray array] forKey:@"sprites"];
		spriteArray = [self getProperty:@"sprites"];
	}
	
	[spriteArray addObject:sprite];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SPRITE_ADDED object:nil userInfo:nil];		
	[self modified];	
}

- (void)removeSprite:(Sprite *)sprite
{
	NSMutableArray *spriteArray = [self getProperty:@"sprites"];
	[spriteArray removeObject:sprite];

	if(sprite == selectedMapObject)
	{
		selectedMapObject = nil;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SPRITE_REMOVED object:nil userInfo:nil];		
	[self modified];	
}


- (void)setSelection:(id)obj
{
	selectedMapObject = obj;

	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_SELECTION_CHANGED object:nil userInfo:nil];	
}

- (void)addConnection:(Connection *)connection
{
	if([self connectionExists:connection])
		return;
	
	// Modify the connections array
	[[self getProperty:@"connections"] addObject:connection];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ROOM_CONNECTED object:nil userInfo:nil];	
}

- (void)removeConnection:(Connection *)connection
{
	if(![self connectionExists:connection])
		return;
	
	NSMutableArray *connections = [NSMutableArray arrayWithArray:[self getProperty:@"connections"]];
	[connections removeObject:connection];
	[self setProperty:connections forKey:@"connections"];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ROOM_DISCONNECTED object:nil userInfo:nil];	
}

- (NSImage *)getImage
{
	return [[[NSImage alloc] initWithData:[self getProperty:@"imageData"]] autorelease];
}

- (Room *)getSelectedRoom
{
	if([selectedMapObject isKindOfClass:[Room class]])
	{
		return (Room *)selectedMapObject;
	}
	
	return nil;
}

- (Sprite *)getSelectedSprite
{
	if([selectedMapObject isKindOfClass:[Sprite class]])
	{
		return (Sprite *)selectedMapObject;
	}
	
	return nil;
}

- (NSString *)getSelectedRoomGUID
{
	Room *selectedRoom = [self getSelectedRoom];
	if(selectedRoom)
	{
		NSString *guid = [selectedRoom getProperty:@"GUID"];
		if(guid)
		{
			return [NSString stringWithString:guid];
		}
	}
	
	return nil;
}



/**
 * Private methods
 **/
- (void)cleanupDeadConnections
{
	NSArray *connections = [NSArray arrayWithArray:[self getProperty:@"connections"]];
	NSArray *rooms = [NSArray arrayWithArray:[self getProperty:@"rooms"]];
    for(Connection *c in connections)
	{
        bool connectionIsGood = NO;
        for(Room *r in rooms)
        {
            NSString *guid = [r getProperty:@"GUID"];

            if([c appliesTo:guid])
                connectionIsGood = YES;
        }
        
        if(!connectionIsGood)
        {
            NSLog(@"Connection %@ is NOT attached to anything!!!", c);
        }
    }
}

- (void)modified
{
    [self cleanupDeadConnections];
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MAP_CHANGED object:nil userInfo:nil];	
}

- (BOOL)connectionExists:(Connection *)connection
{
	NSArray *connections = [NSArray arrayWithArray:[self getProperty:@"connections"]];
	for(Connection *c in connections)
	{
		if([c isEqual:connection])
			return YES;
	}
	
	return NO;
}

- (Room *)findRoomWithGUID:(NSString *)guid
{
	NSArray *rooms = [NSArray arrayWithArray:[self getProperty:@"rooms"]];
	for(Room *room in rooms)
	{
		NSString *roomGUID = [room getProperty:@"GUID"];
		if([roomGUID compare:guid] == NSOrderedSame)
		{
			return room;
		}
	}
	
	return nil;
}

@end
