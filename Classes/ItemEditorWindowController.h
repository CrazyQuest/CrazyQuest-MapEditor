#import "Item.h"
#import "MyWindowController.h"
@protocol ItemEditorDelegate
- (void)onEditFinished:(Item *)item;
@end

@interface ItemEditorWindowController : MyWindowController {
	IBOutlet NSArrayController *constants;

	Item *_item;
	id<ItemEditorDelegate> delegate;
}

- (id)initWithItem:(Item *)item;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)iconClicked:(id)sender;

- (IBAction)addConstant:(id)sender;
- (IBAction)removeConstant:(id)sender;

@property (readwrite, assign) id<ItemEditorDelegate> delegate;

@end
