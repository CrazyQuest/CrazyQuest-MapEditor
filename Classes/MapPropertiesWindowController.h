#import <Cocoa/Cocoa.h>
#import "Map.h"
#import "MyWindowController.h"

@interface MapPropertiesWindowController : MyWindowController {
	Map *_map;
}

- (id)initWithMap:(Map *)m;

@end
