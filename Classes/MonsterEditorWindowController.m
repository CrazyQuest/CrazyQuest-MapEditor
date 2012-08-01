#import "MonsterEditorWindowController.h"
#import "ItemPickerWindowController.h"
#import "Utils.h"
#import "Dialog.h"

@interface MonsterEditorWindowController (Private)
- (NSDictionary *)getMonsterProperties;
@end

@implementation MonsterEditorWindowController

@synthesize delegate;

/**
 * Initializers/destructors
 **/
- (id)initWithMap:(Map *)map andMonster:(Monster *)monster;
{
	self = [super initWithWindowNibName:@"MonsterEditorWindow"];

	_map = [map retain];
	_monster = [[Monster alloc] initWithProperties:[monster getProperties]];
	
	return self;
}

- (void)dealloc
{
	[_map release];
	[_monster release];
	[super dealloc];
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSTextField *levelField = [aNotification object];
	[_monster setProperty:[NSNumber numberWithInt:[levelField intValue]+2] forKey:@"int"];
	[_monster setProperty:[NSNumber numberWithInt:[levelField intValue]+2] forKey:@"str"];
	[_monster setProperty:[NSNumber numberWithInt:[levelField intValue]+2] forKey:@"dex"];
	[_monster setProperty:[NSNumber numberWithInt:[levelField intValue]+2] forKey:@"sta"];
}

/**
 * Action methods
 **/
- (IBAction)done:(id)sender
{
//	NSLog(@"properties: %@", [_monster getProperties]);
	[delegate onEditFinished:_monster];

	[[NSApplication sharedApplication] stopModal];
	[self close];
}

- (IBAction)cancel:(id)sender 
{	
	[[NSApplication sharedApplication] stopModal];
	[self close];
}

- (IBAction)addEquipClicked:(id)sender
{
	ItemPickerWindowController *itemPicker = [[ItemPickerWindowController alloc] initWithItems:[_map getProperty:@"items"]];
	[itemPicker setDelegate:self withCallback:@selector(addEquip:)];
	[[NSApplication sharedApplication] runModalForWindow:[itemPicker window]];
}


- (void)addEquip:(Item *)item
{
	NSLog(@"attempting to add equip: %@", item);
	
	// Create a copy of the object (and assign it a new GUID)
	Class itemClass = [item class];
	Item *newItem = [[itemClass alloc] initWithProperties:[item getProperties]];
	[_equipArrayController addObject:newItem];
}

- (IBAction)editItem:(Item *)item
{	
	NSLog(@"editItem: %@", item);
	
	_tmpItem = item;
	ItemEditorWindowController *itemEditor = [[ItemEditorWindowController alloc] initWithItem:item];
	[itemEditor setDelegate:self];
	
	[[NSApplication sharedApplication] runModalForWindow:[itemEditor window]];
}

- (IBAction)iconClicked:(id)sender
{
	NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	// Only support PNG's and JPG's
	NSMutableArray *types = [NSMutableArray arrayWithCapacity:2];
	[types addObject:@"png"];
	[types addObject:@"jpg"];
	
	NSInteger result = [panel runModalForTypes:types];
	
	switch(result)
	{
		case NSOKButton:
//			NSLog(@"Importing monster image from path: %@", [panel filename]);
			break;
			
		case NSCancelButton:
		default:
			return;
	}
	
	NSData *imageData = [NSData dataWithContentsOfFile:[panel filename]];
	[_monster setImageData:imageData];
}

- (IBAction)addDialogClicked:(id)sender
{	
	NSMutableDictionary *properties = [NSMutableDictionary dictionary];

	[properties setObject:@"" forKey:@"name"];
	[properties setObject:@"" forKey:@"dialog"];
	[properties setObject:@"" forKey:@"questGuid"];
	[properties setObject:@"" forKey:@"requiresProperty"];
	[properties setObject:@"" forKey:@"requiresQuest"];
	[properties setObject:[NSNumber numberWithInt:1] forKey:@"minimumLevel"];
	
	Dialog *newDialog = [[Dialog alloc] initWithProperties:properties];
	[dialogArrayController addObject:newDialog];
}

- (IBAction)addPropertyClicked:(id)sender
{
	id newObject = [propertyDictionaryController newObject];
	[newObject setKey:@"key"];
	[newObject setValue:@"value"];
	
	[propertyDictionaryController addObject:newObject];
}

- (IBAction)removePropertyClicked:(id)sender
{
	[propertyDictionaryController removeObjects:[propertyDictionaryController selectedObjects]];
}


/**
 * ItemEditorDelegate methods
 **/
- (void)onEditFinished:(Item *)item
{	
	NSLog(@"edit finished");
	[_tmpItem setProperties:[item getProperties]];
	_tmpItem = nil;
}

@end
