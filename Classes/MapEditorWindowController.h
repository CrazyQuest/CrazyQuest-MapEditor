//
//  MapEditorWindowController.h
//  medit
//
//  Created by graham on 12/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RoomView.h"
#import "SpriteView.h"
#import "Map.h"
#import "MyWindowController.h"

@interface MapEditorWindowController : MyWindowController <RoomViewDelegate, SpriteViewDelegate> {
	IBOutlet NSView *mapView;
    IBOutlet NSImageView *mapImage;
	
	Map *_map;
	
	NSMutableArray *roomViews;
	NSMutableArray *spriteViews;
	NSMutableArray *roomConnectionViews;
}

- (IBAction)importMapImage:(id)sender;
- (IBAction)importSprite:(id)sender;
- (IBAction)addNewRoom:(id)sender;
- (IBAction)removeSelected:(id)sender;
- (IBAction)fixCoordinates:(id)sender;

@end
