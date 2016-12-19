//
//  HTDemoUploadImageRequest.m
//  HTHttpDemo
//
//  Created by Wang Liping on 15/10/8.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTDemoUploadImageRequest.h"

@interface HTDemoUploadImageRequest ()

@end

@implementation HTDemoUploadImageRequest

+ (NSString *)requestUrl {
    return @"upload";
}

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodPOST;
}

- (BOOL)needCustomRequest {
    return YES;
}

- (void)dealloc {
    NSLog(@"HTDemoUploadImageRequest dealloc");
}

- (HTConstructingMultipartFormBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
        NSString *name = @"lwang.jpg";
        NSString *formKey = @"files";
        NSString *type = @"image/jpeg";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    };
}

@end
