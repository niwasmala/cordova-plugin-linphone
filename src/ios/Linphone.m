//
//  LinPhoneGap.m
//
//  Created by John Roy on 04/01/2014
//  Some code copied from linphone under GPL. See LICENSE.gpl and linphone.org
//  Copyright (c) 2014 BabelRoom. All rights reserved.

#import "Linphone.h"
#import <Cordova/CDV.h>

/* in order to use this plugin you will need to add linphone libraries to your Xcode project. This is
non-trivial and requires experience with Xcode and knowledge of how to download, build and integrate third-party libraries.
Change the 1 below to 0 if you wish to integrate this plugin without including liblinphone.
*/
#if 1

#import "LinphoneManager.h"
#import "lpconfig.h"

struct _ConfigCtx {
    LpConfig *lpConfig;
    const char *section;
};
void iterate_config_entry(const char *entry, void *ctx)
{
    struct _ConfigCtx *pCtx = (struct _ConfigCtx *)ctx;
    NSLog(@"%s::%s",pCtx->section,entry);
}
void iterate_config_sections(const char *section, void *ctx)
{
    struct _ConfigCtx *pCtx = (struct _ConfigCtx *)ctx;
    pCtx->section = section;
    lp_config_for_each_entry(pCtx->lpConfig, section, iterate_config_entry, ctx);
}
void iterate_codecs(const char *type, const MSList *codecs)
{
	LinphoneCore *lc=[LinphoneManager getLc];
	const MSList *elem=codecs;
	for(;elem!=NULL;elem=elem->next){
		PayloadType *pt=(PayloadType*)elem->data;
        int value = -1;
		NSString *pref=[LinphoneManager getPreferenceForCodec:pt->mime_type withRate:pt->clock_rate];
		if (pref)
            value = linphone_core_payload_type_enabled(lc,pt)?1:0;
        NSLog(@"%s: %s:%d (%@) = %d", type, pt->mime_type, pt->clock_rate, pref?pref:@"___", value);
	}
}

@implementation LinPhoneGap

- (void)pluginInitialize
{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onOrientationDidChange:) name:
UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(callUpdateEvent:)
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    if(![LinphoneManager isLcReady]) {
        [[LinphoneManager instance]	startLibLinphone];
    }
    if([LinphoneManager isLcReady]) {
        LinphoneCore* lc = [LinphoneManager getLc];

        [self checkOrientation];

        struct _ConfigCtx ctx;
        ctx.lpConfig = linphone_core_get_config(lc);
        lp_config_for_each_section(ctx.lpConfig, iterate_config_sections, &ctx);
        iterate_codecs("Audio", linphone_core_get_audio_codecs(lc));
        iterate_codecs("Video", linphone_core_get_video_codecs(lc));

        CGRect rect = [[UIScreen mainScreen] bounds];
        CGRect rectPreview = CGRectMake(rect.size.width-180, rect.size.height-240, 150, 200);
        UIView* myView = [[UIView alloc] initWithFrame:rect];
        myView.backgroundColor = [UIColor whiteColor];
        UIView* myPreview = [[UIView alloc] initWithFrame:rectPreview];

        [self.webView.superview insertSubview:myView belowSubview:self.webView];
        [self.webView.superview insertSubview:myPreview aboveSubview:myView];
        [self.webView setOpaque:NO];
        self.webView.backgroundColor = [UIColor clearColor];
        linphone_core_set_native_video_window_id(lc, (unsigned long)myView);
        linphone_core_set_native_preview_window_id(lc, (unsigned long)myPreview);
        linphone_core_enable_video_preview(lc,1);   // this is necessary at present until we fix/set core config
    }

    [super pluginInitialize];
}

- (void)log:(CDVInvokedUrlCommand*)command
{
    id message = [command.arguments objectAtIndex:0];
    NSLog(@"%@",message);
}

