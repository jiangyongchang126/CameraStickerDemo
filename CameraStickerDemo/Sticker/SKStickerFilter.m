//
//  SKStickerFilter.m
//  CameraStickerDemo
//
//  Created by Sinkup on 2016/12/4.
//  Copyright © 2016年 Asura. All rights reserved.
//

#import "SKStickerFilter.h"
#import "SKSticker+OpenGL.h"

@implementation SKStickerFilter
{
    GLuint _framebufferHandle;
    
    CMTime _lastTime;
    CMTime _currentTime;
}

- (void)dealloc
{
    if (_framebufferHandle) {
        glDeleteFramebuffers(1, &_framebufferHandle);
        _framebufferHandle = 0;
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lastTime = kCMTimeInvalid;
        _currentTime = kCMTimeInvalid;
        
        runSynchronouslyOnVideoProcessingQueue(^{
            glGenFramebuffers(1, &_framebufferHandle);
            glBindFramebuffer(GL_FRAMEBUFFER, _framebufferHandle);
        });
    }
    
    return self;
}

- (void)setSticker:(SKSticker *)sticker
{
    runAsynchronouslyOnVideoProcessingQueue(^{
        if (_sticker == sticker) {
            return;
        }
        
        [GPUImageContext useImageProcessingContext];
        
        [_sticker reset];
        _sticker = sticker;
    });
}

- (void)setFaces:(NSArray<NSArray *> *)faces
{
    runAsynchronouslyOnVideoProcessingQueue(^{
        _faces = faces;
    });
}


#pragma mark - Override
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    _currentTime = frameTime;
    [super newFrameReadyAtTime:frameTime atIndex:textureIndex];
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    if (usingNextFrameForImageCapture)
    {
        [firstInputFramebuffer lock];
    }
    
    // 与上一帧的间隔
    NSTimeInterval interval = 0;
    if (CMTIME_IS_VALID(_lastTime)) {
        interval = CMTimeGetSeconds(CMTimeSubtract(_currentTime, _lastTime));
    }
    _lastTime = _currentTime;
    
    if (self.faces.count) {
        // 开启混合
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _framebufferHandle);
        glViewport(0, 0, inputTextureSize.width, inputTextureSize.height);
        
        // 直接绘制在源纹理上
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, firstInputFramebuffer.texture);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, firstInputFramebuffer.texture, 0);
        
        [GPUImageContext setActiveShaderProgram:filterProgram];
        
        for (NSArray *points in _faces) {
            [_sticker drawItemsWithFacePoints:points
                              framebufferSize:inputTextureSize
                                 timeInterval:interval
                                   usingBlock:^(GLfloat *vertices, GLuint texture) {
                                       glActiveTexture(GL_TEXTURE2);
                                       glBindTexture(GL_TEXTURE_2D, texture);
                                       
                                       glUniform1i(filterInputTextureUniform, 2);
                                       
                                       glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
                                       glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
                                       
                                       glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                                       glBindTexture(GL_TEXTURE_2D, 0);
                                   }];
        }
        
        glDisable(GL_BLEND);
    }
    
    // 直接用输入作为输出
    outputFramebuffer = firstInputFramebuffer;
    
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}


@end
