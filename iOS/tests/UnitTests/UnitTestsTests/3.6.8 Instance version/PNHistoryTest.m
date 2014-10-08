//
//  PNikoTest.m
//  UnitTests
//
//  Created by Sergey on 10/1/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>


@interface HistoryDelegateHandler : NSObject

<
PNDelegate
>

@property (nonatomic, weak) PubNub *pubNub;
@property (nonatomic, strong) dispatch_group_t notifyGroupResult;
@property (nonatomic, assign, readonly) BOOL isFailed;

@end

@interface PNHistoryTest : XCTestCase

@end

@implementation PNHistoryTest {
    dispatch_group_t _resultGroup;
    PubNub *_pubNub;
}

- (void)setUp {
    [super setUp];
    
    [PubNub disconnect];
}

- (void)tearDown {
    [super tearDown];
    
    [PubNub disconnect];
}

-(void)testInitialHistoryData {
    
    _resultGroup = dispatch_group_create();
    
    // Configuration, connect, create a channel, subscribe on the channel, publish on the channel with history
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub connect];
    
    HistoryDelegateHandler *historyDelegateHandler = [HistoryDelegateHandler new];
    
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                  andDelegate:historyDelegateHandler];
    
    historyDelegateHandler.pubNub = _pubNub;
    
    PNChannel *channel1 = [PNChannel channelWithName:@"iko1" shouldObservePresence:NO];
    
    // subscribe to the same channel
    [PubNub subscribeOnChannel:channel1];
    [_pubNub subscribeOnChannel:channel1];
    
    // fill history with test messages
    for (NSUInteger i = 0; i < 100; i++) {
        [PubNub sendMessage:[NSString stringWithFormat:@"Message %lu", (unsigned long)i] toChannel:channel1 compressed:YES storeInHistory:YES];
        [_pubNub sendMessage:[NSString stringWithFormat:@"Message %lu", (unsigned long)i] toChannel:channel1 compressed:YES storeInHistory:YES];
    }
    
    // Set startDate, endDate, request history for channel_1
    PNDate *startDate = [PNDate dateWithDate:[NSDate dateWithTimeIntervalSinceNow:(-3600.0f)]];
     NSLog(@" startDate: %@", startDate);
    PNDate *endDate = [PNDate dateWithDate:[NSDate date]];
     NSLog(@" endDate: %@", endDate);
    int limit = 34;
    
    _resultGroup = dispatch_group_create();
    dispatch_group_enter(_resultGroup);
    
    [PubNub requestHistoryForChannel:channel_1
                                from:startDate
                                  to:endDate
                               limit:limit
                      reverseHistory:YES
                 withCompletionBlock:^(NSArray *messages, PNChannel *channel,
                                       PNDate *startDate, PNDate *endDate, PNError *error) {
                     
                     if (error == nil) {
                         // PubNub client successfully retrieved history for channel.
                         for(NSArray *m in messages){
                             NSLog(@" message!!! %@", m);
                         }
                      }
                     else {
                          NSLog(@" Error!!!");
                     }
                     
                     dispatch_group_leave(_resultGroup);
                  }];
    
    if ([GCDWrapper isGroup:_resultGroup timeoutFiredValue:30]) {
        XCTFail(@"Didn't receive error message about invalid congiguration.");
    }
    
    _resultGroup = NULL;
}

@end

