//
//  TreeItem.h
//  MapEditor
//
//  Created by graham on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TreeItem : NSObject {
    NSString *name;
    id object;
}

@property (copy) NSString *name;
@property (assign) id object;

+ (TreeItem *)treeItemWithName:(NSString*)n object:(id)obj;
+ (NSArray *)generateItemTree:(NSDictionary *)items;

@end
