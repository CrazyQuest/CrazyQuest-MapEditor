//
//  MapDocument.h
//  medit
//
//  Created by graham on 12/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Map.h"

@interface MapDocument : NSDocument {
	Map *map;
	NSWindowController *_editorWindow;
	NSWindowController *_roomPropertiesWindow;
	NSWindowController *_roomDescriptionsWindow;
	NSWindowController *_mapPropertiesWindow;
	NSWindowController *_monstersWindow;
	NSWindowController *_itemsWindow;
}

@property (readonly, assign) Map *map;

- (IBAction)displayMapPropertiesWindow:(id)sender;
- (IBAction)displayRoomPropertiesWindow:(id)sender;
- (IBAction)displayRoomDescriptionsWindow:(id)sender;
- (IBAction)displayMonstersWindow:(id)sender;
- (IBAction)displayItemsWindow:(id)sender;

@end
