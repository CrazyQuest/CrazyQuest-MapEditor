#import <Cocoa/Cocoa.h>
#import "Map.h"
#import "MonsterEditorWindowController.h"
#import "MyWindowController.h"

@interface MonstersWindowController : MyWindowController <MonsterEditorDelegate> {
	IBOutlet NSArrayController *_monstersArrayController;
	IBOutlet NSTableView *_monstersTable;
	Map *_map;

	NSMutableArray *_monsters;
}

- (id)initWithMap:(Map *)map;

- (IBAction)addMonster:(id)sender;
- (IBAction)removeMonster:(id)sender;
- (IBAction)editMonster:(id)sender;

@end
