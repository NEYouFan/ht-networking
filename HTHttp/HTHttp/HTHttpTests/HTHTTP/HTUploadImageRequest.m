//
//  HTUploadImageRequest.m
//  HTHttp
//
//  Created by Wang Liping on 15/9/15.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "HTUploadImageRequest.h"
#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface HTUploadImageRequest ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation HTUploadImageRequest

+ (NSString *)requestUrl {
    return @"uploadImage";
}

+ (RKRequestMethod)requestMethod {
    return RKRequestMethodPOST;
}

- (HTConstructingMultipartFormBlock)constructingBodyBlock {
    return ^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(_image, 0.9);
        NSString *name = @"image";
        NSString *formKey = @"image";
        NSString *type = @"image/jpeg";
        [formData appendPartWithFileData:data name:formKey fileName:name mimeType:type];
    };
}

@end
