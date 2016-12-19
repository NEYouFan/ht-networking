//
//  HTNetworking.h
//  HTHttp
//
//  Created by Wangliping on 16/4/11.
//  Copyright © 2016年 NetEase. All rights reserved.
//

#ifndef HTNetworking_h
#define HTNetworking_h

#if __has_include("HTBaseRequest.h")
#import "HTBaseRequest.h"
#import "HTAutoBaseRequest.h"
#import "HTHTTPModel.h"
#import "NSObject+HTModel.h"
#import <Core/NSObject+HTMapping.h>
#import <Core/HTBaseRequest+Advanced.h>
#import <Core/HTBaseRequest+RACSupport.h>
#import <Cache/NSURLRequest+HTCache.h>
#import <Cache/NSURLResponse+HTCache.h>
#import <Freeze/NSURLRequest+HTFreeze.h>
#import <Core/HTNetworkingHelper.h>
#import <Core/HTMockURLResponse.h>
#endif

#if __has_include(<RestKit/RestKit.h>)
#import <RestKit/RestKit.h>
#endif

#if __has_include(<RestKit/Network/RKRequestTypeOperation.h>)
#import <RestKit/Network/RKRequestTypeOperation.h>
#endif

#if __has_include(<Support/HTHttpLog.h>)
#import <Support/HTHttpLog.h>
#endif

#if __has_include(<Cache/HTCacheManager.h>)
#import <Cache/HTCacheManager.h>
#import <Cache/HTCachePolicyManager.h>
#endif

#if __has_include(<ReactiveCocoa/ReactiveCocoa.h>)
#import <ReactiveCocoa/ReactiveCocoa.h>
#endif

#if __has_include(<Freeze/HTFreezeManager.h>)
#import <Freeze/HTFreezeManager.h>
#import <Freeze/HTFreezePolicy.h>
#import <Freeze/HTFreezePolicyMananger.h>
#endif

#endif /* HTNetworking_h */
