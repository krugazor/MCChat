//
//  NZChatManager.h
//  MCChat
//
//  Created by Nicolas Zinovieff on 2016/01/11.
//  Copyright © 2016 Nicolas Zinovieff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@class NZChatManager;

@protocol NZChatManagerDelegate <NSObject>

- (void) chatManager:(NZChatManager*)cm peerDidJoin:(NSString*)displayName;
- (void) chatManager:(NZChatManager*)cm peerDidLeave:(NSString*)displayName;
- (void) chatManager:(NZChatManager*)cm didReceiveMessage:(NSString*)msg fromPeer:(NSString*)displayName;
- (void) chatManager:(NZChatManager*)cm didReceiveImage:(NSData*)img fromPeer:(NSString*)displayName;

@end

@interface NZChatManager : NSObject

@property(strong,nonatomic) id <NZChatManagerDelegate> chatDelegate;

- (instancetype) initAsHostWithDisplayName:(NSString*)n;
- (instancetype) joinWithDisplayName:(NSString*)n;

- (BOOL) isConnected;
- (void) disconnect;

- (void) sendMessage:(NSString*)msg;
- (void) sendImage:(NSData*)d;

@end
