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

@property NSString *title;
@property NSString *textureAtlasName;
@property NSString *upTextureName;
@property NSString *downTextureName;
@property NSString *soundFileName;
@property NSString *upActionName;
@property NSString *downActionName;

@property SKTextureAtlas *textureAtlas;
@property SKTexture *upTexture;
@property SKTexture *downTexture;
@property SKAction *upAction;
@property SKAction *downAction;

@property (class) NSString *defaultTextureAtlasName;
@property (class) NSString *defaultUpActionName;
@property (class) NSString *defaultDownActionName;

@end

NS_ASSUME_NONNULL_END
