#import "PubNub.h"

/**
 Base class extension which provide methods for state manipulation.
 
 @author Sergey Mamontov
 @version 3.6.8
 @copyright © 2009-13 PubNub Inc.
 */
@interface PubNub (State)


#pragma mark - Class (singleton) methods

/**
 Retrieve client state information from \b PubNub service.

 @param clientIdentifier
 Client identifier for which \b PubNub client should retrieve state.

 @param channel
 \b PNChannel instance from which client's state should be pulled out.

 @since 3.6.0
 */
+ (void)requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel;

/**
 Retrieve client state information from \b PubNub service.

 @code
 @endcode
 This method extends \a +requestClientState:forChannel: and allow to specify state retrieval process handling
 block.

 @param clientIdentifier
 Client identifier for which \b PubNub client should retrieve state.

 @param channel
 \b PNChannel instance from which client's state should be pulled out.

 @param handlerBlock
 The block which will be called by \b PubNub client as soon as client state retrieval process operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c state - is \b PNDictionary instance which store state previously bounded to the client at specified channel;
 \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @since 3.6.0
 */
+ (void) requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel
withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock;

/**
 Update client state information.

 @param clientIdentifier
 Client identifier for which \b PubNub client should bound state.

 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.

 @param channel
 \b PNChannel instance for which client's state should be bound.

 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
  PubNub service will remove specified key from client's state at specified channel.

 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.

 @since 3.6.0
 */
+ (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
               forChannel:(PNChannel *)channel;

/**
 Update client state information.

 @code
 @endcode
 This method extends \a +updateClientState:state:forChannel: and allow to specify state update process
 handling block.

 @param clientIdentifier
 Client identifier for which \b PubNub client should bound state.

 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.

 @param channel
 \b PNChannel instance for which client's state should be bound.

 @param handlerBlock
 The block which will be called by \b PubNub client as soon as client state update process operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c channels - is list of \b PNChannel instances in which \c clientIdentifier has been found as subscriber; \c error -
 describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
  PubNub service will remove specified key from client's state at specified channel.

 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.

 @since 3.6.0
 */
+ (void)   updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState
                  forChannel:(PNChannel *)channel
 withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock;


#pragma mark - Instance methods

/**
 Retrieve client state information from \b PubNub service.

 @param clientIdentifier
 Client identifier for which \b PubNub client should retrieve state.

 @param channel
 \b PNChannel instance from which client's state should be pulled out.

 @since 3.6.8
 */
- (void)requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel;

/**
 Retrieve client state information from \b PubNub service.

 @code
 @endcode
 This method extends \a -requestClientState:forChannel: and allow to specify state retrieval process handling
 block.

 @param clientIdentifier
 Client identifier for which \b PubNub client should retrieve state.

 @param channel
 \b PNChannel instance from which client's state should be pulled out.

 @param handlerBlock
 The block which will be called by \b PubNub client as soon as client state retrieval process operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c state - is \b PNDictionary instance which store state previously bounded to the client at specified channel;
 \c error - describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @since 3.6.8
 */
- (void) requestClientState:(NSString *)clientIdentifier forChannel:(PNChannel *)channel
withCompletionHandlingBlock:(PNClientStateRetrieveHandlingBlock)handlerBlock;

/**
 Update client state information.

 @param clientIdentifier
 Client identifier for which \b PubNub client should bound state.

 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.

 @param channel
 \b PNChannel instance for which client's state should be bound.

 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
  PubNub service will remove specified key from client's state at specified channel.

 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.

 @since 3.6.8
 */
- (void)updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState forChannel:(PNChannel *)channel;

/**
 Update client state information.

 @code
 @endcode
 This method extends \a -updateClientState:state:forChannel: and allow to specify state update process
 handling block.

 @param clientIdentifier
 Client identifier for which \b PubNub client should bound state.

 @param clientState
 \b NSDictionary instance with list of parameters which should be bound to the client.

 @param channel
 \b PNChannel instance for which client's state should be bound.

 @param handlerBlock
 The block which will be called by \b PubNub client as soon as client state update process operation will be
 completed. The block takes three arguments:
 \c clientIdentifier - identifier for which \b PubNub client search for channels;
 \c channels - is list of \b PNChannel instances in which \c clientIdentifier has been found as subscriber; \c error -
 describes what exactly went wrong (check error code and compare it with \b PNErrorCodes ).

 @note You can delete previously configured key from state by passing [NSNull null] as value for target key and \b
  PubNub service will remove specified key from client's state at specified channel.

 @warning Client state shouldn't contain any nesting and values should be one of: int, float or string.

 @since 3.6.8
 */
- (void)   updateClientState:(NSString *)clientIdentifier state:(NSDictionary *)clientState forChannel:(PNChannel *)channel
 withCompletionHandlingBlock:(PNClientStateUpdateHandlingBlock)handlerBlock;

#pragma mark -


@end
