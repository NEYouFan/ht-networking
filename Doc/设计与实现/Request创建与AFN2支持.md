# HTHttp Request创建与AFNetworking 2.0支持
===============================================================================

## 一 HTHttp Reqeust创建
HTHttp基于RestKit与AFNetworking 2.x, 因此有多种创建Reqeust的方式; 而一般取到了NSURLRequest对象，都可以使用RestKit所提供的Object Mapping功能。

### 1.1 通过RestKit提供的接口创建
#### 通过RKObjectManager直接创建并调度Request
通常情况下，如果不需要对单个Request作特殊的配置，那么不需要拿到NSMutableURLRequest对象，此时，通过RKObjectManager提供的接口直接发起请求即可；发起请求的过程中，NSMutableURLRequest的对象会先被创建.

以下描述的均为**RKObjectManager**所提供的接口方法, 通过下列接口无法获取到request对象, 也不需要手动去发送请求，RestKit会处理请求的发送等相关操作.


1 通过参数path、parameters以及RKObjectManager的baseURL创建出一个'GET'的URL Request(NSMutableURLRequest对象), 然后使用该Request创建出**'RKObjectRequestOperation'**对象，并加入到RKObjectManager的operation queue中.

	- (void)getObjectsAtPath:(NSString *)path
    	          parameters:(NSDictionary *)parameters
        	         success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
            	     failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;
            	     
2 通过参数path、parameters以及RKObjectManager的baseURL创建出一个'POST'的URL Request(NSMutableURLRequest对象), 然后使用该Request创建出**'RKObjectRequestOperation'**对象，并加入到RKObjectManager的operation queue中.

当传递参数object时，会根据object对应的route以及request descriptor来创建对应的Request; 主要包括，根据route来调整实际请求的url path以及根据request descriptor来创建不同的request.

	- (void)postObject:(id)object
	              path:(NSString *)path
	        parameters:(NSDictionary *)parameters
	           success:(void (^)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult))success
	           failure:(void (^)(RKObjectRequestOperation *operation, NSError *error))failure;            	     
3 其他方法如PUT, DELETE, PATCH等

4 提供request descriptor的GET方法


#### 需要先拿到request对象

以下描述的均为RKObjectManager所提供的接口方法.

1 创建普通的request:根据Object, method, path和parameters来创建Request.

	- (NSMutableURLRequest *)requestWithObject:(id)object
	                                    method:(RKRequestMethod)method
	                                      path:(NSString *)path
	                                parameters:(NSDictionary *)parameters;
	                                
示例1：

    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    NSDictionary *parameters = @{@"key":@"value"};
    NSString *getPath = @"photolist";
     
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl]; 
    NSURLRequest *reqeust = [objectManager requestWithObject:nil method:RKRequestMethodGET path:getPath parameters:parameters];

所创建的是一个GET请求的request, 参数会加到URL之上，实际的请求路径为http://localhost:4547/photolist?key=value

示例2：    
如果定义了对应Object的requestDescriptor, 则参见如下示例：
// TODO: 定义Object之后创建Request

2 创建表单上传的Request

	- (NSMutableURLRequest *)multipartFormRequestWithObject:(id)object
    	                                             method:(RKRequestMethod)method
        	                                           path:(NSString *)path
            	                                 parameters:(NSDictionary *)parameters
                	              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block;
    	                                

3 与Object Manager相关的Request创建方法

#### 通过创建RKObjectRequestOperation的方式来创建Request

通过RKObjectManager提供的如下方法可以创建RKObjectRequestOperation对象; 然后调用者可以自己调度该operation, 也可以从RKObjectRequestOperation对象中获取到request.

	- (id)appropriateObjectRequestOperationWithObject:(id)object
	                                           method:(RKRequestMethod)method
	                                             path:(NSString *)path
	                                       parameters:(NSDictionary *)parameters;

示例：

    NSString *url = @"http://localhost:4567";
    NSURL *baseUrl = [[NSURL alloc] initWithString:url];
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:baseUrl];
    RKObjectRequestOperation *operation = [self.objectManager appropriateObjectRequestOperationWithObject:nil method:RKRequestMethodGET path:@"address" parameters:nil];
    
上述示例代码创建了一个RKObjectRequestOperation对象, 可以通过如下方式获取到request (但一般没有必要，只是可以用来检查request创建是否正确等)

	NSURLRequest *request = operation.HTTPRequestOperation.request;
    
