import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.signals.*;
import ddf.minim.effects.*;
import themidibus.*; //Import the library
import codeanticode.syphon.*;

SyphonServer server;
import de.voidplus.leapmotion.*;
LeapMotion leap;
float handX, handY, handZ;
float handDirX, handDirY, handDirZ;
midiControl midi = new midiControl();
MidiBus myBus; // The MidiBus
Minim minim;
AudioInput in;
FFT         fft;
BeatDetect beat;

PGraphics l3;
float xnoise=0.0;
float ynoise=5.0;
float inc=0.06;
static int SampleRate = 44100; // Assume 44.1Khz Sample Rate
static int SampleSize = 1024;
float shake = 0;
float WaveHeight;
ArrayList al;
int mode = 0;
float total= 0;
float eRadius;

FFT fft2;
float[][] EnergyHistory = new float[10][43];
float[] AverageEnergy = new float[10];
float[] r = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
float FFTWay = 0;
float FFTWayy = 0;
float totalFFT = 0;
float totalNum = 0;
void settings() {
  fullScreen(P3D);
  PJOGL.profile=1;
}
void setup() {
  al = new ArrayList();
  background(255);
  colorMode(HSB);
  hint(DISABLE_DEPTH_TEST);
  blendMode(ADD);
  frameRate(30);

  MidiBus.list(); 
  myBus = new MidiBus(this, "Launch Control XL", "Launch Control XL");
  int totalButton =0;
  for (int y=0; y<360; y+=random(10, 30)) {
    for (int x=0; x<360; x+=random(10, 30)) {
      int K = 260;
      float A = K*cos(radians(x))*cos(radians(y));
      float B = 1.2*K*sin(radians(y));
      float C = K*sin(radians(x))*cos(radians(y));
      al.add(new BB(totalButton++, A, B, C, x, y));
    }
  }

  minim = new Minim(this);
  in = minim.getLineIn();
  beat = new BeatDetect();

  ellipseMode(RADIUS);
  eRadius = 20;

  fft2 = new FFT(SampleSize, SampleRate);
  fft2.window(FFT.HAMMING); // HAMMING-SANDWICH
  fft2.logAverages(43, 1);
  leap = new LeapMotion(this);

  l3 = createGraphics(1280, 800, P3D);
  textureMode(NORMAL);  
  ellipseMode(CENTER);
  rectMode(CENTER);
  imageMode(CENTER);

  //PJOGL.profile=1;
  server = new SyphonServer(this, "Processing Syphon");
}
void draw() {

  soundDetect();
  checkLeap();
  blendMode(ADD);

  WaveHeight = 400 + random(-250, 250);
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  fft.forward( in.mix );
  beat.detect(in.mix);
  if ( beat.isOnset() ) eRadius = 80;
  eRadius *= 0.95;
  if ( eRadius < 20 ) eRadius = 20;

  float cameraX, cameraY, cameraR;
  cameraX = handZ*sin(radians(handX))*cos(radians(handY));
  cameraY = handZ*sin(radians(handY));
  cameraR = handZ*cos(radians(handX))*cos(radians(handY)) + map(eRadius, 80, 20, -150, 100);
  camera(cameraX, cameraY, cameraR, 0, 0, 0, 0, 1+handDirY, 0);
  translate(random(-shake, shake), random(-shake, shake));
  if (random(map(shake, 0, 15, 30, 5))>5) {
    background(0);
  }
  if (mode==1) {
    mode1();
  }
  if (mode>=2 && mode <= 4) {
    mode2();
    mode3();
  } 
  if (mode==4) {
    mode4();
  }
  if (mode==5) {
    mode4();
    mode3();
  }
  if (mode==6) {
    mode1();
    mode3();
  }
  blackStript();

  server.sendScreen();
}
void blackStript() {
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
  blendMode(BLEND);
  for (int s=0; s<map(midi.nob[4][0], 0, 127, 0, total/4); s++) {
    noFill();
    stroke(0);
    triangle(random(width), random(height), random(width), random(height), random(width), random(height));
  }
}
class BB {
  float px, py, pz;
  float x, y, z;
  int tag;
  float p_av, p_tv;
  float p_a, p_t;
  float origin_av, origin_tv;
  float easing = 0.1;
  float R;
  float triZ;
  BB(int MyTAG, float A, float B, float C, float pA, float pT) {
    x = A;
    y = B;
    z = C;
    px = x;
    py = y;
    pz = z;
    triZ = z;
    R = 260;
    p_a=pA;
    p_t=pT;
    tag = MyTAG;
    origin_av=random(3);
    origin_tv=random(3);
    //origin_av=0;
    //origin_tv=0;
    p_av=origin_av;
    p_tv=origin_tv;
  }
  void update() {
    if (mode==3) {
      p_a += p_av;
      p_t += p_tv;
    } else if (mode==2) {
      p_a += -3;
      p_t += 0;
    } 

    px = R*sin(radians(p_a))*cos(radians(p_t));
    py = R*sin(radians(p_t));
    pz = R*cos(radians(p_a))*cos(radians(p_t));
    x += (px-x)*easing;
    y += (py-y)*easing;
    z += (pz-z)*easing;
  }
  void show() {
    pushMatrix();
    pushMatrix();
    stroke(255, 25);
    for (float s=0; s<R; s+=2) {
      float Lx=s*sin(radians(p_a))*cos(radians(p_t));
      float Ly=s*sin(radians(p_t)); 
      float Lz=s*cos(radians(p_a))*cos(radians(p_t));
      line(Lx, Ly, Lz, Lx, Ly + (25*sin(radians(s)))*sin(radians(s + p_a)), Lz);
      //ellipse(0, 0, 5, 5);
    }
    popMatrix();
    popMatrix();
  }
  void showNoise() {
    float noiseX, noiseY;
    for (float i=0; i<360; i+=1.2) {
      float gray=int(noise(xnoise, ynoise)*128)+128;
      x = tag*sin(radians(i+5));
      y = tag*cos(radians(i*map(total, 0, 700, 0, 60)/20));
      stroke(gray);
      pushMatrix();
      translate(x, y, map(midi.slider[0], 0, 127, 0, z));
      point(0, 0);
      popMatrix();
      xnoise=xnoise+inc*2;
    }
    xnoise=0;
    ynoise=ynoise+inc*4;
  }
  void showT(int T) {
    colorMode(HSB, 255);
    fill(100, 100);
    pushMatrix();
    noFill();
    translate(x, y, z);
    //fill(#3811ED, 50);
    fill(#43E1F5, midi.nob[1][0]*2);
    //fill(255);
    ellipse(0, 0, 2, 2);
    popMatrix();
    if (mode==4) {
      R = map(midi.nob[3][0], 0, 127, 260, 1500);
    }
    for (int s=T+1; s<T+3; s++) {
      if (s>=al.size())break;
      else {
        float tx, ty, tz;
        tx = ((BB)al.get(s)).x;
        ty = ((BB)al.get(s)).y;
        tz = ((BB)al.get(s)).z;

        stroke(map(map(ty, -150, 150, 230, 317), 0, 360, 0, 255), map(midi.nob[0][0], 0, 127, 0, 200), 180, map(midi.slider[1], 0, 127, 0, 200));
        line(tx, ty, tz, x, y, z);
      }
    }
  }
}