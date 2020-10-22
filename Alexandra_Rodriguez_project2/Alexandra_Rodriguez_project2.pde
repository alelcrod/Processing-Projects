import http.requests.*;

String url = "https://www.metaweather.com/api/location/44418/"; // london weather
//String url = "https://www.metaweather.com/api/location/2487956/"; // san fransicso weather
int t;
float x;
float y;
float r;
float xd;
float yd;
ArrayList<Float> speed = new ArrayList<Float>();
ArrayList<Float> temp = new ArrayList<Float>();
ArrayList<Float> direction = new ArrayList<Float>();
ArrayList<String> state = new ArrayList<String>();
PImage imgCloud;
PImage imgCloud2;
PImage imgCloud3;
PImage imgCloud4;
PImage imgCloud5;
PImage imgKite;

/* retreives appropriate information for current weather site into a JSONObject, which is then taken into a JSONArray. Proper information is then stored in ArrayLists */
void getInfo(String query) {
  GetRequest get = new GetRequest(query); //Creating the GET Request based of the parameter query
  System.out.println(query); // printing it out to the console as a sanity check
  get.send();  // issuing the request
  println(get.getContent());
  JSONObject obj = parseJSONObject(get.getContent()); // parsing the response into a JSON Object
  JSONArray weather = obj.getJSONArray("consolidated_weather");
  JSONObject current;
  println(weather);
  int i = 0;
  while (weather.size() > i) {
    current = weather.getJSONObject(i);
    temp.add(current.getFloat("the_temp"));
    speed.add(current.getFloat("wind_speed"));
    direction.add(current.getFloat("wind_direction"));
    state.add(current.getString("weather_state_name"));
    i++;
  }
}

void setup() {
  size(displayWidth, displayHeight);
  colorMode(HSB, 360, 100, 100);
  background(255);
  imageMode(CENTER);
  frameRate(100);
  
  t = 0;
  imgCloud = loadImage("cloud3.png");
  imgCloud.resize(200, 200);
  imgCloud2 = imgCloud.copy();
  imgCloud3 = imgCloud.copy();
  imgCloud4 = imgCloud.copy();
  imgCloud5 = imgCloud.copy();
  imgKite = loadImage("kite.png");
  imgKite.resize(300, 600);
  
  getInfo(url);
  setupKite();
}

/* sets up the direction and position of the kite */
void setupKite() {
  r = direction.get(t);
  if (r <= 90) { // going to q1 (start in bottom left)
    x = 0;
    y = height;
    xd = 1;
    yd = -1;
  } else if (r > 90 && r <= 180) { // going to q2 (start in top left)
    x = 0;
    y = 0;
    xd = 1;
    yd = 1;
  } else if (r > 180 && r <= 270) { // going to q3 (start in top right)
    x = width; 
    y = 0;
    xd = -1;
    yd = 1;
  } else if (r > 270 && r <= 360) { // going to q4 (start in bottom right)
    x = width;
    y = height;
    xd = -1;
    yd = -1;
  }
}

void draw() {
  if (outOfBounds() > 0) {
    t = (t + 1) % temp.size();
    setupKite();
  }
  background(200, 100 - temp.get(t)*5, 100);
  textSize(50);
  fill(240, 100, temp.get(t)*10);
  text(temp.get(t)+"\u00b0"+"C", width/10, 6*height/7);
  
  if (state.get(t).equals("Light Cloud")) {
    text("We Got Some Clouds" , width/10, height/7);
    pcloudy();
  } else if (state.get(t).equals("Heavy Cloud")) {
    text("Getting Kinda Cloudy" , width/10, height/7);
    hcloudy();
  } else if (state.get(t).equals("Showers")) {
    text("Nothing Can Rain On My Parade!" , width/10, height/7);
    showers();
  } else if (state.get(t).equals("Light Rain")) {
    text("It's a Little Rainy" , width/10, height/7);
    lightrain();
  } else if (state.get(t).equals("Clear")) {
    text("Clear Skies" , width/10, height/7);
    clearsky();
    println("clear skies");
  }
  /* translates kite to the correct position */
  x = (x + xd*speed.get(t));
  y = (y + yd*speed.get(t));
  translate(x, y);
  rotate(radians(r));
  image(imgKite, 0, 0);
}


