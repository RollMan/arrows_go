Arrows arrows;
void setup() {
  size(500, 500);
  Point c = new Point(width/2, height/2);
  Vector v = new Vector(0, -width/10);
  arrows = new Arrows(c, v);
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