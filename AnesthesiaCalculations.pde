import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.signals.*;
import ddf.minim.effects.*;
import themidibus.*; //Import the library

import de.voidplus.leapmotion.*;
LeapMotion leap;

float handX, handY, handZ;
midiControl midi = new midiControl();
MidiBus myBus; // The MidiBus
Minim minim;
AudioInput in;
FFT         fft;
BeatDetect beat;

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
void setup() {
  fullScreen(P3D);
  al = new ArrayList();
  background(255);
  colorMode(HSB);
  hint(DISABLE_DEPTH_TEST);
  blendMode(ADD);
  frameRate(30);

  MidiBus.list(); 
  myBus = new MidiBus(this, "Launch Control XL", "Launch Control XL");
  for (int y=0; y<360; y+=random(10, 30)) {
    for (int x=0; x<360; x+=random(10, 30)) {
      int K = 260;
      float A = K*cos(radians(x))*cos(radians(y));
      float B = 1.2*K*sin(radians(y));
      float C = K*sin(radians(x))*cos(radians(y));
      al.add(new BB(A, B, C, x, y));
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
}
void draw() {

  soundDetect();
  checkLeap();

  WaveHeight = 500 + random(-250, 250);
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  fft.forward( in.mix );
  beat.detect(in.mix);

  if ( beat.isOnset() ) eRadius = 80;
  eRadius *= 0.95;
  if ( eRadius < 20 ) eRadius = 20;

  float cameraX, cameraY, cameraR;
  cameraX = handZ*sin(radians(handX))*cos(radians(handY));
  cameraY = handZ*sin(radians(handY));
  cameraR = handZ*cos(radians(handX))*cos(radians(handY)) + 
    map(eRadius, 80, 20, -100, 100);
  camera(cameraX, cameraY, cameraR, 0, 0, 0, 0, 1, 0);

  //float cameraX, cameraY, cameraR;
  //cameraR = map(eRadius, 80, 20, 350, 450);
  //cameraX = cameraR*sin(radians(map(FFTWay, 0, 4, -720, 720)));
  //cameraY = cameraR*cos(radians(frameCount));

  translate(random(-shake, shake), random(-shake, shake));
  if (random(map(shake, 0, 15, 30, 5))>5) {
    background(0);
  }
  //lights();
  if (mode==1) {
    camera(0, 0, 500, 0, 0, 0, 0, 1, 0);
    float noiseX, noiseY;
    for (float r=0; r<=200; r++) {
      for (float i=0; i<360; i+=1.2) {
        float gray=int(noise(xnoise, ynoise)*128)+128;
        noiseX = r*sin(radians(i+5));
        noiseY = r*cos(radians(i*map(total, 0, 700, 0, 60)/20));
        stroke(gray);
        point(noiseX, noiseY);
        xnoise=xnoise+inc;
      }
      xnoise=0;
      ynoise=ynoise+inc;
    }
  }
  if (mode>=2) {
    rotate(-1);
    //lights();
    for (int s=0; s<al.size(); s++) {
      ((BB)al.get(s)).update();
      ((BB)al.get(s)).showT(s);
    }
  } 
  if (mode>=3) {
    drawFFTLine();
    rotate(-1.5);
    drawFFTLine();
    //println(FFTWay);
    if (FFTWay>3)FFTWay = 3;
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
  BB(float A, float B, float C, float pA, float pT) {
    x = A;
    y = B;
    z = C;
    px = x;
    py = y;
    pz = z;
    R = 260;
    p_a=pA;
    p_t=pT;
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
  void showT(int T) {
    colorMode(HSB, 255);
    fill(100, 100);
    pushMatrix();
    noFill();
    translate(x, y, z);
    //fill(#3811ED, 50);
    fill(#43E1F5, 50);
    ellipse(0, 0, 3, 3);
    popMatrix();
    for (int s=T+1; s<T+3; s++) {
      if (s>=al.size())break;
      else {
        float tx, ty, tz;
        tx = ((BB)al.get(s)).x;
        ty = ((BB)al.get(s)).y;
        tz = ((BB)al.get(s)).z;
        stroke(map(map(ty, -150, 150, 230, 317), 0, 360, 0, 255), 200, 180, 50);
        line(tx, ty, tz, x, y, z);
      }
    }
  }
}