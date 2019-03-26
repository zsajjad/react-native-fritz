package com.rnfritz;

import org.apache.commons.io.IOUtils;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;

public class Utils {
    private static final int IMAGE_MEAN = 128;
    private static final float IMAGE_STD = 128.0f;

    public static Bitmap getBitmapFromURL(String src) {
        try {
            URL url = new URL(src);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setDoInput(true);
            connection.connect();
            InputStream input = connection.getInputStream();
            Bitmap myBitmap = BitmapFactory.decodeStream(input);
            return myBitmap;
        } catch (IOException e) {
            return null;
        }
    }

    private static InputStream getStream(String src) throws IOException {
        URL url = new URL(src);
        URLConnection conn = url.openConnection();
        conn.setConnectTimeout(5000);
        conn.setReadTimeout(5000);
        conn.connect();

        return conn.getInputStream();
    }

    public static ByteBuffer getByteBufferFromURL(String src){
        try {
            InputStream initialStream = getStream(src);

            ByteBuffer byteBuffer = ByteBuffer.allocate(initialStream.available());
            ReadableByteChannel channel = Channels.newChannel(initialStream);
            IOUtils.readFully(channel, byteBuffer);
            return byteBuffer;

        }catch(IOException e){
            e.printStackTrace();
            return null;
        }
    }

    public static byte[] getByteArrayFromURL(String src) throws IOException {
        InputStream initialStream = getStream(src);
        return IOUtils.toByteArray(initialStream);
    }

    public static ByteBuffer convertBitmapToByteBuffer(Bitmap bitmap, ByteBuffer imgData, int imgSizeX, int imgSizeY, int pixelSize) {
        if (imgData == null || imgSizeX == 0 || imgSizeY == 0 || pixelSize == 0) {
            return null;
        }
        imgData.rewind();
        int[] intValues = new int[imgSizeX * imgSizeY];
        bitmap.getPixels(intValues, 0, bitmap.getWidth(), 0, 0, bitmap.getWidth(), bitmap.getHeight());
        // Convert the image to floating point.
        int pixel = 0;
        for (int i = 0; i < imgSizeX; ++i) {
            for (int j = 0; j < imgSizeY; ++j) {
                final int val = intValues[pixel++];
                addPixelValue(val, imgData, pixelSize);
            }
        }
        return imgData;
    }

    private static void addPixelValue(int pixelValue, ByteBuffer imgData, int pixelSize) {
        if(pixelSize > 1){
            imgData.putFloat((((pixelValue >> 16) & 0xFF) - IMAGE_MEAN) / IMAGE_STD);
            imgData.putFloat((((pixelValue >> 8) & 0xFF) - IMAGE_MEAN) / IMAGE_STD);
        }
        imgData.putFloat(((pixelValue & 0xFF) - IMAGE_MEAN) / IMAGE_STD);
    }
}
