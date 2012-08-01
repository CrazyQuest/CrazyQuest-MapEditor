//
//  MapDocumentOperations.h
//  MapEditor
//
//  Created by graham on 12/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MapDocument.h"
#import "Sprite.h"

@interface MapDocument (UndoableOperations)
// UNDOABLE
- (void)doImportMapImage:(NSData *)imageData;
- (void)doAddRoom:(NSDictionary *)addOperation;
- (void)doRemoveRoom:(Room *)room;
- (void)doAddConnection:(Connection *)c;
- (void)doRemoveConnection:(Connection *)c;
- (void)doMoveRoom:(NSDictionary *)moveOperation;

- (void)doAddSprite:(Sprite *)sprite;
- (void)doRemoveSprite:(Sprite *)sprite;
- (void)doMoveSprite:(NSDictionary *)moveOperation;

// NOT UNDOABLE
- (void)doSetRoomProperties:(NSDictionary *)setPropOperation;
- (void)doSetMapName:(NSString *)name;

- (void)setUndoAction:(NSString *)undoAction redoAction:(NSString *)redoAction;
@end