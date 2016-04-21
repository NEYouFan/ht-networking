//
//  RKTestEnvironment.h
//  RestKit
//
//  Created by Blake Watters on 1/15/10.
//  Copyright (c) 2009-2012 RestKit. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <OCMock/NSNotificationCenter+OCMAdditions.h>

// If Kiwi has been imported, skip Hamcrest
#ifndef KW_VERSION
    #define HC_SHORTHAND
    #import "OCHamcrest.h"
#endif

#define EXP_SHORTHAND
#import "Expecta.h"

// 通过Include CoreData.h来打开CoreData的测试开关RKCoreDataIncluded.
// 原因是CoreData.h中开启了_COREDATADEFINES_H.
#import <CoreData/CoreData.h>

// TODO: 这里更改这些测试文件是不是也不符合Apache License 2.0 ?
// 另一种做法就是还原回去，单独测试RestKit的代码覆盖率..
//#import <RestKit/RestKit.h>
//#import <RestKit/Testing.h>
#import "RestKit.h"
#import "Testing.h"

/*
 Base class for RestKit test cases. Provides initialization of testing infrastructure.
 */
@interface RKTestCase : XCTestCase
@end