也可以直接调度该operation, 例如如下两种方式
	
	// 同步发送该请求
    [operation start];
    [operation waitUntilFinished];    

或者

    // 通过RKObjectManager来调度request
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [manager enqueueObjectRequestOperation:operation];

**建议，仅仅当需要同步发送请求时才通过这种方式创建请求；否则，尽量通过RKObjectManager的接口来创建request.**

### 1.2 自行创建NSMutableURLRequest对象

调用者需要对request做个性化定制时，可以直接通过Apple提供的接口创建NSURLRequest对象或者NSMutableURLRequest对象；然后通过RKObjectManager来调度和发送该request.

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/object_manager/1234/cancel" relativeToURL:self.objectManager.HTTPClient.baseURL]];
    
    // 配置request
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:self.objectManager.responseDescriptors];
    [_objectManager enqueueObjectRequestOperation:operation];


### 1.3 通过AFHttpClient提供的接口创建
AFHttpClient提供了如下接口来创建NSMutableURLRequest对象，RestKit也是使用如下方法; 

	- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
	                                      path:(NSString *)path
	                                parameters:(NSDictionary *)parameters;
	
	- (NSMutableURLRequest *)multipartFormRequestWithMethod:(NSString *)method
	                                                   path:(NSString *)path
	                                             parameters:(NSDictionary *)parameters
	                              constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block;

不推荐使用AFHttpClient的接口来创建request; 
但如果创建了Request, 那么可以使用RestKit提供的Object Mapping功能；方式同自己创建Request一样.


### 1.4 通过AFNetworking 2.x提供的接口创建Request
AFNetworking 2.x并未提供直接创建Request的接口，所有接口都是返回AFHTTPRequestOperation对象；因此尽管从AFHTTPRequestOperation中也可以获取到request对象，但此时该request已经进入调度队列，所以不可以再通过RestKit去处理。

因此，如果希望使用HTHttp, 那么请**不要**使用AFNetworking 2.x的如下接口；否则，直接使用AFNetworking 2.x即可.

	- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSURLRequest *)request
	                                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
	                                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
	
	- (AFHTTPRequestOperation *)GET:(NSString *)URLString
	                     parameters:(id)parameters
	                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
	                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
	                        
### 1.5 推荐用法	                                                
强烈推荐直接通过RKObjectManager来调度发送请求或者通过RKObjectManager来创建请求然后，即尽量使用RKObjectManager提供的接口工作.

示例1: (不需要对request特殊配置)
    
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[RKTestFactory baseURL]];
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[RKTestUser class]];
    [userMapping addAttributeMappingsFromDictionary:@{ @"name": @"name", @"@metadata.query.parameters.userID": @"position" }];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodAny pathPattern:@"/JSON/humans/:userID\\.json" keyPath:@"human" statusCodes:[NSIndexSet indexSetWithIndex:200]];
    [objectManager addResponseDescriptor:responseDescriptor];
    
    __block RKMappingResult *mappingResult = nil;
    [objectManager getObjectsAtPath:@"/JSON/humans/1.json" parameters:@{ @"userID" : @"12" } success:^(RKObjectRequestOperation *operation, RKMappingResult *blockMappingResult) {
        mappingResult = blockMappingResult;
    } failure:nil];
    
示例2: (需要对request特殊配置)	      
           
    NSURLRequest *request = [_objectManager requestWithObject:nil method:RKRequestMethodGET path:@"/the/path" parameters:@{@"key": @"value"}];
    
    // 配置request
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:self.objectManager.responseDescriptors];
    [_objectManager enqueueObjectRequestOperation:operation];      

当然也可以完全自定义创建完整的Reqeust.
示例3: (需要对request特殊配置)	   
           
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/object_manager/1234/cancel" relativeToURL:self.objectManager.HTTPClient.baseURL]];
    
    // 配置request
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:self.objectManager.responseDescriptors];
    [_objectManager enqueueObjectRequestOperation:operation];                    

## 二 HTHttp Request配置与参数解释
如第一部分所述，HTHttp Request创建有多种方式，通过不同的方式进行参数配置也会对request有不同的影响，下面列出通过HTHttp来进行配置对最终生成的request的影响.

### 2.1 配置方式
存在如下有效的配置方式：
1 保持默认配置
2 通过AFHttpClient进行全局配置，不影响已创建的Request
3 通过RKObjectManager进行全局配置，不影响已创建的Request
4 通过AFHTTPClientConfigDelegate提供个性化配置，调用者在获取到request后直接作用于NSURLRequest对象
5 先获取到NSURLRequest对象后，再进行单独配置.
6 通过传入的参数进行配置，主要是传入的参数等，不再额外赘述

