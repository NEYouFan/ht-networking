# 如何写RKRequestDescriptor与RKResponseDescriptor

在实际应用HTHTTP或者HTWzp中，主要的工作都是要写RKRequestDescriptor或者RKResponseDescriptor；或者说写Request对应的RKObjectMapping以及Response对应的RKObjectMapping; 后续的自动化生成代码也建立在此基础上，因此本文档主要是详细描述对应不同的JSON, RKObjectMapping应该怎么写.

主要的参考内容包括RestKit代码中的文档，例如RKObjectMananger.h中的例子，以及RestKit的两个官方文档[RestKit](https://github.com/RestKit/RestKit/blob/master/README.md)与[Object-mapping](https://github.com/RestKit/RestKit/wiki/Object-mapping).

## 一 基本写法
主要介绍基本的写法与最初级的例子.


### 1 官方示例
官方文档中是挑选了Arcticle作为例子，但是只包含了Response的，不包含Request的. 下面我从RKObjectManager.h里面挑选的例子并加以解释.
 
    @interface RKWikiPage : NSObject
    @property (nonatomic, copy) NSString *title;
    @property (nonatomic, copy) NSString *body;
    @end
 
    // Construct a request mapping for our class
    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromDictionary:@{ @"title": @"title", @"body": @"body" }];
    
    // We wish to generate parameters of the format: 
    // @{ @"page": @{ @"title": @"An Example Page", @"body": @"Some example content" } }
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:mapping
                                                                                   objectClass:[RKWikiPage class]
                                                                                   rootKeyPath:@"page"];
 
    // Construct an object mapping for the response
    // We are expecting JSON in the format:
    // {"page": {"title": "<title value>", "body": "<body value>"}}
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKWikiPage class]];
    [responseMapping addAttributeMappingsFromArray:@[ @"title", @"body" ]];
 
    // Construct a response descriptor that matches any URL (the pathPattern is nil), when the response payload
    // contains content nested under the `@"page"` key path, if the response status code is 200 (OK)
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                       pathPattern:nil
                                                                                           keyPath:@"page"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];
 
    // Register our descriptors with a manager
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://restkit.org/"]];
    [manager addRequestDescriptor:requestDescriptor];
    [manager addResponseDescriptor:responseDescriptor];
 
    // Work with the object
    RKWikiPage *page = [RKWikiPage new];
    page.title = @"An Example Page";
    page.body  = @"Some example content";
 
    // POST the parameterized representation of the `page` object to `/posts` and map the response
    [manager postObject:page path:@"/pages" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSLog(@"We object mapped the response with the following result: %@", result);
    } failure:nil];

重点关注：
a. RKObjectMapping的写法：

    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKWikiPage class]];
    [responseMapping addAttributeMappingsFromArray:@[ @"title", @"body" ]];
    
Array中的数组就是RKWikiPage类的属性列表.        

注意：下面的写法也是等价的:

    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKWikiPage class]];
    [requestMapping addAttributeMappingsFromDictionary:@{ @"title": @"title", @"body": @"body" }];
    
从这里也可以看出，如果Model的属性名与JSON的key一样，写起来会简单很多.

b. RKResponseDescriptor的写法：
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                       pathPattern:nil
                                                                                           keyPath:@"page"
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]];

注意两点：
1 如果这个responseDescriptor仅仅和这一个请求关联，那么最好pathPattern填上请求的URL的相对路径**"/pages"**, 这样别的请求就不会用这个responseDescriptor去尝试匹配解析；
2 statusCodes可以调整，这里参数的含义是，如果http status code在200到299之间，才会用这个responseDescriptor去解析; 否则不会.
3 keyPath对应JSON格式定义中的key, 所以是page
	
	{"page": {"title": "<title value>", "body": "<body value>"}	
c. RKRequestDescriptor的写法：

    RKObjectMapping *requestMapping = [RKObjectMapping requestMapping];
    [requestMapping addAttributeMappingsFromDictionary:@{ @"title": @"title", @"body": @"body" }];
    
    // We wish to generate parameters of the format: 
    // @{ @"page": @{ @"title": @"An Example Page", @"body": @"Some example content" } }
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:mapping
                                                                                   objectClass:[RKWikiPage class]
                                                                                   rootKeyPath:@"page"];
首先，RKObjectMapping是类似的，在创建requestDescriptor的时候需要指定Mapping, 以及这个mapping对应哪个类，和rookKeyPath.
这个rootKeyPath和上面创建RKResponseDescriptor的keyPath一样，都是与JSON的那个Key对应.

### 2 常见ResponseMapping的写法
#### a 属性名和列表不对应
在上面的例子上，属性列表和key是完全对应的；如下所示：
    
    @interface RKWikiPage : NSObject
    @property (nonatomic, copy) NSString *title;
    @property (nonatomic, copy) NSString *body;
    @end

	// JSON: {"page": {"title": "<title value>", "body": "<body value>"}} 

