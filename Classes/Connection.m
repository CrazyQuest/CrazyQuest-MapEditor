//
//  Connection.m
//  MapEditor
//
//  Created by graham on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Connection.h"
#import "Utils.h"

@implementation Connection

- (id)initWithBegin:(NSString *)beginGUID toEnd:(NSString *)endGUID
{
	self = [super init];
	
	[self setProperty:[Utils newGUID] forKey:@"GUID"];
	[self setProperty:beginGUID forKey:@"begin"];
	[self setProperty:endGUID forKey:@"end"];
	
	return self;
}

/**
 * Public methods
 **/

- (BOOL)isEqual:(id)object
{
	if([object class] == [Connection class])
	{
		Connection *otherConnection = object;
		
		if(
		   (
				[[otherConnection getProperty:@"begin"] isEqual:[self getProperty:@"begin"]] &&
				[[otherConnection getProperty:@"end"] isEqual:[self getProperty:@"end"]]
		   ) 
		   ||
		   (
			[[otherConnection getProperty:@"begin"] isEqual:[self getProperty:@"end"]] &&
			[[otherConnection getProperty:@"end"] isEqual:[self getProperty:@"begin"]]
			)
		   )
		{
			return YES;
		}
	}
	return NO;
}

- (BOOL)appliesTo:(NSString *)guid
{
	return [[self getBegin] isEqual:guid] || [[self getEnd] isEqual:guid];
}

- (NSString *)getBegin
{
	return [self getProperty:@"begin"];
}

- (NSString *)getEnd
{
	return [self getProperty:@"end"];
}

- (void)modified
{
}

@end
