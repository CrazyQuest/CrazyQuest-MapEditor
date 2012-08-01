//
//  MapEditorWindowController.m
//  medit
//
//  Created by graham on 12/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapEditorWindowController.h"
#import "Utils.h"
#import "XPathQuery.h"
#import "MapDocumentOperations.h"
#import "RoomViewConnection.h"
#import "SpriteView.h"

@interface MapEditorWindowController (Private)
- (NSImage *)loadMapImageFromData:(NSData *)imageData;
- (Map *)getMap;
- (void)clearMapViews;
- (void)addMapViews;
- (RoomView *)findRoomViewWithGUID:(NSString *)roomGUID;
- (RoomView *)findRoomViewWithRoom:(Room *)room;

- (SpriteView *)findSpriteViewWithSprite:(Sprite *)sprite;
- (SpriteView *)findSpriteViewWithGUID:(NSString *)guid;

- (void)mapRedrawNeeded:(NSNotification *)notification;
- (void)onMapImageChanged:(NSNotification *)notification;
- (void)onRoomSelected:(NSNotification *)notification;

@end

@implementation MapEditorWindowController

/**
 * Initializers/destructors
 **/

- (id)initWithMap:(Map *)map
{
	NSLog(@"Loading map");
	
	self = [super initWithWindowNibName:@"MapEditorWindow"];
		
	_map = [map retain];
	roomViews = [[NSMutableArray alloc] init];
	roomConnectionViews = [[NSMutableArray alloc] init];
	spriteViews = [[NSMutableArray alloc] init];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapRedrawNeeded:) name:NOTIFICATION_ROOM_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapRedrawNeeded:) name:NOTIFICATION_MAP_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMapImageChanged:) name:NOTIFICATION_MAP_IMAGE_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSelectionChanged:) name:NOTIFICATION_SELECTION_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapRedrawNeeded:) name:NOTIFICATION_ROOM_CONNECTED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapRedrawNeeded:) name:NOTIFICATION_ROOM_DISCONNECTED object:nil];
		
	return self;
}

- (void)dealloc
{
	[_map release];
	[roomViews release];
	[roomConnectionViews release];
    [spriteViews release];
	[super dealloc];
}

/**
 * Overridden methods
 **/

- (void)windowDidLoad
{
	// Simulate a map change event to redraw the screen initially upon load
	[self mapRedrawNeeded:nil];
	[self onMapImageChanged:nil];
}

/**
 * Public methods
 **/
- (IBAction)importMapImage:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	// Only support PNG's and JPG's
	NSMutableArray *types = [NSMutableArray arrayWithCapacity:2];
	[types addObject:@"png"];
	[types addObject:@"jpg"];
	
	NSInteger result = [panel runModalForTypes:types];
	
	switch(result)
	{
		case NSOKButton:
			NSLog(@"Importing map image from path: %@", [panel filename]);
			break;
			
		case NSCancelButton:
		default:
			return;
	}
	
	NSData *imageData = [NSData dataWithContentsOfFile:[panel filename]];
	[(MapDocument *)[self document] doImportMapImage:imageData];
}

- (IBAction)importSprite:(id)sender 
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];

	// Get the current position of the mouse pointer relative to the map image
	NSPoint windowMouseLoc; 
    windowMouseLoc = [NSEvent mouseLocation]; //get current mouse position
	
	// Only support PNG's and JPG's
	NSMutableArray *types = [NSMutableArray arrayWithCapacity:2];
	[types addObject:@"png"];
	[types addObject:@"jpg"];
	
	NSInteger result = [panel runModalForTypes:types];
	
	switch(result)
	{
		case NSOKButton:
			NSLog(@"Importing map image from path: %@", [panel filename]);
			break;
			
		case NSCancelButton:
		default:
			return;
	}
	
	NSData *imageData = [NSData dataWithContentsOfFile:[panel filename]];
	Sprite *sprite = [[Sprite alloc] initWithImageData:imageData];
	
	NSPoint viewMouseLoc = [[mapView window] convertScreenToBase:windowMouseLoc];
	CGPoint mouseLoc = NSPointToCGPoint(viewMouseLoc);	
		
	CGRect viewRect = NSRectToCGRect([mapView frame]);
	if(CGRectContainsPoint(viewRect, mouseLoc))
	{	
		NSPoint p;
		p.x = mouseLoc.x;
		p.y = mouseLoc.y;
		
		[sprite setPosition:p];		
	}

	[(MapDocument *)[self document] doAddSprite:sprite];	
}


