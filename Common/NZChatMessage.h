//
//  NZChatMessage.h
//  MCChat
//
//  Created by Nicolas Zinovieff on 2016/01/11.
//  Copyright © 2016 Nicolas Zinovieff. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NZChatMessage : NSObject <NSSecureCoding>
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) NSData* image;

@end
