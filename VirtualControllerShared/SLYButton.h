//
//  SLYButton.h
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/24/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const SLYButtonUserDataTitleKey;
FOUNDATION_EXPORT NSString * const SLYButtonUserDataTextureAtlasNameKey;
FOUNDATION_EXPORT NSString * const SLYButtonUserDataUpTextureNameKey;
FOUNDATION_EXPORT NSString * const SLYButtonUserDataDownTextureNameKey;
FOUNDATION_EXPORT NSString * const SLYButtonUserDataSoundFileNameKey;
FOUNDATION_EXPORT NSString * const SLYButtonUserDataUpActionNameKey;
FOUNDATION_EXPORT NSString * const SLYButtonUserDataDownActionNameKey;

@interface SLYButton : SKSpriteNode

@property (weak, nullable) id target;

@property (nullable) SEL action;
@property (nullable) SEL upAction;
@property (nullable) SEL downAction;

@property (nullable) NSString *title;
@property (nullable) NSString *textureAtlasName;
@property (nullable) NSString *upTextureName;
@property (nullable) NSString *downTextureName;
@property (nullable) NSString *soundFileName;
@property (nullable) NSString *skUpActionName;
@property (nullable) NSString *skDownActionName;

@property (nullable) SKTextureAtlas *textureAtlas;
@property (nullable) SKTexture *upTexture;
@property (nullable) SKTexture *downTexture;
@property (nullable) SKAction *skUpAction;
@property (nullable) SKAction *skDownAction;

@property (class) NSString *defaultTextureAtlasName;
@property (class) NSString *defaultUpActionName;
@property (class) NSString *defaultDownActionName;

@end

@interface SKNode (SLYButton)
- (SLYButton *)buttonWithName:(NSString *)name;
- (SLYButton *)buttonWithName:(NSString *)name forceConfigure:(BOOL)forceConfig;
@end

NS_ASSUME_NONNULL_END
