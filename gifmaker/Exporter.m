//
//  Exporter.m
//  gifmaker
//
//  Created by Sergii Simakhin on 12/8/15.
//  Copyright © 2015 Cayugasoft. All rights reserved.
//

#import "Exporter.h"

@implementation Exporter

+ (void)exportImageArrayAsVideo:(NSArray<UIImage *> *)images
                       filename:(NSString *)filename
                    repeatCount:(NSInteger)repeatCount
                  saveToGallery:(BOOL)saveToGallery {
    
    if (repeatCount < 1) {
        repeatCount = 1;
    }
    
    if (repeatCount > 1) {
        NSMutableArray<UIImage *> *repeatedImagesArray = [NSMutableArray array];
        for (int i = 0; i < repeatCount; i++) {
            for (int j = 0; j < images.count; j++) {
                [repeatedImagesArray addObject:images[j]];
            }
        }
        images = repeatedImagesArray;
    }
    
    // Let's set resulting videofile name
    NSString *resultingFilenamePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"];
    NSURL *resultingFilenameURL = [NSURL fileURLWithPath:resultingFilenamePath];
    
    // Remove old file
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtURL:resultingFilenameURL error:&error]) {
        NSLog(@"Can't remove old temporary file, error: %@", [error localizedDescription]);
    }
    
    // Keep width&height for further usage
    int width = images.firstObject.size.width;
    int height = images.firstObject.size.height;
    
    //
    NSError *videoWriterError;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:resultingFilenameURL
                                                           fileType:AVFileTypeQuickTimeMovie
                                                              error:&videoWriterError];
    
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                         outputSettings:videoSettings];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    
    [videoWriter addInput:writerInput];
    
    // Start a writing session
    [videoWriter startWriting];
    
    // Keep clear to start your writing session at the 0 CMTime
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    CVPixelBufferRef buffer = NULL;
    
    int cmtimeAllFramer = (int)(images.count / ((double)images.count / 16));
    int i = 0;
    
    while (1) {
        @autoreleasepool {
            // Check if the writer is ready for more data, if not, just wait
            if (writerInput.readyForMoreMediaData) {
                CMTime frameTime = CMTimeMake(1, cmtimeAllFramer);
                CMTime lastTime=CMTimeMake(i * 1, cmtimeAllFramer);
                CMTime presentTime=CMTimeAdd(lastTime, frameTime);
                
                // Ensure that the first frame starts at 0 CMTime
                if (i == 0) {
                    presentTime = CMTimeMake(0, cmtimeAllFramer);
                }
                
                if (i >= [images count]) {
                    buffer = NULL;
                }
                else {
                    // Convery UIImage to a proper CGImage
                    buffer = [self pixelBufferFromCGImage:[images[i] CGImage] width:width height:height];
                }
                
                if (buffer) {
                    // Give the CGImage to the AVAssetWriter to add to your video
                    [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
                    CVPixelBufferUnlockBaseAddress(buffer, 0); //unlock cropped image buffer
                    CVPixelBufferRelease(buffer);
                    i++;
                }
                else {
                    // Finish the session
                    [writerInput markAsFinished];
                    
                    [videoWriter finishWritingWithCompletionHandler:^{
                        NSLog(@"Finished writing, will check completion status...");
                        if (videoWriter.status != AVAssetWriterStatusFailed && videoWriter.status == AVAssetWriterStatusCompleted) {
                            NSLog(@"Video writing succeeded.");
                            
                            // Init assets library
                            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                            ALAssetsLibraryWriteVideoCompletionBlock videoWriteCompletionBlock = ^(NSURL *newURL, NSError *error) {
                                if (error) {
                                    NSLog(@"Error writing image with metadata to Photo Library: %@", error);
                                } else {
                                    NSLog(@"Wrote image with metadata to Photo Library %@", newURL.absoluteString);
                                }
                            };
                            
                            // Check if video is compatible with iOS Gallery
                            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:resultingFilenameURL]) {
                                [library writeVideoAtPathToSavedPhotosAlbum:resultingFilenameURL
                                                            completionBlock:videoWriteCompletionBlock];
                            } else {
                                NSLog(@"Can't save video - it's not compatible with device gallery!");
                            }
                            
                            CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                        } else {
                            NSLog(@"Video writing failed: %@", videoWriter.error);
                        }
                        
                    }];
                    
                    // Clear the memory
                    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                    
                    NSLog(@"Done");
                    break;
                }
            }
        }
    }
}

+ (CVPixelBufferRef) pixelBufferFromCGImage:(CGImageRef)image width:(int)width height:(int)height {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width,
                                          height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, width,
                                                 height, 8, 4*width, rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
