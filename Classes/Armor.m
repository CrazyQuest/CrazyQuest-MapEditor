//
//  Armor.m
//  MapEditor
//
//  Created by graham on 1/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Armor.h"


@implementation Armor

- (id)init
{
	self = [super init];

	[self setProperty:[NSNumber numberWithInt:1] forKey:@"ac"];	
	[self setProperty:@"cloth" forKey:@"skill"];
	[self setProperty:@"body" forKey:@"slot"];
	[self setProperty:@"a" forKey:@"type"];

	return self;
}

@end
