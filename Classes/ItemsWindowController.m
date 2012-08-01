#import "ItemsWindowController.h"
#import "TreeItem.h"
#import "Weapon.h"
#import "Armor.h"
#import "ItemEditorWindowController.h"

@interface ItemsWindowController (Private)
- (NSArray *)generateItemTree;
- (void)redrawItems:(id)sender;
@end

@implementation ItemsWindowController

- (id)initWithMap:(Map *)map
{
	self = [super initWithWindowNibName:@"ItemsPanel"];
	
	_map = [map retain];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redrawItems:) name:NOTIFICATION_ITEM_CHANGED object:nil];

	return self;
}

- (void)dealloc
{
	[_map release];
	[super dealloc];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return @"Reusable Items";
}

- (void)awakeFromNib
{
	[self redrawItems:self];
	[_itemView setDoubleAction:@selector(editItem:)];
}

- (IBAction)addArmour:(id)sender
{	
	NSMutableArray *itemArray = [[_map getProperty:@"items"] objectForKey:@"armor"];
		
	// Add the armor
	[itemArray addObject:[[Armor alloc] init]];
	
	[self redrawItems:self];
}

- (IBAction)addItem:(id)sender {
	NSMutableArray *itemArray = [[_map getProperty:@"items"] objectForKey:@"items"];
	
	// Add the item
	[itemArray addObject:[[Item alloc] init]];
	
	[self redrawItems:self];	
}

- (IBAction)addWeapon:(id)sender {
	NSMutableArray *itemArray = [[_map getProperty:@"items"] objectForKey:@"weapons"];
	
	// Add the weapon
	[itemArray addObject:[[Weapon alloc] init]];
	
	[self redrawItems:self];
}

- (void)redrawItems:(id)sender
{
	[_itemTree setContent:[TreeItem generateItemTree:[_map getProperty:@"items"]]];
	[_itemView reloadData];
	[_itemView expandItem:nil expandChildren:YES];
}

- (IBAction)editItem:(id)sender
{
	Item *obj = [[[[_itemView itemAtRow:[_itemView clickedRow]] representedObject] representedObject] object];
	
	if(obj)
	{
		_tmpItem = obj;
		ItemEditorWindowController *itemEditor = [[ItemEditorWindowController alloc] initWithItem:obj];
		[itemEditor setDelegate:self];
		
		[[NSApplication sharedApplication] runModalForWindow:[itemEditor window]];
	}
}

- (IBAction)removeItem:(id)sender
{
	Item *obj = [[[[_itemView itemAtRow:[_itemView selectedRow]] representedObject] representedObject] object];
	NSMutableArray *items = [[_map getProperty:@"items"] objectForKey:@"items"];
	NSMutableArray *weapons = [[_map getProperty:@"items"] objectForKey:@"weapons"];
	NSMutableArray *armor = [[_map getProperty:@"items"] objectForKey:@"armor"];
	
	if(obj)
	{
		if([items containsObject:obj])
			[items removeObject:obj];
		if([weapons containsObject:obj])
			[weapons removeObject:obj];
		if([armor containsObject:obj])
			[armor removeObject:obj];

		[self redrawItems:self];
	}
}


/**
 * ItemEditorDelegate methods
 **/
- (void)onEditFinished:(Item *)item
{	
	[_tmpItem setProperties:[item getProperties]];
	_tmpItem = nil;
}

@end
