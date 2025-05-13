//
//	GameViewController.m
//	ControllerApp
//
//	Created by Eddie Hillenbrand on 4/14/25.
//	Copyright © 2025 Silly Utility. All rights reserved.
//

#import <os/log.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

#import "GameViewController.h"
#import "GameScene.h"
#import "NSObject+PeerID.h"

#define Log(fmt, ...) os_log(OS_LOG_DEFAULT, "[VirtualController(iOS.GameViewController)] " fmt "\n", ##__VA_ARGS__)

@interface GameViewController () <MCSessionDelegate,
	MCNearbyServiceAdvertiserDelegate>
@property GameScene *sceneNode;

/* Multipeer Connectivity */

@property MCNearbyServiceAdvertiser *serviceAdvertiser;
@property MCSession *peerSession;
@property NSUInteger maxPeers;

- (void)beginPeerSession;
- (void)endPeerSession;

@property MCPeerID *macPeerID;

@end

@implementation GameViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	// Load the SKScene from 'GameScene.sks'
	self.sceneNode = (GameScene *)[SKScene nodeWithFileNamed:@"GameScene"];
	self.sceneNode.inputReporter = self;

	self.sceneNode.scaleMode = SKSceneScaleModeResizeFill;

	SKView *skView = (SKView *)self.view;

	// Present the scene
	[skView presentScene:self.sceneNode];

	//SKView.showsFPS = YES;
	//skView.showsNodeCount = YES;

	[self beginPeerSession];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		return UIInterfaceOrientationMaskLandscape;
		//return UIInterfaceOrientationMaskAllButUpsideDown;
	} else {
		return UIInterfaceOrientationMaskAll;
	}
}

- (BOOL)prefersStatusBarHidden {
	return YES;
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
}

- (void)beginPeerSession
{
	if (!self.peerSession)
		[self createPeerSession];
	[self.serviceAdvertiser startAdvertisingPeer];
}

- (void)endPeerSession
{
	[self.serviceAdvertiser stopAdvertisingPeer];
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
		self.macPeerID = peerID;
		return;
	case MCSessionStateConnecting:
		Log("peer=%{public}@ is connecting", peerID);
		return;
	case MCSessionStateNotConnected:
		Log("peer=%{public}@ disconnected", peerID);
		self.macPeerID = nil;
		return;
	default:
		Log("Unknown peer session state change %ld", (long)state);
	}
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data
	fromPeer:(MCPeerID *)peerID
{
	Log("%{public}s peer=%{public}@", __func__, peerID);
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

#pragma mark - Input Reporting

- (void)sendInputReport:(void *)report size:(size_t)reportSize
{
	NSData *data = nil;
	NSError *err = nil;
	BOOL ret = NO;

	Log("%{public}s", __func__);

	if (!self.peerSession)
		return;

	if (!self.macPeerID)
		return;

	data = [NSData dataWithBytes:report length:reportSize];
	ret = [self.peerSession sendData:data
        toPeers:self.peerSession.connectedPeers
        withMode:MCSessionSendDataReliable
        error:&err
    ];
	if (!ret || err) {
		Log("Faild sending input report err=%{public}@", err);
		return;
	}

	Log("Sent input report");
}

@end
