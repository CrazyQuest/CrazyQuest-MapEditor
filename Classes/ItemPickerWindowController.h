#import <Cocoa/Cocoa.h>
#import "MyWindowController.h"

@interface ItemPickerWindowController : MyWindowController {
	IBOutlet NSTreeController *_itemTree;
    IBOutlet NSOutlineView    *_itemView;
	NSDictionary *_items;
	id _delegate;
	SEL _callback;
}

- (id)initWithItems:(NSArray *)items;

- (void)setDelegate:(id)delegate withCallback:(SEL)callback;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
