//
//  ViewController.m
//  PubNubDemo
//
//  Created by geremy cohen on 3/27/13.
//  Copyright (c) 2013 geremy cohen. All rights reserved.
//

#import "ViewController.h"
#import "PNMessage+Protected.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize textView, presenceView, uuidView;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [PubNub setClientIdentifier:@"SimpleSubscribe"];
    //[uuidView setText:[NSString stringWithFormat:@"%@", [PubNub clientIdentifier]]];

    [[PNObservationCenter defaultCenter] addMessageReceiveObserver:self
                                                         withBlock:^(PNMessage *message) {

                                                             NSLog(@"Text Length: %i", textView.text.length);

                                                             if (textView.text.length > 2000) {
                                                                 [textView setText:@""];
                                                             }

                                                             [textView setText:[message.message stringByAppendingFormat:@"\n%@\n", textView.text]];

                                                         }];

    PNConfiguration *myConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"  publishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"];

    // Set the presence heartbeat to 5s

    [PubNub setConfiguration:myConfig];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {

        PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);

        // wait 1 second
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){

            // then subscribe on channel zz
            PNChannel *ch1 = [PNChannel channelWithName:@"x" shouldObservePresence:YES];
            PNChannel *ch2 = [PNChannel channelWithName:@"y" shouldObservePresence:YES];
            PNChannel *ch3 = [PNChannel channelWithName:@"a" shouldObservePresence:YES];

            [PubNub subscribeOnChannels:[NSArray arrayWithObjects:ch1,ch2,'\0'] withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *array, PNError *error) {
                NSLog(@"Subscribed to ch1,ch2");
            }];

            int64_t delayInSeconds = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC); dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // grab global occupancy list 5s later

                [PubNub subscribeOnChannel:ch3 withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *array, PNError *error) {
                    NSLog(@"Subscribed to ch3");
                }];


            });

        }); }
            // In case of error you always can pull out error code and identify what happened and what you can do // additional information is stored inside error's localizedDescription, localizedFailureReason and
            // localizedRecoverySuggestion)
                         errorBlock:^(PNError *connectionError) {
                             if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
                                 PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");
                             }

                             UIAlertView *connectionErrorAlert = [UIAlertView new];
                             connectionErrorAlert.title = [NSString stringWithFormat:@"%@(%@)",
                                                                                     [connectionError localizedDescription],
                                                                                     NSStringFromClass([self class])];
                             connectionErrorAlert.message = [NSString stringWithFormat:@"Reason:\n%@\n\nSuggestion:\n%@",
                                                                                       [connectionError localizedFailureReason],
                                                                                       [connectionError localizedRecoverySuggestion]];
                             [connectionErrorAlert addButtonWithTitle:@"OK"];
                             [connectionErrorAlert show];
                         }];


}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clearAll:(id)sender {
    textView.text = @"";
    presenceView.text = @"";
}
@end