其中，通过RKObjectManager进行全局配置的属性（或方法）较少，主要是通过AFHttpClient进行配置, 因此本章重点会描述AFHttpClient所提供的配置接口对于所创建的request的影响.

### 2.2 AFHTTPClient配置
#### AFHTTPClient开放的与配置相关的属性及默认值:
	
	@property (nonatomic, strong) NSURL *baseURL;
	// 根路径. 默认为空. 构造时必须显示传递有效值.
	
	@property (nonatomic, assign) NSStringEncoding stringEncoding;  
	// url encoding方式，默认为NSUTF8StringEncoding. 
	// 对于直接通过AFHTTPClient创建的请求，影响GET请求拼出来URL字符串(例如有中文时), 而且影响POST请求的HTTP BODY.
	// 对于通过RKObjectManager的接口创建出来的请求, 只影响GET请求拼写出来的URL字符串(例如有中文时), 但不影响POST请求的HTTP BODY.
	// 对于表单请求(multipartFormRequestWithMethod)，无论是AFHTTPClient还是RKObjectManager, 都会影响对应的HTTP BODY.
	// 原理: 通过AFNetworking 2.0中的request serializer起作用.
	// TODO: 现在看来，multipartFormRequestWithMethod创建出来的request可能是有问题的. 因为这个时候参数的处理不是通过RestKit来处理的.
	
	
	@property (nonatomic, assign) AFHTTPClientParameterEncoding parameterEncoding;
	// 对于"GET" “HEAD” "DELETE"三类请求之外, 该属性指明用来创建Request对象的参数是如何编码到request body里的. 例如POST请求的HTTP BODY. 
	// 默认值AFFormURLParameterEncoding。
	// 对于通过RKObjectManager的接口创建出来的请求无效. 但RKObjectManager使用了AFHTTPClient的该默认值.
	// 对于AFHTTPClient创建出来的请求也无效. **(TODO: 这里需要额外处理, AFHTTPClient仍然可以正确创建中文参数的正确POST请求)**
	// 原理: 通过AFNetworking 2.0中的request serializer起作用. 但parameterEncoding不同，对应的是不同的request serializer.
	
	@property (nonatomic, assign) NSTimeInterval defaultTimeout;
	// request的默认超时时间.
	// 如果不设置，则创建出来的request的默认超时时间为60s.
	
	@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
	// 安全策略. 默认值为[AFSecurityPolicy defaultPolicy];
	// 对于通过AFHTTPClient创建出来的request无效，直接作用于RKObjectHTTPRequestOperation.
	// 对于通过RKObjectManager的接口创建出来的请求有效.
	
	@property (nonatomic, strong) NSURLCredential *defaultCredential;
	// 默认的URL安全凭据. 作用于Request Operation.
	// 由于AFHTTPClient已不提供RequestOperation, 因此对AFHTTPClient创建出来的Request不起作用.
	// 但是对于任何通过RKObjectManager创建的Request请求或者RequestOperation都起作用.
	
	@property (readwrite, nonatomic, strong) NSDictionary *defaultHeaders;
	// 默认Header. 即对每个HTTP请求都会添加的Header. 
	// 默认添加上的Header参见2.4节 默认的Header.
	// 原理: 通过AFNetworking 2.0中的request serializer起作用.
	
	@property (nonatomic, strong) NSDictionary *defaultParams;
	// 每个请求都需要默认添加的参数.
	// 通过RKObjectManager生效. 即直接通过AFHTTPClient创建的request 不会添加上默认的参数.
	
#### AFHTTPCient开放的与配置相关的方法:

	- (void)addDefaultHeaders:(NSDictionary *)userDefaultHeaders;
	// 在原有默认Headers的基础上增加自定义的Headers;
	// 如果原有默认Headers已有对应的Key, 则直接更新对应的value.
	
	
	- (void)setDefaultHeader:(NSString *)header
                   		value:(NSString *)value;
	// 设置某一个defaultHeader的值. 会影响到defaultHeaders属性.
	// 用于改变某一个Header. 对AFHTTPClient或者RKObjectManager创建的Request对象都生效.
	// value为nil时, 删除对应的header.
	// 原理类似defaultHeaders属性.
	
	- (void)setAuthorizationHeaderWithUsername:(NSString *)username
                                  	   password:(NSString *)password;
	// 根据username和password设置Header "Authorization". 会影响到defaultHeaders属性.
	// 实际添加的Header的Key为"Authorization" Value为 "Basic username:password"在base64加密之后的值.
	// 原理与影响范围类似于defaultHeaders.                                                      		
	
	- (void)setAuthorizationHeaderWithToken:(NSString *)token;
	// 类似于setAuthorizationHeaderWithUsername.
	// 实际添加的header, Key为"Authorization" Value为 "Token token=""@token"". 

	- (void)clearAuthorizationHeader;
	// 清除Header "Authorization"

