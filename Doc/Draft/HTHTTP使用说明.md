# HTHTTP使用说明

本文档主要描述如何使用HTHTTP. 目录如下

 1. [安装](#安装)
 1. [一般使用流程](#一般使用流程)
 1. [Cache的使用](#Cache的使用)
 1. [ReactiveCocoa结合使用](#ReactiveCocoa结合使用)
 1. [上层封装的使用](#上层封装的使用)
 1. [常见问题与注意事项](#常见问题与注意事项)
 1. [Demo示例](#Demo示例)

如果在使用过程中存在问题，可以先查阅"[常见问题与注意事项](#常见问题与注意事项)". 一般情况下，直接通过上层封装好的接口进行使用会更加便捷, 具体可以参阅"[上层封装的使用](#上层封装的使用)".

<h2 id="安装">一 安装</h2>

通过CocoaPods使用HTHTTP库, 在应用工程的podfile中需要添加如下几行：

platform :ios, '7.0'
pod 'HTHttp', :git => 'https://git.hz.netease.com/git/mobile/HTHttp.git', :branch => 'master'
pod 'HTCommonUtility', :git => 'https://git.hz.netease.com/git/mobile/HTCommonUtils.git', :branch => 'master'

Note: HTHttp有不同的分支可以使用，请确认是使用master分支还是其他分支例如wzpSupport分支.

<h2 id="一般使用流程">二 一般使用流程</h2>
 
由于HTHTTP是基于RestKit的，因此一般使用流程也和RestKit一致。由于RestKit提供的接口是非常强大而且灵活的，可以通过RKObjectManager来发起请求，也可以通过RKObjectRequestOperation来发起请求，因为在本文档中为了降低学习成本，只列出一些推荐的、通用的用法；如果希望了解一些更高级的用法，可以参照RestKit的官方文档，也可以直接查阅RKObjectManager.h和RKObjectRequestOperation.h中提供的接口方法进行使用.

### 1 快速入门示例

假定Model类Article定义如下：

	@interface Article : NSObject
	
	@property (nonatomic, copy) NSString * title;
	@property (nonatomic, copy) NSString * author;
	@property (nonatomic, copy) NSString * body;
	
	@end

首先需要创建一个RKObjectManager. 

    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000"]];
    
一般而言，一个应用通常只需要一个RKObjectManager实例. 如果只创建过一个RKObjectManager, 那么可以使用

    [RKObjectManager sharedManager]

来访问这个唯一的RKObjectManager实例.        
    
那么获取一篇文章的信息并且映射到一个数据模型对象中的方法如下:

	// 从/vitural/articles/1234.json获取一篇文章的信息,并把它映射到一个数据模型对象中.
	// JSON 内容: {"article": {"title": "My Article", "author": "Blake", "body": "Very cool!!"}}
	
	// 创建一个RKObjectMapping对象.
	RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[Article class]];
	[mapping addAttributeMappingsFromArray:@[@"title", @"author", @"body"]];
	NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful); // 任何 2xx 状态.
	
	// 创建一个RKResponseDescriptor并且添加到manager中.
	RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/vitural/articles/:articleID" keyPath:@"article" statusCodes:statusCodes];
    [manager addResponseDescriptor:responseDescriptor];
	
	// 发起一个Get请求
	[manager getObject:nil path:@"/vitural/articles/1234.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
	    Article *article = [result firstObject];
	    NSLog(@"Mapped the article: %@", article);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
	    NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];

注意几点：
1 responseDescriptor加到Manager后，不需要重复添加，同一个ResponseDescriptor可以只添加一次；添加一次之后，任何对该path的请求的Response都可以自动被映射到该Model类上, 下次发送请求的时候只需要直接调用就可以了. 例如上面的代码执行过后，如果在另一个不相关的类(例如controller里面)要再次发起该请求，调用方式如下:

	RKObjectManager *manager = [RKObjectManager shareManager];
	[manager getObject:nil path:@"/vitural/articles/1234.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
	    Article *article = [result firstObject];
	    NSLog(@"Mapped the article: %@", article);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
	    NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];

2 parameters正常添加即可，一般是一个字典;

3 如果服务器返回的内容是JSON格式，但是Response Header里面的 MIMETYPE不是，那么需要注册序列化的类. 当然正常情况下，服务器正常开发的话是不会有这个问题的. 不过如果是需要支持XML, 那么需要引入XML解析的类并且进行注册

	// 对于text/plain这种方式, 也使用RKNSJSONSerialization类进行序列化.
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    
4 Get的另一个调用方法是:
    	
    // 发起一个Get请求
	[manager getObjectsAtPath:@"/vitural/articles/1234.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
	    Article *article = [result firstObject];
	    NSLog(@"Mapped the article: %@", article);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
	    NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];
    
  
### 2 Post方法
最基本的Post调用与GET是一致的，只是实际调用的接口不同.

例如：

	// 发起一个POST请求
	[manager postObject:nil path:@"/vitural/articles/1234.json" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
	    Article *article = [result firstObject];
	    NSLog(@"Mapped the article: %@", article);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
	    NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];

同理，parameters正常添加即可，一般是一个字典.    

### 3 自定义Request
    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
     
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl]; 
    NSURLRequest *request = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];
    
    // TODO: 配置请求. Config request.
    
    RKObjectRequestOperation *operation = [_objectManager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
	    Article *article = [result firstObject];
	    NSLog(@"Mapped the article: %@", article);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
	    NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];
    [_objectManager enqueueObjectRequestOperation:operation];

        
### 4 高级应用
由于基本的用法与RestKit一致，因此如果需要了解如何上传表单，创建复杂的ObjectMapping以及应用Route和应用RequestDescritpor，可以参见[RestKit使用与说明][];


<h2 id="Cache的使用">三 Cache的使用</h2>
### 启用Cache相关的功能

如果需要启动Cache相关的功能，那么必须在开始时使用HTHTTPRequestOperation. 否则任何请求都不会保存到cache中，也不会从cache中读取数据, 即使设置了对应请求的cache id.

    [_objectManager registerRequestOperationClass:[HTHTTPRequestOperation class]];

如果直接使用HTBaseRequest以及HTNetworkAgent来发送请求，那么默认情况下Cache是开启的.   
    

<h2 id="ReactiveCocoa结合使用">四 ReactiveCocoa结合使用</h2>
### 基本信号

#### 1 得到RKObjectRequestOperation后信号订阅

	NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		NSLog(@"successful");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
		NSLog(@"fail");
    }];
    
    // 获取到Operation对应的RACSignal.
    RACSignal *signal = [operation rac_enqueueInManager:manager];
    
    // 订阅信号.
    [signal subscribeNext:^(id x) {
    	// 任务获取到的数据. x为实际的RKObjectRequestOperation, 从中可以获取到RequestOperation的数据.
    	if ([x isKindOfClass:[RKObjectRequestOperation class]]) {
            RKObjectRequestOperation *operation = x;
            RKMappingResult *result = operation.mappingResult;
			
			// 结果处理
        }
    } error:^(NSError *error) {
    	// 任务失败
    } completed:^{
    	// 任务成功
    }];
    
通过RKObjectRequestOperation获取到的信号，每次订阅不会重新发起请求；重新获取信号后订阅也不会重新发起请求，请求永远只发送一次.    
    
#### 2 直接通过RKObjectManager使用信号.

    RACSignal *signal = [manager rac_getObjectsAtPath:@"/user" parameters:nil];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];    
    
