#import "MonstersWindowController.h"
#import "Monster.h"

@interface MonstersWindowController (Private)
- (NSArray *)getMonsters;
- (id)getMonsterForIndex:(NSInteger)index;
@end

@implementation MonstersWindowController

/**
 * Initializers
 **/
- (id)initWithMap:(Map *)map
{	
	self = [super initWithWindowNibName:@"MonstersPanel"];
	
	_map = [map retain];
	_monsters = [[[map getSelectedRoom] getProperty:@"monsters"] retain];
		
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRoomChanged:) name:NOTIFICATION_SELECTION_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRoomChanged:) name:NOTIFICATION_ROOM_CHANGED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRoomChanged:) name:NOTIFICATION_ROOM_REMOVED object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRoomChanged:) name:NOTIFICATION_MONSTER_CHANGED object:nil];

	return self;
}

- (void)dealloc
{
	[_monsters release];
	[_map release];
	[super dealloc];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return @"Monsters";
}

- (void)windowDidLoad
{
	[_monstersTable setDoubleAction:@selector(editMonster:)];
}

/**
 * Public methods
 **/
- (IBAction)addMonster:(id)sender
{
	if(![_map getSelectedRoom])
		return;

	[_monstersArrayController addObject:[[[Monster alloc] init] autorelease]];
}

- (IBAction)removeMonster:(id)sender
{
	if(![_map getSelectedRoom])
		return;

	[_monstersArrayController removeObjectAtArrangedObjectIndex:[_monstersTable selectedRow]];
}

- (IBAction)editMonster:(id)sender
{
	Monster *monster = [_monsters objectAtIndex:[_monstersTable clickedRow]];
	if(!monster)
		return;
	
	MonsterEditorWindowController *monsterEditorController = [[MonsterEditorWindowController alloc] initWithMap:_map andMonster:monster];
	[monsterEditorController setDelegate:self];
	
	[[NSApplication sharedApplication] runModalForWindow:[monsterEditorController window]];
}

/**
 * Notification handlers
 **/
- (void)onRoomChanged:(NSNotification *)notification
{
	[_monstersArrayController unbind:@"contentArray"];
	[_monsters release];
	_monsters = [[[_map getSelectedRoom] getProperty:@"monsters"] retain];
	[_monstersArrayController bind:@"contentArray" toObject:self withKeyPath:@"_monsters" options:nil];
	[_monstersTable deselectAll:self];
}

/**
 * MonsterEditorDelegate methods
 **/
- (void)onEditFinished:(Monster *)monster
{
//	NSLog(@"onEditFinished: %@", monster);
	Monster *m = [_monsters objectAtIndex:[_monstersTable clickedRow]];
	[m setProperties:[monster getProperties]];

//	NSLog(@"Should update current monster with these properties...");
}

@end
