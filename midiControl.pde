public class midiControl {
  MidiBus myBus; 
  public int nob[][] = new int[6][3];
  public int slider[] = new int[6];
  /*
  0=zero
   3=red
   16=green
   23=orange
   26=yellow
   */

  midiControl() {
    MidiBus.list();  
    myBus = new MidiBus(this, "Launch Control XL", "Launch Control XL");
    for (int s=41; s<=48; s++) {
      ControlChange change = new ControlChange(0, s, 0);
      myBus.sendControllerChange(change); // Send a controllerChange
    }
    for (int s=0; s<6; s++) {
      slider[s] = 0;
      for (int i=0; i<3; i++) {
        nob[s][i] = 0;
      }
    }
  }
  public void noteOff(Note note) {
    // Receive a noteOff
    //println();
    //println("Note Off:");
    //println("--------");
    //println("Channel:"+note.channel());
    //println("Pitch:"+note.pitch());
    //println("Velocity:"+note.velocity());
    if (note.channel==0) {
      for (int s=73; s<=76; s++) {
        Note noteTemp1 = new Note(note.channel, s, 0);
        myBus.sendNoteOff(noteTemp1);
        Note noteTemp2 = new Note(note.channel, s+16, 0);
        myBus.sendNoteOff(noteTemp2);
      }
      Note noteTemp = new Note(note.channel, note.pitch, 127);
      switch(note.pitch) {
      case 73:
        mode=1;
        myBus.sendNoteOn(noteTemp);
        break;
      case 74:
        mode=2;
        myBus.sendNoteOn(noteTemp);
        break;
      case 75:
        mode=3;
        myBus.sendNoteOn(noteTemp);
        break;
      case 76:
        mode=4;
        myBus.sendNoteOn(noteTemp);
        break;
      case 89:
        mode=5;
        myBus.sendNoteOn(noteTemp);
        break;
      case 90:
        mode=6;
        myBus.sendNoteOn(noteTemp);
        break;
      case 91:
        mode=7;
        myBus.sendNoteOn(noteTemp);
        break;
      case 92:
        mode=8;
        myBus.sendNoteOn(noteTemp);
        break;
      }
    }
  }
  public void controllerChange(ControlChange change) {
    // Receive a controllerChange
    //println();
    //println("Controller Change:");
    //println("--------");
    //println("Channel:"+change.channel());
    //println("Number:"+change.number());
    //println("Value:"+change.value());
    if (change.channel()==9) {
      slider[change.number()-1]=change.value();
    } else if (change.channel()<6 && change.number()<=3) {
      nob[change.channel()][change.number()-1] = change.value();
    }
  }
  void delay(int time) {
    int current = millis();
    while (millis () < current+time) Thread.yield();
  }
}