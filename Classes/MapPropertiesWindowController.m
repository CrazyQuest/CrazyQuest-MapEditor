#import "MapPropertiesWindowController.h"
#import "MapDocumentOperations.h"

@implementation MapPropertiesWindowController

/**
 * Initializers
 **/
- (id)initWithMap:(Map *)map
{	
	self = [super initWithWindowNibName:@"MapPropertiesPanel"];
	
	_map = [map retain];
		
	return self;
}

- (void)dealloc
{
	[_map release];
	[super dealloc];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return @"Map Properties";
}

@end
