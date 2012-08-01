//
//  Map.h
//  MapEditor
//
//  Created by graham on 12/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PropObj.h"
#import "Room.h"
#import "Connection.h"
#import "Sprite.h"

@protocol MapDelegate
- (void)mapChanged;
@end

@interface Map : PropObj {
	id selectedMapObject;
}

- (void)setImageData:(NSData *)data;
- (void)addRoom:(Room *)room andConnections:(NSMutableArray *)newConnections;
- (NSMutableArray *)removeRoom:(Room *)room;
- (void)addConnection:(Connection *)connection;
- (void)removeConnection:(Connection *)connection;

- (void)addSprite:(Sprite *)sprite;
- (void)removeSprite:(Sprite *)sprite;

- (void)setSelection:(id)obj;


- (Room *)getSelectedRoom;
- (NSString *)getSelectedRoomGUID;

- (Sprite *)getSelectedSprite;

- (NSImage *)getImage;

@end
