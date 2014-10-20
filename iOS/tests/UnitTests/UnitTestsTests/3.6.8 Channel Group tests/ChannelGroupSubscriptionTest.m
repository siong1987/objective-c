//
//  ChannelGroupSubscriptionTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 10/10/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>

static NSString *kOriginPath = @"pubsub-emea.pubnub.com";
static NSString *kPublishKey = @"demo";
static NSString *kSubscribeKey = @"demo";
static NSString *kSecretKey = @"mySecret";

@interface ChannelGroupSubscriptionTest : XCTestCase
<
PNDelegate
>
@end

@implementation ChannelGroupSubscriptionTest {
    dispatch_group_t _resGroup1;
    dispatch_group_t _resGroup2;
    dispatch_group_t _resGroup3;
    dispatch_group_t _resGroup4;
    dispatch_group_t _resGroup5;
    dispatch_group_t _resGroup6;
    
    dispatch_group_t _resGroup7;
    dispatch_group_t _resGroup8;
    
    NSString *_namespaceName;
    NSArray *_channels;
    PNChannelGroup *_group;
    PNChannelGroup *_group2;
    NSArray *_groups;
    NSDictionary *_dictionary;
    id _testMessage;
}

- (void)setUp {
    [super setUp];
    
    [PubNub disconnect];
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kOriginPath
                                                                  publishKey:kPublishKey
                                                                subscribeKey:kSubscribeKey
                                                                   secretKey:kSecretKey];
    
    [PubNub setupWithConfiguration:configuration andDelegate:self];
    [PubNub connect];
    
    _channels = [PNChannel channelsWithNames:@[@"test_ios_1", @"test_ios_2", @"test_ios_3"]];
    _group = [PNChannelGroup channelGroupWithName:@"test_channel_group1" inNamespace:@"unit_test_ios_namespace" shouldObservePresence:NO];
    _group2 = [PNChannelGroup channelGroupWithName:@"test_channel_group2" inNamespace:@"unit_test_ios_namespace" shouldObservePresence:NO];
    
    _groups = [NSArray arrayWithObjects:_group,_group2, nil];
    
    _testMessage = @"Test message";
}

- (void)tearDown {
    [PubNub disconnect];
    
    [super tearDown];
}

/**
 Test cases:
  - subscribe on
  - subscribe with completion block
  - subscribe with client state
  - subscribe with client state and completion block
  - unsubscribe
  - unsubscribe with completion block
 */
 
#pragma mark - Tests

// Test 1
- (void)testSubscribeOn {
    _resGroup1 = dispatch_group_create();

    // 1. Add channels to group
    dispatch_group_enter(_resGroup1);
    [[PubNub sharedInstance] addChannels:_channels toGroup:_group];

    if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        dispatch_group_leave(_resGroup1);
        _resGroup1 = NULL;
        return;
    }

    // 2. Subscribe on group
    [PubNub subscribeOn:@[_group]];
    [GCDWrapper sleepForSeconds:3];
    XCTAssert([PubNub isSubscribedOn:_group], @"Is not subscribed on group 1");

    // 3. Check that if we send a message to this group we are able to receive it
    dispatch_group_enter(_resGroup1);
    dispatch_group_enter(_resGroup1);

    [PubNub sendMessage:_testMessage
              toChannel:_channels[0]
             compressed:YES
         storeInHistory:YES
    withCompletionBlock:^(PNMessageState state, id message) {
        if (state == PNMessageSent) {
            dispatch_group_leave(_resGroup1);
        } else if (state == PNMessageSendingError) {
            XCTFail(@"Failed to send message");
        }
    }];

    if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. We didn't receive message about sending channel.");
    }

    _resGroup1 = NULL;
}

