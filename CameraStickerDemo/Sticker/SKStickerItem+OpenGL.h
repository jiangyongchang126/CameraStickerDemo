//
//  SKStickerItem+OpenGL.h
//  CameraStickerDemo
//
//  Created by Sinkup on 2016/12/5.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import "SKStickerItem.h"

@interface SKStickerItem (OpenGL)

/**
 根据时间间隔及当前帧的位置，获取下一帧图片，并生成纹理，供OpenGL使用
 
 @param interval 如视频流每帧的间隔
 @return 纹理
 */
- (GLuint)nextTextureForInterval:(NSTimeInterval)interval;

/**
 删除所有加载的纹理
 */
- (void)deleteTextures;

@end
