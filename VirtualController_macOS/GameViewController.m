//
//  GameViewController.m
//  VirtualController_macOS
//
//  Created by Eddie Hillenbrand on 4/14/25.
//

#import <os/log.h>

#import "GameViewController.h"
#import "GameScene.h"

#import "VirtualController-Swift.h"
#import "NSApplication+Additions.h"
#import "AppDelegate.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(GameViewController)] " fmt "\n", ##__VA_ARGS__)

static void *SLYDriverInstallationStateKVOContext = &SLYDriverInstallationStateKVOContext;
static void *SLYDriverIPCConnectionKVOContext = &SLYDriverIPCConnectionKVOContext;

@interface GameViewController () <NSWindowDelegate>
@property GameScene *sceneNode;
@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	Log("%{public}s", __func__);

    self.sceneNode = [GameScene newGameScene];

    // Present the scene
    SKView *skView = (SKView *)self.view;
    [skView presentScene:self.sceneNode];
    
    skView.ignoresSiblingOrder = YES;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;

	[self addObservers];
	
	[NSApp.appDelegate.driverIPC connect];
	//[NSApp.appDelegate.driverInstallationController checkExtension];
}

- (void)dealloc
{
	[self removeObservers];
}

#pragma mark - Observers

- (void)addObservers
{
	Log("%{public}s", __func__);

	[NSApp.appDelegate.driverInstallationController addObserver:self
		forKeyPath:@"installed"
		options:NSKeyValueObservingOptionNew
		context:SLYDriverInstallationStateKVOContext
	];

	[NSApp.appDelegate.driverIPC addObserver:self
		forKeyPath:@"connected"
		options:NSKeyValueObservingOptionNew
		context:SLYDriverIPCConnectionKVOContext
	];
}

- (void)removeObservers
{
	Log("%{public}s", __func__);

	[NSApp.appDelegate.driverInstallationController
		removeObserver:self
		forKeyPath:@"installed"
	];
	[NSApp.appDelegate.driverIPC
		removeObserver:self
		forKeyPath:@"connected"
	];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
	ofObject:(id)object
	change:(NSDictionary *)change
	context:(void *)context
{
	Log("%{public}s", __func__);

	if (context == SLYDriverInstallationStateKVOContext) {
		Log("DriverInstallationState CHANGED");
		[self.sceneNode driverInstallationStateChange];
	} else if (context == SLYDriverIPCConnectionKVOContext) {
		Log("DriverIPC CONNECTION CHANGED");
		[self.sceneNode driverIPCStateChange];
	} else {
		[super observeValueForKeyPath:keyPath
			ofObject:object
			change:change
			context:context
		];
	}
}

@end
