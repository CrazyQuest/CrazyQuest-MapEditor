#import "Map.h"
#import "ItemEditorWindowController.h"
#import "MyWindowController.h"

@interface ItemsWindowController : MyWindowController <ItemEditorDelegate> {
	IBOutlet NSTreeController *_itemTree;
    IBOutlet NSOutlineView    *_itemView;
	Map *_map;
	Item *_tmpItem;
}

- (id)initWithMap:(Map *)map;

- (IBAction)addArmour:(id)sender;
- (IBAction)addItem:(id)sender;
- (IBAction)addWeapon:(id)sender;

- (IBAction)editItem:(id)sender;
- (IBAction)removeItem:(id)sender;

@end
