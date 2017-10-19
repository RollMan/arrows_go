import java.util.LinkedList;
Arrows arrows;
LinkedList<Food> foodList;
final int FOOD_SIZE = 10;
boolean KEY_UP = false;
boolean KEY_RIGHT = false;
boolean KEY_LEFT = false;
void setup() {
  size(500, 500);
  Point c = new Point(width/2, height/2);
  Vector v = new Vector(0, -width/10);
  arrows = new Arrows(c, v);
  
  foodList = new LinkedList<Food>();
  for(int i = 0; i < FOOD_SIZE; i++){
    Food foodPoint = new Food( new Point(random(0, width), random(0, height)) );
    foodList.add(foodPoint);
  }
}

void draw() {
  background(255);
  frameRate(30);
  arrows.draw();
}

class Point {
  float x, y;
  Point(float x, float y) {
    this.x=x;
    this.y=y;
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
  Arrows(Point c, Vector v) {
    this.c=c;
    this.v=v;
    s=new Vector(0, 0);
  }
  void move() {
    if (KEY_UP) {
      arrows.forward();
    }
    if (KEY_RIGHT) {
      arrows.spin(PI/20);
    }
    if (KEY_LEFT) {
      arrows.spin(-PI/20);
    }
    
    float ny=c.y+s.y/10;
    float nx=c.x+s.x/10;
    if (0<=ny&&ny<=height) c.y=ny;
    if (0<=nx&&nx<=width) c.x=nx;
    s.x*=0.9;
    s.y*=0.9;
  }
  void draw() {
    move();
    line(c.x, c.y, c.x+v.x, c.y+v.y);
  }
  void spin(float th) {
    v=v.spin(th);
  }
  void forward() {
    s.x+=v.x/10;
    s.y+=v.y/10;
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

class Food{
  public Point pos;
  public int passedFrame;
  public Food(){
    pos.x = 0; pos.y = 0; passedFrame = 0;
  }
  public Food(Point pos){
    this.pos.x = pos.x; this.pos.y = pos.y; passedFrame = 0;
  }
  public int update(Arrows arrow){
    passedFrame++;
    if(arrow.touched(pow){
      return 100-passedFrame;
    }
    return 0;
  }
}
