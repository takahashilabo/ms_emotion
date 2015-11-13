// // This sample uses the Apache HTTP client from HTTP Components (http://hc.apache.org/httpcomponents-client-ga/)
import java.io.File;
import java.net.URI;
import org.apache.http.HttpEntity;
import org.apache.http.HttpHeaders;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.FileEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import processing.video.*;
Capture camera;

String result = "";

void setup() 
{
  size(400, 300);
  camera = new Capture(this, width, height);
  camera.start();
}

void draw() 
{
  image(camera, 0, 0);
  text(result, 0, 20);
}

void captureEvent(Capture camera) {
  camera.read();
}

void keyPressed()
{
  upload(camera);
}

void upload(PImage img)
{
  img.save("data/tmp.png");

  try
  {
    URIBuilder builder = new URIBuilder("https://api.projectoxford.ai/emotion/v1.0/recognize");
    URI uri = builder.build();
    HttpPost request = new HttpPost(uri);
    request.setHeader(HttpHeaders.CONTENT_TYPE, "application/octet-stream");
    request.setHeader("Ocp-Apim-Subscription-Key", "d5f08946745840649eba8cbffef2ef30");

    // Request body
    File upfile = new File(dataPath("tmp.png"));
    FileEntity fentity = new FileEntity(upfile, ContentType.create("application/octet-stream", "UTF-8"));
    request.setEntity(fentity);

    HttpClient httpclient = HttpClients.createDefault();
    HttpResponse response = httpclient.execute(request);
    HttpEntity entity = response.getEntity();

    if (entity != null) 
    {
      String ret = EntityUtils.toString(entity);
      println(ret);
      ret = ret.replace("[","").replace("]","");
      JSONObject json = parseJSONObject(ret);
      printResult(json);
    }
  }
  catch (Exception e)
  {
    System.out.println(e.getMessage());
  }
}

void printResult(JSONObject json) 
{
  json = json.getJSONObject("scores");
  result 
  = "anger: " + json.getFloat("anger")
  + "\ncontempt: " + json.getFloat("contempt")
  + "\ndisgust: " + json.getFloat("disgust")
  + "\nhappiness: " + json.getFloat("happiness")
  + "\nneutral: " + json.getFloat("neutral")
  + "\nsadness: " + json.getFloat("sadness")
  + "\nsurprise: " + json.getFloat("surprise");
}