通过RKObjectManager直接获取的信号，每次订阅不会重新发起请求; 但是每次调用都会创建新的Operaiton，因此获取到的也是新的Signal, 新的Signal被订阅的时候是会发送新的请求的.

#### 3 直接通过RKObjectManager使用信号并且希望每次订阅的时候都发送请求.

    RACSignal *signal = [manager rac_startNewOperationWithObject:nil method:RKRequestMethodGET  path:@"/user" parameters:nil];
    [signal subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }];   

该方法每次都会新创建一个Signal, 该Signal每次订阅的时候都会创建新的RKObjectRequestOperation对象并且发送请求。该Signal是有副作用的.

如果希望同一个信号被多次订阅的时候也不发送新的请求，那么对signal调用replay后再使用，这样就会只发送一次网络请求，但是结果可以多次回调. 例如:

    RACSignal *signal = [manager rac_startNewOperationWithObject:nil method:RKRequestMethodGET  path:@"/user" parameters:nil];
    [[signal replay] subscribeNext:^(id x) {
        NSLog(@"%@ : %@", methodName, x);
    } error:^(NSError *error) {
        NSLog(@"%@ : %@", methodName, error);
    } completed:^{
        NSLog(@"%@ : %@", methodName, @"completed");
    }]; 
    
### 与Signal相关的配置
由于ReactiveCocoa中包含三种类型的事件; 分别是next, error, completed; error和completed能够决定事件流的走向。那么就需要如何定义error; 默认情况下，只有请求出错或者解析过程中出错才会走到error分支，但是如果请求过程和解析过程都是正确的，服务器返回的结果并不是想要的结果或者返回的是一个表示错误的结果，那么默认的逻辑里面不会认为这是一个错误的事件。
因此，RKObjectRequestOperation类里面提供了一个block属性validResultBlock; 如果这个属性被设置，那么使用该block判断解析出来的结果是否合法有效；如果该结果不合法，那么会发送error事件而不是completed事件。

