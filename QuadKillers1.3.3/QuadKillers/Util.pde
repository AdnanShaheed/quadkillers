//changes the alpha value of a color
color changeAlpha(color c, float alpha) {
  return color(hue(c), saturation(c), brightness(c), alpha);
}

//Uses a binary search to find the correct place then inserts in front of it
ArrayList<Integer> binaryInsertInt(int value, ArrayList<Integer> list) {
  int left = 0; //index of left bound
  int right = list.size(); //index of right bound
  int i; //the test index (halfway between right and left).
  
  //if the value is beyond the list's edges, add it to the end.
  if (value < list.get(0)) {
    list.add(0, value);
    return list;
  } else if (value > list.get(list.size()-1)) {
    list.add(value);
    return list;
  }
  
  //binary search
  while (right - left > 1) {
    i = floor((right + left) * 0.5); //test index (halfway)
    println(right, left, i);
    if (value <= list.get(i)) {
      right = i;
    } else {
      left = i;
    }
  }
  list.add(right, value);
  return list;
}