package labs.akhdani.linphone;

import android.net.Uri;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.linphone.*;
import org.linphone.core.LinphoneAddress;
import org.linphone.core.LinphoneCore;
import org.linphone.core.LinphoneCoreFactory;
import org.linphone.core.LinphoneProxyConfig;
import org.linphone.mediastream.Log;
import org.linphone.ui.AddressText;

public class Linphone extends CordovaPlugin {
    private static LinphoneManager instance;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        instance = LinphoneManager.createAndStart(cordova.getActivity().getApplicationContext());
    }

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext)
            throws JSONException {
        if (action.equals("login")) {
            login(args.getString(0), args.getString(1), args.getString(2), callbackContext);
            return true;
        }else if (action.equals("logout")) {
            logout(callbackContext);
            return true;
        }else if (action.equals("call")) {
            call(args.getString(0), args.getString(1), callbackContext);
            return true;
        }else if(action.equals("hangup")){
            hangup(callbackContext);
            return true;
        }else if(action.equals("toggleVideo")){
            toggleVideo(callbackContext);
            return true;
        }
        return false;
    }

    private synchronized void login(final String username, final String password, final String domain, final CallbackContext callbackContext) {
        try{
            LinphoneAddress address = LinphoneCoreFactory.instance().createLinphoneAddress("sip:" + username + "@" + domain);
            LinphonePreferences.AccountBuilder builder = new LinphonePreferences.AccountBuilder(LinphoneManager.getLc());
            builder.setUsername(username)
                    .setDomain(domain)
                    .setPassword(password);

            boolean isMainAccountLinphoneDotOrg = domain.equals("sip.linphone.org");

            if (isMainAccountLinphoneDotOrg) {
                builder.setProxy(domain + ":5228")
                        .setTransport(LinphoneAddress.TransportType.LinphoneTransportTcp)
                        .setExpires("604800")
                        .setOutboundProxyEnabled(true)
                        .setAvpfEnabled(true)
                        .setAvpfRRInterval(3)
                        .setQualityReportingCollector("sip:voip-metrics@sip.linphone.org")
                        .setQualityReportingEnabled(true)
                        .setQualityReportingInterval(180)
                        .setRealm(domain);
            }

            builder.saveNewAccount();
            callbackContext.success();
        }catch (Exception e){
            callbackContext.error(e.getMessage());
        }
    }

    private synchronized void logout(final CallbackContext callbackContext) {
        try{
            LinphoneProxyConfig[] prxCfgs = LinphoneManager.getLc().getProxyConfigList();
            final LinphoneProxyConfig proxyCfg = prxCfgs[0];
            LinphoneManager.getLc().removeProxyConfig(proxyCfg);
            callbackContext.success();
        }catch (Exception e){
            callbackContext.error(e.getMessage());
        }
    }

    private synchronized void call(final String address, final String displayName, final CallbackContext callbackContext) {
        try{
            LinphoneManager.getInstance().newOutgoingCall(address, displayName);
            callbackContext.success();
        }catch (Exception e){
            callbackContext.error(e.getMessage());
        }
    }

    private synchronized void hangup(final CallbackContext callbackContext) {
        try{
            LinphoneManager.getInstance().terminateCall();
            callbackContext.success();
        }catch (Exception e){
            callbackContext.error(e.getMessage());
        }
    }

    private synchronized void toggleVideo(final CallbackContext callbackContext) {
        try{
            boolean isenabled = LinphoneManager.getInstance().toggleEnableCamera();
            callbackContext.success(isenabled ? 1 : 0);
        }catch (Exception e){
            callbackContext.error(e.getMessage());
        }
    }
}