总结：这几个方法都是与Header有关，而且理论上来说都属于setDefaultHeader的进一步封装.

#### AFHTTPRequestSerializer属性
该属性可以支持AFHTTPClient创建出与AFNetworking 2.x等价的请求；主要是可以对参数进行一些序列化操作；但由于 1）参数的序列化由RestKit完成； 2）Header、编码方式等属性可以通过AFHTTPClient进行设置；因此暂时不会把requestSerializer开放出来，AFHTTPClient也就无法创建与AFNetworking 2.x等价的request请求，只能通过RKObjectManager提供的接口来创建request.	
	@property (readwrite, nonatomic, strong) AFHTTPRequestSerializer *requestSerializer;

### 2.3 RKObjectManager配置

#### RKObjectManager开放的与配置相关的属性:
	
	@property (nonatomic, strong, readwrite) AFHTTPClient *HTTPClient;
	// 通过AFHTTPClient进行配置。 详见'2.2 AFHTTPClient配置'
	
	@property (nonatomic, weak) id<HTRequestConfigDelegate> configDelegate;
	// 通过configDelegate进行个性化的配置.
	
	@property (nonatomic, strong) NSString *requestSerializationMIMEType;
	// 配置默认的序列化类型.
	// 默认值为RKMIMETypeFormURLEncoded.
	// 通过- (instancetype)initWithHTTPClient:(AFHTTPClient *)client创建的manager, 与AFHTTPClient的parameterEncoding有关. 默认也为RKMIMETypeFormURLEncoded.	
	
#### 与配置相关的方法:
	- (void)setAcceptHeaderWithMIMEType:(NSString *)MIMEType;
	// 等价于[manager.HTTPClient setDefaultHeader:@"Accept" value:MIMEType];
	// 即默认添加了一个"Accept"的Header.
	// 通过+ (instancetype)managerWithBaseURL:(NSURL *)baseURL; 创建的manager，默认添加Header为"Accept" : @"application/json";
	// 通过- (instancetype)initWithHTTPClient:(AFHTTPClient *)client创建的manager, 不会设置默认的"Accept"的Header. 
	
#### requestSerializationMIMEType的影响

除了requestSerializationMIMEType外，对于request的影响都体现在第三方对象例如AFHTTPClient中；因此不作额外阐述.

