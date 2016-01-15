//
//  ViewController.m
//  MCChatiOS
//
//  Created by Nicolas Zinovieff on 2016/01/11.
//  Copyright © 2016 Nicolas Zinovieff. All rights reserved.
//

#import "ViewController.h"
#import "NZChatManager.h"

@interface iViewController () <NZChatManagerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *dnTxt;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *dcBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *hostBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *joinBtn;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textfieldConstraint;
@property (strong, nonatomic) IBOutlet UITextField *sendTxt;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;
@property (strong, nonatomic) IBOutlet UITextView *chatTxt;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendBoxConstraint;

@property(nonatomic, strong) NZChatManager *chatManager;
@end

@implementation iViewController
- (void) updadteUI:(BOOL)animate {
    if(self.chatManager == nil) {
        self.hostBtn.enabled = self.joinBtn.enabled = self.dnTxt.enabled = YES;
        self.dcBtn.enabled = self.sendTxt.enabled = self.sendBtn.enabled = NO;

        if(!animate) {
            self.textfieldConstraint.constant = 0;
            self.sendBoxConstraint.constant = -50;
            [self.view layoutIfNeeded];
        } else {
            [UIView animateWithDuration:1.0
                             animations:^(void) {
                                    self.textfieldConstraint.constant = 0;
                                    self.sendBoxConstraint.constant = -50;
                                 [self.view layoutIfNeeded];
                             }];
        }
    } else {
        self.hostBtn.enabled = self.joinBtn.enabled = self.dnTxt.enabled = NO;
        self.dcBtn.enabled = self.sendTxt.enabled = self.sendBtn.enabled = YES;

        if(!animate) {
            self.textfieldConstraint.constant = -self.dnTxt.frame.size.height;
            self.sendBoxConstraint.constant = 0;
            [self.view layoutIfNeeded];
        } else {
            [UIView animateWithDuration:1.0
                             animations:^(void) {
                                 self.textfieldConstraint.constant = -self.dnTxt.frame.size.height;
                                 self.sendBoxConstraint.constant = 0;
                                 [self.view layoutIfNeeded];
                             }];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self updadteUI:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidAppear:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidDidmiss:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)disconnectAction:(id)sender {
    [self.chatManager disconnect];
    self.chatManager.chatDelegate = nil;
    self.chatManager = nil;

    [self updadteUI:YES];

}
- (IBAction)hostAction:(id)sender {
    NSString *dn = self.dnTxt.text.length > 0 ? self.dnTxt.text : [[UIDevice currentDevice] name];

    if (self.chatManager == nil)
        self.chatManager = [[NZChatManager alloc] initAsHostWithDisplayName:dn];

    self.chatManager.chatDelegate = self;

    [self.dnTxt resignFirstResponder];
    [self updadteUI:YES];
}

- (IBAction)joinAction:(id)sender {
    NSString *dn = self.dnTxt.text.length > 0 ? self.dnTxt.text : [[UIDevice currentDevice] name];

    if (self.chatManager == nil)
        self.chatManager = [[NZChatManager alloc] joinWithDisplayName:dn];

    self.chatManager.chatDelegate = self;

    [self.dnTxt resignFirstResponder];
    [self updadteUI:YES];
}
- (IBAction)sendAction:(id)sender {
    if(self.sendTxt.text.length > 0) {
        [self.chatManager sendMessage:self.sendTxt.text];

        NSString *dn = self.dnTxt.text.length > 0 ? self.dnTxt.text : [[UIDevice currentDevice] name];
        [self chatManager:self.chatManager didReceiveMessage:self.sendTxt.text fromPeer:dn];

        self.sendTxt.text = @"";
    }
}

- (void)chatManager:(NZChatManager *)cm peerDidJoin:(NSString *)displayName {
    if(self.chatTxt.text == nil) self.chatTxt.text = @"";
    NSString *nt = [self.chatTxt.text stringByAppendingFormat:@"%@ did join\n", displayName];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _chatTxt.text = nt;
    });
}

- (void)chatManager:(NZChatManager *)cm peerDidLeave:(NSString *)displayName {
    if(self.chatTxt.text == nil) self.chatTxt.text = @"";
    NSString *nt = [self.chatTxt.text stringByAppendingFormat:@"%@ did leave\n", displayName];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _chatTxt.text = nt;
    });

}

- (void)chatManager:(NZChatManager *)cm didReceiveMessage:(NSString *)msg fromPeer:(NSString *)displayName {
    if(self.chatTxt.text == nil) self.chatTxt.text = @"";
    NSString *nt = [self.chatTxt.text stringByAppendingFormat:@"%@ - %@ : %@\n",[NSDate date], displayName, msg];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _chatTxt.text = nt;
    });

}

- (void)chatManager:(NZChatManager *)cm didReceiveImage:(NSData *)img fromPeer:(NSString *)displayName {
    if(self.chatTxt.text == nil) self.chatTxt.text = @"";
    NSString *nt = [self.chatTxt.text stringByAppendingFormat:@"%@ - %@ : sent an image (unsupperted)\n",[NSDate date], displayName];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        _chatTxt.text = nt;
    });

}

- (void) keyboardDidAppear:(NSNotification*)n {
    double kbH = ([[[n userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height);
    double nc = 0;

    if(self.sendTxt.isFirstResponder) {
        nc = kbH;
    } else {
        nc = 0;
    }

    [UIView animateWithDuration:.2
                     animations:^(void ) {
                         self.sendBoxConstraint.constant = nc;
                         [self.view layoutIfNeeded];
                     }];
}

- (void) keyboardDidDidmiss:(NSNotification*)n {
    [self updadteUI:YES];
}

@end
