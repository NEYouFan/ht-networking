# HTHTTP自动生成代码需求分析

## 目标
通过服务器端的接口描述，自动生成iOS客户端的请求类与代码；

## 已知条件
NEI的接口描述包括：
1 请求方式；例: GET, POST
2 请求地址；例: /xhr/address/deleteAddress.json
3 输入参数描述; 例: id Number 收货地址id
4 输出参数描述; 例: data Array<ShipAddressVO> 收货地址列表
5 返回结果JSON例子，包括key value等
6 输入参数JSON例子，包括key value等

对应关系：
1 请求方式对应request子类的+ (RKRequestMethod)requestMethod方法；
2 请求地址对应request子类的+ (NSString *)requestUrl方法；
3 输入参数对应request子类的- (NSDictionary *)requestParams方法；
4 输入参数的解析可以通过request子类的+ (RKMapping *)responseMapping来描述 和 + (NSString *)keyPath来描述;

## 典型案例
1 假如存在一个GET请求，返回结果可以表示为如下JSON:

	{"name":"lwang", "password":"hehe", "userId":1000, "balance":2000}

那么和如下Model类一一对应：

	@interface RKEUserInfo : NSObject
	
	@property (nonatomic, copy) NSString *name;
	@property (nonatomic, copy) NSString *password;
	@property (nonatomic, assign) long userId;
	@property (nonatomic, assign) long balance;
	
	@end

则 + (RKMapping *)responseMapping 完全可以自动生成. 

## 需求列表
### 一 根据Model类的定义自动生成+ (RKMapping *)responseMapping的实现代码

1 已有Model类A, 所有属性都是基本类型（不包含字典、数组), 自动生成对应的+ (RKMapping *)responseMapping方法；
2 已有Model类A, 所有属性都是基本类型, 包含字典, 但是字典中仍然是基本类型， 自动生成对应的+ (RKMapping *)responseMapping方法； 
3 已有Model类A, 所有属性都是基本类型, 包含数组, 但是数组中仍然是基本类型， 自动生成对应的+ (RKMapping *)responseMapping方法； 
4 已有Model类A, 所有属性都是基本类型, 包含字典, 但是字典中仍然是基本类型， 自动生成对应的+ (RKMapping *)responseMapping方法；
5 已有Model类A, 属性中包含其他Model, 其他的Model仅包含基本类型，自动生成对应的+ (RKMapping *)responseMapping方法； 
6 已有Model类A, 属性中包含其他Model, 其他的Model包含数组和字典，数组和字典中是基本类型，自动生成对应的+ (RKMapping *)responseMapping方法； 
7 已有Model类A, 属性中包含数组，数组中包含ModelB，但所有的项目都同样是ModelB, 自动生成对应的+ (RKMapping *)responseMapping方法； 
8 已有Model类A, 属性中包含数组，数组中的item各种类型都有, 自动生成对应的+ (RKMapping *)responseMapping方法； (我估计这种case可以暂时不考虑)

### 二 根据Model类的定义自动生成+ (RKMapping *)requestMapping的实现代码
TODO: 我觉得这里可能需要考虑的，因为request所需要的数据往往不方便自动生成和表达，即使要生成和表达也需要一道transform

这里有两种思路，一种是利用request descriptor来描述请求参数；另一种是直接通过requestParams来描述。

需要支持的包括：
1 请求参数来自于单一Model;
2 请求参数来自于单一Model的部分属性；
3 请求参数来自于多个Model;
4 请求参数来自于多个Model的部分属性；
5 请求参数来自于多个Model的嵌套；（这里的情况会比较复杂一点）

简单点的做法是：为每个请求的参数生成一个单一的对应的Model, 然后这个Model通过其他的类转换得到或者手动写一个生成该Model对象的方法；具体做法待讨论。

### 三 根据NEI定义自动生成Response对应的Model类
1 简单的映射关系；
2 嵌套；
3 数组和字典的处理;

### 四 根据NEI定义自动生成Request对应的Model类
1 简单的映射关系；
2 嵌套；
3 数组和字典的处理;

### 五 自动生成Model类的存储层解决方案
1 存储策略
例如：自动生成的Model类不允许添加新的内容，包括方法和成员变量；但是在持久化存储的时候，一是可能涉及到数据的计算与重新组织；另外需要提供存取的方法；因此需要考虑提供统一的解决方案，比如说，通过category来添加存储方法或者提供基类或者子类解决类似的问题.

2 向前兼容
例如：版本1.1的Model的定义不同于版本1.2的Model的定义，但是从上个版本的持久化存储中读取出来的内容还是老版本的类的内容，仍然要可以读出并且进行转换.

### 六 自动生成Model类的Transform与Wrapper
自动生成的Model类不允许添加新的方法和属性，但是用于UI展示时往往需要计算或者重新组织与转换。

### 七 根据NEI定义自动生成Request类中的requestUrl方法，requestMethod方法以及Model的keyPath
一个请求的Method是GET, POST还是其他等等以及请求的URL, 需要根据服务器的接口自动生成.

### 八 自动生成回调相关代码
现在HTHTTP的上层封装提供delegate和block两种回调方式，如果通过delegate来进行回调，那么大部分代码应该是类似的并且是有规律的，因此可以考虑自动生成回调相关代码.

## 待确定的问题
1 Model中如果是数组，如何处理？
2 Model的嵌套
3 Request用Model来描述
4 Model自动生成后的扩展

## 额外需求
### iOS客户端：
1 Model类打印出格式化的描述，最好是JSON格式，方便调试和测试；
2 存储与Model的分离：由于
3 界面显示时所需要的数据组织与Model的分离

### 预先准备
对于根据Model类的定义自动生成objectMapping的任务，需要先可以手动写出一致的、规律的代码，然后考虑自动生成的问题.

## 其他
不考虑异构化的JSON;


