import processing.net.*;
import java.util.LinkedList;
import java.util.Iterator;

import java.lang.Exception;

Arrows arrows;
LinkedList<Food> foodList;
Game game;
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

  host = new Server(this, PORT);
}

void init() {
  sw=GAMESTATE.START;

  st=millis();
  en=st*100;
  cleared = false;
  Point c = new Point(width/2, height/2);
  arrows = new Arrows(c, width/10);

  foodList = new LinkedList<Food>();
  foodList.add(new Food(new Point(100, 100)));

  game = new Game();
}

int mx = 0, my = 0;

void communicateJSON(){
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
        sending_json.setJSONArray("food", foods);
        sending_json.setInt("current", game.current);
        sending_json.setInt("total", game.TOTAL);
        sending_json.setInt("tlimit", game.t);
        sending_json.setInt("grabbed", game.grabbed);
        sending_json.setInt("start", sw);

        String nl = System.getProperty("line.separator");
        guest.write(sending_json.toString().replaceAll(nl, " ")+nl);
      }
    }
  }
}

interface GAMESTATE {
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
  communicateJSON();
}

void draw_END() {
  background(0);
  text(str, mx, my-=2);
  text("   score: " + game.grabbed, width*2/3, height/2);
  text("-Press R to restart-", width*2/3, height/2+15);
  cleared=true;
  communicateJSON();
}

void draw_PLAY() {
  background(255);
  fill(0);
  stroke(0);
  text("Next: " + game.t, 20, 20);
  text(game.current + "/" + (game.TOTAL - 1), width - 120, 20);
  text("score: " + game.grabbed, width - 120, 40);
  fill(255);

  communicateJSON();
  
  arrows.draw();
 
  String game_state = "None";

  if( foodList.isEmpty() ){
    game_state = game.update(0);
  }else{
    Food f = foodList.getFirst();
    f.draw(arrows);
    if(f.crushed){
      game_state = game.update(1);
      foodList.remove();
    }else{
      game_state = game.update(0);
      if(game_state == "TL"){
        foodList.remove();
      }
    }
  }
  
  if(game_state == "TL"){
    foodList.add( new Food( new Point(mouseX, mouseY) ) );
  }

  if(game.TOTAL == game.current + 1){
    sw = GAMESTATE.END;
  }
  
}

void draw() {
  switch (sw) {
  case GAMESTATE.START:  
    draw_START();
    break;
  case GAMESTATE.END:  
    draw_END();
    break;
  case GAMESTATE.PLAY:  
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
  
  void draw() {
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
  if (sw == GAMESTATE.START) {
    sw = GAMESTATE.PLAY;
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
    if (sw == GAMESTATE.END) {
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

void mouseReleased(){
  //Food foodPoint = new Food( new Point(mouseX, mouseY) );
  //foodList.add(foodPoint);
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

class Game {
  public int TOTAL;
  public int current;
  public int TLIMIT;
  public int t;
  public int grabbed;
  public Game(){
    TOTAL = 10 + 1;
    current = 0;
    TLIMIT = 60*7;
    t = TLIMIT;
    grabbed = 0;
  }
  public Game(int total, int tlimit){
    TOTAL = total;
    current = 0;
    TLIMIT = tlimit;
    t = TLIMIT;
    grabbed = 0;
  }

  public String update(int grabbed){
    this.grabbed += grabbed;
    t--;
    if(t == 0){
      t = TLIMIT;
      current++;
      if(current == TOTAL){
        //return "FIN";
        return "TL";
      }else{
        return "TL";
      }
    }else{
      return "None";
    }
  }
}