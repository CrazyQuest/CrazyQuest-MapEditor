#import "ItemEditorWindowController.h"
#import "Weapon.h"
#import "Armor.h"

@implementation ItemEditorWindowController

@synthesize delegate;

/**
 * Initializers/destructors
 **/
- (id)initWithItem:(Item *)item
{
	NSLog(@"attempting to edit item: %@", item);
	if([item class] == [Weapon class])
	{
		self = [super initWithWindowNibName:@"WeaponEditor"];
		_item = [[Weapon alloc] initWithProperties:[item getProperties]];
	}
	else if([item class] == [Armor class])
	{
		self = [super initWithWindowNibName:@"ArmorEditor"];
		_item = [[Armor alloc] initWithProperties:[item getProperties]];
	}
	else
	{
		self = [super initWithWindowNibName:@"ItemEditor"];
		_item = [[Item alloc] initWithProperties:item ? [item getProperties] : nil];
	}		
		
	return self;
}

- (void)dealloc
{
	[_item release];
	[super dealloc];
}

/**
 * Action methods
 **/
- (IBAction)done:(id)sender
{
//	NSLog(@"done?");
//	NSLog(@"properties: %@", [_item getProperties]);
	[delegate onEditFinished:_item];
	
	[[NSApplication sharedApplication] stopModal];
	[self close];	
}

- (IBAction)cancel:(id)sender
{
	[[NSApplication sharedApplication] stopModal];
	[self close];
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
	[_item setImageData:imageData];
}

- (IBAction)addConstant:(id)sender
{
	NSMutableDictionary *newConstant = [NSMutableDictionary dictionary];
	[newConstant setObject:@"null" forKey:@"name"];
	[newConstant setObject:@"null" forKey:@"value"];
	[constants addObject:newConstant];
}

- (IBAction)removeConstant:(id)sender
{
	[constants removeObjectAtArrangedObjectIndex:[constants selectionIndex]];
}

@end
