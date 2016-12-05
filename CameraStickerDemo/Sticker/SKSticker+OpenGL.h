//
//  SKSticker+OpenGL.h
//  CameraStickerDemo
//
//  Created by Sinkup on 2016/12/5.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import "SKSticker.h"

@interface SKSticker (OpenGL)

- (void)drawItemsWithFacePoints:(NSArray *)points
                framebufferSize:(CGSize)size
                   timeInterval:(NSTimeInterval)interval
                     usingBlock:(void (^)(GLfloat *vertices, GLuint texture))block;

- (void)reset;

@end
