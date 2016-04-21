# RestKit避免Crash的几个要点:

## 1 Model类

为了防止Map的时候crash, 需要在基类的Model中实现如下两个空方法：

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    return;
}

## 2 JSON数据

例如：

{@"data": @"111"};

这个时候如果key为data, 那么会crash. 因为key为data的时候，对应的必须是一个字典；这个时候对应的response descriptor可以改写成下面这样：

	+ (RKResponseDescriptor *)responseDescriptor{
	    RKObjectMapping *resultMapping = [RKObjectMapping mappingForClass:[YXPayOrderResultModel class]];
	    [resultMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"data"]];
	    
	    RKResponseDescriptor* responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:resultMapping method:[self requestMethod] pathPattern:[self requestUrl] keyPath:@"data" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
	    return responseDescriptor;
	}