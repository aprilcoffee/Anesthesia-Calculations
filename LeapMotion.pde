void checkLeap() {
  // ...
  int fps = leap.getFrameRate();
  for (Hand hand : leap.getHands ()) {

    int     handId             = hand.getId();
    PVector handPosition       = hand.getPosition();
    PVector handStabilized     = hand.getStabilizedPosition();
    PVector handDirection      = hand.getDirection();
    //println(handDirection);
    handX = map(handPosition.x, -200, 2000, -360, 360);
    handY = map(handPosition.y, 50, 1100, -360, 360);
    handZ = map(handPosition.z, -10, 90, -500, 500);

    handDirY = handDirection.y;
    handDirX = handDirection.x;

    //println(handX, handY, handZ);
  }
  for (Device device : leap.getDevices()) {
    float deviceHorizontalViewAngle = device.getHorizontalViewAngle();
    float deviceVericalViewAngle = device.getVerticalViewAngle();
    float deviceRange = device.getRange();
  }
}