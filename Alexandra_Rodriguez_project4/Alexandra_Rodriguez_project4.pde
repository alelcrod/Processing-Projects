import processing.sound.*;

AudioIn mic;
Amplitude analyzer;
float theta = 0;
boolean alive;
float lower_thres, upper_thres, line_length, flame_size;
ArrayList<Flame> fire;
int level;

class Flame {
  float x, y, vx, vy, d, delta, alpha;
  color c;
  
  Flame(float d, color c) {
    x = width/2;
    y = height/2;
    this.d = d;
    this.c =c;
    delta = this.d/40;
    
    vx = random(-1,1)*d;
    vy = random(-1, 1)*d;
    alpha = 255;

  }
  
  void update() {
    x += vx;
    y += vy;
    alpha -= 7;
    d -= delta;
  }
  
  void display() {
    fill(c, alpha);
    noStroke();
    
    // create heart shape flame
    beginShape();
    vertex(x, y - 10*d);
    bezierVertex(x, y - 30*d, x + 40*d, y - 15*d, x, y + 15*d);
    vertex(x, y - 10*d);
    bezierVertex(x, y - 30*d, x - 40*d, y - 15*d, x, y + 15*d);
    endShape();
  }
  
  boolean isDead() {
    return alpha <= 0 || d <= delta;
  }
}




void setup() {
  size(600, 600);
  frameRate(40);
  // setup the microphone and start listening
  mic = new AudioIn(this, 0);
  mic.start();
  
  // setup amplitude analyzer
  analyzer = new Amplitude(this);
  analyzer.input(mic);
  level = 0;
  
  alive = true;
  line_length = 25;
  flame_size = 0;
  fire = new ArrayList<Flame>();
}

void draw() {  
  background(255);
  stroke(0);
  float volume = analyzer.analyze();
  lower_thres = 0.001;
  upper_thres = 0.45;
  
  // draw objects if still alive
  if (alive) {
    if (volume < lower_thres) {
      if (flame_size > 0) {
        flame_size -= .1;
      }
      if (line_length > 0) {
        line_length -= 1;
      }
    } else if (volume > upper_thres) {
      alive = false;
    } else {
      
      if (line_length < 150) {
        line_length += 1;
      } else if (flame_size < 50) {
        flame_size += .1;
      }
    }
    
    // change level
    if (flame_size <= 0 && level > 0) {
      level--;
      flame_size = 0;
    }
    if (flame_size > 10 && level < 5) {
      level++;
      flame_size = 0;
    }
    
    // based on level, pick color of heart flame
    if (level == 0 && flame_size > 0) {
      fire.add(new Flame(flame_size, color(255, 255, random(0, 255)))); // yellow
      //fire.add(new Flame(flame_size, color(255, 153, random(50, 150)))); // orange
    } else if (level == 1 && flame_size > 0) {
      fire.add(new Flame(10, color(255, 255, random(0, 255)))); // yellow
      fire.add(new Flame(flame_size, color(255, 153, random(50, 150)))); // orange
      //fire.add(new Flame(flame_size, color(0, 0, random(100, 255)))); // blue
      //fire.add(new Flame(10, color(255, 153, random(50, 150)))); // orange
    } else if (level == 2 && flame_size > 0) {
      fire.add(new Flame(10, color(255, 255, random(0, 255)))); // yellow
      fire.add(new Flame(10, color(255, 153, random(50, 150)))); // orange
      fire.add(new Flame(flame_size, color(255, random(0, 100), random(0, 20)))); // red
      //fire.add(new Flame(flame_size, color(0, 0, random(100, 255)))); // blue
    } else if (level == 3 && flame_size > 0) {
      fire.add(new Flame(10, color(255, 255, random(0, 255)))); // yellow
      fire.add(new Flame(10, color(255, 153, random(50, 150)))); // orange
      fire.add(new Flame(10, color(255, random(0, 100), random(0, 20)))); // red
      fire.add(new Flame(flame_size, color(random(0, 255), 204, 255))); // blue
    } else if (level == 4 && flame_size > 0) {
      fire.add(new Flame(10, color(255, 255, random(0, 255)))); // yellow
      fire.add(new Flame(10, color(255, 153, random(50, 150)))); // orange
      fire.add(new Flame(10, color(255, random(0, 100), random(0, 20)))); // red
      fire.add(new Flame(10, color(random(0, 255), 204, 255))); // blue
      fire.add(new Flame(flame_size, color(0, 0, random(100, 255)))); // blue
    } else if (level == 5 && flame_size > 0) {
      fire.add(new Flame(10, color(255, 255, random(0, 255)))); // yellow
      fire.add(new Flame(10, color(255, 153, random(50, 150)))); // orange
      fire.add(new Flame(10, color(255, random(0, 100), random(0, 20)))); // red
      fire.add(new Flame(10, color(random(0, 255), 204, 255))); // blue
      fire.add(new Flame(10, color(0, 0, random(100, 255)))); // blue
      fire.add(new Flame(flame_size, color(random(0, 255), random(0, 255), random(0, 255))));
    }
    
    // draw outer lines
    pushMatrix();
    translate(width/2, height/2);
    for (float i = 0; i < TWO_PI; i+= 0.2) {
      stroke(237, 217, 196);
      pushMatrix();
      rotate(theta + i);
      for (float j = 0; j < TWO_PI; j += 0.5) {
        pushMatrix();
        translate(line_length, 0);
        rotate(-theta-j);
        line(0,0,line_length,0);
        popMatrix();
      }
      popMatrix();
    }
    popMatrix();
  } else {
    // this is when the relationship is dead
    background(200,200,200);
    // draw outer lines
    pushMatrix();
    translate(width/2, height/2);
    for (float i = 0; i < TWO_PI; i+= 0.2) {
      stroke(0);
      pushMatrix();
      rotate(theta + i);
      for (float j = 0; j < TWO_PI; j += 0.5) {
        pushMatrix();
        translate(100, 0);
        rotate(-theta-j);
        line(0,0,100,0);
        popMatrix();
      }
      popMatrix();
    }
    popMatrix();
  }
  
  // update & display fire
    for (int i = fire.size() - 1; i >= 0; i--) {
      fire.get(i).update();
      fire.get(i).display();
      
      if (fire.get(i).isDead()) {
        fire.remove(i);
      }
    }
  theta += 0.01;
}

// restarts
void keyPressed() {
  alive = true;
  flame_size = 0;
  line_length = 75;
  fire = new ArrayList<Flame>();
}



  
