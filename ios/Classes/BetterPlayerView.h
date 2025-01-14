// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "CustomVideoPlayerView.h"

@interface BetterPlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, readonly, strong) CustomVideoPlayerView *playerView;

@end
