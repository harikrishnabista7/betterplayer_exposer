//
//  CustomVideoPlayerView.m
//  PlayerLayerRendering
//
//  Created by hari krishna on 09/10/2024.
//

#import "CustomVideoPlayerView.h"

@implementation CustomVideoPlayerView

// Override the setter for player property
- (void)setPlayer:(AVPlayer *)player {
    _player = player;

    if (player.currentItem) {
        NSDictionary *outputSettings = @{
            (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
            (__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{}, // Empty dictionary for IOSurface properties
        };
        self.playerItemOutput = [[AVPlayerItemVideoOutput alloc] initWithOutputSettings:outputSettings];
        [player.currentItem addOutput:self.playerItemOutput];
    }
}

// Init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self setupDisplayLink];
        self.contentMode = UIViewContentModeScaleAspectFit;
    }

    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];

    if (self) {
        [self setupDisplayLink];
    }

    return self;
}

// Setup CADisplayLink to synchronize video frames with the display refresh rate
- (void)setupDisplayLink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateVideoFrame)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.displayLink.preferredFramesPerSecond = 60; // Default 60fps for smoother playback
}


// Function to extract the color space from a pixel buffer
CGColorSpaceRef getColorSpaceFromPixelBuffer(CVPixelBufferRef pixelBuffer) {
    // Get the attachments dictionary from the pixel buffer
    CFDictionaryRef attachments = CVBufferCopyAttachments(pixelBuffer, kCVAttachmentMode_ShouldPropagate);
    
    // Check if there's a color space attachment
    CGColorSpaceRef colorSpace = NULL;
    if (attachments != NULL) {
        // Look for the kCVImageBufferCGColorSpaceKey
        CFTypeRef colorSpaceAttachment = CFDictionaryGetValue(attachments, kCVImageBufferCGColorSpaceKey);
        if (colorSpaceAttachment != NULL) {
            colorSpace = (CGColorSpaceRef)colorSpaceAttachment;
            CFRetain(colorSpace); // Retain the color space to return it
        }
        CFRelease(attachments); // Release the attachments dictionary
    }
    
    return colorSpace;
}

// Update video frame
- (void)updateVideoFrame {
    if (!self.playerItemOutput) {
        return;
    }

    CMTime currentTime = self.player.currentTime;

    if ([self.playerItemOutput hasNewPixelBufferForItemTime:currentTime]) {
        CVPixelBufferRef pixelBuffer = [self.playerItemOutput copyPixelBufferForItemTime:currentTime itemTimeForDisplay:nil];

        if (pixelBuffer) {
            CGColorSpaceRef colorSpace;
            
            colorSpace = getColorSpaceFromPixelBuffer(pixelBuffer);

            if (colorSpace == NULL) {
                colorSpace = CGColorSpaceCreateDeviceRGB();
            }
            
            // Create a CIContext with sRGB color space
          //  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CIContext *context = [CIContext contextWithOptions:@{ kCIContextWorkingColorSpace: (__bridge id)colorSpace }];

            // Convert the pixel buffer to a CIImage
            CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];

            // Create CGImage from CIImage with the proper color space
            CGImageRef cgImage = [context createCGImage:ciImage fromRect:ciImage.extent];

            // Release the color space when done (if you created it)
            if (colorSpace != NULL) {
                CGColorSpaceRelease(colorSpace);
            }
            
            if (cgImage) {
                UIImage *uiImage = [UIImage imageWithCGImage:cgImage];

                dispatch_async(dispatch_get_main_queue(), ^{
                    // Update UIImageView with appropriate aspect ratio
                    CGFloat aspectWidth = self.bounds.size.width / uiImage.size.width;
                    CGFloat aspectHeight = self.bounds.size.height / uiImage.size.height;
                    CGFloat aspectRatio = MIN(aspectWidth, aspectHeight);

                    CGFloat newWidth = uiImage.size.width * aspectRatio;
                    CGFloat newHeight = uiImage.size.height * aspectRatio;

                    self.contentMode = UIViewContentModeScaleAspectFit;
                    self.image = uiImage;
                    self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, newWidth, newHeight);
                });

                CGImageRelease(cgImage); // Don't forget to release CGImageRef
            }

            CVPixelBufferRelease(pixelBuffer); // Release the pixel buffer
        }
    }
}

// Clean up when the view is deallocated
- (void)dealloc {
    [self.displayLink invalidate];
}

@end
