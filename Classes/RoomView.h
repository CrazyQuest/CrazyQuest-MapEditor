//
//  RoomView.h
//  medit
//
//  Created by graham on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UnselectableImageView.h"
#import "Room.h"

@class RoomView;
@protocol RoomViewDelegate
- (void)onRoomViewSelected:(RoomView *)roomView;
- (void)onRoomMoved:(RoomView *)roomView toPoint:(NSPoint)point;
- (void)connectRoom:(RoomView *)origin toRoom:(RoomView *)destination;
- (void)disconnectRoom:(RoomView *)room1 fromRoom:(RoomView *)room2;
@end

@interface RoomView : NSView {
	Room *room;
	id<RoomViewDelegate> delegate;
	NSPoint position;
	NSImageView *roomIcon;
}

- (id)initWithRoom:(Room *)aRoom selected:(BOOL)selected;
- (void)setSelected:(BOOL)selected;

@property (readwrite, retain) Room *room;
@property (readwrite, assign) id<RoomViewDelegate> delegate;
@property (readonly, assign) NSPoint position;

@end
