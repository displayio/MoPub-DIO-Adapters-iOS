//
//  DIOAdapterConfiguration.m
//  MopubAdapterForiOS
//
//  Created by rdorofeev on 23.11.2020.
//  Copyright © 2020 rdorofeev. All rights reserved.
//

#import "DIOAdapterConfiguration.h"

@implementation DIOAdapterConfiguration

NSString *ver = @"3.5.1";

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration
                                  complete:(void(^)(NSError *))complete {
      complete(nil);
}

- (NSString *)adapterVersion{
    return ver;
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName{
    return @"display.io";
}

- (NSString *)networkSdkVersion{
    return ver;
}


@end
