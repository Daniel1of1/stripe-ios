//
//  STPSourceParamsTest.m
//  Stripe
//
//  Created by Ben Guo on 1/25/17.
//  Copyright © 2017 Stripe, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Stripe.h"
#import "STPSourceParams+Private.h"
#import "STPFormEncoder.h"

@interface STPSourceParamsTest : XCTestCase

@end

@implementation STPSourceParamsTest

- (void)testCardParamsWithCard {
    STPCardParams *card = [STPCardParams new];
    card.number = @"4242 4242 4242 4242";
    card.cvc = @"123";
    card.expMonth = 6;
    card.expYear = 2018;
    card.currency = @"usd";
    card.name = @"Jenny Rosen";
    card.addressLine1 = @"123 Fake Street";
    card.addressLine2 = @"Apartment 4";
    card.addressCity = @"New York";
    card.addressState = @"NY";
    card.addressCountry = @"USA";
    card.addressZip = @"10002";

    STPSourceParams *source = [STPSourceParams cardParamsWithCard:card];
    NSDictionary *sourceCard = source.additionalAPIParameters[@"card"];
    XCTAssertEqualObjects(sourceCard[@"number"], card.number);
    XCTAssertEqualObjects(sourceCard[@"cvc"], card.cvc);
    XCTAssertEqualObjects(sourceCard[@"exp_month"], @(card.expMonth));
    XCTAssertEqualObjects(sourceCard[@"exp_year"], @(card.expYear));
    XCTAssertEqualObjects(source.owner[@"name"], card.name);
    NSDictionary *sourceAddress = source.owner[@"address"];
    XCTAssertEqualObjects(sourceAddress[@"line1"], card.addressLine1);
    XCTAssertEqualObjects(sourceAddress[@"line2"], card.addressLine2);
    XCTAssertEqualObjects(sourceAddress[@"city"], card.addressCity);
    XCTAssertEqualObjects(sourceAddress[@"state"], card.addressState);
    XCTAssertEqualObjects(sourceAddress[@"postal_code"], card.addressZip);
    XCTAssertEqualObjects(sourceAddress[@"country"], card.addressCountry);
}

- (NSString *)redirectMerchantNameQueryItemValueFromURLString:(NSString *)urlString {
    NSURLComponents *components = [NSURLComponents componentsWithString:urlString];
    for (NSURLQueryItem *item in components.queryItems) {
        if ([item.name isEqualToString:@"redirect_merchant_name"]) {
            return item.value;
        }
    }
    return nil;
}

- (void)testRedirectMerchantNameURL {
    STPSourceParams *sourceParams = [STPSourceParams sofortParamsWithAmount:1000
                                                                  returnURL:@"test://foo?value=baz"
                                                                    country:@"DE"
                                                        statementDescriptor:nil];

    NSDictionary *params = [STPFormEncoder dictionaryForObject:sourceParams];
    // Should be nil because we have no app name in tests
    XCTAssertNil([self redirectMerchantNameQueryItemValueFromURLString:params[@"redirect"][@"return_url"]]);

    sourceParams.redirectMerchantName = @"bar";
    params = [STPFormEncoder dictionaryForObject:sourceParams];
    XCTAssertEqualObjects([self redirectMerchantNameQueryItemValueFromURLString:params[@"redirect"][@"return_url"]], @"bar");

    sourceParams = [STPSourceParams sofortParamsWithAmount:1000
                                                 returnURL:@"test://foo?redirect_merchant_name=Manual%20Custom%20Name"
                                                   country:@"DE"
                                       statementDescriptor:nil];
    sourceParams.redirectMerchantName = @"bar";
    params = [STPFormEncoder dictionaryForObject:sourceParams];
    // Don't override names set by the user directly in the url
    XCTAssertEqualObjects([self redirectMerchantNameQueryItemValueFromURLString:params[@"redirect"][@"return_url"]], @"Manual Custom Name");

}

@end