假如JSON中的Key与属性名不完全一致，例如

	// JSON: {"page": {"serverTitle": "<title value>", "serverBody": "<body value>"}}

那么只需要调整为如下写法即可：
	    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKWikiPage class]];
    [responseMapping addAttributeMappingsFromDictionary:@{ @"serverTitle": @"title", @"serverBody": @"body" }];

**注意：所添加的字典，key是JSON的Key, value是类的属性名字，不可以写反.**

从上面的例子也可以看出，设计服务器API的时候，返回的JSON中的Key尽量能够符合iOS客户端的命名规则，包括避免使用`id`作为Key等；这样有利于自动生成代码.

扩展：如果部分对应，部分不对应，然后是可以结合addAttributeMappingsFromDictionary和addAttributeMappingsFromArray来添加.
例如：

	@interface RKWikiPage : NSObject
    @property (nonatomic, copy) NSString *title;
    @property (nonatomic, copy) NSString *body;
    @property (nonatomic, copy) NSString *name;
    @end

	// JSON: {"page": {"title": "<title value>", "body": "<body value>", "servername":"<server name value>"}}

对应的Mapping为：
	
	RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKWikiPage class]];
	[responseMapping addAttributeMappingsFromArray:@[ @"title", @"body" ]];
    [responseMapping addAttributeMappingsFromDictionary:@{ @"servername": @"name"}];	
#### b JSON条目数与Model属性不完全对应
其次，实际的JSON比RKObjectMapping的条目少或者RKObjectMapping的条目比Model的属性要少，都不会有问题; 条目不对应，也不会有问题；
但是必须保证RKObjectMapping中所涉及到的类的属性一定是实际存在的，否则会出错.

例如：
    
    @interface RKWikiPage : NSObject
    @property (nonatomic, copy) NSString *title;
    @property (nonatomic, copy) NSString *body;
    @property (nonatomic, copy) NSString *name;
    @end

	// JSON: {"page": {"title": "<title value>", "body": "<body value>"}}
	
那么如下几种写法都是合法的：
	    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKWikiPage class]];
    [responseMapping addAttributeMappingsFromArray:@[ @"title", @"body" ]];
    
以及

    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKWikiPage class]];
    [responseMapping addAttributeMappingsFromArray:@[ @"title", @"body", @"name"]];
    
如下的JSON也可以被正确解析，但是没有加入Mapping的Key-Value不会被解析出来：
    	
    	// JSON: {"page": {"title": "<title value>", "body": "<body value>"} }
        // JSON: {"page": {"title": "<title value>", "body": "<body value>"， @“random” : @"hehe"} }
        // JSON: {"page": {"title": "<title value>", "bodyWrong": "<body value>"， @“random” : @"hehe"} }                                                                           

但是下面这种会出错.
        
    	RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKWikiPage class]];
	    [responseMapping addAttributeMappingsFromArray:@[ @"title", @"bodyWrong", @"name"]];

**原因是RKWikiPage类中不存在属性bodyWrong.**
			            
#### c JSON外部没有KeyPath	    
假定JSON如下：

	// JSON: {"title": "<title value>", "body": "<body value>"}
	
也就是说没有外面的Key "page"了，那么RKObjectMapping是不需要调整的，只需要调整创建RKResponseDescriptor的代码，将keyPath参数从@"page"改为nil.   

    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:responseMapping
                                                                                       pathPattern:nil
                                                                                           keyPath:nil
                                                                                       statusCodes:[NSIndexSet indexSetWithIndex:200]]; 
                                                                                       
#### d 包含数组与字典
           
如果包含数组或者字典，但是里面不需要与Model再进行额外的对应，比如说数组中存放的就是字符串，那么写法不需要任何改变.

例如：
    
    @interface RKWikiPage : NSObject
    @property (nonatomic, copy) NSString *title;
    @property (nonatomic, strong) NSArray *body;
    @end

	// JSON: {"page": {"title": "<title value>", "body": ["<body value>", "<body value2>"]}}                                                                                       

对应的RKObjectMapping还是如下：
    
    RKObjectMapping *responseMapping = [RKObjectMapping mappingForClass:[RKWikiPage class]];
    [responseMapping addAttributeMappingsFromArray:@[ @"title", @"body" ]];
    
#### e 返回的是一个Model的数组
以官方文档的例子来说明：
JSON如下：

	{ "articles": [
	    { "title": "RestKit Object Mapping Intro",
	      "body": "This article details how to use RestKit object mapping...",
	      "author": "Blake Watters",
	      "publication_date": "7/4/2011"
	    },
	    { "title": "RestKit 1.0 Released",
	      "body": "RestKit 1.0 has been released to much fanfare across the galaxy...",
	      "author": "Blake Watters",
	      "publication_date": "9/4/2011"
	    }]
	}

