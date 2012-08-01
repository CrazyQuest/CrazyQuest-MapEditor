//
//  Item.m
//  MapEditor
//
//  Created by graham on 1/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "Utils.h"

@implementation Item

- (id)init
{
	NSMutableDictionary *initialProperties = [NSMutableDictionary dictionary];
	
	// When first creating a new room, assign it a GUID
	[initialProperties setObject:[Utils newGUID] forKey:@"GUID"];
	
	[initialProperties setObject:@"Unknown" forKey:@"name"];
	[initialProperties setObject:@"Nothing interesting..." forKey:@"description"];
	[initialProperties setObject:[NSNumber numberWithInt:1] forKey:@"weight"];
	[initialProperties setObject:[NSNumber numberWithInt:1] forKey:@"value"];
	[initialProperties setObject:[NSNumber numberWithInt:100] forKey:@"drop_percentage"];
	[initialProperties setObject:@"i" forKey:@"type"];

	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"noimage" ofType:@"jpg"];	
	[initialProperties setObject:[NSData dataWithContentsOfFile:filePath] forKey:@"imageData"];
	
	[initialProperties setObject:[NSMutableArray array] forKey:@"constants"];

	return [self initWithProperties:initialProperties];
}

- (void)setImageData:(NSData *)data
{
	[self setProperty:data forKey:@"imageData"];
}	

- (void)modified
{
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ITEM_CHANGED object:nil userInfo:nil];	
}

@end
