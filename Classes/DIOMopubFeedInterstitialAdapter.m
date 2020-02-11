//
//  DIOMopubFeedInterstitialAdapter.m
//  MopubAdapterForiOS
//
//  Created by Ariel Malka on 12/22/19.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#import "DIOMopubFeedInterstitialAdapter.h"

#import <DIOSDK/DIOController.h>
#import <DIOSDK/DIOFeedInterstitialContainer.h>

@implementation DIOMopubFeedInterstitialAdapter

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info {
   [self requestAdWithSize:size customEventInfo:info adMarkup:nil];
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *placementId = [info objectForKey:@"placementid"];
    
    if (![DIOController sharedInstance].initialized) {
        NSLog(@"Error: DIOController not initialized!");
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"DIOController not initialized!"}];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError: error];
    }else {
        NSLog(@"Trying to load Feed Interstitial for placement %@", placementId);
        DIOConsentState state = [[MoPub sharedInstance] canCollectPersonalInfo] ? DIOConsentStateYES : DIOConsentStateNO;
        DIOConsentState gdpr = [[MoPub sharedInstance] isGDPRApplicable] ? DIOConsentStateYES : DIOConsentStateNO;
        [[DIOController sharedInstance] setConsentData:state gdprState:gdpr];
        [[DIOController sharedInstance] setMediationPlatform:DIOMediationPlatformMopub];
        
        [self loadDioFeedInterstitial:placementId];
    }
}

- (void)loadDioFeedInterstitial:(NSString *)placementId{
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (!placement) {
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid placement"}];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError: error];
        return;
    }
    
    DIOAdRequest *request = [placement newAdRequest];
    
    DIOFeedInterstitialContainer *container = [[DIOFeedInterstitialContainer alloc] init];
    
    [container loadWithAdRequest:request completionHandler:^(DIOAd *ad){
        NSLog(@"AD LOADED");
    } errorHandler:^(NSError *error) {
        NSLog(@"AD FAILED TO LOAD: %@", error.localizedDescription);
        
        NSError *error1 = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError: error1];
    }];
    
    [self.delegate bannerCustomEvent:self didLoadAd:[container view]];
}

@end
