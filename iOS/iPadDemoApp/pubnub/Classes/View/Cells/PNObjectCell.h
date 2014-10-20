//
//  PNChannelCell.h
//  pubnub
//
//  Created by Sergey Mamontov on 02/06/13.
//
//

#pragma mark Class forward

@class PNChannel;


#pragma mark - Public interface declaration

@interface PNObjectCell : UITableViewCell


#pragma mark - Properties

/**
 Whether cell should show badge with additional information about channel or not.
 */
@property (nonatomic, assign, getter = shouldShowBadge) BOOL showBadge;


#pragma mark - Instance methods

/**
 * Update cell layout to show data for specified object
 */
- (void)updateForObject:(id <PNChannelProtocol>)object;

#pragma mark -


@end
