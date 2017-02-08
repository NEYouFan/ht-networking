# HTCache详细设计文档
==============================================================================================================================

## 一 接口设计
### 1.1 扩展NSURLRequest

	@interface NSURLRequest (HTCache)
	
	@property (nonatomic, assign) NSInteger ht_cachePolicy;
	// cache策略Id. 可以根据该Id找到对应的cache类
	
	@property (nonatomic, assign) BOOL ht_isCached;
	// 该request是否已经被Cache了.
	
	- (NSString *)cacheKey;
	// 根据request生成唯一的cacheKey便于持久化存储以及查找对应的response
	
	@end
	
**Note: 	** 思考：cacheKey的生成会允许根据cache策略的不同来调整生成算法；例如用户可以定义某一个cache策略类，生成cacheKey的时候忽略URL中的特定参数.
	
	
### 1.2 HTCacheManager管理Cache

	typedef void(^ProgressBlock)(NSInteger progressValue);
	
	@interface HTCacheManager : NSObject
	
	+ (instancetype)sharedManager;
	
	// 将自定义的CacheManager设置为sharedManager，这样用户可以使用自定义的CacheManager.
	+ (void)setSharedManager:(HTCacheManager *)manager;
	
	// 该Request是否存在cache
	- (BOOL)hasCacheForRequest:(NSURLRequest *)request;
	
	// 取出request对应的Cache.
	- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request;
	
	// 缓存request的结果.
	- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request;
	
	// 开放给外部使用的接口
	// 删除与request对应的缓存的response.
	- (void)removeCachedResponseForRequest:(NSURLRequest *)request;
	
	// 清除Cache.
	- (void)removeAllCachedResponses:(ProgressBlock)progress;
	
	// 清除某个时间点之后的所有cache.
	- (void)removeCachedResponsesSinceDate:(NSDate *)date progress:(ProgressBlock)progress;
	
	// 设置默认的Cache超时时间
	- (void)setDefaultExpireTime:(NSTimeInterval)interval;
	
	// 获取到response后，根据服务器返回的结果，设置某一个response的cache超时时间
	- (void)setCacheExpireTime:(NSTimeInterval)interval forResponse:(NSCachedURLResponse *)response;
	
	// 设置某个请求的Cache超时时间. 下次发送相同的request前生效.
	- (void)setCacheExpireTime:(NSTimeInterval)interval forRequest:(NSURLRequest *)request;
	
	// Cache的预设大小. 默认值为5M. 可配置. (TODO: 默认大小需要调整)
	@property (nonatomic, assign) NSUInteger cacheCapacity;
	
	// Cache当前已用大小.
	@property (nonatomic, assign, readonly) NSUInteger curCacheSize;
	
	@end
	
除了限制cache的大小外，如果使用数据库存储cache, 还应该限制记录的条数，否则过多的记录条数既带来性能损耗，又没有实际的意义。	
	
### 1.3 策略管理类HTCachePolicyManager
	
	@interface HTCachePolicyManager : NSObject
	
	// 单例
	+ (instancetype)sharedInstance;
	
	// 根据requestOperation找到对应的处理Cache的策略类.
	- (Class<HTCachePolicyProtocol>)cachePolicyClassForRequest:(HTHTTPRequestOperation *)requestOperation;
	
	// 注册Cache策略类
	- (void)registeCachePolicyWithPolicyId:(int)policyId policy:(Class<HTCachePolicyProtocol>)policy;
	
	// 删除Cache策略类
	- (void)removeCahcePolicyClass:(Class<HTCachePolicyProtocol>)policyClass;
	
	// 删除policy对应的Cache策略类
	- (void)removeCachePolicy:(int)policy;
	
	@end

1 注册的时候应该是一个policyId对应某一个CachePolicy类；而不是一个policyId对应某一个CachePolicy类的实例.
2 HTCachePolicyProtocol应该定义一个类方法而不是一个实例方法; 即策略类是不可配置的，没有属性可以配置.

### 1.4 Cache策略协议

任意一个Cache策略类需要实现遵循如下协议：

	@protocol HTCachePolicyProtocol <NSObject>
	
	@optional
	
	// TODO: 由于CachePolicy不涉及流程，这个方法可有可无. 
	+ (void)processRequest:(HTHTTPRequestOperation*)requestOperation;
	
	@required
	
	// 是否存在Cache.
	+ (BOOL)hasCacheForRequest:(HTHTTPRequestOperation *)requestOperation;
	
	// 取出requestOperation对应的cachedResponse.
	+ (NSCachedURLResponse *)cachedResponseForRequest:(HTHTTPRequestOperation *)requestOperation;
	
	@end
	
