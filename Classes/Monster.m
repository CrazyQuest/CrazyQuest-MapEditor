//
//  Monster.m
//  MapEditor
//
//  Created by graham on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Monster.h"
#import "Utils.h"

@implementation Monster

- (id)init
{
	NSMutableDictionary *initialProperties = [NSMutableDictionary dictionary];
	
	// When first creating a new room, assign it a GUID
	[initialProperties setObject:[Utils newGUID] forKey:@"GUID"];
	
	[initialProperties setObject:@"Unknown" forKey:@"name"];
	[initialProperties setObject:@"Nothing interesting..." forKey:@"description"];
	[initialProperties setObject:[NSNumber numberWithInt:1] forKey:@"str"];
	[initialProperties setObject:[NSNumber numberWithInt:1] forKey:@"dex"];
	[initialProperties setObject:[NSNumber numberWithInt:1] forKey:@"int"];
	[initialProperties setObject:[NSNumber numberWithInt:1] forKey:@"sta"];
	[initialProperties setObject:[NSNumber numberWithInt:1] forKey:@"level"];
	[initialProperties setObject:[NSNumber numberWithInt:1] forKey:@"ac"];
	[initialProperties setObject:[NSNumber numberWithInt:100] forKey:@"spawn_percentage"];
	[initialProperties setObject:[NSNumber numberWithInt:ALIGNMENT_NEUTRAL] forKey:@"alignment"];
	[initialProperties setObject:[NSNumber numberWithBool:NO] forKey:@"aggro"];
	[initialProperties setObject:[NSNumber numberWithBool:NO] forKey:@"no_attack"];
	[initialProperties setObject:[NSMutableArray array] forKey:@"equipment"];
	[initialProperties setObject:[NSMutableArray array] forKey:@"loot"];
	[initialProperties setObject:[NSNumber numberWithInt:45] forKey:@"spawn_timer"];

	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"noimage" ofType:@"jpg"];	
	[initialProperties setObject:[NSData dataWithContentsOfFile:filePath] forKey:@"imageData"];

	[initialProperties setObject:[NSMutableArray array] forKey:@"dialogs"];
		
	return [self initWithProperties:initialProperties];
}

- (id)initWithProperties:(NSDictionary *)properties
{
	self = [super initWithProperties:properties];
	
	if(![self getProperty:@"dialogs"])
	{
		[self setProperty:[NSMutableArray array] forKey:@"dialogs"];
	}
	
	if(![self getProperty:@"properties"])
	{
		[self setProperty:[NSMutableDictionary dictionary] forKey:@"properties"];
	}
	
	return self;
}


- (void)setImageData:(NSData *)data
{
	[self setProperty:data forKey:@"imageData"];
}	

- (void)modified
{
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MONSTER_CHANGED object:nil userInfo:nil];	
}

@end
