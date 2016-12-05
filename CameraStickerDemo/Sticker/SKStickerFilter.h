//
//  SKStickerFilter.h
//  CameraStickerDemo
//
//  Created by Sinkup on 2016/12/4.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@class SKSticker;

@interface SKStickerFilter : GPUImageFilter

/**
 需要绘制的贴纸
 */
@property (nonatomic, strong) SKSticker *sticker;


/**
 关键点，元素需为CGPoint数组
 */
@property (nonatomic, copy) NSArray<NSArray *> *faces;

@end