例如，一个典型的validResultBlock是判断结果是否为空或者仅仅有Error Message.

    operation.validResultBlock = ^(RKObjectRequestOperation *operation) {
        RKMappingResult *mappingResult = operation.mappingResult;
        if ([mappingResult count] == 0) {
                return NO;
        }
            
        // Mapping Result仅仅有Error Message, 无效.
        if (1 == [mappingResult count] && [[mappingResult firstObject] isKindOfClass:[RKErrorMessage class]]) {
            return NO;
        }
        
        return YES;
    };

默认情况下，可以为RKObjectManager设置一个validResultBlock, 所有通过RKObjectManager创建出来的operation都会将validResultBlock设置为RKManager的validResultBlock, 这样，如果所有的请求都有统一的逻辑来判定结果是否有效的话，就不需要每个信号单独设置了。
    
### 信号组合使用
#### 多个请求同时执行，互相没有依赖关系

可以直接调用HTOperationHelper中的方法**batchedSignalWith:inManager:**

其原理就是多个信号的Merge.

	+ (RACSignal *)batchedSignalWith:(NSArray *)operationList inManager:(RKObjectManager *)mananger {
	    NSMutableArray *signalList = [NSMutableArray array];
	    for (RKObjectRequestOperation *operation in operationList) {
	        RACSignal *signal = [operation rac_enqueueInManager:mananger];
	        if (nil != signal) {
	            [signalList addObject:signal];
	        }
	    }
	    
	    return [signalList count] > 0 ? [RACSignal merge:signalList] : nil;
	}
	  
#### 多个请求存在互相依赖关系

