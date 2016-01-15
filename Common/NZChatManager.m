//
//  NZChatManager.m
//  MCChat
//
//  Created by Nicolas Zinovieff on 2016/01/11.
//  Copyright © 2016 Nicolas Zinovieff. All rights reserved.
//

#import "NZChatManager.h"
#import "NZChatMessage.h"

static NSString * const AppServiceType = @"chat-service";

@interface NZChatManager () <MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate>
@property(nonatomic, copy) NSString *displayName;
@property(nonatomic, strong) MCPeerID *localPeerID;
@property(nonatomic, strong) MCNearbyServiceAdvertiser *advertiser;
@property(nonatomic, strong) MCNearbyServiceBrowser *browser;
@property(nonatomic) MCSession *session;
@end

@implementation NZChatManager

- (MCSession*) createOrGetSession {
    if(self.session == nil) {
        
        self.session = [[MCSession alloc] initWithPeer:self.localPeerID
                                      securityIdentity:nil
                                  encryptionPreference:MCEncryptionNone];
        self.session.delegate = self;
    }
    
    return self.session;
}

- (instancetype)initAsHostWithDisplayName:(NSString *)n {
    self.displayName = n;
    
    self.localPeerID = [[MCPeerID alloc] initWithDisplayName:n];
    
    self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.localPeerID
                                                        discoveryInfo:nil
                                                          serviceType:AppServiceType];
    
    self.advertiser.delegate = self;
    [self.advertiser startAdvertisingPeer];
    
    return self;
}

- (void) advertiser:(MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer:(MCPeerID *)peerID
        withContext:(NSData *)context
  invitationHandler:
(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    [self createOrGetSession];
    
    invitationHandler(YES, self.session);
}

- (instancetype)joinWithDisplayName:(NSString *)n {
    self.localPeerID = [[MCPeerID alloc] initWithDisplayName:n];
    
    self.browser = [[MCNearbyServiceBrowser alloc]
                    initWithPeer:self.localPeerID
                    serviceType:AppServiceType];
    
    self.browser.delegate = self;
    
    [self.browser startBrowsingForPeers];
    
    return self;
}

- (void)        browser:(MCNearbyServiceBrowser *)browser
              foundPeer:(MCPeerID *)peerID
      withDiscoveryInfo:(nullable NSDictionary<NSString *, NSString *> *)info {
    [browser invitePeer:peerID
              toSession:[self createOrGetSession]
            withContext:nil
                timeout:30.0]; // 30s
}

// A nearby peer has stopped advertising.
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID {
    
}

- (BOOL)isConnected {
    return self.session != nil;
}

- (void)disconnect {
    [self.session disconnect];
    self.session = nil;
}

- (void)sendMessage:(NSString *)msg {
    NZChatMessage *m = [NZChatMessage new];
    m.message = msg;
    
    NSData * md = [NSKeyedArchiver archivedDataWithRootObject:m];
    
    [self.session sendData:md
                   toPeers:self.session.connectedPeers
                  withMode:MCSessionSendDataReliable
                     error:nil];
}

- (void)sendImage:(NSData *)d {
    NZChatMessage *m = [NZChatMessage new];
    m.image = d;
    
    NSData * md = [NSKeyedArchiver archivedDataWithRootObject:m];
    
    [self.session sendData:md
                   toPeers:self.session.connectedPeers
                  withMode:MCSessionSendDataReliable
                     error:nil];
    
}

- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    switch (state) {
            
        case MCSessionStateNotConnected:
            [self.chatDelegate chatManager:self peerDidLeave:peerID.displayName];
            break;
        case MCSessionStateConnecting:break;
        case MCSessionStateConnected:
            [self.chatDelegate chatManager:self peerDidJoin:peerID.displayName];
            break;
    }
}

- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NZChatMessage *m = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if(m.image != nil) {
        [self.chatDelegate chatManager:self didReceiveImage:m.image fromPeer:peerID.displayName];
    } else if(m.message != nil) {
        [self.chatDelegate chatManager:self didReceiveMessage:m.message fromPeer:peerID.displayName];
    }
}

- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    
}

- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    
}


@end
