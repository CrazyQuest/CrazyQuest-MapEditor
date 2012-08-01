//
//  Utils.m
//  medit
//
//  Created by graham on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (void)displayError:(NSString *)errorString
{
	NSError *error = [NSError errorWithDomain:errorString code:0 userInfo:nil];
	NSAlert *alert = [NSAlert alertWithError:error];
	[alert runModal];
}

+ (NSImage *)loadImageForResource:(NSString *)resource ofType:(NSString *)type
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:resource ofType:type];	
	return [[[NSImage alloc] initWithContentsOfFile:filePath] autorelease];
}

+ (NSString *)newGUID
{
	NSUInteger num = rand();
	
	return [NSString stringWithFormat:@"%d", num];
}

+ (NSRect)getImageRect:(NSImage *)img
{
	NSImageRep *rep = [[img representations] objectAtIndex:0];
	
	return NSMakeRect(0, 0, [rep pixelsWide], [rep pixelsHigh]);		
}

@end
