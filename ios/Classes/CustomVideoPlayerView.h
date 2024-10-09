//
//  CustomVideoPlayerView.h
//  PlayerLayerRendering
//
//  Created by hari krishna on 09/10/2024.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomVideoPlayerView : UIImageView

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItemVideoOutput *playerItemOutput;
@property (nonatomic, strong) CADisplayLink *displayLink;

- (void)setupDisplayLink;
- (void)updateVideoFrame;

@end

NS_ASSUME_NONNULL_END
