/**
 
 @author Vadim Osovets
 @version3.6.8
 @copyright © 2014-10 PubNub Inc.
 
*/

#import <XCTest/XCTest.h>

@interface DelegateHandler : NSObject

<
PNDelegate
>

@property (nonatomic, weak) PubNub *pubNub;
@property (nonatomic, strong) dispatch_group_t notifyGroupResult;
@property (nonatomic, assign, readonly) BOOL isFailed;

@end

@interface PubNubDelegateTest : XCTestCase

@end

@implementation PubNubDelegateTest {
    dispatch_group_t _resGroup;
    
    PubNub *_pubNub2;
    PubNub *_pubNub3;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [PubNub disconnect];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
    [PubNub disconnect];
}

#pragma mark - Test

/**
 Scenario of test:
 
 - use different objects to handle delegates methods from PubNub instances.
 - connect/disconnect from/to services and check delegates method called only for
 */

- (void)testDelegates {
    
    // Initial configuration
    
    DelegateHandler *handler1 = [DelegateHandler new];
    DelegateHandler *handler2 = [DelegateHandler new];
    DelegateHandler *handler3 = [DelegateHandler new];
    
    PNConfiguration *configuration1 = [PNConfiguration defaultConfiguration];
    PNConfiguration *configuration2 = [PNConfiguration defaultConfiguration];
    PNConfiguration *configuration3 = [PNConfiguration defaultConfiguration];
    
    dispatch_group_t groupHandler1 = dispatch_group_create();
//    dispatch_group_t groupHandler2 = dispatch_group_create();
//    dispatch_group_t groupHandler3 = dispatch_group_create();
    
    handler1.pubNub = [PubNub sharedInstance];
    handler1.notifyGroupResult = groupHandler1;
    [PubNub setDelegate:handler1];
    
    _pubNub2 = [PubNub clientWithConfiguration:configuration2
                                   andDelegate:handler2];
    
    [_pubNub2 setupWithConfiguration:configuration2 andDelegate:handler2];
    
    _pubNub3 = [PubNub clientWithConfiguration:configuration3
                                   andDelegate:handler3];

    
    [PubNub setupWithConfiguration:configuration1
                       andDelegate:handler1];
    
    handler2.pubNub = _pubNub2;
    handler2.notifyGroupResult = groupHandler1;
    
    handler3.pubNub = _pubNub3;
    handler3.notifyGroupResult = groupHandler1;


    // Case 1: connect all services. Determine if we receive only our delegates.
    
    dispatch_group_enter(groupHandler1);
    dispatch_group_enter(groupHandler1);
    dispatch_group_enter(groupHandler1);
    
    [PubNub connect];
    [_pubNub2 connect];
    [_pubNub3 connect];
    
    if ([GCDWrapper isGroup:groupHandler1 timeoutFiredValue:30]) {
        XCTFail(@"Timeout during connect case.");
        return;
    }
    
    if (handler1.isFailed || handler2.isFailed || handler3.isFailed) {
        XCTFail(@"One of delegates receive wrong delegate call.");
        return;
    }
    
    // Case 2: disconnect singletone and check that other instances still works.
    groupHandler1 = dispatch_group_create();
    handler1.notifyGroupResult = groupHandler1;
    
    handler2.notifyGroupResult = NULL;
    handler3.notifyGroupResult = NULL;
    
    dispatch_group_enter(groupHandler1);

    [PubNub disconnect];
    
    if ([GCDWrapper isGroup:groupHandler1 timeoutFiredValue:30]) {
        XCTFail(@"Failed to disconnect from origin.");
    }
    
    // let's wait for 5 second to make sure we didn't touch anything
    
    [GCDWrapper sleepForSeconds:5];
    
    if (handler1.isFailed || handler2.isFailed || handler3.isFailed) {
        XCTFail(@"One of delegates receive wrong delegate call.");
        return;
    }
}

@end

#pragma mark - DelegateHandler

@implementation DelegateHandler

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    if ([client isEqual:self.pubNub]) {
        
        dispatch_group_leave(self.notifyGroupResult);
    } else {
        _isFailed = YES;
    }
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {
    if ([client isEqual:self.pubNub]) {
        _isFailed = YES;
        dispatch_group_leave(self.notifyGroupResult);
    } else {
        _isFailed = YES;
    }
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    if ([client isEqual:self.pubNub]) {
        dispatch_group_leave(self.notifyGroupResult);
    } else {
        _isFailed = YES;
    }
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    if ([client isEqual:self.pubNub]) {
        _isFailed = YES;
        dispatch_group_leave(self.notifyGroupResult);
    } else {
        _isFailed = YES;
    }
}

- (void)dealloc {
    _pubNub = nil;
    _notifyGroupResult = NULL;
}

@end
