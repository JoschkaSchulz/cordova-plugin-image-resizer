package info.protonet.imageresizer;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

public class ImageResizer extends CordovaPlugin {
  public CallbackContext callbackContext;

  private String uri;

  public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
    try {
      this.callbackContext = callbackContext;

      Log.i("Protonet", "Dieses Plugin funktioniert :D");
      Log.i("Protonet", "action: " + action);
      Log.i("Protonet", "args: " + args);
      Log.i("Protonet", "callbackContext: " + callbackContext);

      if (action.equals("resize")) {
        Log.i("Protonet","Resizing all the images.");
        checkParameters(args);
        JSONObject jsonObject = args.getJSONObject(0);
        Log.i("Protonet", "The json Object: " + jsonObject.toString());
        //Bitmap bitmap = loadBitmapFromUri("");
        return true;
      } else {
        Log.i("Protonet","that's not nice from you... :(");
        return false;
      }
    } catch(JSONException e) {
    	Log.e("Protonet", "JSON Exception during the Image Resizer Plugin... :(");
    }
    return false;
  }

  private Bitmap loadBitmapFromUri(String uri) {
    Bitmap resultBitmap = null;
    InputStream inputStream = null;
    BufferedInputStream bufferedInputStream = null;
    try {
      URLConnection connection = new URL(uri).openConnection();
      connection.connect();
      inputStream = connection.getInputStream();
      bufferedInputStream = new BufferedInputStream(inputStream, 8192);
      resultBitmap = BitmapFactory.decodeStream(bufferedInputStream);
    }catch(IOException e) {

    }

    return resultBitmap;
  }

  private boolean checkParameters(JSONArray args) {
    if (args.length() != 1) {
        Log.i("Protonet", "Invalid Number of Arguments");
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.INVALID_ACTION));
        return false;
    }
    return true;
  }
}
