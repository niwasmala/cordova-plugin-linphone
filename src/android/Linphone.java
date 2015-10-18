package labs.akhdani.linphone;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class Linphone extends CordovaPlugin {
  @Override
  public void initialize(CordovaInterface cordova, CordovaWebView webView) {
      super.initialize(cordova, webView);
  }

  public boolean execute(String action, JSONArray args, CallbackContext callbackContext)
      throws JSONException {
    if (action.equals("call")) {
      call(args.getString(0), callbackContext);
      return true;
    }else if(action.equals("hangup"){
      hangup(callbackContext);
      return true;
    }else if(action.equals("toggleVideo"){
      toggleVideo(args.getBoolean(), callbackContext);
      return true;
    }
    return false;
  }

  private synchronized void call(final String num, final CallbackContext callbackContext) {

  }

  private synchronized void hangup(final CallbackContext callbackContext) {

  }

  private synchronized void toggleVideo(final Boolean isOn, final CallbackContext callbackContext) {

  }
}