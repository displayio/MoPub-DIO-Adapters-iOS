//
//  DIOMopubInFeedAdapter.m
//  MopubAdapterForiOS
//
//  Created by rdorofeev on 7/15/19.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#import "DIOMopubInFeedAdapter.h"
#import <DIOSDK/DIOController.h>
#import "MoPub.h"

@interface DIOMopubInFeedAdapter ()

@end

@implementation DIOMopubInFeedAdapter

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
        DIOConsentState state = [[MoPub sharedInstance] canCollectPersonalInfo] ? DIOConsentStateYES : DIOConsentStateNO;
        DIOConsentState gdpr = [[MoPub sharedInstance] isGDPRApplicable] ? DIOConsentStateYES : DIOConsentStateNO;
        [[DIOController sharedInstance] setConsentData:state gdprState:gdpr];
        [[DIOController sharedInstance] setMediationPlatform:DIOMediationPlatformMopub];
        
        [self loadDioBanner:placementId];
    }
}

- (void)loadDioBanner:(NSString *)placementId{
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (!placement) {
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid placement"}];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError: error];
        return;
    }
    
    DIOAdRequest *request = [placement newAdRequest];
    
    [request setDetailsRequired:YES];
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
