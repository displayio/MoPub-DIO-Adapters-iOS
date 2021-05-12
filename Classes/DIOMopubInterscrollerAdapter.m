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

- (void)requestAdWithSize:(CGSize)size adapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *placementId = [info objectForKey:@"placementid"];
    
    if (![DIOController sharedInstance].initialized) {
        NSLog(@"Error: DIOController not initialized!");
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"DIOController not initialized!"}];
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
    }else {
        NSLog(@"Trying to load banner for placement %@", placementId);
        DIOConsentState state = [[MoPub sharedInstance] canCollectPersonalInfo] ? DIOConsentStateYES : DIOConsentStateNO;
        DIOConsentState gdpr = [[MoPub sharedInstance] isGDPRApplicable] ? DIOConsentStateYES : DIOConsentStateNO;
        [[DIOController sharedInstance] setConsentData:state gdprState:gdpr];
        [[DIOController sharedInstance] setMediationPlatform:DIOMediationPlatformMopub];
        
        [self loadDioInterscroller:placementId];
    }
}

- (void)loadDioInterscroller:(NSString *)placementId {
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (!placement) {
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid placement"}];
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        [MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error];
        return;
    }
    
    DIOAdRequest *request = [placement newAdRequest];
    
    DIOInterscrollerContainer *container = [[DIOInterscrollerContainer alloc] init];
    
    [container loadWithAdRequest:request completionHandler:^(DIOAd *ad){
        [MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)];
        [self.delegate inlineAdAdapter:self didLoadAdWithAdView:[container view]];
        
        [ad setEventHandler:^(DIOAdEvent event) {
            switch (event) {
                case DIOAdEventOnShown:
                    [MPLogEvent adWillPresentModalForAdapter:NSStringFromClass(self.class)];
                    [self.delegate inlineAdAdapterDidTrackImpression:self];
                    break;
                case DIOAdEventOnFailedToShow:{
                    NSError *errorToShow = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                        code:100
                        userInfo:@{NSLocalizedDescriptionKey:@"Failed to show ad"}];
                    [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:errorToShow];
                    [MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:errorToShow];
                    break;
                }
                case DIOAdEventOnClicked:
                    [MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)];
                    [self.delegate inlineAdAdapterDidTrackClick:self];
                    [self.delegate inlineAdAdapterWillBeginUserAction:self];
                    [self.delegate inlineAdAdapterWillLeaveApplication:self];
                    break;
                case DIOAdEventOnClosed:
                    [MPLogEvent adDidDismissModalForAdapter:NSStringFromClass(self.class)];
                    [self.delegate inlineAdAdapterDidEndUserAction:self];
                    break;
                case DIOAdEventOnAdCompleted:
                    NSLog(@"AD COMPLETED");
                    break;
            }
        
        }];
        NSLog(@"AD LOADED");
    } errorHandler:^(NSError *error) {
        [self.delegate inlineAdAdapter:self didFailToLoadAdWithError:error];
        [MPLogEvent adLoadFailedForAdapter:NSStringFromClass(self.class) error:error];
        NSLog(@"No ad");
    }];
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

@end