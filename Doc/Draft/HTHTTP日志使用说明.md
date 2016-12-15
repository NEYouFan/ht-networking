# HTHTTP日志使用说明

---

本文档描述如何调整HTHTTP日志开关与等级，包括如何输出日志到文件。  

日志的具体实现相关不在本文档描述范围内，请参见[日志整理描述](../设计与实现/日志整理描述.md)

## HTHTTP模块日志

HTHTTP模块自带的日志采用HTLog, 日志等级的开关与设置与HTLog完全一致；不再额外描述。

## RestKit模块日志

HTHTTP中与网络请求以及数据解析相关的日志都在RestKit模块中，RestKit模块日志与HTLog的日志底层采用同样的日志库CocoaLumberjack提供，因为开关的控制类似，但细节稍有区别，下面想起描述。

### 1 默认日志等级与配置方法

默认日志等级是 `RKLogLevelDefault`; 在Debug模式下是`RKLogLevelInfo`, 而Release模式下是`RKLogLevelWarning`。

可以参见 `RKLog.h` 中关于RKLogLevelDefault的定义

```objective-c

/**
 Set the Default Log Level

 Based on the presence of the DEBUG flag, we default the logging for the RestKit parent component
 to Info or Warning.

 You can override this setting by defining RKLogLevelDefault as a pre-processor macro.
 */
#ifndef RKLogLevelDefault
    #ifdef DEBUG
        #define RKLogLevelDefault RKLogLevelInfo
    #else
        #define RKLogLevelDefault RKLogLevelWarning
    #endif
#endif


```

### 2 改变RestKit的日志等级与开关的方法

如果希望改变日志级别，则在`AppDelegate.m`的`didFinishLaunchingWithOptions`方法中，调用如下方法，则整个 `RestKit` 模块的日志级别调整为 `RKLogLevelInfo` .

```objective-c	   

RKLogConfigureByName("RestKit*", RKLogLevelInfo);

```

如果希望关闭日志，则level参数传递`RKLogLevelOff`即可。

### 3 日志输出与打印

由于`RestKit`相关日志也是由`CocoaLumberjack`提供，所以`Logger`的控制，例如控制是否输出到文件，也是由`HTLog`提供的同一套机制控制的，只要往`DDLog`中添加指定的`Logger`即可。

在`AppDelegate.m`的`didFinishLaunchingWithOptions`方法中，调用如下方法, 则在Debug模式下会输出日志到控制台(TTY)和苹果的日志系统(ASL); 而在Release模式下会输出日志到苹果的日志系统，并且`RKLogLevelError`级别的日志会输出到文件.

```objective-c	   

HTLogInit();

```

其中，HTLogInit();方法的实现如下：

```objective-c	

void HTLogInit()
{
#if DEBUG
    //debug版本，打开ASL和TTY，使用ModuleFormatter输出 module名
    DDTTYLogger.sharedInstance.logFormatter = [HTLogFormatter new];
    [DDLog addLogger:DDTTYLogger.sharedInstance];
    [DDLog addLogger:DDASLLogger.sharedInstance];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
#else
    //release版，关闭ASL，打开TTY和file logger，将所有log level设置为error
    [DDLog addLogger:DDASLLogger.sharedInstance];
    
    DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
    
    fileLogger.maximumFileSize = 1024 * 1;  //  1 KB
    fileLogger.rollingFrequency = 60;       // 60 Seconds
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = 4;
    
    [DDLog addLogger:fileLogger withLevel:DDLogLevelError];
#endif
}

```

如果希望调整输出到文件的日志级别，或者调整是否输出到ASL或者TTY, 可以自己编写类似的代码替换掉上面的代码，例如希望关闭ASL和TTY, 仅打开file logger, 并且所有`Info`级别的日志都写在文件中 ，那么在`didFinishLaunchingWithOptions`里不调用`HTLogInit();` 而是调用如下代码即可：

```objective-c	

    DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
    
    fileLogger.maximumFileSize = 1024 * 1;  //  1 KB
    fileLogger.rollingFrequency = 60;       // 60 Seconds
    
    fileLogger.logFileManager.maximumNumberOfLogFiles = 4;
    
    [DDLog addLogger:fileLogger withLevel:DDLogLevelInfo];
    
```    