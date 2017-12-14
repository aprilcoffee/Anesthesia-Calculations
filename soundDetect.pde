void soundDetect() {
  total = 0;
  for (int i = 0; i < in.bufferSize() - 1; i++) {
    total += abs(in.mix.get(i));
  }
  shake = map(total, 0, 1000, 0, 15);
  WaveHeight = 750 + random(-250, 250);
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  fft.forward( in.mix );
  beat.detect(in.mix);
  beat.setSensitivity(300);  
  // make a new beat listener, so that we won't miss any buffers for the analysis
  //bl = new BeatListener(beat, in);  
  if ( beat.isOnset() ) eRadius = 80;
  eRadius *= 0.95;
  if ( eRadius < 20 ) eRadius = 20;
  fft2.forward(in.mix);
  //double FFTWay = 0;

  totalFFT = 0;
  totalNum = 0;
  for (int i = 0; i < 10; i++)
  {
    AverageEnergy[i] = 0;
    for (int j = 42; j > 0; j--)
    {
      AverageEnergy[i] += EnergyHistory[i][j];
      EnergyHistory[i][j] = EnergyHistory[i][j-1];
    }
    AverageEnergy[i] /= 43;
    EnergyHistory[i][0] = fft2.getAvg(i);
  }
  for (int i = 0; i < 10; i ++)
  {
    r[i] *= .95f;
    if (EnergyHistory[i][0] > 1.75f * AverageEnergy[i])
    {
      fill(33, 33, 255);
      r[i] = 50;
    } else
      fill(128, 128, 128);    
    totalFFT+=EnergyHistory[i][0]*i;
    totalNum+=EnergyHistory[i][0];
  }
  if (totalNum < 10)FFTWayy=0;
  else
    FFTWayy = totalFFT/totalNum;
  FFTWay += (FFTWayy-FFTWay)*0.3;
}