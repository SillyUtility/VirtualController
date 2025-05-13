//
//  SLYController.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/25/25.
//  Copyright © 2025 Silly Utility. All rights reserved.
//

#import <os/log.h>

#import "SLYController.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(SLYController)] " fmt "\n", ##__VA_ARGS__)

NSString * const SLYControllerUserDataTextureAtlasNameKey = @"TextureAtlasName";
NSString * const SLYControllerUserDataTextureNameKey = @"TextureName";

@interface SLYController ()
@property SKReferenceNode *referenceNode;
@property (nullable) NSString *textureAtlasName;
@end

@implementation SLYController

+ (NSString *)deviceName
{
	return @"";
}

- (void)configure
{
	if (self.userData[SLYControllerUserDataTextureAtlasNameKey]) {
		self.textureAtlasName = self.userData[SLYControllerUserDataTextureAtlasNameKey];
	}
	SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:self.textureAtlasName];

	if (self.userData[SLYControllerUserDataTextureNameKey]) {
		NSString *textureName = self.userData[SLYControllerUserDataTextureNameKey];
		self.texture = [textureAtlas textureNamed:textureName];
	}

	NSArray *children = self.children;
	for (SKSpriteNode *node in children) {
		if (node.userData[SLYControllerUserDataTextureNameKey]) {
			NSString *textureName = node.userData[SLYControllerUserDataTextureNameKey];
			node.texture = [textureAtlas textureNamed:textureName];
		}
	}
}

@end

@implementation SKNode (SLYController)

- (SLYController *)controllerWithName:(NSString *)name
{
	return [self controllerWithName:name fromScene:name];
}

- (SLYController *)controllerWithName:(NSString *)name fromScene:(NSString *)scene
{
	Log("%{public}s", __func__);

	NSString *filename = [scene stringByAppendingPathExtension:@"sks"];
	NSString *controllerName = [name stringByAppendingString:@"_Controller"];
	NSString *nodePath = [@".//" stringByAppendingString:controllerName];

	Log("name=%{public}@, scene=%{public}@, filename=%{public}@, controllerName=%{public}@, nodePath=%{public}@" ,
		name, scene, filename, controllerName, nodePath);

	SKReferenceNode *referenceNode = [SKReferenceNode referenceNodeWithFileNamed:filename];
	[self addChild:referenceNode];

	SLYController *controller = (SLYController *)[referenceNode childNodeWithName:nodePath];
	controller.referenceNode = referenceNode;

	return controller;
}

@end
