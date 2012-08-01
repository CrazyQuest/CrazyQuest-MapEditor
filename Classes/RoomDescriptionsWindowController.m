#import "RoomDescriptionsWindowController.h"

@implementation RoomDescriptionsWindowController

/**
 * Initializers
 **/
- (id)initWithMap:(Map *)map
{	
	self = [super initWithWindowNibName:@"RoomDescriptionsPanel"];
	
	_map = [map retain];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomsChanged:) name:NOTIFICATION_SELECTION_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomsChanged:) name:NOTIFICATION_ROOM_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roomsChanged:) name:NOTIFICATION_ROOM_REMOVED object:nil];
		
	return self;
}

- (void)dealloc
{
	[_map release];
	[super dealloc];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return @"Room Descriptions";
}

/**
 * Public methods
 **/
- (IBAction)addDescription:(id)sender
{
	if(![_map getSelectedRoom])
		return;

	NSMutableDictionary *newDescription = [NSMutableDictionary dictionary];
	[newDescription setObject:@"Unknown" forKey:@"name"];
	[newDescription setObject:@"Unknown" forKey:@"description"];
	
	[_descriptions addObject:newDescription];
}

- (IBAction)removeDescription:(id)sender
{
	if(![_map getSelectedRoom])
		return;

	[_descriptions removeObjectAtArrangedObjectIndex:[_descriptionsTable selectedRow]];
}


/**
 * Notification handlers
 **/
- (void)roomsChanged:(NSNotification *)notification
{
	NSMutableArray *rooms = [_map getProperty:@"rooms"];
	[_rooms setSelectionIndex:[rooms indexOfObject:[_map getSelectedRoom]]];
}

@end
