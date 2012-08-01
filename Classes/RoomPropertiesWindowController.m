#import "RoomPropertiesWindowController.h"
#import "MapDocumentOperations.h"

@implementation RoomPropertiesWindowController

/**
 * Initializers
 **/
- (id)initWithMap:(Map *)map
{	
	self = [super initWithWindowNibName:@"RoomPropertiesPanel"];
	
	_map = [map retain];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomsChanged:) name:NOTIFICATION_SELECTION_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomsChanged:) name:NOTIFICATION_ROOM_ADDED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomsChanged:) name:NOTIFICATION_ROOM_REMOVED object:nil];
	
	return self;
}

- (void)dealloc
{
	[_map release];
	[super dealloc];
}

- (void)windowDidLoad
{
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return @"Room Properties";
}


/**
 * Notification handlers
 **/
- (void)roomsChanged:(NSNotification *)notification
{
	NSMutableArray *rooms = [_map getProperty:@"rooms"];
	[_rooms setSelectionIndex:[rooms indexOfObject:[_map getSelectedRoom]]];
}

- (IBAction)addConstant:(id)sender
{
	NSMutableDictionary *newConstant = [NSMutableDictionary dictionary];
	[newConstant setObject:@"null" forKey:@"name"];
	[newConstant setObject:@"null" forKey:@"value"];
	[_constants addObject:newConstant];
}

- (IBAction)removeConstant:(id)sender
{
	[_constants removeObjectAtArrangedObjectIndex:[_constants selectionIndex]];
}

@end
