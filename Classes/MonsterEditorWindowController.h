#import <Cocoa/Cocoa.h>
#import "Monster.h"
#import "Item.h"
#import "Map.h"
#import "ItemEditorWindowController.h"
#import "MyWindowController.h"

@protocol MonsterEditorDelegate
- (void)onEditFinished:(Monster *)monster;
@end

@interface MonsterEditorWindowController : MyWindowController <ItemEditorDelegate, NSTextFieldDelegate> {
	IBOutlet NSArrayController *_equipArrayController;
	IBOutlet NSArrayController *dialogArrayController;
	IBOutlet NSDictionaryController *propertyDictionaryController;
	Map *_map;
	Monster *_monster;
	Item *_tmpItem;
	id<MonsterEditorDelegate> delegate;
}

- (id)initWithMap:(Map *)map andMonster:(Monster *)monster;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)iconClicked:(id)sender;
- (IBAction)addEquipClicked:(id)sender;
- (IBAction)addDialogClicked:(id)sender;
- (IBAction)addPropertyClicked:(id)sender;
- (IBAction)removePropertyClicked:(id)sender;

- (void)addEquip:(Item *)item;

@property (readwrite, assign) id<MonsterEditorDelegate> delegate;

@end
