//
//  SKSticker.h
//  CameraStickerDemo
//
//  Created by Sinkup on 2016/10/14.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    SKStickerItemTypeFace,        // 脸部
    SKStickerItemTypeScreen,      // 屏幕
} SKStickerItemType;


typedef enum {
    SKStickerItemAlignPositionTop,
    SKStickerItemAlignPositionLeft,
    SKStickerItemAlignPositionBottom,
    SKStickerItemAlignPositionRight,
    SKStickerItemAlignPositionCenter
    // ...
} SKStickerItemAlignPosition;

typedef enum {
    SKStickerItemTriggerTypeNormal,     // 始终
    SKStickerItemTriggerTypeFace,       // 有人脸
    SKStickerItemTriggerTypeMouthOpen,  // 张嘴
    SKStickerItemTriggerTypeBlink,      // 眨眼
    SKStickerItemTriggerTypeFrown       // 皱眉
} SKStickerItemTriggerType;


/**
 一套贴纸中，某一部件（如鼻子）的所有信息。
 */
@interface SKStickerItem : NSObject

/**
 显示的位置类型
 */
@property (nonatomic) SKStickerItemType type;

/**
 触发条件，默认0，始终显示
 */
@property (nonatomic) SKStickerItemTriggerType triggerType;

/**
 资源的目录（包含一组图片序列帧）
 */
@property (nonatomic, copy) NSString *dir;

/**
 帧数（一组序列帧组成一个动画效果）
 */
@property (nonatomic) NSUInteger count;

/**
 每帧的持续时间，秒
 */
@property (nonatomic) NSTimeInterval frameDuration;

/**
 图片的宽
 */
@property (nonatomic) float width;

/**
 图片的高
 */
@property (nonatomic) float height;

// 脸部item参数
/**
 在脸部的参考点索引
 */
@property (nonatomic, copy) NSArray *alignIndexes;

/**
 边缘item参数
 边缘位置（top、bottom、left、right）
 */

@property (nonatomic) SKStickerItemAlignPosition alignPosition;

/**
 宽度缩放系数（对于脸部的item，以眼间距为参考；对于边缘的item则以屏幕的宽高作为参考，下同）
 */
@property (nonatomic) float scaleWidth;

/**
 高度缩放系数
 */
@property (nonatomic) float scaleHeight;

/**
 水平方向偏移系数
 */
@property (nonatomic) float offsetX;

/**
 垂直方向偏移系数
 */
@property (nonatomic) float offsetY;


/**
 已触发
 */
@property (nonatomic) BOOL triggered;

/**
 当前帧的索引
 */
@property (nonatomic) NSUInteger currentFrameIndex;

/**
 剩余循环次数
 */
@property (nonatomic) NSUInteger loopCountdown;


/**
 初始化

 @param dict 包含item数据的字典
 @return item实例
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)dict;


/**
 根据时间间隔及当前帧的位置，获取下一帧图片，以此适应不同帧率的视频流，保证动画的效果。
 
 @param interval 如视频流每帧的间隔
 @return 此图片可以加到当前的视频帧中
 */
- (NSUInteger)nextFrameIndexForInterval:(NSTimeInterval)interval;

/**
 根据索引获取对应的图片

 @param index 图片在目录中的索引
 @return UIImage图片
 */
- (UIImage *)imageAtIndex:(NSUInteger)index;

@end