- (IBAction)addNewRoom:(id)sender {
	// Get the current position of the mouse pointer relative to the map image
	NSPoint windowMouseLoc; 
    windowMouseLoc = [NSEvent mouseLocation]; //get current mouse position
	NSPoint viewMouseLoc = [[mapView window] convertScreenToBase:windowMouseLoc];
	CGPoint mouseLoc = NSPointToCGPoint(viewMouseLoc);	
	NSMutableDictionary *addOperation = [NSMutableDictionary dictionary];

	Room *newRoom = [[Room alloc] init];
	
	CGRect viewRect = NSRectToCGRect([mapView frame]);
	if(CGRectContainsPoint(viewRect, mouseLoc))
	{	
		NSPoint p;
		p.x = mouseLoc.x;
		p.y = mouseLoc.y;
		[newRoom setPosition:p];
		[addOperation setObject:newRoom forKey:@"room"];
				
		[(MapDocument *)[self document] doAddRoom:addOperation];
	}
}

- (IBAction)removeSelected:(id)sender {
	// Don't allow removing the selected room if no room is selected
	if([_map getSelectedRoom])
	{
		[(MapDocument *)[self document] doRemoveRoom:[_map getSelectedRoom]];
		return;
	}
	else if([_map getSelectedSprite])
	{
		[(MapDocument *)[self document] doRemoveSprite:[_map getSelectedSprite]];
		return;
	}
	
	[Utils displayError:@"Nothing selected"];
	return;
}

- (IBAction)fixCoordinates:(id)sender
{
	NSSize mapSize = [[_map getImage] size];
	
	// Iterate over all rooms
	for(int i = 0; i < [roomViews count]; i++)
	{
		RoomView *roomView = [roomViews objectAtIndex:i];		
		NSPoint position = [roomView position];
				
		if( (position.x < 0 || position.x > mapSize.width) ||
		    (position.y < 0 || position.y > mapSize.height) )
		{
			NSLog(@"Found invisible room, adjusting to origin...");
			
			NSPoint origin;
			origin.x = 0;
			origin.y = 0;
			
			NSMutableDictionary *moveOperation = [NSMutableDictionary dictionary];
			[moveOperation setObject:[roomView room] forKey:@"room"];
			[moveOperation setObject:[NSValue valueWithPoint:origin] forKey:@"point"];
			
			[(MapDocument *)[self document] doMoveRoom:moveOperation];
		}
	}	
}


/**
 * RoomViewDelegate methods
 **/
- (void)onRoomViewSelected:(RoomView *)roomView
{
	[_map setSelection:[roomView room]];
}

- (void)connectRoom:(RoomView *)r1 toRoom:(RoomView *)r2
{
	NSString *beginGUID = [[r1 room] getProperty:@"GUID"];
	NSString *endGUID = [[r2 room] getProperty:@"GUID"];
	
	Connection *c = [[Connection alloc] initWithBegin:beginGUID toEnd:endGUID];

	[(MapDocument *)[self document] doAddConnection:c];
}

- (void)disconnectRoom:(RoomView *)room1 fromRoom:(RoomView *)room2;
{
	Connection *c = [[Connection alloc] initWithBegin:[[room1 room] getProperty:@"GUID"] toEnd:[[room2 room] getProperty:@"GUID"]];

	[(MapDocument *)[self document] doRemoveConnection:c];
}

- (void)onRoomMoved:(RoomView *)roomView toPoint:(NSPoint)point
{
	NSMutableDictionary *moveOperation = [NSMutableDictionary dictionary];
	[moveOperation setObject:[roomView room] forKey:@"room"];
	[moveOperation setObject:[NSValue valueWithPoint:point] forKey:@"point"];

	[(MapDocument *)[self document] doMoveRoom:moveOperation];
}

/**
 * SpriteViewDelegate methods
 **/
- (void)onSpriteSelected:(SpriteView *)spriteView
{
	[_map setSelection:[spriteView sprite]];
}

- (void)onSpriteMoved:(SpriteView *)spriteView toPoint:(NSPoint)point
{
	NSMutableDictionary *moveOperation = [NSMutableDictionary dictionary];
	[moveOperation setObject:[spriteView sprite] forKey:@"sprite"];
	[moveOperation setObject:[NSValue valueWithPoint:point] forKey:@"point"];
	
	[(MapDocument *)[self document] doMoveSprite:moveOperation];	
}


/**
 * Notification handler methods
 **/
- (void)mapRedrawNeeded:(NSNotification *)notification
{
	NSLog(@"mapRedrawNeeded");
	
	// Clear and then add the room views
	[self clearMapViews];
	[self addMapViews];
}

