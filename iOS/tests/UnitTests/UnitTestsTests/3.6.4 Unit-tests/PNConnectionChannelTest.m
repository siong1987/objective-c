//
//  PNConnectionChannelTest.m
//  UnitTestSample
//
//  Created by Vadim Osovets on 5/7/13.
//  Copyright (c) 2013 Micro-B. All rights reserved.
//

#import "PNConnectionChannelTest.h"
#import "PNConnectionChannel.h"
#import "PNConnectionChannel+Protected.h"

#import <OCMock/OCMock.h>

#import "PNConnection.h"
#import "PNSubscribeRequest.h"
#import "PNChannel.h"
#import "PNRequestsQueue.h"

typedef NS_OPTIONS(NSUInteger, PNConnectionStateFlag)  {

    // Channel trying to establish connection to PubNub services
    PNConnectionChannelConnecting = 1 << 0,

    // Channel reconnecting with same settings which was used during initialization
    PNConnectionChannelReconnect = 1 << 1,

    // Channel is resuming it's operation state
    PNConnectionChannelResuming = 1 << 2,

    // Channel is ready for work (connections established and requests queue is ready)
    PNConnectionChannelConnected = 1 << 3,

    // Channel is transferring to suspended state
    PNConnectionChannelSuspending = 1 << 4,

    // Channel is in suspended state
    PNConnectionChannelSuspended = 1 << 5,

    // Channel is disconnecting on user request (for example: leave request for all channels)
    PNConnectionChannelDisconnecting = 1 << 6,

    // Channel is ready, but was disconnected and waiting command for connection (or was unable to connect during
    // initialization). All requests queue is alive (if they wasn't flushed by user)
    PNConnectionChannelDisconnected = 1 << 7
};

typedef NS_OPTIONS(NSUInteger, PNConnectionActionFlag)  {

    // Flag which allow to set whether client is reconnecting at this moment or not
    PNConnectionReconnect = 1 << 3,

    // Flag which allow to set whether client should connect back as soon as disconnection will be completed or not
    PNConnectionReconnectOnDisconnect = 1 << 4,

    // Flag which allow to set whether client should disconnect or not
    PNConnectionDisconnect = 1 << 5,

    // Flag which allow to set whether read stream configuration started or not
    PNReadStreamConfiguring = 1 << 9,

    // Flag which allow to set whether write stream configuration started or not
    PNWriteStreamConfiguring = 1 << 10,

    // Flag which allow to set whether connection configuration started or not
    PNConnectionConfiguring = (PNReadStreamConfiguring | PNWriteStreamConfiguring),

    // Flag which allow to set whether read stream configured or not
    PNReadStreamConfigured = 1 << 11,

    // Flag which allow to set whether write stream configured or not
    PNWriteStreamConfigured = 1 << 12,

    // Flag which allow to set whether connection configured or not
    PNConnectionConfigured = (PNReadStreamConfigured | PNWriteStreamConfigured),

    // Flag which allow to set whether read stream is connecting right now or not
    PNReadStreamConnecting = 1 << 13,

    // Flag which allow to set whether write stream is connecting right now or not
    PNWriteStreamConnecting = 1 << 14,

    // Flag which allow to set whether client is connecting at this moment or not
    PNConnectionConnecting = (PNReadStreamConnecting | PNWriteStreamConnecting),

    // Flag which allow to set whether read stream is connected right now or not
    PNReadStreamConnected = 1 << 15,

    // Flag which allow to set whether write stream is connected right now or not
    PNWriteStreamConnected = 1 << 16,

    // Flag which allow to set whether connection channel is preparing to establish connection
    PNConnectionPrepareToConnect = 1 << 17,

    // Flag which allow to set whether client is connected or not
    PNConnectionConnected = (PNReadStreamConnected | PNWriteStreamConnected),

    // Flag which allow to set whether connection is suspended or not or not
    PNConnectionResuming = 1 << 18,

    // Flag which allow to set whether read stream is disconnecting right now or not
    PNReadStreamDisconnecting = 1 << 19,

    // Flag which allow to set whether write stream is disconnecting right now or not
    PNWriteStreamDisconnecting = 1 << 20,

    // Flag which allow to set whether client is disconnecting at this moment or not
    PNConnectionDisconnecting = (PNReadStreamDisconnecting | PNWriteStreamDisconnecting),

    // Flag which allow to set whether connection is suspending or not or not
    PNConnectionSuspending = 1 << 21,

    // Flag which allow to set whether read stream is disconnected right now or not
    PNReadStreamDisconnected = 1 << 22,

    // Flag which allow to set whether write stream is disconnected right now or not
    PNWriteStreamDisconnected = 1 << 23,

    // Flag which allow to set whether client is disconnected at this moment or not
    PNConnectionDisconnected = (PNReadStreamDisconnected | PNWriteStreamDisconnected),

    // Flag which stores all states which is responsible for connection 'reconnect' state
    PNConnectionReconnection = (PNConnectionReconnect | PNConnectionReconnectOnDisconnect),

    // Flag which allow to set whether connection is suspended or not or not
    PNConnectionSuspended = 1 << 24,

    // Flag which allow to set whether connection should schedule next requests or not
    PNConnectionProcessingRequests = 1 << 25
};

