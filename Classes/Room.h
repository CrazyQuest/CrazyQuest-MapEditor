//
//  Room.h
//  MapEditor
//
//  Created by graham on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PropObj.h"

@interface Room : PropObj {
	NSPoint _position;
}

- (id)initWithProperties:(NSDictionary *)initialProperties withPosition:(NSPoint)position;

- (void)setPosition:(NSPoint)position;
- (NSPoint)getPosition;

@end
