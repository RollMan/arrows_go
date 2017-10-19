import java.util.LinkedList;
Arrows arrows;
LinkedList<Food> foodList;
final int FOOD_SIZE = 10;
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
  frameRate(120);
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
  Vector v;
  Arrows(Point c, Vector v) {
    this.c=c;
    this.v=v;
  }
  void draw() {
    line(c.x, c.y, c.x+v.x, c.y+v.y);
  }
  void spin(float th) {
    v=v.spin(th);
  }
  void forward() {
    float ny=c.y+v.y/10;
    float nx=c.x+v.x/10;
    if (0<=ny&&ny<=height) c.y=ny;
    if (0<=nx&&nx<=width) c.x=nx;
  }
};

void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      arrows.forward();
    }
    if (keyCode == RIGHT) {
      arrows.spin(PI/20);
    }
    if (keyCode == LEFT) {
      arrows.spin(-PI/20);
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