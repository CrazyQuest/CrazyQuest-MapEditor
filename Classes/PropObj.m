//
//  PropObj.m
//  MapEditor
//
//  Created by graham on 12/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PropObj.h"


@implementation PropObj

- (id)init
{
	return [self initWithProperties:[NSMutableDictionary dictionary]];;
}

- (id)initWithProperties:(NSDictionary *)properties
{
	self = [super init];
	
	[self setProperties:properties];
	
	return self;
}

- (void)dealloc
{
	[_properties release];
	[super dealloc];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@ properties:\n%@", [super description], [self getProperties]];
}

- (void)setProperties:(NSDictionary *)properties
{
	if(!_properties)
	{
		_properties = [[NSMutableDictionary dictionary] retain];
	}

	[_properties removeAllObjects];
	for(NSString *key in properties)
	{
		[_properties setObject:[properties objectForKey:key] forKey:key];
	}
	
	[self modified];
}

- (void)setProperty:(id)property forKey:(NSString *)key
{
	[_properties setObject:property forKey:key];
	[self modified];
}

- (void)removePropertyForKey:(NSString *)key
{
	[_properties removeObjectForKey:key];
	[self modified];
}

- (NSDictionary *)getProperties
{
	return [NSDictionary dictionaryWithDictionary:_properties];
}

- (id)getProperty:(NSString *)propName
{
	return [_properties objectForKey:propName];
}


- (void)modified
{
	NSAssert(0, @"You must override this method");
}

/**
 * NSCoding protocol
 **/
- (void)encodeWithCoder:(NSCoder *)encoder
{
//	NSLog(@"encoding %@", [self className]);
//	NSLog(@"properties: %@", _properties);
	[encoder encodeObject:_properties forKey:@"properties"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	return [self initWithProperties:[decoder decodeObjectForKey:@"properties"]];
}

@end
