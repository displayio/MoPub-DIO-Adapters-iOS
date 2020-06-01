//
//  BrandioInterstitialMopubAdapter.m
//  MopubAdapterForiOS
//
//  Created by rdorofeev on 7/12/19.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#import "DIOMopubInterstitialAdapter.h"

#import <DIOSDK/DIOController.h>

@interface DIOMopubInterstitialAdapter ()

@property (nonatomic, strong) DIOAd *dioAd;

@end

@implementation DIOMopubInterstitialAdapter

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    [self requestInterstitialWithCustomEventInfo:info adMarkup:nil];
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    
        NSString *placementId = [info objectForKey:@"placementid"];
    
    if (![DIOController sharedInstance].initialized) {
        NSLog(@"Error: DIOController not initialized!");
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"DIOController not initialized!"}];
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError: error];
    }else {
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
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError: error];
        return;
    }
    
    DIOAdRequest *request = [placement newAdRequest];
    
    [request requestAdWithAdReceivedHandler:^(DIOAdProvider *adProvider) {
        [adProvider loadAdWithLoadedHandler:^(DIOAd *ad) {
            self.dioAd = ad;
            [self.delegate interstitialCustomEvent:self didLoadAd:ad];
        } failedHandler:^(NSError *error){
            NSError *error1 = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                                 code:100
                                             userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
            [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError: error1];
            NSLog(@"%@", error.localizedDescription);
        }];
    } noAdHandler:^(NSError *error){
        NSLog(@"No ad provider");
    }];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController{
    if (self.dioAd != nil) {
        [self.dioAd showAdFromViewController:rootViewController eventHandler:^(DIOAdEvent event){
            switch (event) {
                case DIOAdEventOnShown:
                    [self.delegate trackImpression];
                    [self.delegate interstitialCustomEventWillAppear: self];
                    [self.delegate interstitialCustomEventDidAppear: self];
                    NSLog(@"AdEventOnShown");
                    break;
                    
                case DIOAdEventOnClicked:
                    [self.delegate trackClick];
                    NSLog(@"AdEventOnClicked");
                    break;
                    
                case DIOAdEventOnFailedToShow: {
                    NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                                         code:100
                                                     userInfo:@{NSLocalizedDescriptionKey:@"Failed to show ad"}];
                    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError: error];
                    NSLog(@"AdEventOnFailedToShow");
                    self.dioAd = nil;
                    break;
                }
                    
                case DIOAdEventOnClosed:
                    [self.delegate interstitialCustomEventWillDisappear: self];
                    [self.delegate interstitialCustomEventDidDisappear: self];
                    NSLog(@"AdEventOnClosed");
                    self.dioAd = nil;
                    break;
                    
                case DIOAdEventOnAdCompleted:
                    [self.delegate interstitialCustomEventWillDisappear: self];
                    [self.delegate interstitialCustomEventDidDisappear: self];
                    NSLog(@"AdEventOnAdCompleted");
                    self.dioAd = nil;
                    break;
            }
        }];
    }
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return NO;
}

@end