Model类定义如下：
	
	@interface Article : NSObject
    
    @property (nonatomic, copy) NSString* title;
    @property (nonatomic, copy) NSString* body;
    @property (nonatomic, copy) NSString* author;
    @property (nonatomic) NSDate*   publicationDate;
	
	@end
	
我们要得到的结果是一个存放Article对象的数组，对应的RKResponseDescriptor如下：

	RKObjectMapping* articleMapping = [RKObjectMapping mappingForClass:[Article class]];
	[articleMapping addAttributeMappingsFromDictionary:@{ 
	    @"title": @"title",
	    @"body": @"body",
	    @"author": @"author",
	    @"publication_date": @"publicationDate"
	}];
	
	RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:articleMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"articles" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
	
**可以发现，无论返回的是一个Model的数组还是一个Model, 其对应的RKResponseDescriptor是完全相同的, 不需要为数组添加额外的映射相关的信息**  
    
#### f 简单嵌套
以官方文档中的例子来说明：
JSON:

	{ "articles": [
	    { "title": "RestKit Object Mapping Intro",
	      "body": "This article details how to use RestKit object mapping...",
	      "author": {
	          "name": "Blake Watters",
	          "email": "blake@restkit.org"
	      },
	      "publication_date": "7/4/2011"
	    }]
	}

对应的Model:

	@interface Author : NSObject
	    @property (nonatomic, copy) NSString* name;
	    @property (nonatomic, copy) NSString* email;
	@end
	
	@interface Article : NSObject
	    @property (nonatomic, copy) NSString* title;
	    @property (nonatomic, copy) NSString* body;
	    @property (nonatomic) Author* author;
	    @property (nonatomic) NSDate* publicationDate;
	@end
	
写法：

	// Create our new Author mapping
	RKObjectMapping* authorMapping = [RKObjectMapping mappingForClass:[Author class] ];
	// NOTE: When your source and destination key paths are symmetrical, you can use addAttributesFromArray: as a shortcut instead of addAttributesFromDictionary:
	[authorMapping addAttributeMappingsFromArray:@[ @"name", @"email" ]];
	
	// Now configure the Article mapping
	RKObjectMapping* articleMapping = [RKObjectMapping mappingForClass:[Article class] ];
	[articleMapping addAttributeMappingsFromDictionary:@{
	    @"title": @"title",
	    @"body": @"body",
	    @"publication_date": @"publicationDate"
	}];
	
	// Define the relationship mapping
	[articleMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"author"
	                                                                               toKeyPath:@"author"
	                                                                             withMapping:authorMapping]];
	
	RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:articleMapping
	                                                                                        method:RKRequestMethodAny
	                                                                                   pathPattern:nil
	                                                                                       keyPath:@"articles"
	                                                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
	                                                                                   
尅一看到，核心是RKRelationshipMapping, 注意：**FromKeyPath对应JSON中的Key, toKeyPath对应Model中的属性**. 	                                                                                   
#### g 嵌套数组  
在上一个例子基础上作如下更改：

JSON:

	{ "articles": [
	    { "title": "RestKit Object Mapping Intro",
	      "body": "This article details how to use RestKit object mapping...",
	      "author": [{"name": "Blake Watters", "email": "blake@restkit.org"}, 
	      {"name": "lwang", "email": "lwang@restkit.org"}],
	      "publication_date": "7/4/2011"
	    }]
	}

对应的Model:

	@interface Author : NSObject
	    @property (nonatomic, copy) NSString* name;
	    @property (nonatomic, copy) NSString* email;
	@end
	
	@interface Article : NSObject
	    @property (nonatomic, copy) NSString* title;
	    @property (nonatomic, copy) NSString* body;
	    @property (nonatomic) NSArray* author;
	    @property (nonatomic) NSDate* publicationDate;
	@end

也就是Author变成了一个数组而不是一个Author对象；根据之前得到的结论“**可以发现，无论返回的是一个Model的数组还是一个Model, 其对应的RKResponseDescriptor是完全相同的, 不需要为数组添加额外的映射相关的信息** ”, 这个时候的responseDescriptor不需要做任何修改，和原来一样即可.

#### h 混合
{ "first_name": "Example", "last_name": "McUser", "city": "New York City", "state": "New York", "zip": 10038 }     

TODO: 根据这一条我们可以做多个Model合并过来的需求，这样RequestDescriptor都可以描述.   

TODO: 
{ code: 500, error: 1000, data:{}}
这种如果分在两个Model中，而且keypath都是nil的话，是不可以叠加的；应该是必须用relationMapping才可以搞定.
而且感觉Model还必须嵌套；如果是两个互不包含的Model, 貌似也搞不定.....(这个待研究)

keyPath为nil似乎是可以搞定，否则搞不定.      
                
## 二 进阶
请参阅RestKit官方文档

## 三 高级

问题1: 如果requestDescriptor涉及到多个Model, 应该怎么写？

## 四 常见问题
主要搜集在使用HTHTTP时需要写Object-mapping时遇到的问题与注意事项，待补充