- (void)onMapImageChanged:(NSNotification *)notification
{
	NSLog(@"map image changed");
	if([_map getImage])
	{
		NSPoint origin = [[self window] frame].origin;
		NSSize imgSize = [Utils getImageRect:[_map getImage]].size;
		[[self window] setContentSize:imgSize];
		[[self window] setFrameOrigin:origin];
		
		// Set the map's background image
		[mapImage setImage:[_map getImage]];
	}
}	

- (void)onSelectionChanged:(NSNotification *)notification
{
	// Mark all rooms as unselected
	for(RoomView *roomView in roomViews)
	{
		[roomView setSelected:NO];
	}
	
	for(SpriteView *spriteView in spriteViews)
	{
		[spriteView setSelected:NO];
	}

	Room *selectedRoom = [_map getSelectedRoom];	
	if(selectedRoom)
	{
		// Mark the newly selected RoomView as selected
		[[self findRoomViewWithRoom:selectedRoom] setSelected:YES];
	}
	
	Sprite *selectedSprite = [_map getSelectedSprite];
	if(selectedSprite)
	{
		[[self findSpriteViewWithSprite:selectedSprite] setSelected:YES];
	}
}



/**
 * Private methods
 **/
- (Map *)getMap
{
	return [(MapDocument *)[self document] map];
}

- (void)clearMapViews
{
	// Remove all of the rooms
	for(RoomView *roomView in roomViews)
	{
		[roomView removeFromSuperview];
	}
	[roomViews removeAllObjects];

	// Remove all of the sprites
	for(SpriteView *spriteView in spriteViews)
	{
		[spriteView removeFromSuperview];
	}
	[spriteViews removeAllObjects];
	
	// Remove all of the connections
	for(RoomViewConnection *connection in roomConnectionViews)
	{
		[connection removeFromSuperview];
	}
	[roomConnectionViews removeAllObjects];	
}

- (void)addMapViews
{
	for(Sprite *sprite in [_map getProperty:@"sprites"])
	{
		SpriteView *s = [[SpriteView alloc] initWithSprite:sprite selected:[_map getSelectedSprite] == sprite ? YES : NO];
		[s setDelegate:self];
		[spriteViews addObject:s];
		[mapView addSubview:s];
	}
	
	for(Room *room in [_map getProperty:@"rooms"])
	{
		RoomView *r = [[RoomView alloc] initWithRoom:room selected:[_map getSelectedRoom] == room ? YES : NO];
		[r setDelegate:self];
		[roomViews addObject:r];
		[mapView addSubview:r];
	}
	
	for(Connection *connection in [_map getProperty:@"connections"])
	{
		RoomView *b = [self findRoomViewWithGUID:[connection getProperty:@"begin"]];
		RoomView *e = [self findRoomViewWithGUID:[connection getProperty:@"end"]];
		
		if(!b || !e)
		{
			NSLog(@"Skipping invalid connection");
			continue;
		}
		
		RoomViewConnection *c = [[RoomViewConnection alloc] initWithOrigin:b withTarget:e];
		[roomConnectionViews addObject:c];
		[mapView addSubview:c];
	}
}

- (RoomView *)findRoomViewWithRoom:(Room *)room
{
	NSString *roomGUID = [room getProperty:@"GUID"];
	return [self findRoomViewWithGUID:roomGUID];
}

- (RoomView *)findRoomViewWithGUID:(NSString *)roomGUID
{
	for(RoomView *roomView in roomViews)
	{
		NSString *roomViewId = [[roomView room] getProperty:@"GUID"];
		
		if([roomViewId compare:roomGUID] == NSOrderedSame)
		{
			return roomView;
		}
	}
	return nil;
}

- (SpriteView *)findSpriteViewWithSprite:(Sprite *)sprite
{
	NSString *guid = [sprite getProperty:@"GUID"];
	return [self findSpriteViewWithGUID:guid];
}

- (SpriteView *)findSpriteViewWithGUID:(NSString *)guid
{
	for(SpriteView *view in spriteViews)
	{
		NSString *g = [[view sprite] getProperty:@"GUID"];
		
		if([g compare:guid] == NSOrderedSame)
		{
			return view;
		}
	}
	return nil;
}



- (NSImage *)loadMapImageFromData:(NSData *)imageData
{
	NSImage *img = [[NSImage alloc] initWithData:imageData];
	
	NSRect imgRect = [Utils getImageRect:img];
		
	if(imgRect.size.width > MAX_MAP_RESOLUTION_X ||
	   imgRect.size.height != MAX_MAP_RESOLUTION_Y)
	{
		NSLog(@"INVALID RESOLUTION");
		return nil;		
	}
	
	return img;
}

@end
