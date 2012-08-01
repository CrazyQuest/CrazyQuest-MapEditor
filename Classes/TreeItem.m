//
//  TreeItem.m
//  MapEditor
//
//  Created by graham on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TreeItem.h"
#import "Item.h"

@implementation TreeItem

@synthesize name;
@synthesize object;

+ (TreeItem *)treeItemWithName:(NSString*)n object:(id)obj
{
	TreeItem *item = [[[TreeItem alloc] init] autorelease];
	[item setName:n];
	[item setObject:obj];
	
	return item;
}

+ (NSArray *)generateItemTree:(NSDictionary *)items
{	
    NSMutableArray *roots = [[NSMutableArray alloc] init];
	
	// Add each category
	for(NSString *key in items)
	{
		NSTreeNode *categoryNode = [[NSTreeNode alloc] initWithRepresentedObject:[TreeItem treeItemWithName:[key capitalizedString] object:nil]];
		
		// Add all of the items for each category
		for(Item *item in [items objectForKey:key])
		{
			NSTreeNode *itemNode = [[NSTreeNode alloc] initWithRepresentedObject:[TreeItem treeItemWithName:[item getProperty:@"name"] object:item]];
			[[categoryNode mutableChildNodes] addObject:itemNode];
		}
		
		// Add the category to the roots
		[roots addObject:categoryNode];
	}
	
	return roots;
}

@end
