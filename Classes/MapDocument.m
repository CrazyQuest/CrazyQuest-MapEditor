//
//  MapDocument.m
//  MapEditor
//
//  Created by graham on 12/19/09.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import "MapDocument.h"
#import "MapEditorWindowController.h"
#import "DBUploadWindowController.h"
#import "MapPropertiesWindowController.h"
#import "RoomPropertiesWindowController.h"
#import "RoomDescriptionsWindowController.h"
#import "MonstersWindowController.h"
#import "ItemsWindowController.h"

@implementation MapDocument

@synthesize map;

- (id)init
{
    self = [super init];

	map = [[Map alloc] init];
    
	return self;
}

- (void)dealloc
{
	[map release];
	[_editorWindow release];
	[_mapPropertiesWindow release];
	[_roomPropertiesWindow release];
	[_roomDescriptionsWindow release];
	[_monstersWindow release];
	[_itemsWindow release];
	[super dealloc];
}

- (void)makeWindowControllers
{	
	_editorWindow = [[MapEditorWindowController alloc] initWithMap:map];
	[self addWindowController:_editorWindow];	
	[_editorWindow setShouldCloseDocument:YES];
	
	_mapPropertiesWindow = [[MapPropertiesWindowController alloc] initWithMap:map];
	[[_editorWindow window] addChildWindow:[_mapPropertiesWindow window] ordered:NSWindowAbove];
	
	_roomDescriptionsWindow = [[RoomDescriptionsWindowController alloc] initWithMap:map];
	[[_editorWindow window] addChildWindow:[_roomDescriptionsWindow window] ordered:NSWindowAbove];

	_roomPropertiesWindow = [[RoomPropertiesWindowController alloc] initWithMap:map];
	[[_editorWindow window] addChildWindow:[_roomPropertiesWindow window] ordered:NSWindowAbove];
	
	NSRect editorFrame = [[_editorWindow window] frame];
	NSRect frame;
	
	_monstersWindow = [[MonstersWindowController alloc] initWithMap:map];
	frame = [[_monstersWindow window] frame];
	frame.origin.x = editorFrame.origin.x + editorFrame.size.width + 2;
	[[_monstersWindow window] setFrameOrigin:frame.origin];
	[[_editorWindow window] addChildWindow:[_monstersWindow window] ordered:NSWindowAbove];

	_itemsWindow = [[ItemsWindowController alloc] initWithMap:map];
	frame = [[_itemsWindow window] frame];
	frame.origin.x = editorFrame.origin.x + editorFrame.size.width + 2;
	[[_itemsWindow window] setFrameOrigin:frame.origin];
	[[_editorWindow window] addChildWindow:[_itemsWindow window] ordered:NSWindowAbove];
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
	return [NSKeyedArchiver archivedDataWithRootObject:map];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	Map *tmp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	
	map = [[Map alloc] initWithProperties:[tmp getProperties]];
	
	*outError = nil;
//	*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    return YES;
}

- (IBAction)displayMapPropertiesWindow:(id)sender
{
	[_mapPropertiesWindow showWindow:self];
}

- (IBAction)displayRoomPropertiesWindow:(id)sender
{
	[_roomPropertiesWindow showWindow:self];
}

- (IBAction)displayRoomDescriptionsWindow:(id)sender
{
	[_roomDescriptionsWindow showWindow:self];
}

- (IBAction)displayMonstersWindow:(id)sender
{
	[_monstersWindow showWindow:self];
}

- (IBAction)displayItemsWindow:(id)sender
{
	[_itemsWindow showWindow:self];
}

- (IBAction)displayUploadMapWindow:(id)sender
{
	NSWindowController *uploaderWindow = [[DBUploadWindowController alloc] initWithMap:map];
		
	[[NSApplication sharedApplication] runModalForWindow:[uploaderWindow window]];
}

@end
