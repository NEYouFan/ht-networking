# HTHTTP客户端Mock数据快速使用文档

---

主要描述使用HTHTTP如何快速在iOS客户端Mock数据。

## 一 在HTBaseRequest层面Mock数据
### 核心步骤
1. 对全局的`HTNetworkAgent`单例配置时调用`enableMockTest`.
2. 创建实际Request类的对象并且设置`enableMock`属性为YES;
3. 设置该对象的mock数据内容；常见有两种选择，一是设置mockResponseObject为合法的JSON对象；或者 设置mockJsonFilePath为合法的JSON文件（前提是JSON文件需要添加到工程中;
4. 发送请求;

### 示例代码

```objective-c

- (void)testMockWithRequest {
    [[HTNetworkAgent sharedInstance] enableMockTest];
    HTMockUserInfoRequest *request = [[HTMockUserInfoRequest alloc] init];
    request.enableMockTest = YES;
    
    // 设置Mock数据内容.
    request.mockResponseObject =
          @"data": @{
                  @"accessToken": @"d77fc418-d595-4623-bc23-90f7123bc551",
                  @"admin": @(YES),
                  @"expireIn": @(604800),
                  @"refreshToken": @"2d7ed9af-ac5a-4fda-8c45-4af6341aeb5a",
                  @"refreshTokenExpireIn": @(2592000),
                  @"userName": @"叶锋",
                  @"yunxinToken":@"2g7gdgaf-acda-4gda-8cd5-4afd341ded5d"
                  },
          @"code": @(200)};
    };
    
    // 或者设置Mock的JSON文件，文件需要添加到工程中.
 	// request.mockJsonFilePath = [[NSBundle mainBundle] pathForResource:@"HTMockAuthorize" ofType:@"json"];
 	
    [request startWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
    	// ...
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
		// ...
	}];
}

```

如果希望根据请求来控制返回不同的数据，可以设置mockBlock;

```objective-c

 request.mockBlock = ^(NSURLRequest *mockRequest) {
 		// 此处可以根据mockRequest的内容来进行判断，模拟不同的数据.
        mockRequest.ht_mockResponseObject =
        @{
          @"data": @{
                  @"accessToken": @"d77fc418-d595-4623-bc23-90f7123bc551",
                  @"admin": @(YES),
                  @"expireIn": @(604800),
                  @"refreshToken": @"2d7ed9af-ac5a-4fda-8c45-4af6341aeb5a",
                  @"refreshTokenExpireIn": @(2592000),
                  @"userName": @"叶锋",
                  @"yunxinToken":@"2g7gdgaf-acda-4gda-8cd5-4afd341ded5d"
                  },
          @"code": @(200)
          };
    };

```

此外，还可以模拟出错的case, 主要通过设置mockError和mockResponse来完成;

```objective-c

	request.ht_mockError = [NSError errorWithDomain:@"testMockResponseError" code:555 userInfo:nil];

```

## 二 在RestKit层发送请求时Mock数据
### 核心步骤
1. `[manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];`注册Mock数据的RequestOperation.
2. 创建NSURLRequest对象；
3. 设置该对象的mock数据内容；常见有两种选择，一是设置ht_mockResponseObject为合法的JSON对象；或者 设置ht_mockJsonFilePath为合法的JSON文件（前提是JSON文件需要添加到工程中;
4. 发送请求;

### 示例代码

```objective-c

    [manager registerRequestOperationClass:[HTMockHTTPRequestOperation class]];
    NSURLRequest *request = [manager requestWithObject:nil method:RKRequestMethodPOST path:@"/authorize" parameters:nil];
    
    // 设置Mock的数据
    request.ht_mockResponseObject = @{
          @"data": @{
                  @"accessToken": @"d77fc418-d595-4623-bc23-90f7123bc551",
                  @"admin": @(YES),
                  @"expireIn": @(604800),
                  @"refreshToken": @"2d7ed9af-ac5a-4fda-8c45-4af6341aeb5a",
                  @"refreshTokenExpireIn": @(2592000),
                  @"userName": @"叶锋",
                  @"yunxinToken":@"2g7gdgaf-acda-4gda-8cd5-4afd341ded5d"
                  },
          @"code": @(200)};
	
	// 或者设置Mock数据对应的JSON文件
	// NSBundle *curBundle = [NSBundle bundleForClass:[self class]];
    // request.ht_mockJsonFilePath = [curBundle pathForResource:@"HTMockAuthorize" ofType:@"json"];             
   
    RKObjectRequestOperation *operation = [manager objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

    } failure:^(RKObjectRequestOperation *operation, NSError *error) {

    }];

```