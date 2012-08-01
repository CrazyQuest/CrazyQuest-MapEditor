#import "DBUploadWindowController.h"
#import "Utils.h"
#import "NSData+Base64.h"
#include <mysql.h> 
#import "Item.h"

@interface DBUploadWindowController (Private)
- (void)displayLastSQLError;
- (BOOL)doQuery:(NSString *)query;
- (NSString *)parseDescription:(NSString *)d;
- (NSString *)getCostOfItemWithGUID:(NSString *)guid;
- (NSString *)getNameOfItemWithGUID:(NSString *)guid;
- (NSArray *)getAllItems;
- (NSString *)md5:(NSString *)str;
@end

static MYSQL *mysql = NULL;

NSString *QuoteWrap(NSString *str)
{
	if(str)
	{
		return [NSString stringWithFormat:@"\"%@\"", str];
	}
	
	return @"NULL";
}

@implementation DBUploadWindowController
- (id)initWithMap:(Map *)m
{
	self = [super initWithWindowNibName:@"DBUploadWindow"];
	
	mysql = malloc(sizeof(MYSQL));
	mysql_init(mysql); 
	
	map = [m retain];
	
	return self;
}

- (void)dealloc
{
	[map release];
	[super dealloc];
}

- (IBAction)cancel:(id)sender 
{
	[[NSApplication sharedApplication] stopModal];
	[self close];
}