### 1.5 Cache 策略id定义

	typedef NS_ENUM(NSUInteger, HTCachePolicyId) {
	    HTCachePolicyNoCache = 0,
	    HTCachePolicyCacheFirst = 1,
	    HTCachePolicyUserDefined = 100,
	};
	
1 0表示客户端不做Cache;
2 Cache策略设置与HTTP默认支持的Cache 无关;
3 用户自定义的CachePolicyId从HTCachePolicyUserDefined往上加，这样方便预留给框架后续添加默认的Cache策略;

### 1.6 默认支持的Cache策略类
需提供如下默认支持的Cache策略类并默认在HTCachePolicyManager中注册

1 有Cache时读取Cache, 不再发送请求；

所有的Cache策略类都从基类HTCachePolicy中派生，基类默认是不做Cache.

**Note:** Cache策略类不处理调度；即“先取Cache数据再发送该请求”这一逻辑从该层去除，移到应用层实现.
	
## 二 工作流程

1 使用RKObjectManager注册派生类HTHTTPRequestOperation, 该类已实现；

    [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
  
  注册后，HTHTTPRequestOperation类中可以处理请求的发送;
    
2 在 HTHTTPRequestOperation的start()方法中，判断是否可以正确取到Cache的response, 可以取到，则结束NSOperation; 否则发送请求.

	- (void)start {
	    Class<HTCachePolicyProtocol> cachePolicyClass = [[HTCachePolicyManager sharedInstance] cachePolicyClassForRequest:self];
	    NSCachedURLResponse *cachedURLResponse = [cachePolicyClass cachedResponseForRequest:self];
	    if (nil != cachedURLResponse) {
	        [self updateResponseWithCache:cachedURLResponse];
	        
	        [self willChangeValueForKey:@"isFinished"];
	        [self didChangeValueForKey:@"isFinished"];
	    } else {
	        [super start];
	    }
	}
	
如果request设定为不使用Cache, 那么实际的过程中只是去内存中查了一下有没有对应的cache策略类，不会有性能损耗；如果配置了使用cache, 那么一定会去做一次查询的；但start不是在主线程中，所以不会阻塞主线程，只是有必要的查询cache的性能损耗.

在这一步中，首先HTCachePolicyManager根据HTHTTPRequestOperation的request的policyId找到对应的cachePolicy类；
如果找不到可以处理的策略类，例如request没有设置使用cache, 对应的policyId没有注册对应的策略类，那么一定不存在该request对应的response的；
如果找到可用的缓存策略类，去获取对应的response;

如果找到cached response, 那么根据取到的cachedURLResponse来更新response和responseData, 结束NSOperation; 流程转到RestKit的RKRequestOperation中处理，即对responseData进行object Mapping.

如果没有找到cached response, 那么正常发送请求；

3 最简单的策略也即默认的策略

	+ (NSCachedURLResponse *)cachedResponseForRequest:(HTHTTPRequestOperation *)requestOperation {
	    HTCacheManager *cacheManager = [HTCacheManager sharedManager];
	    NSURLRequest* request = requestOperation.request;
	    NSCachedURLResponse *cachedResponse = [cacheManager cachedResponseForRequest:request];
	    return cachedResponse;
	}
不需要任何额外的条件，直接根据request去找是否存在对应的cache即可.

**Note:** 原有的设计中，不同的Cache策略类是可以调度请求的，例如取出Cache后仍然发送请求；但现在这一部分已经决定要移到应用层了;
所以Cache策略类只需要根据一定的规则找到对应的request；可以加上一些时间的限制或者版本的限制或者URL的限制等等；总结就是Cache策略类只决定在该策略下能否取到cachedResponse以及cachedResponse是否可用.

4 completionBlock的正确执行
CachePolicy的执行后一定会转到start()方法中，而在这个方法中，内部会在取到response后通知判断isFinished, 从而保证了HTHTTPRequestOperation一定可以正确结束，从而保证ObjectMapping一定可以正确执行；而且RestKit的流程不需要关心responseData是怎么获取的.

5 cached response的save
在 HTTPRequestOperation的completionBlock中，判断该request是否需要缓存到本地，如果需要，则保存；示例代码如下：

	
	[self.HTTPRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
			 // ....
			 
			// 在其中调用HTHTTPRequestOperation的方法来save cache到本地.
	        [weakSelf cacheResponseForOperation:operation];
	        
	 		// ....
	 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			// ...
	 }];
	    
	 // Send the request
	 [self.HTTPRequestOperation start];

