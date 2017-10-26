import java.util.LinkedList;
import java.util.Iterator;

import java.lang.Exception;

Arrows arrows;
LinkedList<Food> foodList;
final int FOOD_SIZE = 1;
boolean KEY_UP = false;
boolean KEY_RIGHT = false;
boolean KEY_LEFT = false;
int st;

File finishMessageFile;
boolean cleared;
void setup() {
  size(500, 500);
  frameRate(60);
  init();
}

void init() {
  st=millis();
  cleared = false;
  Point c = new Point(width/2, height/2);
  arrows = new Arrows(c, width/10);

  foodList = new LinkedList<Food>();
  for (int i = 0; i < FOOD_SIZE; i++) {
    println(random(0, width));
    Food foodPoint = new Food( new Point(random(0, width), random(0, height)) );
    foodList.add(foodPoint);
  }
}

int mx = 0, my = 0;


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
    String[] stra = loadStrings("./finishMessage.txt");
    String str = String.join("\n", stra);

    background(0);
    text(str, mx, my--);
    text("Press R to restart", width/2, height/2);
    cleared=true;
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
    float p=2.0/7.0;
    triangle(
      c.x+v.x, c.y+v.y, 
      c.x+v.x*(1.0-p)+v.y*p, c.y+v.y*(1.0-p)-v.x*p, 
      c.x+v.x*(1.0-p)-v.y*p, c.y+v.y*(1.0-p)+v.x*p);
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
  if (keyCode == 'R') {
    println("R"); 
    if (cleared) {
      init();
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