//
//  DIOMopubRewardedVideoAdapter.m
//  MopubAdapterForiOS
//
//  Created by rdorofeev on 8/23/19.
//  Copyright © 2019 rdorofeev. All rights reserved.
//

#import "DIOMopubRewardedVideoAdapter.h"

#import <DIOSDK/DIOController.h>

@interface DIOMopubRewardedVideoAdapter ()

@property (nonatomic, strong) DIOAd *dioAd;

@end


@implementation DIOMopubRewardedVideoAdapter

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info {
    [self requestRewardedVideoWithCustomEventInfo:info adMarkup:nil];
}

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    
    NSString *placementId = [info objectForKey:@"placementid"];
    
    if (![DIOController sharedInstance].initialized) {
        NSLog(@"Error: DIOController not initialized!");
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"DIOController not initialized!"}];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
    }else {
        DIOConsentState state = [[MoPub sharedInstance] canCollectPersonalInfo] ? DIOConsentStateYES : DIOConsentStateNO;
        DIOConsentState gdpr = [[MoPub sharedInstance] isGDPRApplicable] ? DIOConsentStateYES : DIOConsentStateNO;
        [[DIOController sharedInstance] setConsentData:state gdprState:gdpr];
        [[DIOController sharedInstance] setMediationPlatform:DIOMediationPlatformMopub];
        
        [self loadDioRewardedVideo:placementId];
    }
}

- (void)loadDioRewardedVideo:(NSString *)placementId{
    DIOPlacement *placement = [[DIOController sharedInstance] placementWithId:placementId];
    if (!placement) {
        NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                             code:100
                                         userInfo:@{NSLocalizedDescriptionKey:@"Invalid placement"}];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error: error];
        return;
    }
    
    DIOAdRequest *request = [placement newAdRequest];

    [request requestAdWithAdReceivedHandler:^(DIOAdProvider *adProvider) {
        [adProvider loadAdWithLoadedHandler:^(DIOAd *ad) {
            self.dioAd = ad;
            
            [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
            NSLog(@"Ad for placement %@ received!", placementId);
        } failedHandler:^(NSError *error){
            NSError *error1 = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                                 code:100
                                             userInfo:@{NSLocalizedDescriptionKey:error.localizedDescription}];
            [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error1];
            NSLog(@"%@", error.localizedDescription);
        }];
    } noAdHandler:^(NSError *error){
        NSLog(@"No ad provider");
    }];
}

-(BOOL)hasAdAvailable{
//    NSLog(self.dioAd != nil ? @"DIO Ad is available" : @"DIO Ad is not available");
    return self.dioAd != nil;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)rootViewController{
    
    if (self.dioAd != nil) {
        [self.dioAd showAdFromViewController:rootViewController eventHandler:^(DIOAdEvent event){
            switch (event) {
                case DIOAdEventOnShown:
                    [self.delegate trackImpression];
                    [self.delegate rewardedVideoWillAppearForCustomEvent:self];
                    [self.delegate rewardedVideoDidAppearForCustomEvent:self];
                    NSLog(@"AdEventOnShown");
                    break;
                    
                case DIOAdEventOnClicked:
                    NSLog(@"AdEventOnClicked");
                    break;
                    
                case DIOAdEventOnFailedToShow: {
                    NSError *error = [NSError errorWithDomain:@"https://appsrv.display.io/srv"
                                                         code:100
                                                     userInfo:@{NSLocalizedDescriptionKey:@"Failed to show ad"}];
                    [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error: error];
                    NSLog(@"AdEventOnFailedToShow");
                    self.dioAd = nil;
                    break;
                }
                    
                case DIOAdEventOnClosed:
                    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
                    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
                    NSLog(@"AdEventOnClosed");
                    self.dioAd = nil;
                    break;
                    
                case DIOAdEventOnAdCompleted:
                    [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
                    [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
                    [self.delegate rewardedVideoShouldRewardUserForCustomEvent:self reward:nil]; // TODO reward?

                    NSLog(@"AdEventOnAdCompleted");
                    self.dioAd = nil;
                    break;
            }
        }];
    }
}

@end