@interface PNConnectionTestChannel : PNConnectionChannel
@end

@implementation PNConnectionTestChannel
// it should be reloaded in subclasses
- (BOOL)shouldStoreRequest:(PNBaseRequest *)request {
    return YES;
}

@end


@interface PNConnection ()
@property (nonatomic, assign) unsigned long state;
@end

@interface PNConnectionChannel ()

@property (nonatomic, strong) PNConnection *connection;
@property (nonatomic, strong) PNRequestsQueue *requestsQueue;

//- (BOOL)shouldStoreRequest:(PNBaseRequest *)request;
- (id)requestFromStorage:(NSMutableDictionary *)storage withIdentifier:(NSString *)identifier;
- (void)removeRequest:(PNBaseRequest *)request fromStorage:(NSMutableDictionary *)storage;
- (PNBaseRequest *)observedRequestWithIdentifier:(NSString *)identifier;
- (PNBaseRequest *)storedRequestAtIndex:(NSUInteger)requestIndex;

@property (nonatomic, strong) NSMutableDictionary *observedRequests;
@property (nonatomic, strong) NSMutableDictionary *storedRequests;
@property (nonatomic, strong) NSMutableArray *storedRequestsList;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) unsigned long state;

@end

@interface PNConnectionChannelTest () <PNConnectionChannelDelegate>

@end

@implementation PNConnectionChannelTest

- (void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
	[super tearDown];
}

#pragma mark - States tests

- (void)testConnectionChannelWithTypeAndDelegate {
    
    PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
    PNConnectionChannel *connectionChannel = [PNConnectionChannel connectionChannelWithConfiguration:configuration type:PNConnectionChannelMessaging andDelegate:self];
    
    XCTAssertNotNil(connectionChannel, @"Couldn't create connection with message type and delegate");
    
    
connectionChannel = [PNConnectionChannel connectionChannelWithConfiguration:configuration type:PNConnectionChannelService andDelegate:self];    XCTAssertNotNil(connectionChannel, @"Couldn't create connection with service type and delegate");
}

- (void)testInitWithTypeAndDelegate {
    PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
    PNConnectionChannel *connectionChannel = [PNConnectionChannel connectionChannelWithConfiguration:configuration type:PNConnectionChannelMessaging andDelegate:self];
    
    XCTAssertNotNil(connectionChannel, @"Couldn't create connection with message type and delegate");
    
    connectionChannel = [PNConnectionChannel connectionChannelWithConfiguration:configuration type:PNConnectionChannelService andDelegate:self];
    
    XCTAssertNotNil(connectionChannel, @"Couldn't create connection with service type and delegate");
}

