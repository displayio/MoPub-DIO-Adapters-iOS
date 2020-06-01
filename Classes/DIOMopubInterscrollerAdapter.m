//
//  DIOMopubInterscrollerAdapter.m
//  MopubAdapterForiOS
//
//  Created by Ariel Malka on 12/22/19.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#import "DIOMopubInterscrollerAdapter.h"

#import <DIOSDK/DIOController.h>
#import <DIOSDK/DIOInterscrollerContainer.h>

@implementation DIOMopubInterscrollerAdapter

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
        NSLog(@"Trying to load Interscroller for placement %@", placementId);
        DIOConsentState state = [[MoPub sharedInstance] canCollectPersonalInfo] ? DIOConsentStateYES : DIOConsentStateNO;
        DIOConsentState gdpr = [[MoPub sharedInstance] isGDPRApplicable] ? DIOConsentStateYES : DIOConsentStateNO;
        [[DIOController sharedInstance] setConsentData:state gdprState:gdpr];
        [[DIOController sharedInstance] setMediationPlatform:DIOMediationPlatformMopub];
        
        [self loadDioInterscroller:placementId];
    }
}

- (void)loadDioInterscroller:(NSString *)placementId{
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (!placement) {
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid placement"}];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError: error];
        return;
    }
    
    DIOAdRequest *request = [placement newAdRequest];
    
    DIOInterscrollerContainer *container = [[DIOInterscrollerContainer alloc] init];
    
    [container loadWithAdRequest:request completionHandler:^(DIOAd *ad){
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

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

@end
