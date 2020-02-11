//
//  DIOMopubBannerAdapter.h
//  MopubAdapterForiOS
//
//  Created by rdorofeev on 17.12.2019.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

#import <DIOSDK/DIOController.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIOMopubBannerAdapter : MPBannerCustomEvent

@end

NS_ASSUME_NONNULL_END
