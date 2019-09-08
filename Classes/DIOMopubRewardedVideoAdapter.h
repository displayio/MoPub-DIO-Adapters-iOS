//
//  DIOMopubRewardedVideoAdapter.h
//  MopubAdapterForiOS
//
//  Created by rdorofeev on 8/23/19.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MPRewardedVideo.h"
#import "MPRewardedVideoCustomEvent.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface DIOMopubRewardedVideoAdapter : MPRewardedVideoCustomEvent

@end

NS_ASSUME_NONNULL_END