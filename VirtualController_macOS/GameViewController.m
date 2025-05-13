//
//	GameViewController.m
//	VirtualController_macOS
//
//	Created by Eddie Hillenbrand on 4/14/25.
//

#import <os/log.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "GameViewController.h"
#import "GameScene.h"

#import "VirtualController-Swift.h"
#import "NSApplication+Additions.h"
#import "AppDelegate.h"
#import "NSObject+PeerID.h"

static void *SLYDriverInstallationStateKVOContext = &SLYDriverInstallationStateKVOContext;
static void *SLYDriverIPCConnectionKVOContext = &SLYDriverIPCConnectionKVOContext;

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(macOS.GameViewController)] " fmt "\n", ##__VA_ARGS__)

@interface GameViewController () <NSWindowDelegate,
	MCSessionDelegate, MCNearbyServiceAdvertiserDelegate,
	MCNearbyServiceBrowserDelegate>
@property GameScene *sceneNode;

/* Multipeer Connectivity */

@property MCNearbyServiceBrowser *serviceBrowser;
@property MCNearbyServiceAdvertiser *serviceAdvertiser;
@property MCSession *peerSession;
@property NSUInteger maxPeers;

- (void)beginPeerSession;
- (void)endPeerSession;

@property MCPeerID *playerPeerID;

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
	//skView.showsFPS = YES;
	//skView.showsNodeCount = YES;

	[self addObservers];

	[NSApp.appDelegate.driverIPC connect];
	//[NSApp.appDelegate.driverInstallationController checkExtension];

	[self beginPeerSession];
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

#pragma mark - Multipeer Connectivity

- (void)createPeerSession
{
	self.maxPeers = 1;

	self.peerSession = [[MCSession alloc] initWithPeer:self.peerID
		securityIdentity:nil
		encryptionPreference:MCEncryptionOptional
	];
	self.peerSession.delegate = self;

	NSDictionary<NSString *, NSString *> *serviceInfo = @{
		kIdentityKey: kServiceIdentity
	};
	self.serviceAdvertiser = [[MCNearbyServiceAdvertiser alloc]
		initWithPeer:self.peerID
		discoveryInfo:serviceInfo
		serviceType:kServiceType
	];
	self.serviceAdvertiser.delegate = self;

	self.serviceBrowser = [[MCNearbyServiceBrowser alloc]
		initWithPeer:self.peerID
		serviceType:kServiceType
	];
	self.serviceBrowser.delegate = self;
}

- (void)beginPeerSession
{
	if (!self.peerSession)
		[self createPeerSession];
	[self.serviceAdvertiser startAdvertisingPeer];

	if (!self.serviceBrowser) {
		self.serviceBrowser = [[MCNearbyServiceBrowser alloc]
			initWithPeer:self.peerID
			serviceType:kServiceType
		];
		self.serviceBrowser.delegate = self;
	}
	[self.serviceBrowser startBrowsingForPeers];
}

- (void)endPeerSession
{
	[self.serviceAdvertiser stopAdvertisingPeer];
	[self.serviceBrowser stopBrowsingForPeers];
	self.serviceBrowser = nil;
	[self.peerSession disconnect];
}

#pragma mark - Multipeer Connectivity - Session Delegate

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID
	didChangeState:(MCSessionState)state
{
	Log("%{public}s peer=%{public}@", __func__, peerID);
	switch (state) {
	case MCSessionStateConnected:
		Log("peer=%{public}@ connected", peerID);
		self.playerPeerID = peerID;
		[self.sceneNode controllerConnected];
		return;
	case MCSessionStateConnecting:
		Log("peer=%{public}@ is connecting", peerID);
		[self.sceneNode controllerConnecting];
		return;
	case MCSessionStateNotConnected:
		Log("peer=%{public}@ disconnected", peerID);
		[self.sceneNode controllerDisconnected];
		self.playerPeerID = nil;
		return;
	default:
		Log("Unknown peer session state change %ld", (long)state);
	}
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data
	fromPeer:(MCPeerID *)peerID
{
	Log("%{public}s peer=%{public}@", __func__, peerID);

	[NSApp.appDelegate.driverIPC sendInputReport:data.bytes size:data.length];
}

- (void)session:(MCSession *)session
	didReceiveStream:(NSInputStream *)stream
	withName:(NSString *)streamName
	fromPeer:(MCPeerID *)peerID
{
	Log("%{public}s", __func__);
}

- (void)session:(MCSession *)session
	didStartReceivingResourceWithName:(NSString *)resourceName
	fromPeer:(MCPeerID *)peerID
	withProgress:(NSProgress *)progress
{
	Log("%{public}s", __func__);
}

- (void)session:(MCSession *)session
	didFinishReceivingResourceWithName:(NSString *)resourceName
	fromPeer:(MCPeerID *)peerID
	atURL:(nullable NSURL *)localURL
	withError:(nullable NSError *)error
{
	Log("%{public}s", __func__);
}

#pragma mark - Multipeer Connectivity - Service Advertiser Delegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
	didReceiveInvitationFromPeer:(MCPeerID *)peerID
	withContext:(nullable NSData *)context
	invitationHandler:(void (^)(BOOL accept, MCSession * __nullable session))invitationHandler
{
	Log("%{public}s peer=%{public}@", __func__, peerID);
	if (self.peerSession.connectedPeers.count < self.maxPeers)
		invitationHandler(true, self.peerSession);
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser
	didNotStartAdvertisingPeer:(NSError *)error
{
	Log("%{public}s error=%{public}@", __func__, error);
}

#pragma mark - Multipeer Connectivity - Nearby Service Browser Delegate

- (void)browser:(MCNearbyServiceBrowser *)browser
	foundPeer:(MCPeerID *)peerID
	withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info
{
	Log("%{public}s peer=%{public}@", __func__, peerID);
	NSString *serviceIdentity = info[kIdentityKey];
	if (![serviceIdentity isEqualToString:kServiceIdentity])
		return;
	if (self.peerSession.connectedPeers.count < self.maxPeers)
		[self.serviceBrowser invitePeer:peerID
			toSession:self.peerSession
			withContext:nil
			timeout:10
		];
}

- (void)browser:(MCNearbyServiceBrowser *)browser
	lostPeer:(MCPeerID *)peerID
{
	Log("%{public}s peer=%{public}@", __func__, peerID);
}

- (void)browser:(MCNearbyServiceBrowser *)browser
	didNotStartBrowsingForPeers:(NSError *)error
{
	Log("%{public}s error=%{public}@", __func__, error);
}

@end
