//
//  DIOMopubInFeedAdapter.m
//  MopubAdapterForiOS
//
//  Created by rdorofeev on 7/15/19.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#import "DIOMopubInFeedAdapter.h"

#import <DIOSDK/DIOController.h>

@interface DIOMopubInFeedAdapter ()

@end

@implementation DIOMopubInFeedAdapter

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
    
    [request requestAdWithAdReceivedHandler:^(DIOAdProvider *adProvider) {
        [adProvider loadAdWithLoadedHandler:^(DIOAd *ad) {
            [ad setEventHandler:^(DIOAdEvent event) {
                switch (event) {
                    case DIOAdEventOnShown:
                        [self.delegate trackImpression];
                        break;
                    case DIOAdEventOnFailedToShow:{
                        NSError *errorToShow = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                            code:100
                            userInfo:@{NSLocalizedDescriptionKey:@"Failed to show ad"}];
                        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError: errorToShow];
                        break;
                    }
                    case DIOAdEventOnClicked:
                        [self.delegate trackClick];
                        break;
                    case DIOAdEventOnClosed:
                        [self.delegate bannerCustomEventDidCollapseAd:self];
                        break;
                    case DIOAdEventOnAdCompleted:
                        NSLog(@"AD COMPLETED");
                        break;
                }
            }];
            [self.delegate bannerCustomEvent:self didLoadAd:[ad view]];
        } failedHandler:^(NSError *error){
            NSError *error1 = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                                 code:100
                                                 userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
            [self.delegate bannerCustomEvent:self didFailToLoadAdWithError: error1];
            NSLog(@"%@", error.localizedDescription);
        }];
    } noAdHandler:^(NSError *error){
        NSLog(@"No ad");
    }];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

@end