展示如何利用ReactiveCocoa发送多个相互依赖的请求, 例如，A请求的输出作为B请求的输入继续发送; 并不仅仅是请求的顺序依赖关系，还包括数据的流动.

	- (void)demoDependentRequests {
	    NSString *methodName = NSStringFromSelector(_cmd);
	    RACSignal *signal = [self signalGetUserInfoOperation];
	    RACSignal *combinedSignal = [signal flattenMap:^RACStream *(id value) {
	        NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:@{@"name":@"lwang", @"password":@"test", @"type":@"photolist"}];
	        if ([value isKindOfClass:[RKObjectRequestOperation class]]) {
	            RKObjectRequestOperation *operation = value;
	            RKDemoUserInfo *userInfo = operation.mappingResult.dictionary[@"data"];
	            if ([userInfo.name length] > 0) {
	                parameters[@"name"] = userInfo.name;
	            }
	        }
	        
	        NSURLRequest *request = [_manager requestWithObject:nil method:RKRequestMethodPOST path:@"/collection" parameters:parameters];
	        RKObjectRequestOperation *photoListOperation = [self operationWithRequest:request methodName:methodName];
	        
	        return [self signalOfOperation:photoListOperation];
	    }];
	    
	    [combinedSignal subscribeNext:^(id x) {
	        // 此处x为RKObjectRequestOperation.
	        if ([x isKindOfClass:[RKObjectRequestOperation class]]) {
	            RKObjectRequestOperation *operation = x;
	            RKMappingResult *result = operation.mappingResult;
	            NSLog(@"%@ result : %@", methodName, result);
	        }
	    } error:^(NSError *error) {
	        NSLog(@"%@ : %@", methodName, error);
	    } completed:^{
	        NSLog(@"%@ : %@", methodName, @"completed");
	    }];
	}

#### 如果A成功，那么执行B; 否则执行C.

	- (void)demoIfAThenBElseC {
	    NSString *methodName = NSStringFromSelector(_cmd);
	    RKObjectRequestOperation *operationA = [self getUserInfoOperation];
	    RKObjectRequestOperation *operationB = [self getUserPhotoListInfoOperation];
	    RKObjectRequestOperation *operationC = [self getPhotoListInfoOperation];
	    RACSignal *signal = [HTOperationHelper if:operationA then:operationB else:operationC inManager:self.manager validResultBlock:nil];
	    [signal subscribeNext:^(id x) {
	        NSLog(@"%@ : %@", methodName, x);
	    } error:^(NSError *error) {
	        NSLog(@"%@ : %@", methodName, error);
	    } completed:^{
	        NSLog(@"%@ : %@", methodName, @"completed");
	    }];
	}


<h2 id="上层封装的使用">五 上层封装的使用</h2>

### 基本使用方法
上层封装了一个HTBaseRequest类作为网络请求的基类，SDK的使用者只需要为每一种请求创建一个HTBaseRequest的子类，然后在发送该请求的时候实例化对应子类的对象即可。

第一步:
必须事先配置后要使用的RKObjectManager, 这一步需要在发送所有的请求之前做；建议可以在应用启动的时候就完成该工作. 例如:
    
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:3000"];
    RKObjectManager *manager = [HTNetworkAgentHelper defaultRKObjectManagerWithURL:baseURL errorMsgKeyPath:@"code"];
    // 如果有需要，可以在这里对manager进行配置, 例如编码方式等等.
    
    // 表明HTNetworkAgent只使用这一个manager进行请求的发送.
    [HTNetworkAgent setupWithObjectManager:manager];
    
第二步: 根据请求的类型实现一个HTBaseRequest的子类，并且指定请求的url，参数, response Descriptor等等.
例如，一个简单的GET请求的子类实现如下:

	@implementation HTDemoGetUserInfoRequest
	
	- (NSString *)requestUrl {
	    return @"/user";
	}
	
	+ (RKMapping *)responseMapping {
	    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[RKEUserInfo class]];
	    [mapping1 addAttributeMappingsFromArray:@[@"userId", @"balance"]];
	
	    // 类型不匹配也可以正确解析.
	    [mapping1 addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
	    
	    return mapping1;
	}
	
	+ (NSString *)pathPattern {
	    return @"/user";
	}
	
	+ (NSString *)keyPath {
	    return @"data";
	}
	
	@end
	
从上面的实现代码中我们可以看到这个子类指定了请求的path为/user, 并且指定了返回的JSON结果的Mapping对象，会和RKEUserInfo进行映射. 这里对映射的描述既可以通过responseMapping, pathPattern和keyPath来描述，也可以通过自己创建的ResponseDescriptor来描述.

