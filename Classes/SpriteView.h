//
//  SpriteView.h
//  MapEditor
//
//  Created by graham on 4/29/11.
//  Copyright 2011 Rocket Mobile, Inc. All rights reserved.
//

#import "Sprite.h"

@class SpriteView;
@protocol SpriteViewDelegate
- (void)onSpriteSelected:(SpriteView *)spriteView;
- (void)onSpriteMoved:(SpriteView *)spriteView toPoint:(NSPoint)point;
@end

@interface SpriteView : NSView {
	Sprite *sprite;
	id<SpriteViewDelegate> delegate;
	NSPoint position;
	
	NSImageView *spriteIcon;	
}

- (id)initWithSprite:(Sprite *)aSprite selected:(BOOL)selected;
- (void)setSelected:(BOOL)selected;

@property (readwrite, retain) Sprite *sprite;
@property (readwrite, assign) id<SpriteViewDelegate> delegate;
@property (readonly, assign) NSPoint position;

@end