1 对于普通POST请求，会添加Header {"Content-Type":{"%@; charset=%@"}; 其中前面对应的是requestSerializationMIMEType对应的字符串;
2 对于普通POST请求，参数会由requestSerializationMIMEType对应的RKSerialization来处理序列化;

默认有两种序列化方式
MIMEType为RKMIMETypeFormURLEncoded时, 对应的serializationClass为RKURLEncodedSerialization;
MIMEType为RKMIMETypeJSON时，对应的serializationClass为RKNSJSONSerialization;

如果要添加额外的MIMEType, 但是指定的serializationClass为已有的，那么可采用如下方式：

    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/plain"];

那么即使当requestSerializationMIMEType设置为"text/plain"时，也会按照Json的方式来处理参数.

同样，也可以自己扩展一个RKSerialization类，可以参见RKNSJSONSerialization的实现，假如实现了一个RKNSXMLSerialization的类， 那么如下代码可以使得普通的POST请求生成XML格式的HTTP BODY.

	[RKMIMETypeSerialization registerClass:[RKNSXMLSerialization class] forMIMEType:RKMIMETypeXML];
	manager.requestSerializationMIMEType = RKMIMETypeXML;
	
**注意：**	

    [RKMIMETypeSerialization registerClass:[RKNSXMLSerialization class] forMIMEType:RKMIMETypeXML];
    
除了表明Request的MIME Type为RKMIMETypeXML时，由RKNSXMLSerialization进行序列化之外，如果服务器有返回结果，且返回的Content-Type为RKMIMETypeXML时, 结果的解析也是由RKNSXMLSerialization来完成的。
		

#### 额外说明
1 实际创建出来的request受创建request时所创建的参数影响较大，例如，RKRouter可以影响path; Object影响URL Parameter或者HTTP BODY. 
  可以详细参见request创建示例与Demo. (未完成)
2 可以通过注册新的序列化类的方式来扩展不同的序列化方式，默认情况下暂时只支持JSON序列化, 更多扩展详见'五 添加XML序列化方式'
3 defaultHeaders, baseURL只读; 建议在开始使用前通过AFHTTPClient或者HTConfig设置；在使用过程中尽量避免修改全局默认的headers与baseURL. 如果需要对某个request添加额外的Header, 建议在创建request之后，自行更改header.

TODO: AFNetworking 2.x中，如果需要对每个request都做个性化的header配置，是通过每次都重新创建新的requestSerializer对象来做的	

### 2.4 默认配置
使用AFHTTPClient创建的Request得到的默认属性如下： 
Header: (如果AFHTTPClient没有用于创建RKObjectManager，那么不会包含Accept头)

    Accept = "application/json";
    "Accept-Language" = "en;q=1, fr;q=0.9, de;q=0.8, zh-Hans;q=0.7, zh-Hant;q=0.6, ja;q=0.5";
    "User-Agent" = "(null)/(null) (iPhone Simulator; iOS 8.3; Scale/2.00)";
    
Post请求的Header:
    
    Accept = "application/json";
    "Accept-Language" = "en;q=1, fr;q=0.9, de;q=0.8, zh-Hans;q=0.7, zh-Hant;q=0.6, ja;q=0.5";
    "Content-Type" = "application/x-www-form-urlencoded";
    "User-Agent" = "(null)/(null) (iPhone Simulator; iOS 8.3; Scale/2.00)";

Multipart请求的Header

    Accept = "application/json";
    "Accept-Language" = "en;q=1, fr;q=0.9, de;q=0.8, zh-Hans;q=0.7, zh-Hant;q=0.6, ja;q=0.5";
    "Content-Length" = 292;
    "Content-Type" = "multipart/form-data; boundary=Boundary+D17FD07E1E6DF3FF";
    "User-Agent" = "(null)/(null) (iPhone Simulator; iOS 8.3; Scale/2.00)";
    
    

使用RKObjectManager创建的Request得到的默认属性如下：

Header

    Accept = "application/json";
    "Accept-Language" = "en;q=1, fr;q=0.9, de;q=0.8, zh-Hans;q=0.7, zh-Hant;q=0.6, ja;q=0.5";
    "User-Agent" = "(null)/(null) (iPhone Simulator; iOS 8.3; Scale/2.00)";


Post request的Header

    Accept = "application/json";
    "Accept-Language" = "en;q=1, fr;q=0.9, de;q=0.8, zh-Hans;q=0.7, zh-Hant;q=0.6, ja;q=0.5";
    "Content-Type" = "application/x-www-form-urlencoded; charset=utf-8";
    "User-Agent" = "(null)/(null) (iPhone Simulator; iOS 8.3; Scale/2.00)";
    
Multipart请求的Header

    Accept = "application/json";
    "Accept-Language" = "en;q=1, fr;q=0.9, de;q=0.8, zh-Hans;q=0.7, zh-Hant;q=0.6, ja;q=0.5";
    "Content-Length" = 292;
    "Content-Type" = "multipart/form-data; boundary=Boundary+D17FD07E1E6DF3FF";
    "User-Agent" = "(null)/(null) (iPhone Simulator; iOS 8.3; Scale/2.00)";



对比，使用AFNetworking 2.0创建的Request得到的默认属性如下:

### 2.6 通过AFN进行配置 (不推荐)
如果直接通过AFNetworking 2.x提供的接口创建request, 那么请参见AFNetworking 相关文档 

**不推荐通过更改AFHttpClient的request serializer来影响要创建的request, 暂时也未开放对应接口 (15.08.11).**

### 2.7 存在的问题
1 AFHTTPClient直接创建出来的Request和AFN创建出来的不能一一对应上;
2 AFHTTPClient直接创建出来的Request和RKObjectManager创建出来的请求不是完全对等
3 RKObjectManager更换AFHTTPClient后，存在配置缺失的问题；如果原有配置是通过AFHTTPClient来设置的，那么没问题，调用者可以理解；但如果是通过HTConfig来设置的，那么调用者应该是不可以理解的；调用者会认为HTConfig的设置应该仍然生效；
4 RestKit需要添加对XML参数的默认处理方式

## 三 HTHttp Request创建的部分细节剖析
主要在于RestKit在对GET,POST的请求进行处理时逻辑不一致，部分是由AFHttpClient直接处理掉；部分会屏蔽掉原有AFHttpClient的处理，而加上RestKit自己的处理逻辑，故需要作为设计与实现文档的一部分；但不作为对外开放的接口文档.




## 四 AFNetworking 2.x支持

### 1.1 设计思路
RestKit对于AFNetworking的依赖主要体现在：
1 Request的创建；
2 Request的调度与发送；

由于AFNetworking 2.0相对于1.x版本而言，发送部分并没有发生变化；调度部分也仅有少部分修改，而且RestKit通过派生AFHttpRequestOperation的方式自行进行调度。
因此主要的改动集中在对于Request的修改。

#### 1.1.1 Request的创建
AFNetworking 1.x版本依靠AFHttpClient提供NSMutableRequest对象的创建；在2.x版本中，AFHttpClient类被抛弃，request的创建接口被隐藏起来，在AFHttpOperationManager创建AFHttpReqeustOperation时通过request serializer进行创建。

为了尽量减少对于原有代码的修改，我们重写了AFHttpClient类，使用AFNetworking 2.x的reqeust serializer来提供创建request的接口；因此，只需要保证AFHttpClient能够在各种配置下创建出NSMutableURlRequest对象即可。

此外，AFHTTPClient并不会影响AFNetworking部分的逻辑实现，因此，将AFHTTPClient看作是RestKit的一部分；原来一些在RKObjectManager中才扩展出来的属性直接在AFHTTPClient中扩展，一些可以用来设置的属性不再声明为readonly.

#### 1.1.2 Request的配置
如上，在AFNetworking 1.x版本时，可以通过直接配置AFHttpClient来达到customize http request的目的；但是AFNetworking 2.x版本中，很多与request配置相关的信息移到了AFHTTPRequestSerializer; 为了降低用户使用的复杂性，HTHttp的使用者应该通过对AFHttpClient一些属性的配置或者对RKObjectManager的一些属性的配置来创建出不同的request，而不应该要求使用者自己去学习AFHttpRequestSerializer;

应该尽量避免开放AFHttpRequestSerializer的另一个原因是，RestKit一般会在获取到NSMutableURLRequest对象后，自己进行一些参数的处理；而部分处理是与AFHttpRequestSerializer重复的，例如对于POST请求的参数的处理；也就是说，此时对于AFHttpRequestSerializer进行的一些个性化配置，对最终库所创建的NSMutableURLRequest对象是不会生效的.

所以实现过程中重要的一块也是需要添加单元测试的部分就是，通过RKObjectManager或者AFHttpClient的接口进行配置后，可以得到与AFNetworking 2.0等价的NSMutableURLRequest对象；更进一步，使用者大部分情况下应该只关心如何使用RKObjectManager提供的接口进行配置。

#### 1.1.3 responseSerializer的处理
在AFHTTPRequestOperation类中，定义有如下属性：

	@property (nonatomic, strong) AFHTTPResponseSerializer <AFURLResponseSerialization> * responseSerializer;

而实际上，RestKit提供了对于结果的反序列化, 根本不需要AFNetworking 2.x提供的responseSerializer; 同时，AFN 2.x的responseSerializer会对结果进行校验与判断，如何认为结果非法则会抛出错误；默认情况下如果返回的status code不是200～299， 都会报错；而在AFN 2.x报错的情况下，RestKit对于结果的Object Mapping不会进行，因为RestKit认为此时是出现了网络错误。
但按照RestKit自身的设计，只要有错误信息返回，都是需要进行错误信息的解析的。
因此，综合以上两个原因，我们需要确保RKHTTPRequestOperation的responseSerializer永远都是nil的，这样既保证了不会做重复的反序列化，也不会提前抛出错误阻碍错误信息的解析。	

### 2.1 待解决的问题
1 如果其他工程直接引用了AFNetworking 1.x, 则AFHttpClient会有命名冲突；
类似问题：其他工程直接使用了RestKit, 冲突会更多

2 使用AFHttpClient创建的POST请求，与AFNetworking 2.0创建的请求以及RestKit直接创建的请求并不对等

3 RestKit默认只支持Json格式的请求参数与返回内容的解析；暂不支持XML, Text/Plain, Property List等. 
对XML的支持会在近期添加.

## 五 添加XML序列化方式
TODO: 添加property list序列化方式.