同理，一个简单的POST请求的子类实现如下：

	@implementation HTDemoGetUserPhotoListRequest
	
	- (RKRequestMethod)requestMethod {
	    return RKRequestMethodPOST;
	}
	
	- (NSString *)requestUrl {
	    return @"/collection";
	}
	
	- (NSDictionary *)requestParams {
	    return @{@"name":@"lwang", @"password":@"test", @"type":@"photolist"};
	}
	
	+ (RKResponseDescriptor *)responseDescriptor {
	    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[HTDemoPhotoInfo class]];
	    [mapping addAttributeMappingsFromArray:[HTDemoHelper getPropertyList:[HTDemoPhotoInfo class]]];
	    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:@"/collection" keyPath:@"photolist" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
	    return responseDescriptor;
	}
	
	@end

这里是指明了这是一个POST请求，然后告知了请求的path和参数, 同时通过responseDescriptor来描述映射关系.

更多高级的用法可以参见HTBaseRequest.h中对于接口的描述与注释.
    
    
### 存在的问题
暂时所有上层封装的请求只能在一个RKObjectManager中工作; 通常情况下也可以满足需求了.
更多问题可以补充在[上层封装的使用与问题](#上层封装的使用)    
更多具体的例子可以参见HTHttpDemo中的“Requests”以及HTWrapRequestTestViewController中的使用.

<h2 id="常见问题与注意事项">六 常见问题与注意事项</h2>
1 
Q: 设置了请求的cache id, 但是cache 没有生效
A: 需要注册HTHTTPRequestOperation或者直接使用HTBaseRequest. 详细可以参见[Cache的使用](#Cache的使用)

2
Q: 服务器返回的数据不是JSON格式，而是XML格式，无法正确解析并且映射成为Model.
A: RestKit中默认已经将XML serializer去掉了，所以你如果希望解析XML的话，那么需要自己准备一个XML解析的类，并且进行注册.
RestKit提供了一个开源的XML解析的类，叫做[RKXMLReaderSerialization](https://github.com/RestKit/RKXMLReaderSerialization)
git地址是：https://github.com/RestKit/RKXMLReaderSerialization
引入到自己的工程后，在整个应用发送请求之前，确保下面的代码被正确调用过即可.

	[RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"application/xml"];

其含义就是告诉RestKit, 对于`application/xml`格式的response，使用RKXMLReaderSerialization类来进行解析；
类似的，也可以实现自己的XML解析类.
更进一步，例如服务器返回的实际是JSON,但是MIME type描述是text/plain; 那么我们可以通过调用下面的方法
	
	[RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];

告诉HTHTTP或者RestKit, 如果MIME type为“text/plain”, 使用RKNSJSONSerialization类进行反序列化.

参考：[Restkit Response in text/xml](http://stackoverflow.com/questions/14876495/restkit-response-in-text-xml)

3 
Q: 如何对Request做更多个性化的配置
A: 如下面所示，如果希望自己对Request进行更灵活的配置，那么可以通过下面的方法创建出自己想要的request或者定制出自己任意想要的NSURLRequest对象后，再通过RKObjectManager提供的方法来创建出自己需要的RKObjectRequestOperation对象进行操作. 
	
	 NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodGET path:@"/user" parameters:nil];
    // Note: 这里可以对Request进行配置.    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
    }];
    [manager enqueueObjectRequestOperation:operation];

当然，通常情况下，你并不需要如此调用. HTHTTP提供的上层封装已经将这些细节封装起来，你自己需要在HTBaseRequest的子类中重写部分方法返回特定的属性即可.
HTBaseRequest类中也提供了如下接口：

	- (void)customRequest:(NSMutableURLRequest *)request;

你可以在子类化一个Request的时候，重写该方法提供你自己想要的任意定制化的Request.

4 baseUrl与requestUrl对于"/"的使用规则
例如：
	
	RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org"]];
	[manager getObjectsAtPath:@"/articles" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    // Handled with articleDescriptor
	} failure:^(RKObjectRequestOperation *operation, NSError *error) {
	    // Transport error or server error handled by errorDescriptor
	}];	

