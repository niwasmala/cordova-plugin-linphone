package labs.akhdani.linphone;

import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.linphone.LinphoneManager;
import org.linphone.LinphonePreferences;
import org.linphone.core.LinphoneAddress;
import org.linphone.core.LinphoneCall;
import org.linphone.core.LinphoneCallStats;
import org.linphone.core.LinphoneChatMessage;
import org.linphone.core.LinphoneChatRoom;
import org.linphone.core.LinphoneContent;
import org.linphone.core.LinphoneCore;
import org.linphone.core.LinphoneCoreFactory;
import org.linphone.core.LinphoneCoreListener;
import org.linphone.core.LinphoneEvent;
import org.linphone.core.LinphoneFriend;
import org.linphone.core.LinphoneInfoMessage;
import org.linphone.core.LinphoneProxyConfig;
import org.linphone.core.PublishState;
import org.linphone.core.SubscriptionState;
import org.linphone.mediastream.Log;
import org.linphone.mediastream.video.capture.hwconf.AndroidCameraConfiguration;
import org.linphone.ui.AddressText;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteBuffer;
import java.util.Timer;
import java.util.TimerTask;

public class Linphone extends CordovaPlugin {
    public static Linphone mInstance;
    public static LinphoneMiniManager mLinphoneManager;
    public static LinphoneCore mLinphoneCore;
    public static Context mContext;
    public static Timer mTimer;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        mContext = cordova.getActivity().getApplicationContext();
        mLinphoneManager = new LinphoneMiniManager(mContext);
        mLinphoneCore = mLinphoneManager.getLc();
        mInstance = this;
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
        }else if (action.equals("videocall")) {
            videocall(args.getString(0), args.getString(1), callbackContext);
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

    public static synchronized void login(final String username, final String password, final String domain, final CallbackContext callbackContext) {
        try{
            Log.d("login", username, password, domain);
            LinphoneAddress address = LinphoneCoreFactory.instance().createLinphoneAddress("sip:" + username + "@" + domain);
            LinphonePreferences.AccountBuilder builder = new LinphonePreferences.AccountBuilder(mLinphoneManager.getLc())
                    .setUsername(username)
                    .setDomain(domain)
                    .setPassword(password);

            boolean isMainAccountLinphoneDotOrg = domain.equals("sip.linphone.org");

            Log.d("Login", isMainAccountLinphoneDotOrg);
            if (isMainAccountLinphoneDotOrg) {
                builder.setProxy(domain + ":5223")
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

            Log.d("login", "saving");
            builder.saveNewAccount();
            Log.d("login sukses");
            callbackContext.success();
        }catch (Exception e){
            Log.d("login error", e.getMessage());
            callbackContext.error(e.getMessage());
        }
    }

    public static synchronized void logout(final CallbackContext callbackContext) {
        try{
            Log.d("logout");
            LinphoneProxyConfig[] prxCfgs = mLinphoneManager.getLc().getProxyConfigList();
            final LinphoneProxyConfig proxyCfg = prxCfgs[0];
            mLinphoneManager.getLc().removeProxyConfig(proxyCfg);
            Log.d("logout sukses");
            callbackContext.success();
        }catch (Exception e){
            Log.d("Logout error", e.getMessage());
            callbackContext.error(e.getMessage());
        }
    }

    public static synchronized void call(final String address, final String displayName, final CallbackContext callbackContext) {
        try {
            Log.d("call", address, displayName);
            mLinphoneManager.newOutgoingCall(address, displayName);
            Log.d("call sukses");
            callbackContext.success();
        }catch (Exception e){
            Log.d("call error", e.getMessage());
            callbackContext.error(e.getMessage());
        }
    }

    public static synchronized void videocall(final String address, final String displayName, final CallbackContext callbackContext) {
        try{
            Log.d("incall", address, displayName);
            Intent intent = new Intent(mContext, LinphoneMiniActivity.class);
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            intent.putExtra("address", address);
            intent.putExtra("displayName", displayName);
            mContext.startActivity(intent);
            Log.d("incall sukses");
            callbackContext.success();
        }catch (Exception e){
            Log.d("incall error", e.getMessage());
            callbackContext.error(e.getMessage());
        }
    }

    public static synchronized void hangup(final CallbackContext callbackContext) {
        try{
            Log.d("hangup");
            mLinphoneManager.terminateCall();
            Log.d("hangup sukses");
            callbackContext.success();
        }catch (Exception e){
            Log.d("hangup error", e.getMessage());
            callbackContext.error(e.getMessage());
        }
    }

    public static synchronized void toggleVideo(final CallbackContext callbackContext) {
        try{
            Log.d("toggleVideo");
            boolean isenabled = mLinphoneManager.toggleEnableCamera();
            Log.d("toggleVideo sukses",isenabled);
            callbackContext.success(isenabled ? 1 : 0);
        }catch (Exception e){
            Log.d("toggleVideo error", e.getMessage());
            callbackContext.error(e.getMessage());
        }
    }
}
