void drawFFTLine() {
  pushMatrix();
  colorMode(RGB, 800);
  for (int i = 0; i < in.bufferSize() - 1; i++)
  {
    if (in.mix.get(i)*WaveHeight < 20 && in.mix.get(i)*WaveHeight > -20)
      stroke(abs(in.mix.get(i))*WaveHeight+150, 150);

    else  stroke(198, abs(in.mix.get(i))*WaveHeight+100, abs(in.mix.get(i))*WaveHeight*3, 150);
    line( i, height/2 + in.left.get(i)*WaveHeight, i+1, height/2 + in.left.get(i+1)*WaveHeight );
    line( i, height/2 + in.right.get(i)*WaveHeight, i+1, height/2 + in.right.get(i+1)*WaveHeight );

    line( -i, height/2 + in.left.get(i)*WaveHeight, -i-1, height/2 + in.left.get(i+1)*WaveHeight );
    line( -i, height/2 + in.right.get(i)*WaveHeight, -i-1, height/2 + in.right.get(i+1)*WaveHeight );
  }
  popMatrix();
  pushMatrix();
  translate(0, height/2);
  stroke(#E14EF2, 110);
  for (int i = 0; i < in.bufferSize() - 1; i++)
  {
    if (in.mix.get(i)*WaveHeight <50 && in.mix.get(i)*WaveHeight > -50)
      stroke(abs(in.mix.get(i))*WaveHeight+150, 150);
    else stroke(292, abs(in.mix.get(i))*WaveHeight+50, abs(in.mix.get(i))*WaveHeight*3, 150);
    line( width/2 + in.left.get(i)*WaveHeight, i, width/2 + in.left.get(i+1)*WaveHeight, i+1);    
    line( width/2 + in.right.get(i)*WaveHeight, i, width/2 + in.right.get(i+1)*WaveHeight, i+1);


    line( width/2 + in.left.get(i)*WaveHeight, -i, width/2 + in.left.get(i+1)*WaveHeight, -i-1);    
    line( width/2 + in.right.get(i)*WaveHeight, -i, width/2 + in.right.get(i+1)*WaveHeight, -i-1);
  }

  popMatrix();
}