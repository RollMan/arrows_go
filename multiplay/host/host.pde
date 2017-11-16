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

Server host;
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

  host = new Server(this, PORT);
}

void init() {
  st=millis();
  en=st*100;
  cleared = false;
  Point c = new Point(width/2, height/2);
  arrows = new Arrows(c, width/10);

  foodList = new LinkedList<Food>();
  /*
  for (int i = 0; i < FOOD_SIZE; i++) {
    println(random(0, width));
    Food foodPoint = new Food( new Point(random(0, width), random(0, height)) );
    foodList.add(foodPoint);
  }
  */
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
  text("TIME: "+(m-st)/100, 20, 20);
  //println(""+(m-st)/100);
  fill(255);

  Client guest = host.available();
  if(guest != null){
    String received_str = guest.readStringUntil('\n');
    if(received_str != null){
      JSONObject received_json = parseJSONObject(received_str);
      if(received_json == null){
        println("Received data could not be parsed.");
      }else{
        float x = received_json.getInt("x");
        float y = received_json.getInt("y");
        float vx = received_json.getInt("vx");
        float vy = received_json.getInt("vy");
        float sx = received_json.getInt("sx");
        float sy = received_json.getInt("sy");
        float sz = received_json.getInt("sz");
        float rt = received_json.getInt("rt");
        Arrows newone = new Arrows(new Point(x, y),
                                   new Vector(vx, vy),
                                   new Vector(sx, sy),
                                   sz, rt);

        arrows = newone;
      }
    }
  }
  arrows.draw();


  for (Iterator<Food> it = foodList.iterator(); it.hasNext(); ) {
    Food f = it.next();
    f.draw(arrows);
    if (f.crushed) {
      it.remove();
    }
  }

  if(guest != null){
    JSONArray foods = new JSONArray();
    int idx = 0;
    for(Iterator<Food> it = foodList.iterator(); it.hasNext();){
      Food f = it.next();
      JSONObject fjson = new JSONObject();
      fjson.setFloat("x", f.pos.x);
      fjson.setFloat("y", f.pos.y);

      foods.setJSONObject(idx, fjson);
      idx++;
    }
    JSONObject sending_json = new JSONObject();
    sending_json.setJSONArray("foods", foods);
  }

/*
  if (foodList.isEmpty()) {
    en = m;
    sw = GAME.END;
  }
  */
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
  Arrows(Point c, Vector v, Vector s, float sz, float rt){
    this.c = c;
    this.v = v;
    this.s = s;
    this.sz = sz;
    this.rt = rt;
  }
  void move() {
    float ma=PI/40, mi=-ma;
    /*
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
    */
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

void mouseReleased(){
  Food foodPoint = new Food( new Point(mouseX, mouseY) );
  foodList.add(foodPoint);
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