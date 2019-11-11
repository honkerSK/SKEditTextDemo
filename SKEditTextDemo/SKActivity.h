//
//  SKActivity.h
//  SKEditTextDemo
//
//  Created by cqmac on 2019/11/11.
//  Copyright © 2019 KentSun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SKActivity : NSObject

// [ { "content": "string", "type": 0 }]
@property (nonatomic, strong) NSMutableArray *content;

@end

NS_ASSUME_NONNULL_END