#pragma mark - Interaction tests

- (void)testScheduleRequestShouldObserveProcessing {
    PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
    PNConnectionChannel *connectionChannel = [PNConnectionChannel connectionChannelWithConfiguration:configuration type:PNConnectionChannelMessaging andDelegate:self];
    
    id mockChannel = [OCMockObject partialMockForObject:connectionChannel];
    
    [[mockChannel expect] scheduleNextRequest];
    [[[mockChannel stub] andReturnValue:OCMOCK_VALUE((BOOL){YES})] shouldStoreRequest:OCMOCK_ANY];
    
    PNChannel *channel = [PNChannel channelWithName:@"MyTestChannel"];
    PNSubscribeRequest *mockRequest = [PNSubscribeRequest subscribeRequestForChannel:channel byUserRequest:YES withClientState: nil];
    
    [mockChannel scheduleRequest:mockRequest shouldObserveProcessing:YES];
    
    [mockChannel verify];
}

// All methods below just redirect to PNConnection private property of PNConnectionChannel

- (void)testScheduleNextRequestMock {
    // init connection
    PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
    PNConnectionChannel *connectionChannel = [PNConnectionChannel connectionChannelWithConfiguration:configuration type:PNConnectionChannelMessaging andDelegate:self];

    // create mock for private property
    id mockConnect = [OCMockObject partialMockForObject:[PNConnection connectionWithConfiguration:configuration andIdentifier:@"MyTestConnect"]];
    
    [[mockConnect expect] scheduleNextRequestExecution];
    [connectionChannel setConnection:mockConnect];
    
    [connectionChannel scheduleNextRequest];
    
    [mockConnect verify];
}

- (void)testUnscheduleNextRequest {
    // init connection
    
    PNConfiguration *configuration = [PNConfiguration defaultConfiguration];
    PNConnectionChannel *connectionChannel = [PNConnectionChannel connectionChannelWithConfiguration:configuration type:PNConnectionChannelMessaging andDelegate:self];
    
    // create mock for private property
    id mockConnect = [OCMockObject partialMockForObject:[PNConnection connectionWithConfiguration:configuration andIdentifier:@"MyTestConnect"]];
    
    [[mockConnect expect] unscheduleRequestsExecution];
    [connectionChannel setConnection:mockConnect];
    
    [connectionChannel unscheduleNextRequest];
    
    [mockConnect verify];
}

- (void)testUnscheduleRequestMock {
    // init connection
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    
    // create mock for private property
    id mockRequestQueue = [OCMockObject partialMockForObject:[[PNRequestsQueue alloc] init]];
    
    [[mockRequestQueue expect] removeRequest:OCMOCK_ANY];
    [connectionChannel setRequestsQueue:mockRequestQueue];
    
    [connectionChannel unscheduleRequest:nil];
    
    [mockRequestQueue verify];
}

- (void)testClearScheduledRequestsQueue {
    // init connection
    PNConnectionChannel *connectionChannel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    
    // create mock for private property
    id mockRequestQueue = [OCMockObject partialMockForObject:[[PNRequestsQueue alloc] init]];
    
    [[mockRequestQueue expect] removeAllRequests];
    [connectionChannel setRequestsQueue:mockRequestQueue];
    
    [connectionChannel clearScheduledRequestsQueue];
    
    [mockRequestQueue verify];
    
    [connectionChannel setRequestsQueue:nil];
}

#pragma mark - PNConnectionChannel Delegate
- (BOOL)connectionChannelCanConnect:(PNConnectionChannel *)channel {
    return YES;
}

