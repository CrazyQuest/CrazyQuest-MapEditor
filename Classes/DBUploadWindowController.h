#import <Cocoa/Cocoa.h>
#import "Map.h"
#import "Monster.h"
#import "MyWindowController.h"

@interface DBUploadWindowController : MyWindowController {
	IBOutlet NSTextField *hostnameTextField;
	IBOutlet NSTextField *portTextField;
	IBOutlet NSTextField *usernameTextField;
	IBOutlet NSTextField *passwordTextField;
	IBOutlet NSTextField *dbTextField;
	IBOutlet NSProgressIndicator *progressBar;
	
	Map *map;
}

- (id)initWithMap:(Map *)m;

- (IBAction)cancel:(id)sender;
- (IBAction)upload:(id)sender;

@end
