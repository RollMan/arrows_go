import java.util.LinkedList;
import java.util.Iterator;

import java.io.File;
import java.io.FileReader;
import java.io.BufferedReader;

import java.lang.Exception;

Arrows arrows;
LinkedList<Food> foodList;
final int FOOD_SIZE = 10;
boolean KEY_UP = false;
boolean KEY_RIGHT = false;
boolean KEY_LEFT = false;
int st;

File finishMessageFile;
void setup() {
  st=millis();
  size(500, 500);
  Point c = new Point(width/2, height/2);

  foodList = new LinkedList<Food>();
  for (int i = 0; i < FOOD_SIZE; i++) {
    println(random(0, width));
    Food foodPoint = new Food( new Point(random(0, width), random(0, height)) );
    foodList.add(foodPoint);
  }
  arrows = new Arrows(c, width/10);
  frameRate(60);
}

void draw() {

  background(255);


  int m = millis();
  fill(0);
  stroke(0);
  text("TIME: "+(m-st)/100, 20, 20);
  //println(""+(m-st)/100);
  fill(255);

  arrows.draw();
  for (Iterator<Food> it = foodList.iterator(); it.hasNext(); ) {
    Food f = it.next();
    f.draw(arrows);
    if (f.crushed) {
      it.remove();
    }
  }

  if (foodList.isEmpty()) {
    try {
      background(0);
      finishMessageFile = new File("finishMessage.txt");
      BufferedReader finishMessageBufferedReader = new BufferedReader(new FileReader(finishMessageFile));
      String str = new String();
      String line;
      while ((line = finishMessageBufferedReader.readLine()) != null) {
        str += line;
      }
      finishMessageBufferedReader.close();

      while (true) {
        double x = 0, y = 0;
        text(str, (int)x, (int)y);
        x += 0.1; 
        y += 0.1;
      }
    }    
    catch(Exception e) {
      print(e.getMessage());
      exit();
    }
  }
}

class Point {
  float x, y;
  Point(float x, float y) {
    this.x=x;
    this.y=y;
  }
  float dist(Point a) {
    return sqrt((x-a.x)*(x-a.x)+(y-a.y)*(y-a.y));
  }
};

class Vector extends Point {
  Vector(float x, float y) {
    super(x, y);
  }
  Vector spin(float th) {
    return new Vector(cos(th)*x-sin(th)*y, sin(th)*x+cos(th)*y);
  }
};

class Arrows {
  Point c;
  Vector v, s;
  float sz;
  Arrows(Point c, float sz) {
    this.c=c;
    this.v=new Vector(0, -sz);
    s=new Vector(0, 0);
    this.sz=sz;
  }
  void move() {
    if (KEY_UP) {
      arrows.forward();
    }
    if (KEY_RIGHT) {
      arrows.spin(PI/40);
    }
    if (KEY_LEFT) {
      arrows.spin(-PI/40);
    }

    float ny=c.y+s.y/20;
    float nx=c.x+s.x/20;
    if (0<=ny&&ny<=height) c.y=ny;
    if (0<=nx&&nx<=width) c.x=nx;
    s.x*=0.9;
    s.y*=0.9;
  }
  void draw() {
    move();
    stroke(0);  
    line(c.x, c.y, c.x+v.x, c.y+v.y);
    ellipse(c.x+v.x/6*5, c.y+v.y/6*5, sz/3, sz/3);
  }
  void spin(float th) {
    v=v.spin(th);
  }
  void forward() {
    s.x+=v.x/10;
    s.y+=v.y/10;
  }
  boolean isTouched(Point p) {
    Point o = new Point(c.x+v.x/6*5, c.y+v.y/6*5);
    return o.dist(p)<=sz/3;
  }
};

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      KEY_UP=true;
    }
    if (keyCode == RIGHT) {
      KEY_RIGHT=true;
    }
    if (keyCode == LEFT) {
      KEY_LEFT=true;
    }
  }
}
void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) {
      KEY_UP=false;
    }
    if (keyCode == RIGHT) {
      KEY_RIGHT=false;
    }
    if (keyCode == LEFT) {
      KEY_LEFT=false;
    }
  }
}

class Food {
  public Point pos;
  public int passedFrame;
  public boolean crushed;
  color b = color(0, 0, 0);
  color c = color(100, 200, 100); 
  public Food() {
    this.pos = new Point(0, 0);
    pos.x = 0; 
    pos.y = 0; 
    passedFrame = 0;
    crushed = false;
  }
  public Food(Point pos) {
    this.pos = new Point(0, 0);
    this.pos.x = pos.x; 
    this.pos.y = pos.y; 
    passedFrame = 0;
  }
  void draw(Arrows arrows) {
    if (arrows.isTouched(pos)) {
      stroke(c);
      crushed = true;
    } else {
      stroke(b);
    }
    ellipse(pos.x, pos.y, 20, 20);
  }
}