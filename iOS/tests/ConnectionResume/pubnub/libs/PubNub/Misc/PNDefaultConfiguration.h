//
//  PNDefaultConfiguration.h
//  pubnub
//
//  Created by Sergey Mamontov on 12/4/12.
//
//

#ifndef PNDefaultConfiguration_h
#define PNDefaultConfiguration_h

// Stores reference on host URL which is used to access PubNub services
static NSString * const kPNOriginHost = @"pubsub.pubnub.com";

// Stores reference on keys which is required to establish connection and send packets to it
static NSString * const kPNPublishKey = @"pub-c-6887e7f3-aec8-4470-b9a0-e68567c7bd71";
static NSString * const kPNSubscriptionKey = @"sub-c-2d4a4646-0e77-11e3-9bef-02ee2ddab7fe";
static NSString * const kPNSecretKey = @"sec-c-ZjRmZmQzMmYtMDMxMC00NDU1LTliOTUtZmM1ODNlZWM3ZGVm";
static NSString * const kPNCipherKey = nil;
static NSString * const kPNAuthorizationKey = nil;
static BOOL const kPNSecureConnectionRequired = YES;
static BOOL const kPNShouldAutoReconnectClient = YES;
static BOOL const kPNShouldResubscribeOnConnectionRestore = YES;
static BOOL const kPNShouldRestoreSubscriptionFromLastTimeToken = NO;
static BOOL const kPNShouldAcceptCompressedResponse = YES;

static NSTimeInterval const kPNConnectionIdleTimeout = 310.0f;
static NSTimeInterval const kPNNonSubscriptionRequestTimeout = 10.0f;
static NSTimeInterval const kPNSubscriptionRequestTimeout = 10.0f;

// This flag tells whether client should reduce SSL rules when connecting to remote origin because of connection
// error (which probably caused by SSL certificate validation error) If set to YES,
// client will try to preserve SSL security but will use not so strict rules as for remote origin SSL certificate
static BOOL const kPNShouldReduceSecurityLevelOnError = YES;

// This flag tells whether client can discard security option and connect using plain HTTP connection or not. This
// option will be used only if client will fail to connect with specified security rules.
static BOOL const kPNCanIgnoreSecureConnectionRequirement = YES;


#endif // PNDefaultConfiguration_h
