//
//  Dialog.m
//  MapEditor
//
//  Created by graham on 4/8/11.
//  Copyright 2011 Rocket Mobile, Inc. All rights reserved.
//

#import "Dialog.h"

@implementation Dialog

- (void)modified
{
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DIALOG_CHANGED object:nil userInfo:nil];	
}

@end
