package info.protonet.imageresizer;

import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Environment;
import android.util.Base64;
import android.util.Log;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.camera.FileHelper;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class ImageResizer extends CordovaPlugin {
    private static final int ARGUMENT_NUMBER = 1;
    public CallbackContext callbackContext;

    private String uri;
    private String folderName;
    private String fileName;
    private int quality;
    private int width;
    private int height;
    private boolean fixRotation = false;
    private boolean base64 = false;

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        try {
            this.callbackContext = callbackContext;

            if (action.equals("resize")) {
                checkParameters(args);

                // get the arguments
                JSONObject jsonObject = args.getJSONObject(0);
                uri = jsonObject.getString("uri");
                folderName = null;
                if (jsonObject.has("folderName")) {
                    folderName = jsonObject.getString("folderName");
                }
                fileName = null;
                if (jsonObject.has("fileName")) {
                    fileName = jsonObject.getString("fileName");
                }
                quality = jsonObject.getInt("quality");
                width = jsonObject.getInt("width");
                height = jsonObject.getInt("height");
                if(jsonObject.has("fixRotation")){
                  fixRotation = jsonObject.getBoolean("fixRotation");
                }
                if(jsonObject.has("base64")){
                  base64 = jsonObject.getBoolean("base64");
                }

                // load the image from uri
                Bitmap bitmap = loadScaledBitmapFromUri(uri, width, height);

                if(bitmap == null){
                  Log.e("Protonet", "There was an error reading the image");
                  callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR));
                  return false;
                }

                if(fixRotation){
                  // Get the exif rotation in degrees, create a transformation matrix, and rotate
                  // the bitmap
                  int rotation = getRoationDegrees(getRotation(uri));
                  Matrix matrix = new Matrix();
                  if (rotation != 0f) {matrix.preRotate(rotation);}
                  bitmap = Bitmap.createBitmap(
                    bitmap,
                    0,
                    0,
                    bitmap.getWidth(),
                    bitmap.getHeight(),
                    matrix,
                    true);
                }

                if(base64){
                  // convert the bitmap to a b64 string and return
                  ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
                  bitmap.compress(CompressFormat.JPEG, 100, byteArrayOutputStream);
                  byte[] byteArray = byteArrayOutputStream .toByteArray();
                  String encoded = Base64.encodeToString(byteArray, Base64.DEFAULT);
                  callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK,
                    "data:image/jpeg;base64,"+encoded));
                }else {
                  // save the image as jpeg on the device
                  Uri scaledFile = saveFile(bitmap);

                  if(scaledFile == null){
                    Log.e("Protonet", "There was an error saving the thumbnail");
                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR));
                    return false;
                  }
                  callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK,
                    scaledFile.toString()));
                }
                return true;
            } else {
                callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR));
                return false;
            }
        } catch (JSONException e) {
            Log.e("Protonet", "JSON Exception during the Image Resizer Plugin... :(");
        }
        callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR));
        return false;
    }

    /**
    * Gets the image rotation from the image EXIF Data
    *
    * @param exifOrientation ExifInterface.ORIENTATION_* representation of the rotation
    * @return the rotation in degrees
    */
    private int getRoationDegrees(int exifOrientation){
      if (exifOrientation == ExifInterface.ORIENTATION_ROTATE_90) { return 90; }
      else if (exifOrientation == ExifInterface.ORIENTATION_ROTATE_180) {  return 180; }
      else if (exifOrientation == ExifInterface.ORIENTATION_ROTATE_270) {  return 270; }
      return 0;
    }

    /**
    * Gets the image rotation from the image EXIF Data
    *
    * @param uriString the URI of the image to get the rotation for
    * @return ExifInterface.ORIENTATION_* representation of the rotation
    */
    private int getRotation(String uriString){
      try {
        ExifInterface exif = new ExifInterface(uriString);
        return exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
      } catch (IOException e) {
        return ExifInterface.ORIENTATION_NORMAL;
      }
    }

    /**
     * Loads a Bitmap of the given android uri path
     *
     * @params uri the URI who points to the image
     **/
    private Bitmap loadScaledBitmapFromUri(String uriString, int width, int height) {
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeStream(FileHelper.getInputStreamFromUriString(uriString, cordova), null, options);

            //calc aspect ratio
            int[] retval = calculateAspectRatio(options.outWidth, options.outHeight);

            options.inJustDecodeBounds = false;
            options.inSampleSize = calculateSampleSize(options.outWidth, options.outHeight, width, height);
            Bitmap unscaledBitmap = BitmapFactory.decodeStream(FileHelper.getInputStreamFromUriString(uriString, cordova), null, options);
            return Bitmap.createScaledBitmap(unscaledBitmap, retval[0], retval[1], true);
        } catch (FileNotFoundException e) {
            Log.e("Protonet", "File not found. :(");
        } catch (IOException e) {
            Log.e("Protonet", "IO Exception :(");
        } catch (Exception e) {
            Log.e("Protonet", e.toString());
        }
        return null;
    }

    private Uri saveFile(Bitmap bitmap) {
        File folder = null;
        if (folderName == null) {
            folder = new File(this.getTempDirectoryPath());
        } else {
            if (folderName.contains("/")) {
                folder = new File(folderName.replace("file://", ""));
            } else {
                Context context = this.cordova.getActivity().getApplicationContext();
                folder          = context.getDir(folderName, context.MODE_PRIVATE);
            }
        }
        boolean success = true;
        if (!folder.exists()) {
            success = folder.mkdir();
        }

        if (success) {
            if (fileName == null) {
                fileName = System.currentTimeMillis() + ".jpg";
            }
            File file = new File(folder, fileName);
            if (file.exists()) file.delete();
            try {
                FileOutputStream out = new FileOutputStream(file);
                bitmap.compress(Bitmap.CompressFormat.JPEG, quality, out);
                out.flush();
                out.close();
            } catch (Exception e) {
                Log.e("Protonet", e.toString());
            }
            return Uri.fromFile(file);
        }
        return null;
    }

    /**
     * Figure out what ratio we can load our image into memory at while still being bigger than
     * our desired width and height
     *
     * @param srcWidth
     * @param srcHeight
     * @param dstWidth
     * @param dstHeight
     * @return
     */
    private int calculateSampleSize(int srcWidth, int srcHeight, int dstWidth, int dstHeight) {
        final float srcAspect = (float) srcWidth / (float) srcHeight;
        final float dstAspect = (float) dstWidth / (float) dstHeight;

        if (srcAspect > dstAspect) {
            return srcWidth / dstWidth;
        } else {
            return srcHeight / dstHeight;
        }
    }

    /**
     * Maintain the aspect ratio so the resulting image does not look smooshed
     *
     * @param origWidth
     * @param origHeight
     * @return
     */
    private int[] calculateAspectRatio(int origWidth, int origHeight) {
        int newWidth = width;
        int newHeight = height;

        // If no new width or height were specified return the original bitmap
        if (newWidth <= 0 && newHeight <= 0) {
            newWidth = origWidth;
            newHeight = origHeight;
        }
        // Only the width was specified
        else if (newWidth > 0 && newHeight <= 0) {
            newHeight = (newWidth * origHeight) / origWidth;
        }
        // only the height was specified
        else if (newWidth <= 0 && newHeight > 0) {
            newWidth = (newHeight * origWidth) / origHeight;
        }
        // If the user specified both a positive width and height
        // (potentially different aspect ratio) then the width or height is
        // scaled so that the image fits while maintaining aspect ratio.
        // Alternatively, the specified width and height could have been
        // kept and Bitmap.SCALE_TO_FIT specified when scaling, but this
        // would result in whitespace in the new image.
        else {
            double newRatio = newWidth / (double) newHeight;
            double origRatio = origWidth / (double) origHeight;

            if (origRatio > newRatio) {
                newHeight = (newWidth * origHeight) / origWidth;
            } else if (origRatio < newRatio) {
                newWidth = (newHeight * origWidth) / origHeight;
            }
        }

        int[] retval = new int[2];
        retval[0] = newWidth;
        retval[1] = newHeight;
        return retval;
    }

    private boolean checkParameters(JSONArray args) {
        if (args.length() != ARGUMENT_NUMBER) {
            callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.INVALID_ACTION));
            return false;
        }
        return true;
    }

    private String getTempDirectoryPath() {
        File cache = null;

        // SD Card Mounted
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            cache = new File(Environment.getExternalStorageDirectory().getAbsolutePath() +
                    "/Android/data/" + cordova.getActivity().getPackageName() + "/cache/");
        } else {
            // Use internal storage
            cache = cordova.getActivity().getCacheDir();
        }

        // Create the cache directory if it doesn't exist
        cache.mkdirs();
        return cache.getAbsolutePath();
    }
}
