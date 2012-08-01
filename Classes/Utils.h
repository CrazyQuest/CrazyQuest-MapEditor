//
//  Utils.h
//  medit
//
//  Created by graham on 12/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Utils : NSObject {

}

+ (void)displayError:(NSString *)errorString;
+ (NSImage *)loadImageForResource:(NSString *)resource ofType:(NSString *)type;
+ (NSString *)newGUID;
+ (NSRect)getImageRect:(NSImage *)img;

@end
