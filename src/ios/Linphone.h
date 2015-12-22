#import <Cordova/CDV.h>
#import "LinphoneManager.h"
#include "linphone/linphonecore.h"

@interface Linphone : CDVPlugin{
    LinphoneManager *lm;
    LinphoneCore *lc;
    LinphoneCall *call;
}

@property (nonatomic) LinphoneManager *lm;
@property (nonatomic) LinphoneCore *lc;
@property (nonatomic) LinphoneCall *call;

- (void)login:(CDVInvokedUrlCommand*)command;
- (void)logout:(CDVInvokedUrlCommand*)command;
- (void)call:(CDVInvokedUrlCommand*)command;
- (void)videocall:(CDVInvokedUrlCommand*)command;
- (void)hangup:(CDVInvokedUrlCommand*)command;
- (void)toggleVideo:(CDVInvokedUrlCommand*)command;
- (void)toggleSpeaker:(CDVInvokedUrlCommand*)command;
- (void)toggleMute:(CDVInvokedUrlCommand*)command;
- (void)sendDtmf:(CDVInvokedUrlCommand*)command;

@end