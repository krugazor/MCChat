//
//  ViewController.m
//  MCChat
//
//  Created by Nicolas Zinovieff on 2016/01/11.
//  Copyright © 2016 Nicolas Zinovieff. All rights reserved.
//

#import "ViewController.h"
#import "NZChatManager.h"

@interface ViewController () <NZChatManagerDelegate>
@property (strong) IBOutlet NSTextField *dnTxt;
@property (strong) IBOutlet NSButton *hostBtn;
@property (strong) IBOutlet NSButton *joinBtn;
@property (strong) IBOutlet NSButton *dcBtn;
@property (strong) IBOutlet NSTextView *chatTxt;
@property (strong) IBOutlet NSTextField *sendTxt;
@property (strong) IBOutlet NSButtonCell *sendBtn;

@property(nonatomic, strong) NZChatManager *chatManager;
@end


@implementation ViewController

- (void) updadteUI {
    if(self.chatManager == nil) {
        self.hostBtn.enabled = self.joinBtn.enabled = self.dnTxt.enabled = YES;
        self.dcBtn.enabled = self.sendTxt.enabled = self.sendBtn.enabled = NO;
    } else {
        self.hostBtn.enabled = self.joinBtn.enabled = self.dnTxt.enabled = NO;
        self.dcBtn.enabled = self.sendTxt.enabled = self.sendBtn.enabled = YES;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.

    [self updadteUI];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)hostAction:(id)sender {
    NSString *dn = self.dnTxt.stringValue.length > 0 ? self.dnTxt.stringValue : [[NSHost currentHost] localizedName];

    if (self.chatManager == nil)
        self.chatManager = [[NZChatManager alloc] initAsHostWithDisplayName:dn];

    self.chatManager.chatDelegate = self;

    [self updadteUI];

}
- (IBAction)joinAction:(id)sender {
    NSString *dn = self.dnTxt.stringValue.length > 0 ? self.dnTxt.stringValue : [[NSHost currentHost] localizedName];

    if (self.chatManager == nil)
        self.chatManager = [[NZChatManager alloc] joinWithDisplayName:dn];

    self.chatManager.chatDelegate = self;

    [self updadteUI];

}
- (IBAction)sendAction:(id)sender {
    if(self.sendTxt.stringValue.length > 0) {
        [self.chatManager sendMessage:self.sendTxt.stringValue];

        NSString *dn = self.dnTxt.stringValue.length > 0 ? self.dnTxt.stringValue : [[NSHost currentHost] localizedName];
        [self chatManager:self.chatManager didReceiveMessage:self.sendTxt.stringValue fromPeer:dn];

        self.sendTxt.stringValue = @"";
    }
}
- (IBAction)disconnectAction:(id)sender {
    [self.chatManager disconnect];
    self.chatManager.chatDelegate = nil;
    self.chatManager = nil;

    [self updadteUI];

}

- (void)chatManager:(NZChatManager *)cm peerDidJoin:(NSString *)displayName {
    if(self.chatTxt.string == nil) self.chatTxt.string = @"";
    NSString *nt = [self.chatTxt.string stringByAppendingFormat:@"%@ did join\n", displayName];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _chatTxt.string = nt;
    });
}

- (void)chatManager:(NZChatManager *)cm peerDidLeave:(NSString *)displayName {
    if(self.chatTxt.string == nil) self.chatTxt.string = @"";
    NSString *nt = [self.chatTxt.string stringByAppendingFormat:@"%@ did leave\n", displayName];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _chatTxt.string = nt;
    });

}

- (void)chatManager:(NZChatManager *)cm didReceiveMessage:(NSString *)msg fromPeer:(NSString *)displayName {
    if(self.chatTxt.string == nil) self.chatTxt.string = @"";
    NSString *nt = [self.chatTxt.string stringByAppendingFormat:@"%@ - %@ : %@\n",[NSDate date], displayName, msg];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _chatTxt.string = nt;
    });

}

- (void)chatManager:(NZChatManager *)cm didReceiveImage:(NSData *)img fromPeer:(NSString *)displayName {
    if(self.chatTxt.string == nil) self.chatTxt.string = @"";
    NSString *nt = [self.chatTxt.string stringByAppendingFormat:@"%@ - %@ : sent an image (unsupperted)\n",[NSDate date], displayName];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _chatTxt.string = nt;
    });

}


@end
