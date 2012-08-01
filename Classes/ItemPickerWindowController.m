#import "ItemPickerWindowController.h"
#import "TreeItem.h"
#import "Item.h"

@interface ItemPickerWindowController (Private)
- (void)redrawItems:(id)sender;
@end

@implementation ItemPickerWindowController

- (id)initWithItems:(NSArray *)items
{
	self = [self initWithWindowNibName:@"ItemPickerWindow"];

	_items = [items retain];
	
	return self;
}

- (void)dealloc
{
	[_items release];
	[super dealloc];
}

- (void)awakeFromNib
{
	[self redrawItems:self];
	[_itemView setDoubleAction:@selector(itemPicked:)];
}

- (void)setDelegate:(id)delegate withCallback:(SEL)callback
{
	_delegate = delegate;
	_callback = callback;
}

- (void)redrawItems:(id)sender
{
	[_itemTree setContent:[TreeItem generateItemTree:_items]];
	[_itemView reloadData];
	[_itemView expandItem:nil expandChildren:YES];
}

- (void)itemPicked:(id)sender
{
	[self done:sender];
}

- (IBAction)done:(id)sender
{
	Item *obj = [[[[_itemView itemAtRow:[_itemView selectedRow]] representedObject] representedObject] object];
	
	if(obj)
	{
		NSLog(@"picked item: %@", obj);
		
		// Notify the delegate that an item was chosen
		[_delegate performSelector:_callback withObject:obj];
		
		[[NSApplication sharedApplication] stopModal];
		[self close];
	}	
}

- (IBAction)cancel:(id)sender
{
	[[NSApplication sharedApplication] stopModal];
	[self close];
}

@end
