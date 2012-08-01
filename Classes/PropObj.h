//
//  PropObj.h
//  MapEditor
//
//  Created by graham on 12/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PropObj : NSObject <NSCoding> {
	NSMutableDictionary *_properties;
}

- (id)initWithProperties:(NSDictionary *)properties;
- (void)setProperties:(NSDictionary *)properties;
- (void)setProperty:(id)property forKey:(NSString *)key;
- (void)removePropertyForKey:(NSString *)key;
- (NSDictionary *)getProperties;
- (id)getProperty:(NSString *)propName;
- (void)modified;

@end