## 三 使用流程
### 1 一般使用流程
1 全局设置默认的Cache策略
	RestKit中应该新增设置，设置默认情况下使用的cache策略.

2 对单个request设置cachePolicyId

    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:baseUrl];
    [manager registerRequestOperationClass:[HTHTTPRequestOperation class]];
    
    RKObjectMapping *mapping1 = [RKObjectMapping mappingForClass:[HTHuman class]];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping1 method:RKRequestMethodGET pathPattern:@"/JSON/humans/1.json" keyPath:@"human" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [manager addResponseDescriptor:responseDescriptor];

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/JSON/humans/1.json" relativeToURL:manager.baseURL]];
    request.ht_cachePolicy = 1;
    
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"%@", mappingResult);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    expect(operation.HTTPRequestOperation).to.beKindOf([HTHTTPRequestOperation class]);
    
    [operation start];

### 2 扩展方式
自定义Cache策略类, 注册然后在Cache策略类中做扩展.

	[[HTCachePolicyManager sharedManager] registeCachePolicyWithPolicyId:(HTCachePolicyUserDefined + 1) policy:[MyCachePolicy class]];
	
### 3 扩展HTCacheManager
尽管不建议扩展HTCacheManager, 但是用户也可以自己实现一个HTCacheManager并通过

	+ (void)setSharedManager:(HTCacheManager *)manager;

来使用自定义的HTCacheManager.	

## 四 详细实现的设计
1 cache存储使用数据库(将NSCachedURLResponse编码后的数据存取);
2 cache的版本号存放于数据库中，可以直接增加新的字段或者通过NSCachedURLResponse的userInfo来存放；（具体暂未确定） 
3 暂时只需要实现一个默认的Cache策略类，即根据request生成的key以及设定的过期时间来判断是否有可用的CachedResponse.
4 HTTP 默认Cache 的支持和我们的框架无关
5 RKObjectManager中需要支持一个全局设置来设置是否需要Cache以及CachePolicy是什么

## 五 待讨论的问题

0812问题提出:

1 Cache存储的问题（暂时按照文件来存储）
2 Cache版本的问题（版本号如何定义）
3 要实现哪几个默认的Cache策略类
4 对HTTP默认Cache的支持
5 RKObjectManager中需要支持一个全局设置来设置是否需要Cache.
6 需要确保自定义cache策略类的实现仍然可以保证operation正常的结束流程，让operation的completionblock可以被调用到.
7 cache满的时候自动清理过时的response (怎么决定清理的顺序呢？这里需要读多个文件的)
  暂时不会出现读同一个request的cache的情况.
8 对某个response设置超时时间由谁去决定呢？还是在配置request的时候决定？


讨论更新：0813
1 Cache的存储虽然用文件比较简单，但是考虑今后的使用，决定使用数据库来进行支持；(将NSData存到数据库中)
2 对于缓存后还需要发送请求的情况，需要重新创建一个新的RKHTTPRequestOperation; 但是这样的话，无法将接口开放给CachePolicy类来做
（取得结果后会标识这个结果是从缓存中取到还是从网络请求中取到）
3 与HTTP 的NSURLCache互不影响；不考虑对NSURLCache的支持；如果调用者只需要使用 NSURLCache那么默认设置request不作Cache即可;
如果调用者既使用了NSURLCache, 也使用HTCache, 那么可能会缓存两遍;
4 CachePolicy是以类的方式还是实例的方式，暂时还没有讨论清楚。以实例的方式的话，存在的问题是，如果给cachePolicy设置了属性，那么调用者可能需要给不同的策略配置同一个策略类的不同实例，会比较难控制；但是如果以类的方式的话，控制起来会比较弱，会导致仅仅想更改一个策略的配置的时候，需要准备一个新的策略类；
例如：过期时间的设置；但是现在关于某个request的过期时间的配置也是比较奇怪的；
5 Cache的接口参见 NSURLCache；（要不断考虑自己实现的同系统默认的NSURLCache的差异）


讨论更新：0814
不处理取得缓存后重新发送请求的情况; 因为这个属于调度层面的东西

最新实现细节问题(0814)：
1 过期Cache的删除时机？(现在没有整个的processRequest方法了)
2 如果预先设置request的过期时间，如何保存该时间直到获取到response ? (一种是使用category扩展一个属性)


讨论更新：0821

使用一个新的Model类来保存过期时间等清晰信息，这样HTCacheManager的接口所操作的都要变成HTCacheResponse这个Model类.