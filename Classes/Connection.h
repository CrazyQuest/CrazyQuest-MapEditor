//
//  Connection.h
//  MapEditor
//
//  Created by graham on 12/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PropObj.h"


@interface Connection : PropObj {
}

- (id)initWithBegin:(NSString *)beginGUID toEnd:(NSString *)endGUID;

- (NSString *)getBegin;
- (NSString *)getEnd;

- (BOOL)isEqual:(id)object;
- (BOOL)appliesTo:(NSString *)roomGUID;

@end
