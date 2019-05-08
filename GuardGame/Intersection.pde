/* Credit to Joseph O'Rourke Segment Intersection Functions in cPointi.java */

/* Signed area of triangle determined by a,b,c; positive if counterclockwise and negative if clockwise */
  float AreaSign(Vertex a, Vertex b, Vertex c)
  {
    float area;
    area = (b.x - a.x) * (float)(c.y - a.y) - (c.x - a.x) * (float)(b.y - a.y);
    /*area = (float)(a.x - b.x) * (float)(c.y - a.y) + (float)(c.x - a.x) * (float)(b.y - a.y); */
    
    if(area > 0.5) {
      return 1;
    }
    else if(area < -0.5) {
     return -1; 
    }
    else {
     return 0; 
    }
    
  }
  
  /* Left Test */
  boolean Left(Vertex a, Vertex b, Vertex c)
  {
   return AreaSign(a,b,c) > 0; // >= 0
    
  }
  
  /* Left Test Interior of Polygon */
  boolean LeftInterior(Vertex a, Vertex b, Vertex c) 
  {
   return AreaSign(a,b,c) > 0; 
  }
  
  /* Left of or on Line Segment */
  boolean LeftOn(Vertex a,Vertex b, Vertex c)
  {
   return AreaSign(a,b,c) >= 0; 
  }
  
  boolean Xor(boolean x, boolean y)
  {
   return !x ^ !y; 
  }
  
  /* Xor Left Tests to Determine whether or not line segments properly intersect */
  boolean IntersectProp(Vertex a, Vertex b, Vertex c, Vertex d)
  { 
    return Xor( Left(a,b,c), Left(a,b,d) ) && Xor ( Left(c,d,a), Left(c,d,b));  //<>//
  }
  
  boolean samePoint(Vertex v1, Vertex v2)
  {
    if (abs(v1.x - v2.x) < 0.01 && abs(v1.y - v2.y) < 0.01){
      return true;
    } else {
      return false;
    }
  }
  /* Checks if line segments intersect */
  boolean lineintersection(Vertex a, Vertex b, Vertex c, Vertex d)
  { //<>//
     /* test */
     if(samePoint(a, c) || samePoint(a, d) || samePoint(b, c) || samePoint(b, d)){
       return false;
     }
     if(IntersectProp(a, b, c, d))
     {
       return true; 
     }
     else {
      return false; 
     }
  }
