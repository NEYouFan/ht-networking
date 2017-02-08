# HTHTTP总体设计与架构文档

----

HTHTTP是一个iOS网络框架库，基于RestKit与AFNetworking进行封装，提供对网络请求的描述、发送以及请求结果的解析与映射；并且实现了一套High Level的API, 提供了更高层次的网络访问抽象；此外，额外集成了cache、冻结请求、请求调度等高级功能。

## 一 HTHTTP的目的
1. 请求的描述与请求发送的分离；
2. 更方便的替换底层网络请求发送库；可以扩展支持私有TCP协议；
3. 网络请求返回数据与Model的自动映射；支持不同类型的序列化与反序列化协议。
4. 集成cache冻结请求等功能；
5. 提高请求复用粒度；封装网络请求的细节；
6. 更方便的进行功能的扩展;
7. 结合NEI实现网络请求代码的自动生成.

其中，让应用开发者不需要关心底层的实现，只需要关注请求的描述，是重点；也方便替换底层发送模块和代码的自动生成。

## 二 技术选型与设计思路
### 技术选型
iOS下常见的网络请求库包括:

1. RestKit
2. AFNetworking
3. MKNetworkKit
4. YTKNetworking
5. ASIHTTPRequest

主要是面对HTTP请求，面对私有TCP协议的并没有找到相关涵盖了上层封装的网络框架库；其中，ASIHTTPRequest已经停止设计与维护，MKNetworkKit的实现与设计都相对简单，相对AFNetworking没有任何优势；RestKit提供了强大的Object Mapping功能，AFNetworking主要专注于HTTP请求的发送；YTKNetworking在AFNetworking上做了简单的封装。

我们的选择是RestKit+AFNetworking, 然后在此基础上提供扩展与High level的封装; 原因如下：

1. AFNetworking对于HTTP请求的发送支持得最好，并且不断维护与更新;
2. RestKit集成了强大的数据与Model自动映射的功能，并且将请求的描述与请求的发送分离，二者是一个很松的耦合；对请求的描述与Router等功能也非常强大；
3. RestKit和AFNetworking都向外提供了便利的扩展功能；AFNetworking和RestKit都可以方便的对序列化过程进行扩展, 可以很方便的支持JSON、XML以及一些二进制的序列化协议；RestKit可以方便的扩展以扩充对于请求的调度过程;

存在的问题：

1. RestKit与AFNetworking之间的耦合很紧，直接使用了AFNetworking 1.x的版本；
2. RestKit这一层提供的对于网络请求的操作虽然非常强大，但是学习成本相对比较高；

解决的思路:

1. 解除RestKit与AFNetworking之间的耦合，之前RestKit提供的RKObjectHTTPRequestOperation是直接从AFHTTPRequestOperation中派生，那么通过使用组合来替换集成，从而使得AFNetworking模块能够被替换掉；例如，我们将WZP协议的发送与请求也替换掉了，后续会使用NSURLSession来替换掉现在的NSURLConnection;
2. 通过Command模式来提供一套High Level的API, 将每个请求封装成为一个独立的Request类，这个Request类描述这个请求的属性，将请求的创建、配置、发送、cache的处理等等封装起来，从而将RestKit使用的复杂性封装起来，降低应用开发者使用的难度，并且在此基础上进一步实现代码的自动生成。

### 架构
架构示意图如下：（TODO: 需要画一个图）

1. 最底层是系统提供的API或者通过socket进行请求的发送，例如使用iOS自带的请求API, 那么就是使用NSURLConnection或者NSURLSession; 如果使用私有TCP协议，那么就是使用socket来进行请求的发送；
2. 最底层往上是整个请求的封装以及报文的转换；对于HTTP请求来说，就没有报文转换这一层，有的是请求的发送；例如AFNetworking就是在这一层；HTWzp也是在这一层；HTWzp展示了对于私有TCP协议扩展所需要的元素: HTTP Request请求报文到TCP报文的转换、TCP回应报文到HTTP Response报文的转换、发送的协议接口；
3. RestKit请求调度与Object Mapping这一层, RestKit就在这一层; 提供了请求的调度、对象的映射；此外我们在RestKit的基础上进行了扩展，cache等功能与是在这一层，但cache等功能的实现并不影响原有RestKit的实现。
4. 上层封装；每个请求封装成为一个HTBaseRequest的子类，将通过RestKit创建和发送请求的操作全部封装起来；仅仅将HTBaseRequest的接口开放给外部；

### 代码自动生成

通过上述架构，我们可以发现，应用开发者所需要做的只有如下几件事情：

1. 创建一个HTBaseRequest的子类描述请求，包括URL, HTTP Method等；
2. 创建一个Model类描述请求返回的数据类型；
3. 描述请求的内容与Model的对应关系；

那么结合RestKit的Object Mapping功能、runtime我们能够写出几乎一样模式的请求类，在此基础上就可以实现代码的自动生成了。

### 核心功能
1. AFHTTPRequestOperation: 默认的HTTP请求发送类，来自于AFNetworking;
2. RKObjectRequestOperation: 派生自NSOperation, 包含了请求的调度以及Object Mapping的实施；
3. RKObjectMananger: 对RKObjectRequestOperation的管理；
4. HTBaseRequest: 对请求的描述；
5. HTNetworkAgent: 将HTBaseRequest的配置转为NSURLRequest, 并且通过RKObjectMananger或者RKObjectRequestOperation发送请求，将请求的结果返回给HTBaseRequest.

### 扩展
主要在如下几个方面可以进行扩展：

1. 返回结果的反序列化: 默认支持JSON格式, 可以方便的扩展支持XML以及protobuf, messagePack等二进制格式；
2. 请求模块的扩展: 如上，可以替换掉实际的请求发送模块，从而支持私有TCP协议；
3. 对调度与发送流程的扩展，通过对RKObjectRequestOperation类的派生与派生类的注册，可以接管整个工作流程，从而添加cache, 冻结请求等一系列功能；
4. 对请求配置的扩展: 在RestKit这一层可以传递自己创建的NSURLRequest对象；在上层(HTBaseRequest)，也可以通过`- (void)customRequest:(NSMutableURLRequest *)request`方法来实现对请求的个性化配置.

## 三 参考

关于RestKit与AFNetworking, 请参阅如下链接：

1. [RestKit](https://github.com/RestKit/RestKit)
2. [AFNetworking](https://github.com/AFNetworking/AFNetworking)

Done. 