- (IBAction)upload:(id)sender 
{
	const char *hostname = [[hostnameTextField stringValue] cStringUsingEncoding:NSUTF8StringEncoding];
	const char *username = [[usernameTextField stringValue] cStringUsingEncoding:NSUTF8StringEncoding];
	const char *password = [[passwordTextField stringValue] cStringUsingEncoding:NSUTF8StringEncoding];
	const char *db = [[dbTextField stringValue] cStringUsingEncoding:NSUTF8StringEncoding];
	NSUInteger port = [[portTextField stringValue] intValue];
	
	if(!mysql_real_connect(mysql, hostname, username, password, db, port, NULL, 0))
	{ 
		[self displayLastSQLError];
		return;
	} 
	
	/**
	 * Delete the previous map
	 **/
	NSString *deleteMapQuery = [NSString stringWithFormat:@"DELETE FROM maps WHERE guid=%d",
								[[map getProperty:@"GUID"] intValue]];
	if(![self doQuery:deleteMapQuery]) return;
	
	/**
	 * Delete the previous map's image as well...
	 */
	NSString *deleteMapImageQuery = [NSString stringWithFormat:@"DELETE FROM images WHERE guid=%d",
								[[map getProperty:@"GUID"] intValue]];
	if(![self doQuery:deleteMapImageQuery]) return;
	
	
	NSRect imageRect = [Utils getImageRect:[map getImage]];
	
	/**
	 * Insert the map
	 **/
	NSString *insertMapQuery = [NSString stringWithFormat:@"INSERT INTO maps (guid, name, width, height) VALUES (%d, \"%@\", %f, %f)",
								[[map getProperty:@"GUID"] intValue],
								[map getProperty:@"name"],
								imageRect.size.width,
								imageRect.size.height];
	
	if(![self doQuery:insertMapQuery]) return;
	
	/**
	 * Insert the map image
	 **/
	NSString *base64ImageData = [[map getProperty:@"imageData"] base64EncodedString];
	NSString *insertMapImageQuery = [NSString stringWithFormat:@"INSERT INTO images (guid, md5, data) VALUES (%d, '%@', '%@')",
									 [[map getProperty:@"GUID"] intValue],
									 [self md5:base64ImageData],
									 base64ImageData];
	
	if(![self doQuery:insertMapImageQuery]) return;

	/**
	 * Insert all of the items
	 */
	for(Item *item in [self getAllItems])
	{
		NSString *insertItemQuery = [NSString stringWithFormat:@"INSERT INTO items (guid, map_guid, type, name, description, weight, value, skill, damage, ac, slot, use_action, use_script) VALUES (%d, %d, \"%@\", \"%@\", \"%@\", %d, %d, %@, %@, %d, %@, %@, %@)",
									 [[item getProperty:@"GUID"] intValue],
									 [[map getProperty:@"GUID"] intValue],
									 [item getProperty:@"type"],
									 [item getProperty:@"name"],
									 [item getProperty:@"description"],
									 [[item getProperty:@"weight"] intValue],
									 [[item getProperty:@"value"] intValue],
									 QuoteWrap([item getProperty:@"skill"]),
									 QuoteWrap([item getProperty:@"damage"]),
									 [[item getProperty:@"ac"] intValue],
									 QuoteWrap([item getProperty:@"slot"]),
									 QuoteWrap([item getProperty:@"use_action"]),
									 QuoteWrap([item getProperty:@"use_script"]) ];
		if(![self doQuery:insertItemQuery]) return;
		
	}
	
	NSArray *rooms = [NSArray arrayWithArray:[map getProperty:@"rooms"]];
	for(Room *room in rooms)
	{
		NSString *description = [self parseDescription:[room getProperty:@"description"]];
		
		description = [description stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
		
		/**
		 * Special magic is performed on the y coordinate so that things show up properly on the client (ugh)
		 **/
		NSString *insertRoomQuery = [NSString stringWithFormat:@"INSERT INTO rooms (map_guid, guid, link, name, description, is_dark, is_seller, x, y) VALUES (%d, %d, %d, \"%@\", \"%@\", %d, %f, %f)",
									 [[map getProperty:@"GUID"] intValue],
									 [[room getProperty:@"GUID"] intValue],
									 [[room getProperty:@"link"] length] > 0 ? [[room getProperty:@"link"] intValue] : 0,
									 [[room getProperty:@"name"] length] > 0 ? [room getProperty:@"name"] : @"",
									 description,
									 [[room getProperty:@"is_seller"] boolValue] == YES ? 1 : 0,
									 [room getPosition].x,
									 imageRect.size.height - [room getPosition].y];
		
		if(![self doQuery:insertRoomQuery]) return;
		
		/**
		 * Insert room descriptions
		 **/
		for(NSDictionary *description in [room getProperty:@"descriptions"])
		{
			NSString *insertDescriptionQuery = [NSString stringWithFormat:@"INSERT INTO descriptions (room_guid, name, description, event) VALUES (%d, \"%@\", '%@', \"%@\")",
												[[room getProperty:@"GUID"] intValue],
												[description objectForKey:@"name"],
												[description objectForKey:@"description"],
												@""];
			
			if(![self doQuery:insertDescriptionQuery]) return;			
		}
		
		/**
		 * Insert room constants
		 */
		for(NSDictionary *nameValuePair in [room getProperty:@"constants"])
		{
			NSString *name = [nameValuePair objectForKey:@"name"];
			NSString *value = [nameValuePair objectForKey:@"value"];
			
			NSString *insertRoomConstantQuery = [NSString stringWithFormat:@"INSERT INTO room_constants (room_guid, name, value) VALUES (%d, \"%@\", \"%@\")",
												 [[room getProperty:@"GUID"] intValue],
												 name,
												 value];
			if(![self doQuery:insertRoomConstantQuery]) return;			

		}	
		
		/**
		 * Insert monsters
		 **/
		for(Monster *monster in [room getProperty:@"monsters"])
		{
			NSLog(@"Monster: %@", monster);
			NSString *insertMonsterQuery = [NSString stringWithFormat:@"INSERT INTO monsters (guid, room_guid, level, name, description, str, sta, `int`, dex, ac, aggro, no_attack, alignment, spawn_percentage, spawn_timer) VALUES (%d, %d, %d, \"%@\", \"%@\", %d, %d, %d, %d, %d, %d, %d, %@, %d, %d)",
											[[monster getProperty:@"GUID"] intValue],
											[[room getProperty:@"GUID"] intValue],
											[[monster getProperty:@"level"] intValue],
											[monster getProperty:@"name"],
											[monster getProperty:@"description"],
											[[monster getProperty:@"str"] intValue],
											[[monster getProperty:@"sta"] intValue],
											[[monster getProperty:@"int"] intValue],
											[[monster getProperty:@"dex"] intValue],
											[[monster getProperty:@"ac"] intValue],
											[[monster getProperty:@"aggro"] intValue],
											[[monster getProperty:@"no_attack"] intValue],
											[monster getProperty:@"alignment"],
											[[monster getProperty:@"spawn_percentage"] intValue],
											[[monster getProperty:@"spawn_timer"] intValue]
											];
			
			if(![self doQuery:insertMonsterQuery]) return;				
			
			/**
			 * Add all of the monster's equipment
			 **/
			for(Item *item in [monster getProperty:@"equipment"])
			{				
				NSLog(@"There was an item: %@", item);
								
				NSString *insertDropQuery = [NSString stringWithFormat:@"INSERT INTO loot (item_guid, monster_guid, percentage) VALUES (%d, %d, %d)",
											 [[item getProperty:@"GUID"] intValue],
											 [[monster getProperty:@"GUID"] intValue],
											 [[item getProperty:@"drop_percentage"] intValue]
											 ];
				if(![self doQuery:insertDropQuery]) return;
			}
						

		}
	}
		
	/**
	 * Connections between rooms
	 **/
	NSArray *connections = [NSArray arrayWithArray:[map getProperty:@"connections"]];
	for(Connection *connection in connections)
	{
		NSString *addConnectionQuery = [NSString stringWithFormat:@"INSERT INTO connections (guid, map_guid, from_guid, to_guid) VALUES (%d, %d, %d, %d)",
										[[connection getProperty:@"GUID"] intValue],
										[[map getProperty:@"GUID"] intValue],
										[[connection getProperty:@"begin"] intValue],
										[[connection getProperty:@"end"] intValue]];
		if(![self doQuery:addConnectionQuery]) return;
	}
	
	mysql_close(mysql);

	[[NSApplication sharedApplication] stopModal];
	[self close];
}

- (BOOL)doQuery:(NSString *)query
{
	if(mysql_query(mysql, [query cStringUsingEncoding:NSUTF8StringEncoding])) 
	{
		[self displayLastSQLError];
		[self close];
		return FALSE;
	}
	
	return TRUE;
}

- (void)displayLastSQLError
{
	[Utils displayError:[NSString stringWithFormat:@"mySQL error: (%d) %s", mysql_errno(mysql), mysql_error(mysql)]];
}

- (NSString *)parseDescription:(NSString *)d
{
	if(!d)
	{
		return @"";
	}
	
	NSScanner* scanner = [NSScanner scannerWithString:d];
	NSString *tmp = nil;
	NSMutableString *description = [NSMutableString string];
		
	// Skip no characters
	[scanner setCharactersToBeSkipped:nil];
	
	@try
	{
		while(![scanner isAtEnd])
		{
			NSString *object = nil;
			
			// Scan up to the next action block
			[scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"["] intoString:&tmp];
			
			if(tmp != nil)
			{
				[description appendString:tmp];
			}
			
			if([scanner isAtEnd])
				break;
			
			// Skip the beginning of the object block
			[scanner scanString:@"[" intoString:nil];
			
			// Scan up to the end character
			[scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"]"] intoString:&object];
			
			// Parse the object
			NSScanner *objectScanner = [NSScanner scannerWithString:object];
			NSString *objectType = nil;
			NSString *objectName = nil;
			[objectScanner scanCharactersFromSet:[[NSCharacterSet characterSetWithCharactersInString:@":"] invertedSet] intoString:&objectType];
			[objectScanner scanString:@":" intoString:nil];
			[objectScanner scanCharactersFromSet:[[NSCharacterSet characterSetWithCharactersInString:@"]"] invertedSet] intoString:&objectName];		
			
			// Skip the end of the object block
			[scanner scanString:@"]" intoString:&tmp];
			
			NSLog(@"objectName: %@ objectType: %@", objectName, objectType);
			
			if([objectType compare:@"itemname"] == NSOrderedSame)
			{
				NSString *itemGUID = objectName;
				[description appendString:[self getNameOfItemWithGUID:itemGUID]];
			}
			else
			{
				[description appendFormat:@"[%@:%@]", objectType, objectName];
			}
		}
	}
	@catch(NSException *e)
	{
		NSLog(@"Stack: %@", [e description]);
		// Do nothing
	}	
	
	return description;
}

