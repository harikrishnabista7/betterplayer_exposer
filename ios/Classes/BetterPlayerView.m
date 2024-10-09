// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// BetterPlayerView.m
#import "BetterPlayerView.h"

@implementation BetterPlayerView

// Getter for player, accessing playerView's player
- (AVPlayer *)player {
    return self.playerView.player;
}

// Setter for player, setting playerView's player
- (void)setPlayer:(AVPlayer *)player {
    self.playerView.player = player;
}

// Custom init method
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialize playerView and add it as a subview
        _playerView = [[CustomVideoPlayerView alloc] initWithFrame:self.bounds];
        _playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_playerView];
    }
    return self;
}

// If using init, call initWithFrame:
- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

@end
