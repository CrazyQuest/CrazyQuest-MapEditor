//
//  Weapon.m
//  MapEditor
//
//  Created by graham on 1/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Weapon.h"


@implementation Weapon

- (id)init
{
	self = [super init];

	[self setProperty:@"knife/dagger" forKey:@"skill"];
	[self setProperty:@"1D4" forKey:@"damage"];
	[self setProperty:@"physical" forKey:@"damage_type"];
	[self setProperty:@"w" forKey:@"type"];
	[self setProperty:@"hand" forKey:@"slot"];

	return self;
}

@end
