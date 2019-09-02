//
//  DIOBannerMopubAdapter.m
//  MopubAdapterForiOS
//
//  Created by rdorofeev on 7/15/19.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#import "DIOMopubBannerAdapter.h"
#import <DIOSDK/DIOController.h>

@interface DIOMopubBannerAdapter ()

@end

@implementation DIOMopubBannerAdapter

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info{
    NSString *placementId = [info objectForKey:@"placementid"];
    
    if (![DIOController sharedInstance].initialized) {
        NSLog(@"Error: DIOController not initialized!");
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"DIOController not initialized!"}];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError: error];
    }else {
        NSLog(@"Trying to load banner for placement %@", placementId);
        [self loadDioBanner:placementId];
    }
}

- (void)loadDioBanner:(NSString *)placementId{
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    DIOAdRequest *request = [placement newAdRequest];
    
    [request requestAdWithAdReceivedHandler:^(DIOAdProvider *adProvider) {
        [adProvider loadAdWithLoadedHandler:^(DIOAd *ad) {
            [self.delegate bannerCustomEvent:self didLoadAd:[ad view]];
        } failedHandler:^(NSString *message){
            NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                                 code:100
                                             userInfo:@{NSLocalizedDescriptionKey:message}];
            [self.delegate bannerCustomEvent:self didFailToLoadAdWithError: error];
            NSLog(@"%@", message);
        }];
    } noAdHandler:^{
        NSLog(@"No ad");
    }];
}

@end
