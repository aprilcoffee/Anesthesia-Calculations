void mode1() {
  //camera(0, 0, 500, 0, 0, 0, 0, 1, 0);
  for (int s=0; s<(int)map(midi.slider[3], 0, 127, 0, al.size()); s++) {
    ((BB)al.get(s)).showNoise();
  }
}
void mode2() {
  for (int s=0; s<(int)map(midi.slider[3], 0, 127, 0, al.size()); s++) {
    ((BB)al.get(s)).update();
    ((BB)al.get(s)).showT(s);
  }
}
void mode3() {
  pushMatrix();
  drawFFTLine();
  rotate(-1.5);
  drawFFTLine();
  //println(FFTWay);
  if (FFTWay>3)FFTWay = 3;
  popMatrix();
}
void mode4() {

  pushMatrix();
  l3.beginDraw();
  l3.colorMode(HSB);
  l3.smooth();
  l3.hint(DISABLE_DEPTH_TEST);
  l3.blendMode(ADD);
  if (random(map(shake, 0, 15, 30, 5))>5) {
    l3.background(0);
  }
  //l3.background(0);
  l3.pushMatrix();
  l3.colorMode(RGB, 800);
  for (int i = 0; i < in.bufferSize() - 1; i++)
  {
    if (in.mix.get(i)*WaveHeight < 20 && in.mix.get(i)*WaveHeight > -20)
      l3.stroke(abs(in.mix.get(i))*WaveHeight+150, 250);

    else  l3.stroke(198, abs(in.mix.get(i))*WaveHeight+100, abs(in.mix.get(i))*WaveHeight*3, 400);
    l3.line( i, height/2 + in.left.get(i)*WaveHeight, i+1, height/2 + in.left.get(i+1)*WaveHeight );
    l3.line( i, height/2 + in.right.get(i)*WaveHeight, i+1, height/2 + in.right.get(i+1)*WaveHeight );

    l3.line( -i, height/2 + in.left.get(i)*WaveHeight, -i-1, height/2 + in.left.get(i+1)*WaveHeight );
    l3.line( -i, height/2 + in.right.get(i)*WaveHeight, -i-1, height/2 + in.right.get(i+1)*WaveHeight );
  }
  l3.popMatrix();
  l3.pushMatrix();
  l3.translate(0, height/2);
  l3.stroke(#E14EF2, 110);
  for (int i = 0; i < in.bufferSize() - 1; i++)
  {
    if (in.mix.get(i)*WaveHeight <50 && in.mix.get(i)*WaveHeight > -50)
      l3.stroke(abs(in.mix.get(i))*WaveHeight+150, 250);
    else stroke(292, abs(in.mix.get(i))*WaveHeight+50, abs(in.mix.get(i))*WaveHeight*3, 400);
    l3.line( width/2 + in.left.get(i)*WaveHeight, i, width/2 + in.left.get(i+1)*WaveHeight, i+1);    
    l3.line( width/2 + in.right.get(i)*WaveHeight, i, width/2 + in.right.get(i+1)*WaveHeight, i+1);

    l3.line( width/2 + in.left.get(i)*WaveHeight, -i, width/2 + in.left.get(i+1)*WaveHeight, -i-1);    
    l3.line( width/2 + in.right.get(i)*WaveHeight, -i, width/2 + in.right.get(i+1)*WaveHeight, -i-1);
  }
  l3.popMatrix();
  l3.endDraw();

  noStroke();
  beginShape(TRIANGLE_STRIP);
  texture(l3);
  fill(255, 70);
  int r =  260;
  vertex(r*cos(radians(0)) * cos(radians(0)), r*sin(radians(0)), r*sin(radians(0)) * cos(radians(0)), 0, 0);
  for (int t=10; t<360; t+=10) {
    for (int s=0; s<360; s+=10) {
      float x, y, z;
      x = r*cos(radians(s)) * cos(radians(t));
      y = r*sin(radians(t));
      z = r*sin(radians(s)) * cos(radians(t));
      vertex(x, y, z, map(s, 0, 360, 0, 1), map(t, 0, 360, 0, 1));
      x = r*cos(radians(s)) * cos(radians(t-10));
      y = r*sin(radians(t-10));
      z = r*sin(radians(s)) * cos(radians(t-10));
      vertex(x, y, z, map(s, 0, 360, 0, 1), map(t-10, 0, 360, 0, 1) );
    }
  }
  vertex(r*cos(radians(360)) * cos(radians(360)), r*sin(radians(360)), r*sin(radians(360)) * cos(radians(360)), 1, 1);
  endShape();
  popMatrix();
}