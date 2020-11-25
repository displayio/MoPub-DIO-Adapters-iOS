//
//  DIOMopubInterscrollerAdapter.h
//  MopubAdapterForiOS
//
//  Created by Ariel Malka on 12/22/19.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#if __has_include(<MoPub/MoPub.h>)
#import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
#import <MoPubSDKFramework/MoPub.h>
#else
#import "MoPub.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface DIOMopubInterscrollerAdapter : MPInlineAdAdapter <MPThirdPartyInlineAdAdapter>

@end

NS_ASSUME_NONNULL_END
