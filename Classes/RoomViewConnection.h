//
//  RoomViewConnection.h
//  medit
//
//  Created by graham on 12/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RoomView.h"

@interface RoomViewConnection : NSView {
	RoomView *originRoom;
	RoomView *targetRoom;
	NSPoint target;
}

- (id)initWithOrigin:(RoomView *)r1 withTarget:(RoomView *)r2;
- (void)setTarget:(NSPoint)point;
- (void)setTargetRoomView:(RoomView *)room;

@property (readonly, assign) RoomView *originRoom;
@property (readonly, assign) RoomView *targetRoom;

@end
