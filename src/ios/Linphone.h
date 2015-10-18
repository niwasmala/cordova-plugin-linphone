//
//  LinPhoneGap.h
//
//  Created by John Roy on 04/01/2014
//  Some code copied from linphone under GPL. See LICENSE.gpl and linphone.org
//  Copyright (c) 2014 BabelRoom. All rights reserved.

#import <Cordova/CDV.h>

@interface LinPhoneGap : CDVPlugin

- (void)log:(CDVInvokedUrlCommand*)command;
- (void)call:(CDVInvokedUrlCommand*)command;
- (void)hangup:(CDVInvokedUrlCommand*)command;
- (void)toggleVideo:(CDVInvokedUrlCommand*)command;

@end