float cx = 0;
float cy = 0;
float cx2 = 2*width/3 + 100;
float cy2 = 2*height/3 + 100;

/* clear skies */
void clearsky() {
  fill(55, 100, 100);
  stroke(55, 100, 100);
  circle(2*width/3, 2*height/3, 300);
}

/* partially cloudy background */
void pcloudy() {
  cx = (cx + speed.get(t)) % width;
  cy = (cy + speed.get(t)/5) % height;
  cx2 = (cx2 + speed.get(t)) % width;
  cy2 = (cy2 + speed.get(t)/5) % height;
  image(imgCloud, cx, cy);
  image(imgCloud2, cx2, cy2);
}

/* heavy clouds background */
void hcloudy() {
  cx = (cx + speed.get(t)) % width;
  cy = (cy + speed.get(t)/5) % height;
  cx2 = (cx2 + speed.get(t)) % width;
  cy2 = (cy2 + speed.get(t)/5) % height;
  image(imgCloud, cx, cy);
  image(imgCloud2, cx2, cy2);
  image(imgCloud3, cx2, (2*cy2 % height));
  image(imgCloud4, cx, (2*cy % height));
}

int rainCount = 0;
void snow() {
  rainCount = (rainCount + 1) % 10;
  for (int rx = 0; rx < 50; rx++) {
    stroke(200, 10, 100);
    fill(200, 10, 100);
    circle(random(rx, width), random(rx, height), random(1, 10));
  }
}

/* rainy background */
void showers() {
  for (int j = 0; j < 300; j++) {
    stroke(233, 100, 60);
    float rx = random(0, width);
    float ry = random(0, height);
    line(rx, ry, rx + 5*xd, ry + 5*yd);
  }
}

/* light rain background */
void lightrain() {
  for (int j = 0; j < 100; j++) {
    //stroke(200, 10, 100);
    stroke(233, 100, 58);
    float rx = random(0, width);
    float ry = random(0, height);
    line(rx, ry, rx + 3*xd, ry + 3*yd);
  }
}

/* returns -1 if x position for kite is too far left,
   returns 1 if x position for kite is too far right,
   returns 0 if x position for kite is within display width bounds
*/
int xBounds() {
  if (x < -150) {
    return -1;
  } else if (x > (width + 150)) {
    return 1;
  }
  return 0;
}

/* returns -1 if y position for kite is too high,
   returns 1 if y position for kite is too low,
   returns 0 if y position for kite is within display height bounds
*/
int yBounds() {
  if (y < -300) {
    return -1;
  } else if (y > (height + 300)) {
    return 1;
  }
  return 0;
}

/* determines if the kite is out of bounds,
   if so it returns that quadrant # the kite is in 
   - q1: top right
   - q2: bottom right
   - q3: bottom left
   - q4: top left
*/
int outOfBounds() {
  if ((xBounds() == 1 && yBounds() < (displayHeight/2)) || (yBounds() == -1 && x > (displayWidth/2))) { // kite in q1
    return 1;
  } else if ((xBounds() == 1 && yBounds() > (displayHeight/2)) || (yBounds() == 1 && x > (displayWidth/2))) { // kite in q2
    return 2;
  } else if ((xBounds() == -1 && yBounds() > (displayHeight/2)) || (yBounds() == 1 && x < (displayWidth/2))) { // kite in q3
    println("mitchell was here");
    return 3;
  } else if ((xBounds() == -1 && yBounds() < (displayHeight/2)) || (yBounds() == -1 && x < (displayWidth/2))) { // kite in q4
    return 4;
  }
  return 0;
}