// Test 2
- (void)t1estSubscribeOnWithCompletionBlockInstance {
    _resGroup2 = dispatch_group_create();
    
    NSArray *channels = [PNChannel channelsWithNames:@[@"test_ios_4", @"test_ios_5", @"test_ios_6"]];
    
    // 1. Add channels to group
    dispatch_group_enter(_resGroup2);
    [[PubNub sharedInstance] addChannels:channels toGroup:_group];
    
    if ([GCDWrapper isGroup:_resGroup2 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        dispatch_group_leave(_resGroup2);
        _resGroup2 = NULL;
        return;
    }
    
    // 2. Subscribe on groups with block
    dispatch_group_enter(_resGroup2);
    
    [PubNub subscribeOn:@[_group] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *groups, PNError *error) {
        
        if (_resGroup2 != NULL) {
            if (error == nil) {
                XCTAssert([groups isEqual:@[_group]], @"Received groups is wrong: %@ <> %@", groups, _group);
            } else {
                XCTFail(@"PubNub client did fail to subscribe to an array of groups %@", error);
            }
            dispatch_group_leave(_resGroup2);
        }
    }];
    
    if ([GCDWrapper isGroup:_resGroup2 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. We didn't subscribe to an array of groups.");
        dispatch_group_leave(_resGroup2);
    }
    
    _resGroup2 = NULL;
}

- (void)testSimultaneousSubscription {
    _resGroup7 = dispatch_group_create();
    
    NSArray *channels1 = [PNChannel channelsWithNames:@[@"test_sim_1", @"test_sim_2", @"test_sim_3"]];
    NSArray *channels2 = [PNChannel channelsWithNames:@[@"test_ios_4", @"test_ios_5", @"test_ios_6"]];
    
    // 1. Add channels to group
    dispatch_group_enter(_resGroup7);
    
    [[PubNub sharedInstance] addChannels:channels1 toGroup:_group];
    
    if ([GCDWrapper isGroup:_resGroup7 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        dispatch_group_leave(_resGroup7);
        _resGroup7 = NULL;
        return;
    }
    
    _resGroup7 = NULL;
    
    _resGroup8 = dispatch_group_create();
    dispatch_group_enter(_resGroup8);
    [[PubNub sharedInstance] addChannels:channels2 toGroup:_group];
    
    if ([GCDWrapper isGroup:_resGroup8 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        dispatch_group_leave(_resGroup8);
        _resGroup8 = NULL;
        return;
    }

    _resGroup7 = NULL;
    _resGroup8 = NULL;
}

#warning Failed due to: timeout fired for addChannels.
- (void)t1estSubscribeWithClientStateInstance {
    _resGroup3 = dispatch_group_create();
    
    NSArray *channels = [PNChannel channelsWithNames:@[@"test_ios_7", @"test_ios_8", @"test_ios_9"]];
    
    // 1. Add channels to group
    dispatch_group_enter(_resGroup3);
    [[PubNub sharedInstance] addChannels:channels toGroup:_group];
    
    if ([GCDWrapper isGroup:_resGroup3 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        dispatch_group_leave(_resGroup3);
        _resGroup3 = NULL;
        return;
    }
    
    // 2. Subscribe on group with client state
    dispatch_group_enter(_resGroup3);
    _dictionary = [NSDictionary dictionaryWithObject:@"tObject1" forKey:@"tKey1"];
    
    [PubNub subscribeOn:@[_group] withClientState:_dictionary];
    [GCDWrapper sleepForSeconds:3];
    XCTAssert([PubNub isSubscribedOn:_group], @"Is not subscribed on group 1");
    
    _resGroup3 = NULL;
}

// Test 4
- (void)t1estSubscribeWithClientStateAndCompletionBlockInstance {
    _resGroup4 = dispatch_group_create();
    
    // 1. Add channels to group
    dispatch_group_enter(_resGroup4);
    [[PubNub sharedInstance] addChannels:_channels toGroup:_group];
    
    if ([GCDWrapper isGroup:_resGroup4 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        dispatch_group_leave(_resGroup4);
        _resGroup4 = NULL;
        return;
    }
    
    // 2. Subscribe on group with client state and block
    dispatch_group_enter(_resGroup4);
    _dictionary = [NSDictionary dictionaryWithObject:@"tObject1" forKey:@"tKey1"];
    
    [PubNub subscribeOn:@[_group] withClientState:_dictionary andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *groups, PNError *error) {
        if (_resGroup4 != NULL) {
            if (error == nil) {
                XCTAssert([groups isEqual:@[_group]], @"Received groups is wrong: %@ <> %@", groups, _groups);
            } else {
                XCTFail(@"PubNub client did fail to subscribe to an array of groups %@", error);
            }
            dispatch_group_leave(_resGroup4);
        }
    }];
    
    if ([GCDWrapper isGroup:_resGroup4 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. We didn't subscribe to an array of groups.");
        dispatch_group_leave(_resGroup4);
    }
    
    _resGroup4 = NULL;
}

// Test 5
- (void)t1estUnsubscribeInstance {
    _resGroup5 = dispatch_group_create();
    
    // 1. Add channels to group
    dispatch_group_enter(_resGroup5);
    [[PubNub sharedInstance] addChannels:_channels toGroup:_group];
    
    if ([GCDWrapper isGroup:_resGroup5 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        dispatch_group_leave(_resGroup5);
        _resGroup5 = NULL;
        return;
    }
    
    // 2. Subscribe on group
    dispatch_group_enter(_resGroup5);
    [PubNub subscribeOn:@[_group]];
    [GCDWrapper sleepForSeconds:3];
    XCTAssert([PubNub isSubscribedOn:_group], @"Is not subscribed on group 1");
    
    // 3. Unubscribe from group
    dispatch_group_enter(_resGroup5);
    [PubNub unsubscribeFrom:@[_group]];
    
    [GCDWrapper sleepForSeconds:3];
    if ([PubNub isSubscribedOn:_group]) {
        XCTFail(@"Is not unsubscribed from group 1");
    }
    
    _resGroup5 = NULL;
}

// Test 6
- (void)t1estUnsubscribeWithCompletionBlockInstance {
    _resGroup6 = dispatch_group_create();
    
    // 1. Add channels to group
    dispatch_group_enter(_resGroup6);
    [[PubNub sharedInstance] addChannels:_channels toGroup:_group];
    
    if ([GCDWrapper isGroup:_resGroup6 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't receive delegates call about adding/failing channels");
        dispatch_group_leave(_resGroup6);
        _resGroup6 = NULL;
        return;
    }
    
    // 2. Subscribe on group
    dispatch_group_enter(_resGroup6);
    [PubNub subscribeOn:@[_group]];
    [GCDWrapper sleepForSeconds:3];
    XCTAssert([PubNub isSubscribedOn:_group], @"Is not subscribed on group 1");
    
    // 3. Unubscribe from group with block
    dispatch_group_enter(_resGroup6);
    
    [PubNub unsubscribeFrom:@[_group] withCompletionHandlingBlock:^(NSArray *groups, PNError *error) {
        if (_resGroup6 != NULL) {
            if (error == nil) {
                XCTAssert([groups isEqual:@[_group]], @"Received groups is wrong: %@ <> %@", groups, _group);
            } else {
                XCTFail(@"PubNub client did fail to unsubscribe from groups %@", error);
            }
            dispatch_group_leave(_resGroup6);
        }
    }];
    
    if ([GCDWrapper isGroup:_resGroup6 timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. We didn't unsubscribe from groups.");
        dispatch_group_leave(_resGroup6);
    }
    
    _resGroup6 = NULL;
}



#pragma mark - PNDelegate

// Receive message (did)
- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    if (_resGroup1) {
        dispatch_group_leave(_resGroup1);
    }
}

// Receive message (fail)
- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
    if (_resGroup1) {
        XCTFail(@"Did fail during test 1: %@", error);
        dispatch_group_leave(_resGroup1);
    }
}


// Add channels in group (did)
- (void)pubnubClient:(PubNub *)client didAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
    
    if (_resGroup1 != NULL) {
        dispatch_group_leave(_resGroup1);
    }
    
    if (_resGroup2 != NULL) {
        dispatch_group_leave(_resGroup2);
    }
    
    if (_resGroup3 != NULL) {
        dispatch_group_leave(_resGroup3);
    }
    if (_resGroup4 != NULL) {
        dispatch_group_leave(_resGroup4);
    }
    if (_resGroup5 != NULL) {
        dispatch_group_leave(_resGroup5);
    }
    if (_resGroup6 != NULL) {
        dispatch_group_leave(_resGroup6);
    }
    
    if (_resGroup7 != NULL) {
        dispatch_group_leave(_resGroup7);
    }
    
    if (_resGroup8 != NULL) {
        dispatch_group_leave(_resGroup8);
    }
    
    for(NSArray *channel in channels){
        NSLog(@"!!! Did receive channel: %@ in group: %@", channel, group);
    }
}

// Add channels to group (fail)
- (void)pubnubClient:(PubNub *)client channelsAdditionToGroupDidFailWithError:(PNError *)error {
    if (_resGroup1 != NULL) {
        dispatch_group_leave(_resGroup1);
    }
    if (_resGroup2 != NULL) {
        dispatch_group_leave(_resGroup2);
    }
    if (_resGroup3 != NULL) {
        dispatch_group_leave(_resGroup3);
    }
    if (_resGroup4 != NULL) {
        dispatch_group_leave(_resGroup4);
    }
    if (_resGroup5 != NULL) {
        dispatch_group_leave(_resGroup5);
    }
    if (_resGroup6 != NULL) {
        dispatch_group_leave(_resGroup6);
    }
    
    if (_resGroup7 != NULL) {
        dispatch_group_leave(_resGroup7);
    }
    
    if (_resGroup8 != NULL) {
        dispatch_group_leave(_resGroup8);
    }
    
    if (error) {
        XCTFail(@"PubNub client did fail to add channels from the group: %@", error);
    }
}

// Subscribe on group (did)
- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
    if (_resGroup3) {
        dispatch_group_leave(_resGroup3);
    }
    if (_resGroup5) {
        dispatch_group_leave(_resGroup5);
    }
    if (_resGroup6) {
        dispatch_group_leave(_resGroup6);
    }
}

// Subscribe on group (fail)
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    if (_resGroup1) {
        XCTFail(@"Did fail during test 1: %@", error);
        dispatch_group_leave(_resGroup2);
    }
    if (_resGroup3) {
        XCTFail(@"Did fail during test 3: %@", error);
        dispatch_group_leave(_resGroup3);
    }
    if (_resGroup5) {
        XCTFail(@"Did fail during test 5: %@", error);
        dispatch_group_leave(_resGroup5);
    }
    if (_resGroup6) {
        XCTFail(@"Did fail during test 6: %@", error);
        dispatch_group_leave(_resGroup6);
    }
    
    if (_resGroup7) {
        XCTFail(@"Did fail during test 7: %@", error);
        dispatch_group_leave(_resGroup7);
    }
    
    if (_resGroup8) {
        XCTFail(@"Did fail during test 8: %@", error);
        dispatch_group_leave(_resGroup8);
    }
    
}


// Unsubscribe from group (did)
- (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
    if (_resGroup5) {
        dispatch_group_leave(_resGroup5);
    }
}

// Unsubscribe from group (fail)
- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    if (_resGroup5) {
        XCTFail(@"Did fail during test 5: %@", error);
        dispatch_group_leave(_resGroup5);
    }
}

@end