- (void)connectionChannelConfigurationDidFail:(PNConnectionChannel *)channel {}
- (void)connectionChannelWillSuspend:(PNConnectionChannel *)channel {}
- (void)connectionChannelWillResume:(PNConnectionChannel *)channel {}
- (void)connectionChannelDidSuspend:(PNConnectionChannel *)channel {}
- (void)connectionChannelDidResume:(PNConnectionChannel *)channel {}
- (void)connectionChannelDidResume:(PNConnectionChannel *)channel requireWarmUp:(BOOL)isWarmingUpRequired {}

- (void)connectionChannel:(PNConnectionChannel *)channel
         didConnectToHost:(NSString *)host {}

- (void)connectionChannel:(PNConnectionChannel *)channel
       didReconnectToHost:(NSString *)host {}

- (void)connectionChannel:(PNConnectionChannel *)channel
connectionDidFailToOrigin:(NSString *)host
                withError:(PNError *)error {}

- (void)connectionChannel:(PNConnectionChannel *)channel
  didDisconnectFromOrigin:(NSString *)host {}

- (void)connectionChannel:(PNConnectionChannel *)channel
 willDisconnectFromOrigin:(NSString *)host
                withError:(PNError *)error {}
- (BOOL)connectionChannelShouldRestoreConnection:(PNConnectionChannel *)channel {return NO;}

#pragma mark - Tests

-(void)testConnectionChannelWithType {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	XCTAssertTrue( channel.delegate == self, @"");
	XCTAssertTrue( [channel.observedRequests isKindOfClass: [NSMutableDictionary class]] == YES, @"");
	XCTAssertTrue( [channel.storedRequests isKindOfClass: [NSMutableDictionary class]] == YES, @"");
	XCTAssertTrue( [channel.storedRequestsList isKindOfClass: [NSMutableArray class]] == YES, @"");
	XCTAssertTrue( [channel.name isEqualToString: @"PNMessagingConnectionIdentifier"] == YES, @"");
	XCTAssertTrue( [channel.requestsQueue isKindOfClass: [PNRequestsQueue class]] == YES, @"");
	XCTAssertTrue( channel.requestsQueue.delegate == channel, @"");
	XCTAssertTrue( PNBitsIsOn( channel.state, PNConnectionChannelDisconnected, PNConnectionChannelConnecting, BITS_LIST_TERMINATOR) == YES, @"" );
	XCTAssertTrue( [channel.connection isKindOfClass: [PNConnection class]], @"");
}

-(void)testConnect {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	[channel connect];
	XCTAssertTrue( PNBitsIsOn( channel.state, PNConnectionChannelDisconnected, PNConnectionChannelConnecting, BITS_LIST_TERMINATOR) == YES, @"" );
	XCTAssertTrue( [channel.connection isKindOfClass: [PNConnection class]], @"");
}

-(void)testIsConnecting {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOff( &state, PNConnectionChannelDisconnected, PNConnectionChannelConnecting);
	channel.state = state;
	XCTAssertTrue( [channel isConnecting] == NO, @"" );

	state = channel.state;
	PNBitsOn( &state, PNConnectionChannelDisconnected, PNConnectionChannelConnecting);
	channel.state = state;
	XCTAssertTrue( [channel isConnecting] == YES, @"" );
}

-(void)testIsReconnecting {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOff( &state, PNConnectionChannelConnecting, PNConnectionChannelReconnect);
	channel.state = state;
	XCTAssertTrue( [channel isReconnecting] == NO, @"" );

	state = channel.state;
	PNBitsOn( &state, PNConnectionChannelConnecting, PNConnectionChannelReconnect);
	channel.state = state;
	XCTAssertTrue( [channel isReconnecting] == YES, @"" );
}

-(void)testIsConnected {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOff( &state, PNConnectionChannelConnected);
	channel.state = state;
	XCTAssertTrue( [channel isConnected] == NO, @"" );

	state = channel.state;
	PNBitsOff( &state, PNConnectionChannelConnecting, PNConnectionChannelReconnect);
	PNBitOn( &state, PNConnectionChannelConnected);
	channel.state = state;
	XCTAssertTrue( [channel isConnected] == YES, @"" );
}

