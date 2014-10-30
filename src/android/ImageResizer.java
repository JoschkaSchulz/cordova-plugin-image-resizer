package info.protonet.imageresizer;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;

import android.util.Log;

public class ImageResizer extends CordovaPlugin {
  public CallbackContext callbackContext;

  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    this.callbackContext = callbackContext;

    Log.i("Protonet", "Dieses Plugin funktioniert :D");

    return true;
  }
}
