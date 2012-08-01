//
//  Sprite.h
//  MapEditor
//
//  Created by graham on 4/29/11.
//  Copyright 2011 Rocket Mobile, Inc. All rights reserved.
//

#import "PropObj.h"

@interface Sprite : PropObj 
{
	NSPoint position;
}

- (id)initWithImageData:(NSData *)imageData;
- (void)setPosition:(NSPoint)p;
- (NSRect)frame;

@property(readonly, assign, nonatomic) NSPoint position;

@end