- (Item *)findItemWithGUID:(NSString *)guid
{
	NSArray *items = [self getAllItems];
	
	for(Item *item in items)
	{
		if([[item getProperty:@"GUID"] intValue] == [guid intValue])
		{
			return item;
		}
	}
	return nil;
}

- (NSArray *)getAllItems
{
	NSArray *items = [[map getProperty:@"items"] objectForKey:@"items"];
	NSArray *weapons = [[map getProperty:@"items"] objectForKey:@"weapons"];
	NSArray *armor = [[map getProperty:@"items"] objectForKey:@"armor"];
	NSMutableArray *allItems = [[NSMutableArray alloc] init];
	
	[allItems addObjectsFromArray:items];
	[allItems addObjectsFromArray:armor];
	[allItems addObjectsFromArray:weapons];

	return allItems;
}

- (NSString *)getNameOfItemWithGUID:(NSString *)guid
{
	Item *item = [self findItemWithGUID:guid];
	
	if(item)
	{
		return [NSString stringWithFormat:@"%@", [item getProperty:@"name"]];
	}
	
	return @"?Unknown Error?";	
}

- (NSString *)getCostOfItemWithGUID:(NSString *)guid
{
	Item *item = [self findItemWithGUID:guid];
	
	if(item)
	{
		return [NSString stringWithFormat:@"%d", [[item getProperty:@"value"] intValue]];
	}
	
	return @"Free";
}

- (NSString *)md5:(NSString *)str
{
	const char *cStr = [str UTF8String];	
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	
	return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
		result[0], result[1],
		result[2], result[3],
		result[4], result[5],			
		result[6], result[7],
		result[8], result[9],
		result[10], result[11],
		result[12], result[13],
		result[14], result[15]			
			];
	
}

@end
