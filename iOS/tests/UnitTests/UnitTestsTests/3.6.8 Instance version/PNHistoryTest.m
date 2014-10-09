/**
 
@author Sergey Kazanskiy
@version3.6.8
@copyright © 2014-10 PubNub Inc.

*/

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
                                  andDelegate:nil];
    
//    historyDelegateHandler.pubNub = _pubNub;
    [_pubNub connect];
    
    PNChannel *channel1 = [PNChannel channelWithName:@"test_channel" shouldObservePresence:NO];
    
    // subscribe to the same channel
    [PubNub subscribeOnChannel:channel1];
    [_pubNub subscribeOnChannel:channel1];
    
    // fill history with test messages
    for (NSUInteger i = 0; i < 100; i++) {
        [PubNub sendMessage:[NSString stringWithFormat:@"Message %lu", (unsigned long)i] toChannel:channel1 compressed:YES storeInHistory:YES];
        [_pubNub sendMessage:[NSString stringWithFormat:@"Message %lu", (unsigned long)i] toChannel:channel1 compressed:YES storeInHistory:YES];
    }
    
    _resultGroup = dispatch_group_create();
    dispatch_group_enter(_resultGroup);
    dispatch_group_enter(_resultGroup);
    
    [PubNub requestHistoryForChannel:channel1
                                from:nil
                                  to:nil
                               limit:0
                      reverseHistory:YES
                 withCompletionBlock:^(NSArray *messages, PNChannel *channel,
                                       PNDate *startDate, PNDate *endDate, PNError *error) {
                     if (error == nil) {
                         // PubNub client successfully retrieved history for channel.
                      }
                     else {
                         XCTFail(@"Cannot retrieve history from server-side with error: %@", error);
                     }
                     
                     dispatch_group_leave(_resultGroup);
                  }];
    
    [_pubNub requestHistoryForChannel:channel1
                                 from:nil
                                   to:nil
                                limit:0
                       reverseHistory:YES
                  withCompletionBlock:^(NSArray *messages, PNChannel *channel,
                                       PNDate *startDate, PNDate *endDate, PNError *error) {
                      if (error == nil) {
                          // PubNub client successfully retrieved history for channel.
                      }
                      else {
                          XCTFail(@"Cannot retrieve history from server-side with error: %@", error);
                      }
                      
                      dispatch_group_leave(_resultGroup);
                  }];
    
    if ([GCDWrapper isGroup:_resultGroup timeoutFiredValue:30]) {
        XCTFail(@"Didn't receive error message about invalid congiguration.");
    }
    
    _resultGroup = NULL;
}


/**
 Check that we receive only delegates call from our instance.
 */
 
-(void)testHistoryDelegate {
    
    _resultGroup = dispatch_group_create();
    
    // Configuration, connect, create a channel, subscribe on the channel, publish on the channel with history
    [PubNub setConfiguration:[PNConfiguration defaultConfiguration]];
    [PubNub connect];
    
    HistoryDelegateHandler *historyDelegateHandler = [HistoryDelegateHandler new];
    
    _pubNub = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration]
                                  andDelegate:historyDelegateHandler];
    
    historyDelegateHandler.pubNub = _pubNub;
    [_pubNub connect];
    
    PNChannel *channel1 = [PNChannel channelWithName:@"test_channel" shouldObservePresence:NO];
    
    // subscribe to the same channel
    [PubNub subscribeOnChannel:channel1];
    [_pubNub subscribeOnChannel:channel1];
    
    // fill history with test messages
    for (NSUInteger i = 0; i < 100; i++) {
        [PubNub sendMessage:[NSString stringWithFormat:@"Message %lu", (unsigned long)i] toChannel:channel1 compressed:YES storeInHistory:YES];
        [_pubNub sendMessage:[NSString stringWithFormat:@"Message %lu", (unsigned long)i] toChannel:channel1 compressed:YES storeInHistory:YES];
    }
    
    _resultGroup = dispatch_group_create();
    historyDelegateHandler.notifyGroupResult = _resultGroup;
    
    dispatch_group_enter(_resultGroup);
    dispatch_group_enter(_resultGroup);
    dispatch_group_enter(_resultGroup);
    
    [PubNub requestHistoryForChannel:channel1
                                from:nil
                                  to:nil
                               limit:0
                      reverseHistory:YES
                 withCompletionBlock:^(NSArray *messages, PNChannel *channel,
                                       PNDate *startDate, PNDate *endDate, PNError *error) {
                     if (error == nil) {
                         // PubNub client successfully retrieved history for channel.
                     }
                     else {
                         XCTFail(@"Cannot retrieve history from server-side with error: %@", error);
                     }
                     
                     dispatch_group_leave(_resultGroup);
                 }];
    
    [_pubNub requestHistoryForChannel:channel1
                                 from:nil
                                   to:nil
                                limit:0
                       reverseHistory:YES
                  withCompletionBlock:^(NSArray *messages, PNChannel *channel,
                                        PNDate *startDate, PNDate *endDate, PNError *error) {
                      if (error == nil) {
                          // PubNub client successfully retrieved history for channel.
                      }
                      else {
                          XCTFail(@"Cannot retrieve history from server-side with error: %@", error);
                      }
                      
                      dispatch_group_leave(_resultGroup);
                  }];
    
    if ([GCDWrapper isGroup:_resultGroup timeoutFiredValue:30]) {
        XCTFail(@"Didn't receive error message about invalid congiguration.");
    }
    
    if (historyDelegateHandler.isFailed) {
        XCTFail(@"Receive wrong delegate call from wrong instance.");
    }
    
    _resultGroup = NULL;
}

@end

#pragma mark - HistoryDelegateHandler

@implementation HistoryDelegateHandler

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didReceiveMessageHistory:(NSArray *)messages forChannel:(PNChannel *)channel startingFrom:(PNDate *)startDate to:(PNDate *)endDate {
    if ([client isEqual:self.pubNub]) {
        dispatch_group_leave(self.notifyGroupResult);
    } else {
        _isFailed = YES;
    }
}

- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {
    if ([client isEqual:self.pubNub]) {
        dispatch_group_leave(self.notifyGroupResult);
        _isFailed = YES;
    } else {
        _isFailed = YES;
    }
}

- (void)dealloc {
    _pubNub = nil;
    _notifyGroupResult = NULL;
}

@end


