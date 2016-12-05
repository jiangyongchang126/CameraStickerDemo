//
//  SKStickerManager.h
//  PLMediaStreamingKitDemo
//
//  Created by Sinkup on 2016/10/13.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SKStickerItem.h"


@class SKSticker;

/**
 贴纸管理，加载等
 */
@interface SKStickersManager : NSObject

/**
 异步方式从文件读取所有贴纸的信息
 
 @param completion 读取完成后的回调
 */
+ (void)loadStickersWithCompletion:(void(^)(NSArray<SKSticker *> *stickers))completion;

@end


/**
 一套贴纸
 */
@interface SKSticker : NSObject

/**
 包含的所有部件
 */
@property (nonatomic, readonly) NSArray<SKStickerItem *> *items;


/**
 贴纸的目录
 */
@property (nonatomic, readonly) NSString *dir;


/**
 贴纸的名称
 */
@property (nonatomic, readonly) NSString *name;


/**
 预览图文件名
 */
@property (nonatomic, readonly) NSString *preview;


/**
 音效的文件名
 */
@property (nonatomic, readonly) NSString *audio;


/**
 版本号
 */
//@property (nonatomic, readonly) NSUInteger version;


/**
 根据指定的目录进行初始化
 
 @param url 路径
 @return 创建的实例
 */
- (instancetype)initWithDirectoryURL:(NSURL *)url;

@end
