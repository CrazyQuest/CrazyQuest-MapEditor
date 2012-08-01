#import <Cocoa/Cocoa.h>
#import "Map.h"
#import "MyWindowController.h"

@interface RoomPropertiesWindowController : MyWindowController {
	IBOutlet NSArrayController *_rooms;
	IBOutlet NSArrayController *_constants;
	Map *_map;
}

- (id)initWithMap:(Map *)m;

- (IBAction)addConstant:(id)sender;
- (IBAction)removeConstant:(id)sender;

@end