-(void)testDisconnect {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	[channel disconnect];
	XCTAssertTrue( channel.state == 128, @"");
}

-(void)testIsDisconnecting {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOff( &state, PNConnectionChannelConnected, PNConnectionChannelDisconnecting);
	channel.state = state;
	XCTAssertTrue( [channel isDisconnecting] == NO, @"" );

	state = channel.state;
	PNBitsOn( &state, PNConnectionChannelConnected, PNConnectionChannelDisconnecting);
	channel.state = state;
	XCTAssertTrue( [channel isDisconnecting] == YES, @"" );
}

-(void)testIsDisconnected {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOff( &state, PNConnectionChannelConnecting);
	PNBitOn( &state, PNConnectionChannelDisconnected);
	channel.state = state;
	XCTAssertTrue( [channel isDisconnected] == YES, @"" );

	state = 0;
	PNBitOn( &state, PNConnectionChannelSuspended);
	PNBitOff( &state, PNConnectionChannelConnecting);
	channel.state = state;
	XCTAssertTrue( [channel isDisconnected] == YES, @"" );
}

-(void)testSuspend {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	[channel suspend];
	XCTAssertTrue( channel.state == 160, @"");
}

-(void)testIsSuspending {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOn( &state, PNConnectionChannelConnected, PNConnectionChannelSuspending);
	channel.state = state;
	XCTAssertTrue( [channel isSuspending] == YES, @"" );

	channel.state = 0;
	XCTAssertTrue( [channel isSuspending] == NO, @"" );
}

-(void)testIsSuspended {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOn( &state, PNConnectionChannelConnected, PNConnectionChannelSuspending);
	channel.state = state;
	XCTAssertTrue( [channel isSuspended] == YES, @"" );

	channel.state = 0;
	XCTAssertTrue( [channel isSuspended] == NO, @"" );
}

-(void)testResume {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	[channel resume];
	XCTAssertTrue( channel.state == 8, @"");
}

-(void)testIsResuming {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	unsigned long state = channel.state;
	PNBitsOn( &state, PNConnectionChannelDisconnected, PNConnectionChannelResuming);
	channel.state = state;
	XCTAssertTrue( [channel isResuming] == YES, @"" );

	channel.state = 0;
	XCTAssertTrue( [channel isResuming] == NO, @"" );

	XCTAssertTrue( [channel shouldScheduleRequest: nil] == YES, @"");
}

-(void)testPurgeObservedRequestsPool {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	[channel.observedRequests setObject: @"object" forKey: @"key"];
	XCTAssertTrue( channel.observedRequests.count > 0, @"");
	[channel purgeObservedRequestsPool];
	XCTAssertTrue( channel.observedRequests.count == 0, @"");
}

-(void)testRequestFromStorage {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	XCTAssertTrue( [channel requestFromStorage: [@{@"id":request} mutableCopy] withIdentifier: @"id"] == request, @"");
	XCTAssertTrue( [channel requestFromStorage: [@{@"id":request} mutableCopy] withIdentifier: @"id1"] == nil, @"");
}

-(void)testRemoveRequest {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	NSMutableDictionary *storage = [@{request.shortIdentifier:request} mutableCopy];
	XCTAssertTrue( [channel requestFromStorage: storage withIdentifier: request.shortIdentifier] == request, @"");

	[channel removeRequest: nil fromStorage: storage];
	XCTAssertTrue( storage.count == 1, @"");
	[channel removeRequest: request fromStorage: storage];
	XCTAssertTrue( [channel requestFromStorage: storage withIdentifier: @"id"] == nil, @"");
}

