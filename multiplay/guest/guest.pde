import processing.net.*;
import java.util.LinkedList;
import java.util.Iterator;

import java.lang.Exception;

Arrows arrows;
LinkedList<Food> foodList;
final int FOOD_SIZE = 5;
boolean KEY_UP = false;
boolean KEY_RIGHT = false;
boolean KEY_LEFT = false;
long st, en;
int sw;

int current, total, tlimit, grabbed;

Client guest;
final int PORT = 25565;

File finishMessageFile;
boolean cleared;
String str;
void setup() {
  size(500, 500);
  frameRate(60);
  init();
  String[] stra = loadStrings("./finishMessage.txt");
  str = String.join("\n", stra);
  sw=GAME.START;

  //guest = new Client(this, "192.168.43.194", PORT);
  guest = new Client(this, "127.0.0.1", PORT);
}

void init() {
  st=millis();
  en=st*100;
  cleared = false;
  Point c = new Point(width/2, height/2);
  arrows = new Arrows(c, width/10);

  foodList = new LinkedList<Food>();

}

int mx = 0, my = 0;

interface GAME {
  int 
    START = 0, 
    PLAY = 1, 
    END = 2;
};

void draw_START() {
  background(255);
  stroke(0);
  fill(0);
  textSize(30);
  text("ARROWS GO", width/5, height/3);
  text("-PRESS ANY KEY TO START-", width/10, height*2/3);
  textSize(12);
}

void draw_END() {
  background(0);
  text(str, mx, my-=2);
  text("   Time: "+ (en-st)/100, width*2/3, height/2);
  text("-Press R to restart-", width*2/3, height/2+15);
  cleared=true;
}

void draw_PLAY() {
  background(255);
  long m = millis();
  fill(0);
  stroke(0);
  text("Next: " + tlimit, 20, 20);
  text(current + "/" + total, width - 120, 20);
  text("score: " + grabbed, width - 120, 40);
  //println(""+(m-st)/100);
  fill(255);

  arrows.draw();

  {
    JSONObject json = new JSONObject();
    json.setFloat("x", arrows.c.x);
    json.setFloat("y", arrows.c.y);
    json.setFloat("vx", arrows.v.x);
    json.setFloat("vy", arrows.v.y);
    json.setFloat("sx", arrows.s.x);
    json.setFloat("sy", arrows.s.y);
    json.setFloat("sz", arrows.sz);
    json.setFloat("rt", arrows.rt);
    String nl = System.getProperty("line.separator");
    println(json.toString().replaceAll(nl, " ")+nl);
    guest.write(json.toString().replaceAll(nl, " ")+nl);
  }

  {
    String received_str = guest.readStringUntil('\n');
    if (received_str != null) {
      JSONObject received_json = parseJSONObject(received_str);
      if (received_json == null) {
        println("Received data could not be parsed.");
      } else {
        foodList = new LinkedList<Food>();  
        JSONArray items = received_json.getJSONArray("food");
        for (int i=0; i < items.size(); i++) {
          JSONObject item = items.getJSONObject(i);
          float x=item.getFloat("x");
          float y=item.getFloat("y");
          foodList.add(new Food(new Point(x, y)));
        }
        current = received_json.getInt("current");
        total   = received_json.getInt("total");
        tlimit  = received_json.getInt("tlimit");
        grabbed = received_json.getInt("grabbed");
        println("current:" + current);
        println("total  :" + total);
        println("tlimit :" + tlimit);
        println("grabbed:" + grabbed);
      }
    }
  }

  for (Iterator<Food> it = foodList.iterator(); it.hasNext(); ) {
    Food f = it.next();
    f.draw(arrows);
    if (f.crushed) {
      it.remove();
    }
  }
  
}

void draw() {
  switch (sw) {
  case GAME.START:  
    draw_START();
    break;
  case GAME.END:  
    draw_END();
    break;
  case GAME.PLAY:  
    draw_PLAY();
    break;
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
  float rt;
  final float u=0.05;
  final boolean debug = false;
  Arrows(Point c, float sz) {
    this.c=c;
    this.v=new Vector(0, -sz);
    s=new Vector(0, 0);
    this.sz=sz;
    rt=0;
  }
  void move() {
    float ma=PI/40, mi=-ma;
    if (KEY_UP) {
      arrows.forward();
    }
    if (KEY_RIGHT) {
      rt+=PI/400;
    }
    if (KEY_LEFT) {
      //rt-=PI/400;
    }
    rt=min(rt, ma);
    rt=max(rt, mi);
    v=v.spin(rt);

    float ny=c.y+s.y/20;
    float nx=c.x+s.x/20;
    if (0<=ny&&ny<=height) c.y=ny;
    if (0<=nx&&nx<=width) c.x=nx;
    s.x*=(1-u);
    s.y*=(1-u);
    rt*=(1-u);
  }
  void draw() {
    move();
    stroke(0);  
    float p=3.0/8.0;
    line(c.x, c.y, c.x+v.x, c.y+v.y);
    fill(0);
    line(c.x+v.y*p/2, c.y-v.x*p/2, c.x-v.y*p/2, c.y+v.x*p/2);
    quad(
      c.x+v.y*p/2, c.y-v.x*p/2, 
      c.x-v.y*p/2, c.y+v.x*p/2, 
      c.x-v.y*p/2+v.x*(1-p), c.y+v.x*p/2+v.y*(1-p), 
      c.x+v.y*p/2+v.x*(1-p), c.y-v.x*p/2+v.y*(1-p));
    triangle(
      c.x+v.x, c.y+v.y, 
      c.x+v.x*(1.0-p)+v.y*p, c.y+v.y*(1.0-p)-v.x*p, 
      c.x+v.x*(1.0-p)-v.y*p, c.y+v.y*(1.0-p)+v.x*p);

    if (debug) {
      float   q=2.5/8.0;
      fill(0, 0, 255);
      ellipse(c.x+v.x*(1-q/1.5), c.y+v.y*(1-q/1.5), sz*q, sz*q);
    }
    fill(255);
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
  if (sw == GAME.START) {
    sw = GAME.PLAY;
  }
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
      sw = GAME.START;
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