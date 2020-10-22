int x, cloud_x, y, MAX;

void setup() {
  size(800,800);
  frameRate(20);
  x = 0;
  y = 0;
  MAX = height/2 - 110;
}

void draw() {
  /* translation for fish, speeds up after getting near fishing pole */
  if (y == MAX) {
    x = (x + 5) % width;
  } else {
    x = (x + 1) % width;
  }
  if (x == 0) {
    y = 0;
  } else if (y < MAX) {
    y = y + 1;
  }

  background(255);
  
  /* draws the five nested sunset circles, with each iteration, draws a smaller,
     less opague, circle with a color that has higher B & G values (which makes
     it go from more red, to yellow) */
  for (int i = 0; i < 5; i++) {
    stroke(300, 100 + i*40, 100, i*50 + 10);
    fill(300, 100 + i*40, 100, i*50 + 10);
    circle (400,400, 800 - (i*100));
  }
  
  /* draws the fish, which moves each time 
     fish rotated to appear swimming upward until a certain height is reached
     once height reached, fish straightens out */
  pushMatrix();
  fill(136,119,206);
  stroke(136,119,206);
  translate(x, height - y);
  if (y == MAX) {
    rotate(PI);
  } else {
    rotate(3*PI/4);
  }
  ellipse(10,10,30,20); // body of fish
  triangle(25,10,35,0,35,20); // tail of fish
  popMatrix();
  
  /* water: slightly translucent */
  stroke(20,197,252, 50);
  fill(20,197,252, 50);
  rect(0,450, 800, 800);
    
  /* fishing pole/line: moves when fish comes near */
  pushMatrix();
  if (y == MAX - 1) {
    translate(-5, -35);
  }
  stroke(124,124,129);
  line(430, 415, 400, 380); // pole
  noFill();
  bezier(400, 380, 350, 340, 320, 470, 310, 480); // line
  popMatrix();
  
  /* boat */
  fill(167,136,96);
  arc(460, 410, 100, 100, 0, PI, OPEN);
  
  /* person: head drops slightly after he fails to catch fish */
  fill(178,175,172);
  stroke(178,175,172);
  triangle(435, 410, 450, 380, 460, 410); // body
  pushMatrix();
  if (y == MAX) {
    translate(-5, 5);
  }
  circle(450,370, 20); // head
  popMatrix();

  // clouds
  fill(255, 500);
  stroke(255);
  for(int i = 0; i < 6; i++) {
    circle(600 + i*20, 200, 20 + i*5);
    circle(550 + i*20, 225, 20 + i*2);
  }
}