-(void)testRequestWithIdentifier {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel.observedRequests setObject: request forKey: request.identifier];
	XCTAssertTrue( [channel requestWithIdentifier: @"id"] == request, @"");

	[channel.observedRequests removeObjectForKey: request.identifier];
	[channel.storedRequests setObject: @{@"request":request} forKey: request.identifier];
	XCTAssertTrue( [channel requestWithIdentifier: @"id"] == request, @"");

	[channel.storedRequests removeObjectForKey: request.identifier];
	XCTAssertTrue( [channel requestWithIdentifier: @"id"] == nil, @"");
}

-(void)testObservedRequestWithIdentifier {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel.observedRequests setObject: request forKey: request.shortIdentifier];
	XCTAssertTrue( [channel observedRequestWithIdentifier: request.shortIdentifier] == request, @"");
	XCTAssertTrue( [channel observedRequestWithIdentifier: @"id1"] == nil, @"");

	[channel removeObservationFromRequest: request];
	XCTAssertTrue( [channel observedRequestWithIdentifier: request.identifier] == nil, @"");
}

-(void)testPurgeStoredRequestsPool {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel.storedRequestsList addObject: request];
	[channel.storedRequests setObject: request forKey: request.identifier];
	XCTAssertTrue( channel.storedRequestsList.count == 1, @"");
	XCTAssertTrue( channel.storedRequests.count == 1, @"");
	[channel purgeStoredRequestsPool];
	XCTAssertTrue( channel.storedRequestsList.count == 0, @"");
	XCTAssertTrue( channel.storedRequests.count == 0, @"");
}

-(void)testStoredRequestWithIdentifier {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel.storedRequests setObject: @{@"request":request} forKey: request.identifier];
	XCTAssertTrue( [channel storedRequestWithIdentifier: request.identifier] == request, @"");
}

-(void)testNextStoredRequest {
	PNConnectionChannel *channel = [PNConnectionTestChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel scheduleRequest: request shouldObserveProcessing: YES];
	PNBaseRequest *request1 = [[PNBaseRequest alloc] init];
	request.identifier = @"id1";
	[channel scheduleRequest: request1 shouldObserveProcessing: YES];
    
	XCTAssertTrue( [channel nextStoredRequest] == request, @"");
	XCTAssertTrue( [channel nextStoredRequestAfter: request] == request1, @"");
	XCTAssertTrue( [channel lastStoredRequest] == request1, @"");
	XCTAssertTrue( [channel storedRequestAtIndex: 0] == request, @"");
	XCTAssertTrue( [channel storedRequestAtIndex: 1] == request1, @"");
	XCTAssertTrue( [channel storedRequestAtIndex: 2] == nil, @"");
}

-(void)testIsWaitingStoredRequestCompletion {
	PNConnectionChannel *channel = [PNConnectionTestChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel scheduleRequest: request shouldObserveProcessing: NO];
	PNBaseRequest *request1 = [[PNBaseRequest alloc] init];
	request.identifier = @"id1";
	[channel scheduleRequest: request1 shouldObserveProcessing: YES];
	XCTAssertTrue( [channel isWaitingStoredRequestCompletion: @"id"] == NO, @"");
}

-(void)testRemoveStoredRequest {
	PNConnectionChannel *channel = [PNConnectionTestChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel scheduleRequest: request shouldObserveProcessing: NO];
	[channel scheduleRequest: request shouldObserveProcessing: YES];
	XCTAssertTrue( [channel.storedRequestsList indexOfObject: request.shortIdentifier] != NSNotFound, @"");
	XCTAssertTrue( [[channel.storedRequests objectForKey: request.shortIdentifier] objectForKey:@"request"] == request, @"");

	[channel removeStoredRequest: request];
	XCTAssertTrue( [channel.storedRequestsList indexOfObject: request.shortIdentifier] == NSNotFound, @"");
	XCTAssertTrue( [[channel.storedRequests objectForKey: request.shortIdentifier] objectForKey:@"request"] == nil, @"");
}

