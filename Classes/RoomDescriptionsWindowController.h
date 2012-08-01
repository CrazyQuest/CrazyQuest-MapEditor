#import <Cocoa/Cocoa.h>
#import "Map.h"
#import "MyWindowController.h"

@interface RoomDescriptionsWindowController : MyWindowController {
	IBOutlet NSArrayController *_rooms;
	IBOutlet NSArrayController *_descriptions;
	IBOutlet NSTableView *_descriptionsTable;

	Map *_map;
}

- (IBAction)addDescription:(id)sender;
- (IBAction)removeDescription:(id)sender;

- (id)initWithMap:(Map *)map;

@end
