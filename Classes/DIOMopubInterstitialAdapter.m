//
//  BrandioInterstitialMopubAdapter.m
//  MopubAdapterForiOS
//
//  Created by rdorofeev on 7/12/19.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#import "DIOMopubInterstitialAdapter.h"
#import <DIOSDK/DIOController.h>
#if __has_include("MoPub.h")
    #import "MPLogging.h"
    #import "MoPub.h"
#endif

@interface DIOMopubInterstitialAdapter ()

@property (nonatomic, strong) DIOAd *dioAd;

@end

@implementation DIOMopubInterstitialAdapter

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *placementId = [info objectForKey:@"placementid"];

 if (![DIOController sharedInstance].initialized) {
    NSLog(@"Error: DIOController not initialized!");
    NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                         code:100
                                     userInfo:@{NSLocalizedDescriptionKey:@"DIOController not initialized!"}];
     [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];

} else {
    DIOConsentState state = [[MoPub sharedInstance] canCollectPersonalInfo] ? DIOConsentStateYES : DIOConsentStateNO;
    DIOConsentState gdpr = [[MoPub sharedInstance] isGDPRApplicable] ? DIOConsentStateYES : DIOConsentStateNO;
    [[DIOController sharedInstance] setConsentData:state gdprState:gdpr];
    [[DIOController sharedInstance] setMediationPlatform:DIOMediationPlatformMopub];

    [self loadDioInterstitial:placementId];
 }
}

- (void)loadDioInterstitial:(NSString *)placementId{
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (!placement) {
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid placement"}];
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
        return;
    }
    
    DIOAdRequest *request = [placement newAdRequest];
    
    [request requestAdWithAdReceivedHandler:^(DIOAdProvider *adProvider) {
        [adProvider loadAdWithLoadedHandler:^(DIOAd *ad) {
            self.dioAd = ad;
            [self.delegate fullscreenAdAdapterDidLoadAd:self];
            [MPLogEvent adLoadSuccessForAdapter:NSStringFromClass(self.class)];
        } failedHandler:^(NSError *error){
            NSError *error1 = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                                 code:100
                                             userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
            [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error1];
            NSLog(@"%@", error1.localizedDescription);
        }];
    } noAdHandler:^(NSError *error2){
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error2];
        NSLog(@"No ad provider");
    }];
}

- (void)presentAdFromViewController:(UIViewController *)viewController {
    if (self.dioAd != nil) {
        [self.dioAd showAdFromViewController:viewController eventHandler:^(DIOAdEvent event){
            switch (event) {
                case DIOAdEventOnShown:
                    [MPLogEvent adDidAppearForAdapter:NSStringFromClass(self.class)];
                    [MPLogEvent adShowSuccessForAdapter:NSStringFromClass(self.class)];
                    [self.delegate fullscreenAdAdapterAdWillAppear:self];
                    [self.delegate fullscreenAdAdapterAdDidAppear:self];
                    [self.delegate fullscreenAdAdapterDidTrackImpression:self];
                    NSLog(@"AdEventOnShown");
                    break;
                    
                case DIOAdEventOnClicked:
                    [MPLogEvent adTappedForAdapter:NSStringFromClass(self.class)];
                    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
                    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
                    [self.delegate fullscreenAdAdapterDidTrackClick:self];
                    NSLog(@"AdEventOnClicked");
                    break;
                    
                case DIOAdEventOnFailedToShow: {
                    NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                                         code:100
                                                     userInfo:@{NSLocalizedDescriptionKey:@"Failed to show ad"}];
                    [MPLogEvent adShowFailedForAdapter:NSStringFromClass(self.class) error:error];
                    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
                    NSLog(@"AdEventOnFailedToShow");
                    self.dioAd = nil;
                    break;
                }
                    
                case DIOAdEventOnClosed:
                    [MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)];
                    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
                    [MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)];
                    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
                    
                    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
                        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
                    }
                    NSLog(@"AdEventOnClosed");
                    self.dioAd = nil;
                    break;
                    
                case DIOAdEventOnAdCompleted:
                    [MPLogEvent adWillDisappearForAdapter:NSStringFromClass(self.class)];
                    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
                    [MPLogEvent adDidDisappearForAdapter:NSStringFromClass(self.class)];
                    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
                    
                    if ([self.delegate respondsToSelector:@selector(fullscreenAdAdapterAdDidDismiss:)]) {
                        [self.delegate fullscreenAdAdapterAdDidDismiss:self];
                    }
                    NSLog(@"AdEventOnAdCompleted");
                    self.dioAd = nil;
                    break;
            }
        }];
    }
}

- (BOOL)isRewardExpected {
    return NO;
}

- (BOOL)hasAdAvailable {
    return self.dioAd != nil;
}

- (BOOL)enableAutomaticImpressionAndClickTracking {
    return NO;
}

@end