- (void)call:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* sipaddr = [command.arguments objectAtIndex:0];
    if([LinphoneManager isLcReady]) {
        LinphoneCore* lc = [LinphoneManager getLc];
        if (!linphone_core_get_current_call(lc)) {  /* only 1 call at a time */
            [[LinphoneManager instance] call:sipaddr displayName:@"BabelRoom SIP" transfer:FALSE];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
    }
    if (pluginResult==nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)hangup:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    if([LinphoneManager isLcReady]) {
        LinphoneCore* lc = [LinphoneManager getLc];
        LinphoneCall* currentcall = linphone_core_get_current_call(lc);
        if(currentcall != NULL) { // In a call
            linphone_core_terminate_call(lc, currentcall);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }
    } else {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot trigger hangup button: Linphone core not ready"];
    }
    if (pluginResult==nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)callUpdateEvent: (NSNotification*) notif {
    LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    // Fake call update
    if(call == NULL) {
        return;
    }

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"hotdog"];
    NSMutableString *jsStatement = [NSMutableString stringWithString:@"window.plugins.LinPhoneGap._phoneEvent({_:0"];
    switch (state) {
        case LinphoneCallIdle:                  /**<Initial call state */
        case LinphoneCallIncomingReceived:      /**<This is a new incoming call */
            return;
        case LinphoneCallOutgoingInit:          /**<An outgoing call is started */
            [jsStatement appendString:@",canCall:false"];
            break;
        case LinphoneCallOutgoingProgress:      /**<An outgoing call is in progress */
        case LinphoneCallOutgoingRinging:       /**<An outgoing call is ringing at remote end */
        case LinphoneCallOutgoingEarlyMedia:    /**<An outgoing call is proposed early media */
        case LinphoneCallConnected:             /**<Connected, the call is answered */
            return;
        case LinphoneCallStreamsRunning:        /**<The media streams are established and running*/
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            [jsStatement appendString:@",canHangup:true"];
            if (linphone_call_params_video_enabled(linphone_call_get_current_params(call))) {
                [jsStatement appendString:@",canStopVideo:true"];
                [jsStatement appendString:@",canStartVideo:false"];
                }
            else {
                [jsStatement appendString:@",canStartVideo:true"];
                [jsStatement appendString:@",canStopVideo:false"];
                }
            break;
        case LinphoneCallPausing:               /**<The call is pausing at the initiative of local end */
        case LinphoneCallPaused:                /**< The call is paused, remote end has accepted the pause */
        case LinphoneCallResuming:              /**<The call is being resumed by local end*/
        case LinphoneCallRefered:               /**<The call is being transfered to another party, resulting in a new outgoing call to follow immediately*/
        case LinphoneCallError:                 /**<The call encountered an error*/
        case LinphoneCallEnd:                   /**<The call ended normally*/
        case LinphoneCallPausedByRemote:        /**<The call is paused by remote end*/
        case LinphoneCallUpdatedByRemote:       /**<The call's parameters change is requested by remote end, used for example when video is added by remote */
        case LinphoneCallIncomingEarlyMedia:    /**<We are proposing early media to an incoming call */
        case LinphoneCallUpdating:              /**<A call update has been initiated by us */
            return;
        case LinphoneCallReleased: ;              /**< The call object is no more retained by the core */
            [jsStatement appendString:@",canCall:true,canHangup:false,canStartVideo:false,canStopVideo:false"];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            break;
    }
/*    [jsStatement appendFormat:@",_state:'%s'", linphone_call_state_to_string(state)]; -- good for debugging, reference */
    [jsStatement appendString:@"})"];
    [super writeJavascript:jsStatement];
}

- (void)toggleVideo:(CDVInvokedUrlCommand*)command
{
    BOOL onOff = [[command.arguments objectAtIndex:0] boolValue];
    CDVPluginResult* pluginResult = nil;
    if([LinphoneManager isLcReady]) {
        LinphoneCore* lc = [LinphoneManager getLc];
        if (linphone_core_video_enabled(lc)) {
            LinphoneCall* call = linphone_core_get_current_call(lc);
            if (call) {
                LinphoneCallAppData* callAppData = (__bridge LinphoneCallAppData*)linphone_call_get_user_pointer(call);
                callAppData->videoRequested=onOff; /* will be used later to notify user if video was not activated because of the linphone core */
                LinphoneCallParams* call_params =  linphone_call_params_copy(linphone_call_get_current_params(call));
                linphone_call_params_enable_video(call_params, onOff);
                linphone_core_update_call(lc, call, call_params);
                linphone_call_params_destroy(call_params);
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot toggle video, because no current call"];
            }
        }
    }
    if (pluginResult==nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) checkOrientation
{
    UIInterfaceOrientation co = [[UIApplication sharedApplication] statusBarOrientation];
    NSLog(@"orientation change - %d %d", 0, co);
    int nr = -1;
    switch (co) {
        case UIInterfaceOrientationPortrait:
            nr = 0;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            nr = 180;
            break;
        case UIInterfaceOrientationLandscapeRight:
            nr = 270;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            nr = 90;
            break;
    }
    if (nr>=0 && [LinphoneManager isLcReady]) {
        int or = linphone_core_get_device_rotation([LinphoneManager getLc]);
        if (nr!=or) {
            LinphoneCore* lc = [LinphoneManager getLc];
            NSLog(@"rotation update - %d %d",nr,or);
            linphone_core_set_device_rotation(lc, nr);
            LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
            if (call && linphone_call_params_video_enabled(linphone_call_get_current_params(call))) {
                //Orientation has changed, must call update call
                linphone_core_update_call([LinphoneManager getLc], call, NULL);
            }
        }
    }
}

- (void) onOrientationDidChange: (NSNotification *) notif
{
    [self checkOrientation];
}

@end

#endif /* have included linphone libraries in project */