-(void)testDestroyRequest {
	PNConnectionChannel *channel = [PNConnectionTestChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel scheduleRequest: request shouldObserveProcessing: NO];
	[channel scheduleRequest: request shouldObserveProcessing: YES];
	XCTAssertTrue( [channel.storedRequestsList indexOfObject: request.shortIdentifier] != NSNotFound, @"");
	XCTAssertTrue( [[channel.storedRequests objectForKey: request.shortIdentifier] objectForKey:@"request"] == request, @"");

	[channel destroyRequest: request];
	XCTAssertTrue( [channel.storedRequestsList indexOfObject: request.shortIdentifier] == NSNotFound, @"");
	XCTAssertTrue( [[channel.storedRequests objectForKey: request.shortIdentifier] objectForKey:@"request"] == nil, @"");
}

-(void)testDestroyByRequestClass {
	PNConnectionChannel *channel = [PNConnectionTestChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel scheduleRequest: request shouldObserveProcessing: NO];
	[channel scheduleRequest: request shouldObserveProcessing: YES];
	XCTAssertTrue( [channel.storedRequestsList indexOfObject: request.shortIdentifier] != NSNotFound, @"");
	XCTAssertTrue( [[channel.storedRequests objectForKey: request.shortIdentifier] objectForKey:@"request"] == request, @"");
	[channel destroyByRequestClass: [PNBaseRequest class]];
	XCTAssertTrue( [channel.storedRequestsList indexOfObject: request.shortIdentifier] == NSNotFound, @"");
	XCTAssertTrue( [[channel.storedRequests objectForKey: request.shortIdentifier] objectForKey:@"request"] == nil, @"");
}

-(void)testHasRequestsWithClass {
	PNConnectionChannel *channel = [PNConnectionTestChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel scheduleRequest: request shouldObserveProcessing: NO];
	[channel scheduleRequest: request shouldObserveProcessing: YES];
	XCTAssertTrue( [channel hasRequestsWithClass: [PNBaseRequest class]] == YES, @"");
	XCTAssertTrue( [channel hasRequestsWithClass: [PNSubscribeRequest class]] == NO, @"");
	[channel destroyByRequestClass: [PNBaseRequest class]];
	XCTAssertTrue( [channel hasRequestsWithClass: [PNBaseRequest class]] == NO, @"");
}

-(void)testRequestsWithClass {
	PNConnectionChannel *channel = [PNConnectionTestChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	NSArray *requests = [channel requestsWithClass: [PNBaseRequest class]];
	XCTAssertTrue( requests.count == 0, @"");

	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel scheduleRequest: request shouldObserveProcessing: NO];
	[channel scheduleRequest: request shouldObserveProcessing: YES];

	requests = [channel requestsWithClass: [PNBaseRequest class]];
	XCTAssertTrue( [requests isEqualToArray: @[request]] == YES, @"");
}

-(void)testConnection {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	XCTAssertTrue( [[channel connection] isKindOfClass: [PNConnection class]], @"");
}

-(void)testScheduleRequest {
	PNConnectionChannel *channel = [PNConnectionTestChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: self];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel scheduleRequest: request shouldObserveProcessing: YES];
	XCTAssertTrue( channel.storedRequestsList.count == 1, @"");
}

-(void)testReconnect {
	PNConnectionChannel *channel = [PNConnectionChannel connectionChannelWithType: PNConnectionChannelMessaging andDelegate: nil];
	PNBaseRequest *request = [[PNBaseRequest alloc] init];
	request.identifier = @"id";
	[channel reconnect];
	unsigned long state = channel.state;
	XCTAssertTrue( PNBitIsOn( state, PNConnectionChannelReconnect) == YES, @"");
}

- (void)testTerminate {
    PNConnectionChannel *channel = [[PNConnectionChannel alloc] initWithType:PNConnectionChannelMessaging andDelegate:self];
    id mockConnect = [OCMockObject partialMockForObject:channel];
    [[mockConnect expect] cleanUp];
    [channel terminate];
    [mockConnect verify];
}

@end




