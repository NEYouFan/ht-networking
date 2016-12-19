//
//  HTHttpTest.h
//  HTHttp
//
//  Created by NetEase on 15/8/7.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#ifndef HTHttp_HTHttpTest_h
#define HTHttp_HTHttpTest_h

#import "RKRequestProvider.h"
#import "AFNetworking.h"
#import "RestKit.h"
#import "HTConfigDelegateObject.h"
#import "HTHTTPRequestOperation.h"
#import "HTNetworking.h"
#import <OCMock/OCMock.h>
#import <OCMock/NSNotificationCenter+OCMAdditions.h>

// If Kiwi has been imported, skip Hamcrest
#ifndef KW_VERSION
#define HC_SHORTHAND
#import "OCHamcrest.h"
#endif

#define EXP_SHORTHAND
#import "Expecta.h"

#endif
