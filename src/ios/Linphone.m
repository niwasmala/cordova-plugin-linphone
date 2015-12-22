#import "Linphone.h"
#import "LinphoneManager.h"
#import <Cordova/CDV.h>

@implementation Linphone

@synthesize lm;
@synthesize lc;

- (void)login:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    NSString* username = [command.arguments objectAtIndex:0];
    NSString* password = [command.arguments objectAtIndex:1];
    NSString* domain = [command.arguments objectAtIndex:2];
    
    lc = [LinphoneManager getLc];
    LinphoneProxyConfig *proxyCfg = linphone_core_create_proxy_config(lc);
    NSString *server_address = domain;
    
    char normalizedUserName[256];
    linphone_proxy_config_normalize_number(proxyCfg, [username UTF8String], normalizedUserName,
                                           sizeof(normalizedUserName));
    
    const char *identity = linphone_proxy_config_get_identity(proxyCfg);
    if (!identity || !*identity)
        identity = "sip:user@example.com";
    
    LinphoneAddress *linphoneAddress = linphone_address_new(identity);
    linphone_address_set_username(linphoneAddress, normalizedUserName);
    
    if (domain && [domain length] != 0) {
        // when the domain is specified (for external login), take it as the server address
        linphone_proxy_config_set_server_addr(proxyCfg, [server_address UTF8String]);
        linphone_address_set_domain(linphoneAddress, [domain UTF8String]);
    }
    
    char *extractedAddres = linphone_address_as_string_uri_only(linphoneAddress);
    
    LinphoneAddress *parsedAddress = linphone_address_new(extractedAddres);
    ms_free(extractedAddres);
    
    char *c_parsedAddress = linphone_address_as_string_uri_only(parsedAddress);
    
    linphone_proxy_config_set_identity(proxyCfg, c_parsedAddress);
    
    linphone_address_destroy(parsedAddress);
    ms_free(c_parsedAddress);
    
    LinphoneAuthInfo *info = linphone_auth_info_new([username UTF8String], NULL, [password UTF8String], NULL, NULL,
                                                    linphone_proxy_config_get_domain(proxyCfg));
    lm = [LinphoneManager instance];
    [lm configurePushTokenForProxyConfig:proxyCfg];
    [lm removeAllAccounts];
    
    linphone_proxy_config_enable_register(proxyCfg, true);
    linphone_core_add_auth_info(lc, info);
    linphone_core_add_proxy_config(lc, proxyCfg);
    linphone_core_set_default_proxy_config(lc, proxyCfg);
    
    call = NULL;
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end

- (void)logout:(CDVInvokedUrlCommands*)command
{
    CDVPluginResult* pluginResult = nil;
    linphone_core_clear_all_auth_info([LinphoneManager getLc]);
    linphone_core_clear_proxy_config([LinphoneManager getLc]);
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end

- (void)call:(CDVInvokedUrlCommands*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* address = [command.arguments objectAtIndex:0];
    NSString* displayName = [command.arguments objectAtIndex:1];
    
    LinphoneAddress* addr = linphone_core_interpret_url(lc, address);
    call = linphone_core_invite_address(lc, addr);
    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end

- (void)videocall:(CDVInvokedUrlCommands*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* address = [command.arguments objectAtIndex:0];
    NSString* displayName = [command.arguments objectAtIndex:1];
    
    if(call == NULL){
        call = linphone_core_invite(lc, address);
        linphone_call_ref(call);
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end

- (void)hangup:(CDVInvokedUrlCommands*)command
{
    CDVPluginResult* pluginResult = nil;
    
    if(call && linphone_call_get_state(call) != LinphoneCallEnd){
        linphone_core_terminate_call(lc, call);
        linphone_call_unref(call);
        call = NULL;
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end

- (void)toggleVideo:(CDVInvokedUrlCommands*)command
{
    CDVPluginResult* pluginResult = nil;
    
    if (call != NULL && linphone_call_params_get_used_video_codec(linphone_call_get_current_params(call))) {
        if(isenabled){
            
        }else{
            linphone_call_set_next_video_frame_decoded_callback(call, hideSpinner, (__bridge void *)(self));
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end

- (void)toggleSpeaker:(CDVInvokedUrlCommands*)command
{
    CDVPluginResult* pluginResult = nil;
    
    if (call != NULL && linphone_call_get_state(call) != LinphoneCallEnd){
        if(enable) {
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute
                                     , sizeof (audioRouteOverride)
                                     , &audioRouteOverride);
            bluetoothEnabled = FALSE;
        } else {
            UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
            AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute
                                     , sizeof (audioRouteOverride)
                                     , &audioRouteOverride);
        }
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end

- (void)toggleMute:(CDVInvokedUrlCommands*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* isenabled = [command.arguments objectAtIndex:0]
    
    if(call && linphone_call_get_state(call) != LinphoneCallEnd){
        linphone_core_mic_enabled(lc, isenabled);
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end

- (void)sendDtmf:(CDVInvokedUrlCommands*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* dtmf = [command.arguments objectAtIndex:0];
    
    if(call && linphone_call_get_state(call) != LinphoneCallEnd){
        linphone_call_send_dtmf(lc, dtmf);
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}
@end
