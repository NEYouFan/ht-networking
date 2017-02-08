//
//  HTKVCHandler.h
//  Pods
//
//  Created by Wangliping on 15/12/9.
//
//

#import <Foundation/Foundation.h>
#import "RKMappingOperation.h"

@interface HTModelMappingHandler : NSObject <RKMappingOperationDelegate>

+ (instancetype)sharedInstance;

@end
