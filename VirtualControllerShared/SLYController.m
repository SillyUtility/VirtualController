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

@interface SLYController ()
@property SKReferenceNode *referenceNode;
@end

@implementation SLYController

- (void)configure
{
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