从例子中可以看到，baseUrl是`http://restkit.org`而不是`http://restkit.org/`; path是`/articles`而不是`articles`. 如果请求过程中出现找不到对应的ResponseDecritor的错误，可以检查baseUrl是否正确.

5 
Q: 如何查看返回的JSON对象?
A: 在调试过程中，经常会需要查看返回的原始的JSON数据以确定究竟是网络出错还是Object Mapping出错，这个时候可以在RKResponseMapperOperation.m的main方法中找到如下代码行

	id parsedBody = [self parseResponseData:&error];
	
这里得到的parsedBody就是得到的JSON数据.

或者在获得结果后，通过下面的字符串可以拿到:

	RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org"]];
	[manager getObjectsAtPath:@"/articles" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
		// 获取JSON字符串.
		NSString *reponseString = operation.HTTPOperation.responseString;
		
	} failure:^(RKObjectRequestOperation *operation, NSError *error) {
	    // Transport error or server error handled by errorDescriptor
	}];	

6  关于错误处理
在RestKit中，会根据HTTP Status code做一个判断，如果status code不在200到400之间，那么就会走到error分支，会报错. 如果希望在出错的情况下仍然检查是否有返回的内容被映射成为Model, 可以通过如下方法获取到Response内容转换而成的Model:

	NSArray *mappingResults = [error.userInfo objectForKey:RKObjectMapperErrorObjectsKey];
	
这个数组中存放的是解析出来的Model对象的列表.

如果是使用实现HTBaseRequest子类的方式来发送请求，那么可以在子类里面实现方法validResultBlock方法来使得收到的结果不合法时，自动走到出错的回调. 

如下代码所示，表示当没有解析出任何结果时，会走到failure的block回调中去.

	- (HTValidResultBlock)validResultBlock {
	    return ^(RKObjectRequestOperation *operation) {
	        RKMappingResult *result = operation.mappingResult;
	        if (0 == [result count]) {
	            return NO;
	        }
	        
	        return YES;
	    };
	}

7 
Q: 如何让同一个RKObjectManager支持不同的baseUrl的请求?
A: 原则上，RestKit中一个RKObjectManager是对应一个baseUrl的，所有的请求都必须基于这一个baseUrl, 否则，ObjectMapping会找不到对应请求的Response Descriptor, 从而无法得到正确的数据. 但通过调整Restkit后，我们可以支持同一个RKObjectManager支持不同的baseUrl.

对于调用者来说，就是RKResponseDescriptor的Path Pattern和请求时的path都传全路径即可. 示例如下：

    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[RKEUserInfo class]];
    [mapping1 addAttributeMappingsFromArray:@[@"userId", @"balance"]];
    
    [mapping1 addAttributeMappingsFromDictionary:@{@"version":@"name", @"status":@"password"}];
    // RKObjectManager修正后, Path pattern可使用全路径.
    RKResponseDescriptor *responseDescriptor1 = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"http://localhost:3000/user" keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://baidu:3000"]];
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];
    [manager addResponseDescriptor:responseDescriptor1];
    
    [manager getObject:nil path:@"http://localhost:3000/user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"success");
        [self showResult:YES operation:operation result:mappingResult error:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"failure");
        
        NSLog(@"Loaded this error: %@", [error localizedDescription]);
        
        // You can access the model object used to construct the `NSError` via the `userInfo`
        RKErrorMessage *errorMessage =  [[error.userInfo objectForKey:RKObjectMapperErrorObjectsKey] firstObject];
        NSLog(@"%@", errorMessage);
        
        [self showResult:NO operation:operation result:nil error:error];
    }];

RKObjectManager的baseUrl为**@"http://baidu:3000"**, 而getObject的参数path和创建RKResponseDescriptor的pathPattern为**@"http://localhost:3000/user"**，即实际请求的全路径. 



<h2 id="Demo示例">七 Demo示例</h2>

具体的例子可以参见HTHttpDemo中的例子.


[RestKit使用与说明]: https://github.com/RestKit/RestKit/blob/master/README.md
[上层封装的使用与问题]:上层封装的使用与问题.md
