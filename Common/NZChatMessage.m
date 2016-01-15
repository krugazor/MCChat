//
//  NZChatMessage.m
//  MCChat
//
//  Created by Nicolas Zinovieff on 2016/01/11.
//  Copyright © 2016 Nicolas Zinovieff. All rights reserved.
//

#import "NZChatMessage.h"

@implementation NZChatMessage
+ (BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    if(self.message != nil)
        [coder encodeObject:[self.message dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES] forKey:@"msg"];

    if(self.image != nil)
        [coder encodeObject:self.image forKey:@"img"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)coder {
    NSData *tmp = [coder decodeObjectForKey:@"msg"];
    if(tmp != nil)
        self.message = [[NSString alloc] initWithData:tmp encoding:NSUTF8StringEncoding];

    tmp = [coder decodeObjectForKey:@"img"];
    self.image = tmp;

    return self;
}


@end
