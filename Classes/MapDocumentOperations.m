//
//  MapDocumentOperations.m
//  MapEditor
//
//  Created by graham on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapDocumentOperations.h"

@implementation MapDocument (UndoableOperations)

- (void)doImportMapImage:(NSData *)imageData
{
	NSData *oldMapImageData = [map getProperty:@"imageData"];
	
	[map setImageData:imageData];
	
//	[[self undoManager] setActionName:@"Import Map Image"];
//	[[self undoManager] registerUndoWithTarget:self selector:@selector(doImportMapImage:) object:oldMapImageData];	
}

- (void)doAddRoom:(NSDictionary *)addOperation
{	
	Room *room = [addOperation objectForKey:@"room"];	
	
	[map addRoom:room andConnections:[addOperation objectForKey:@"connections"]];
	
	[self setUndoAction:@"Remove Room" redoAction:@"Add Room"];
	[[self undoManager] registerUndoWithTarget:self selector:@selector(doRemoveRoom:) object:room];	
}

- (void)doRemoveRoom:(Room *)room
{	
	NSMutableArray *deletedConnections = [map removeRoom:room];
	NSMutableDictionary *undoOperation = [NSMutableDictionary dictionary];
	[undoOperation setObject:room forKey:@"room"];
	[undoOperation setObject:deletedConnections forKey:@"connections"];
	
	[self setUndoAction:@"Add Room" redoAction:@"Remove Room"];
	[[self undoManager] registerUndoWithTarget:self selector:@selector(doAddRoom:) object:undoOperation];
}

- (void)doAddSprite:(Sprite *)sprite
{
	[map addSprite:sprite];

	[self setUndoAction:@"Remove Sprite" redoAction:@"Add Sprite"];
	[[self undoManager] registerUndoWithTarget:self selector:@selector(doRemoveSprite:) object:sprite];	
}

- (void)doRemoveSprite:(Sprite *)sprite
{
	[map removeSprite:(Sprite *)sprite];
	
	[self setUndoAction:@"Add Sprite" redoAction:@"Remove Sprite"];
	[[self undoManager] registerUndoWithTarget:self selector:@selector(doAddSprite:) object:sprite];
}

- (void)doAddConnection:(Connection *)c
{	
	[map addConnection:c];
	
	[self setUndoAction:@"Remove Connection" redoAction:@"Add Connection"];
	[[self undoManager] registerUndoWithTarget:self selector:@selector(doRemoveConnection:) object:c];
}

- (void)doRemoveConnection:(Connection *)c
{	
	[map removeConnection:c];
	
	[self setUndoAction:@"Add Connection" redoAction:@"Remove Connection"];
	[[self undoManager] registerUndoWithTarget:self selector:@selector(doAddConnection:) object:c];
}

- (void)doMoveRoom:(NSDictionary *)moveOperation
{	
	Room *room = [moveOperation objectForKey:@"room"];
	NSPoint point = [[moveOperation objectForKey:@"point"] pointValue];
	
	NSMutableDictionary *undoMoveOperation = [NSMutableDictionary dictionary];
	[undoMoveOperation setObject:room forKey:@"room"];
	[undoMoveOperation setObject:[NSValue valueWithPoint:[room getPosition]] forKey:@"point"];
	
	[room setPosition:point];
	
	[[self undoManager] setActionName:@"Move Room"];
	[[self undoManager] registerUndoWithTarget:self selector:@selector(doMoveRoom:) object:undoMoveOperation];
}

- (void)doMoveSprite:(NSDictionary *)moveOperation
{	
	Sprite *sprite = [moveOperation objectForKey:@"sprite"];
	NSPoint point = [[moveOperation objectForKey:@"point"] pointValue];
	
	NSMutableDictionary *undoMoveOperation = [NSMutableDictionary dictionary];
	[undoMoveOperation setObject:sprite forKey:@"sprite"];
	[undoMoveOperation setObject:[NSValue valueWithPoint:[sprite position]] forKey:@"point"];
	
	[sprite setPosition:point];
	
	[[self undoManager] setActionName:@"Move Sprite"];
	[[self undoManager] registerUndoWithTarget:self selector:@selector(doMoveSprite:) object:undoMoveOperation];
}


- (void)doSetRoomProperties:(NSDictionary *)setPropOperation
{
	NSLog(@"doSetRoomProperties");
	Room *room = [setPropOperation objectForKey:@"room"];
	NSDictionary *props = [setPropOperation objectForKey:@"properties"];
	
	[room setProperties:props];
	
	// DO NOT SUPPORT UNDO FOR SETTING ROOM PROPERTIES	
	[[self undoManager] removeAllActions];
}

- (void)doSetMapName:(NSString *)name
{	
	// Set the map's name
	NSMutableDictionary *d = [NSMutableDictionary dictionaryWithDictionary:[map getProperties]];
	[d setObject:name forKey:@"name"];
	[map setProperties:d];
	
	// DO NOT SUPPORT UNDO FOR SETTING MAP NAME	
	[[self undoManager] removeAllActions];
}

- (void)setUndoAction:(NSString *)undoAction redoAction:(NSString *)redoAction
{
	if([[self undoManager] isUndoing])
	{
		[[self undoManager] setActionName:undoAction];
	}
	else if([[self undoManager] isRedoing])
	{
		[[self undoManager] setActionName:redoAction];
	}
	else
	{
		[[self undoManager] setActionName:redoAction];
	}
}

@end
