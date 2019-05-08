/* Credit to Joseph O'Rourke InCone Functions in cPolygon.java *///<>// //<>// //<>//

/* Initialized Shared Variables */
ChildApplet child; 
boolean mousePressedOnParent = false;
boolean randomVerticesChosen =  false;
boolean setup = false;
boolean lastEdge = false;

/* Flag is True if All Guards Have Been Chosen */
boolean guarding = false;
/* Flag is True Once Polygonizer Initial Window is Setup */
boolean polygonizerSetup = false;
/* Flag is True Once Polygon Has All of its Edges Including All of the Vertices without any crossing segments */
boolean finishedPolygon = false;
boolean winnerSelected = false;
boolean endReached = false;
ArrayList<Vertex> vertices = new ArrayList<Vertex>();
/* List of Guard Vertices Chosen */
ArrayList<Vertex> guardVertices = new ArrayList<Vertex>();
ArrayList<Vertex> polygonizerVertices = new ArrayList<Vertex>();
/* List of Vertices in order chosen for building simple polygon */
ArrayList<Vertex> builtPolygon = new ArrayList<Vertex>();
/* List of Vertices Visible by at least one guard */
ArrayList<Vertex> visibleVertices = new ArrayList<Vertex>();
/* List of Remaining Vertices to check whether or not they are visible by at least one guard */
ArrayList<Vertex> remainingVertices = new ArrayList<Vertex>();
Vertex mostRecentlyAddedVertex;
Vertex secondMostRecentlyAddedVertex;
/* Temp to show computing */
ArrayList<Vertex> guardsToDraw = new ArrayList<Vertex>();
ArrayList<Vertex> remainToDraw = new ArrayList<Vertex>();
ArrayList<Integer> goodToDraw = new ArrayList<Integer>();
ArrayList<Vertex> intersectingEdge1 = new ArrayList<Vertex>();
ArrayList<Vertex> intersectingEdge2 = new ArrayList<Vertex>();
ArrayList<Vertex> allVertices = new ArrayList<Vertex>();
boolean end = false;

void settings() {
  size(1000, 1000, P3D);
  smooth();
}

/* Guarder Program */
void setup() {
  surface.setTitle("The Guarder");
  child = new ChildApplet();
}

/* Guarder window initially displays 15 randomly positioned vertices */
void initialWindow() {
  background(250);
  for (int i = 0; i < 15; i++) {
    int r = (int)random(970);
    int r2 = (int)random(970);
    fill(0, 240, 0);
    ellipse(r, r2, 20, 20);
    Vertex v = new Vertex(r, r2);
    vertices.add(v);
    polygonizerVertices.add(v);
    allVertices.add(v);
  }
  randomVerticesChosen = true;
}

/* If mouse clicks vertex and guard number is less than 5, change that vertex color to red and add to list of guarding vertices */
void mouseClicked() {
  if (guarding == false) {
    for (int i = 0; i < vertices.size(); i++) {
      if (dist(mouseX, mouseY, vertices.get(i).x, vertices.get(i).y) < 20) {
        fill(255, 0, 0);
        ellipse(vertices.get(i).x, vertices.get(i).y, 20, 20);
        guardVertices.add(vertices.get(i));
        vertices.remove(i);
        if (guardVertices.size() == 5) {
          guarding = true;
        }
      }
    }
  }
}

/* When computing result, add all guards and vertices adjacent to guards as visible */
/* Do not add same vertex to visibleVertex list multiple times */
void getGuardsAdjacentVertices()
{
  boolean addBeforeGuard = true;
  boolean addAfterGuard = true;
  boolean addGuard = true;
  for (int i = 0; i < guardVertices.size(); i++)
  {
    for (int j = 0; j < builtPolygon.size(); j++)
    {
      if (builtPolygon.get(j) == guardVertices.get(i))
      {
        for (int k = 0; k < visibleVertices.size(); k++)
        {
          if (visibleVertices.get(k) == guardVertices.get(i)) {
            addGuard = false;
          }
          if (j == 0)
          {
            if (visibleVertices.get(k) == builtPolygon.get(builtPolygon.size() - 1)) {
              addBeforeGuard = false;
            }
          } else
          {
            if (visibleVertices.get(k) == builtPolygon.get(j - 1))
            {
              addBeforeGuard = false;
            }
          }
          if (j == builtPolygon.size() - 1)
          {
            if (visibleVertices.get(k) == builtPolygon.get(0))
            {
              addAfterGuard = false;
            }
          } else 
          {
            if (visibleVertices.get(k) == builtPolygon.get(j + 1))
            {
              addAfterGuard = false;
            }
          }
        }

        if (addGuard == true)
        {
          visibleVertices.add(guardVertices.get(i)); 
          remainingVertices.remove(guardVertices.get(i));
        }
        if (addBeforeGuard == true)
        {
          if (j == 0) {
            fill(130, 130, 0);
            ellipse(builtPolygon.get(builtPolygon.size() - 1).x, builtPolygon.get(builtPolygon.size() - 1).y, 20, 20);
            visibleVertices.add(builtPolygon.get(builtPolygon.size() - 1)); 
            remainingVertices.remove(builtPolygon.get(builtPolygon.size() - 1));
          } else {
            fill(130, 130, 0);
            ellipse(builtPolygon.get(j - 1).x, builtPolygon.get(j - 1).y, 20, 20);
            visibleVertices.add(builtPolygon.get(j - 1));
            remainingVertices.remove(builtPolygon.get(j - 1));
          }
        }
        if (addAfterGuard == true)
        {
          if (j == builtPolygon.size() - 1)
          {
            fill(130, 130, 0);
            ellipse(builtPolygon.get(0).x, builtPolygon.get(0).y, 20, 20);
            visibleVertices.add(builtPolygon.get(0)); 
            remainingVertices.remove(builtPolygon.get(0));
          } else {
            fill(130, 130, 0);
            ellipse(builtPolygon.get(j + 1).x, builtPolygon.get(j + 1).y, 20, 20);
            visibleVertices.add(builtPolygon.get(j + 1)); 
            remainingVertices.remove(builtPolygon.get(j + 1));
          }
        }
        addBeforeGuard = true;
        addAfterGuard = true;
        addGuard = true;
      }
    }
  }
}

/* Returns true if and only if the diagonal (a,b) is strictly internal to the polygon in the neighborhood of the a endpoint */
boolean InCone(Vertex a, Vertex b)
{
  Vertex aNext = a;
  Vertex aPrev = a;
  for (int i = 0; i < builtPolygon.size(); i++) 
  {
    if (builtPolygon.get(i).x == a.x && builtPolygon.get(i).y == a.y)
    {
      if (i == builtPolygon.size() - 1)
      {
        aNext = builtPolygon.get(0);
      } else 
      {
        aNext = builtPolygon.get(i + 1);
      }
      if (i == 0)
      {
        aPrev = builtPolygon.get(builtPolygon.size() - 1);
      } else 
      {
        aPrev = builtPolygon.get(i-1);
      }
    }
  }
  
  if (LeftOn(a, aNext, aPrev))                
  {
   /*Convex*/
    return LeftInterior(a, b, aPrev) && LeftInterior(b, a, aNext);
  } 
  /*Reflex*/
  return !(LeftOn(a, b, aNext) && LeftOn(b, a, aPrev));  
}

/* Check that line segment does not intersect any of the polygon's segments */

boolean checkIntersections(float x1, float y1, float x2, float y2) {
  Vertex a = new Vertex(x1, y1);
  Vertex b = new Vertex(x2, y2);
  for (int i = 0; i < builtPolygon.size() - 1; i++) {
    boolean result = lineintersection(a, b, builtPolygon.get(i), builtPolygon.get(i+1));
    if (result == true) {
      intersectingEdge1.add(builtPolygon.get(i));
      intersectingEdge2.add(builtPolygon.get(i+1));
      goodToDraw.add(111);
      return true;
    }
  }
  /* Check for intersection to edge between last point and first point */
  boolean result = lineintersection(a, b, builtPolygon.get(builtPolygon.size() - 1), builtPolygon.get(0));
  if (result == true) {
    goodToDraw.add(111);
    return true;
  }
  /* Make sure line segment is inside polygon */
  boolean insidePolygon = InCone(a, b);
  if (insidePolygon == true)  //false
  {
    goodToDraw.add(222);
    return true;
  }
  goodToDraw.add(333);
  return false;
}

/* Compute number of vertices visible from the selected guards to determine winner */
void computeResult() 
{
  for (int i = 0; i < remainingVertices.size(); i++) {
    boolean intersectFree = false;
    for (int j = 0; j < guardVertices.size(); j++) {
      boolean intersect = true;
      guardsToDraw.add(guardVertices.get(j));
      remainToDraw.add(remainingVertices.get(i));
      intersect = checkIntersections(remainingVertices.get(i).x, remainingVertices.get(i).y, guardVertices.get(j).x, guardVertices.get(j).y);
      if (intersect == false)
      {
        intersectFree = true;
        line(remainingVertices.get(i).x, remainingVertices.get(i).y, guardVertices.get(j).x, guardVertices.get(j).y);
        break;
      }
    }
    if (intersectFree == true) {
      visibleVertices.add(remainingVertices.get(i));
    }
  }
}

void draw() {
  /* Guarder Setup */
  if (setup == false) {
    initialWindow();
    fill(0, 0, 0);
    textSize(25);
    text("Guarder: Select 5 Vertex Guards", 20, 20);
    setup = true;
  }

  if (finishedPolygon == true && guarding == true)
  {
    fill(255, 255, 255);
    textSize(25);
    text("Guarder: Select 5 Vertex Guards", 20, 20);
    fill(255, 0, 255);
    textSize(30);
    text("Computing Result....", 20, 30); 
    for (int i = 0; i < builtPolygon.size(); i++) {
      remainingVertices.add(builtPolygon.get(i));
    }
    getGuardsAdjacentVertices();
    for (int i = 0; i < guardVertices.size(); i++) 
    {
      fill(255, 0, 0);
      ellipse(guardVertices.get(i).x, guardVertices.get(i).y, 20, 20);
    }
    /* temp */
    if(end == false) {
    if (winnerSelected == false) {
      computeResult();
    } else {
      delay(1500);
      background(240, 240, 240);

      strokeWeight(3);
      stroke(150, 0, 0);
      for (int i = 0; i < builtPolygon.size() - 1; i++) {
        line(builtPolygon.get(i).x, builtPolygon.get(i).y, builtPolygon.get(i+1).x, builtPolygon.get(i+1).y);
      }
      line(builtPolygon.get(builtPolygon.size() - 1).x, builtPolygon.get(builtPolygon.size() - 1).y, builtPolygon.get(0).x, builtPolygon.get(0).y); 
      /* Show computations for debug */
      if (guardsToDraw.size() > 0) {
        fill(255, 170, 170);
        ellipse(guardsToDraw.get(0).x, guardsToDraw.get(0).y, 30, 30);
        fill(255, 0, 255);
        textSize(30);
        text("GUARD: (" + guardsToDraw.get(0).x + "," + guardsToDraw.get(0).y + ")\n", 25, 30);
      } else {
        fill(255, 0, 255);
        textSize(30);
        text("No guards left to show.", 25, 30);
      }
      if (remainToDraw.size() > 0) {
        fill(255, 255, 40);
        ellipse(remainToDraw.get(0).x, remainToDraw.get(0).y, 30, 30);
        fill(255, 0, 255);
        textSize(30);
        text("REMAIN: (" + remainToDraw.get(0).x + "," + remainToDraw.get(0).y + ")\n", 25, 60);
        /* draw connecting line */
        strokeWeight(4);
        stroke(0, 200, 200);
        line(remainToDraw.get(0).x, remainToDraw.get(0).y, guardsToDraw.get(0).x, guardsToDraw.get(0).y);
      } else {
        fill(255, 0, 255);
        textSize(30);
        endReached = true;
      }
      if (goodToDraw.size() > 0) {
        if (goodToDraw.get(0) == 333) {
          fill(0, 0, 255);
          textSize(30);
          text("VISIBLE", 25, 90);
        } else if (goodToDraw.get(0) == 111) {
          fill(255, 0, 0);
          textSize(30);
          text("Not visible. Intersection detected.", 25, 90);
          strokeWeight(5);
          stroke(255, 0, 0);
          line(intersectingEdge1.get(0).x, intersectingEdge1.get(0).y, intersectingEdge2.get(0).x, intersectingEdge2.get(0).y);
          intersectingEdge1.remove(0);
          intersectingEdge2.remove(0);
        } else if (goodToDraw.get(0) == 222) {
          fill(255, 0, 0);
          textSize(30);
          text("Not visible. Line of visibility outside of polygon.", 25, 90);
        } else {
          fill(255, 0, 0);
          textSize(30);
          text("Unknown error.", 25, 90);
        }
        goodToDraw.remove(0);
      }
      if (guardsToDraw.size() > 0) {
        fill(255, 20, 20);
        ellipse(guardsToDraw.get(0).x, guardsToDraw.get(0).y, 10, 10);
        guardsToDraw.remove(0);
      }
      if (remainToDraw.size() > 0) {
        fill(20, 200, 20);
        ellipse(remainToDraw.get(0).x, remainToDraw.get(0).y, 10, 10);
        remainToDraw.remove(0);
      }
    }
    /* Display Winner */
    if (winnerSelected == false || endReached == true) {
      if (visibleVertices.size() == 15)
      {
        fill(255, 0, 255);
        textSize(50);
        text("GUARDER WINS", 25, 900);
      } else
      {
        fill(255, 0, 255);
        textSize(30);
        text("POLYGONIZER WINS: " + str(15 - visibleVertices.size()) + " vertices not guarded!", 25, 900);
      }
      if (endReached == true && winnerSelected == true) {
        for(int i = 0; i < allVertices.size(); i++)
        {
              float r = allVertices.get(i).x;
              float r2 = allVertices.get(i).y;
              fill(0, 240, 0);
              ellipse(r, r2, 20, 20);
        }
        computeResult();
        end = true;
      }
      endReached = false;
      winnerSelected = true;
    }
    }
    delay(500);
  }
}

/* Polygonizer Program */
class ChildApplet extends PApplet {

  public ChildApplet() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(1000, 1000, P3D);
    smooth();
  }

  /* Initialize Window with Randomly Chosen Vertices */
  public void setup() { 
    surface.setTitle("The Polygonizer");
    background(255);
    while (randomVerticesChosen == false) {
    }
    for (int i = 0; i < polygonizerVertices.size(); i++) {
      fill(0, 240, 0);
      ellipse(polygonizerVertices.get(i).x, polygonizerVertices.get(i).y, 20, 20);
    }
    polygonizerSetup = true;
  }

  void mouseClicked() {
    if (winnerSelected == false) {
      /* Handle Removing Most Recently Added Polygon Segment */
      if ((mouseX > 10) && (mouseX < 270) && (mouseY > 10) && (mouseY < 20)) {
        if (builtPolygon.size() == 1) {
          polygonizerVertices.add(builtPolygon.remove(0));
          fill(255, 255, 255);
          rect(10, 10, 270, 20);
        } else if (builtPolygon.size() == 0) {
          return;
        } else {
          builtPolygon.remove(builtPolygon.size() - 1);
          strokeWeight(4);
          stroke(255, 255, 255);
          line(mostRecentlyAddedVertex.x, mostRecentlyAddedVertex.y, secondMostRecentlyAddedVertex.x, secondMostRecentlyAddedVertex.y);
          polygonizerVertices.add(mostRecentlyAddedVertex);
          mostRecentlyAddedVertex = secondMostRecentlyAddedVertex;
          if (builtPolygon.size() < 2)
          {
            secondMostRecentlyAddedVertex = null;
          } else {
            secondMostRecentlyAddedVertex = builtPolygon.get(builtPolygon.size() - 2);
          }
          strokeWeight(1);
        }
      }

      /* Handle Adding Final Segment to Simple Polygon */
      if (polygonizerVertices.size() == 0) {
        lastEdge = true;
        boolean intersect = checkIntersections(builtPolygon.get(builtPolygon.size()-1).x, builtPolygon.get(builtPolygon.size()-1).y, builtPolygon.get(0).x, builtPolygon.get(0).y);
        lastEdge = false;
        if (intersect == true) {
          fill(0, 0, 0);
          textSize(25);
          text("Cannot Add Intersecting Line to Simple Polygon", 100, 100);
          return;
        }
        line(builtPolygon.get(builtPolygon.size()-1).x, builtPolygon.get(builtPolygon.size()-1).y, builtPolygon.get(0).x, builtPolygon.get(0).y);
        finishedPolygon = true;
        fill(0, 200, 255);
        rect(10, 10, 270, 20);
        fill(0, 0, 0);
        fill(255, 0, 255);
        textSize(30);
        text("Computing Result....", 20, 75);
      }

      /* Adding Segments to Simple Polygon */
      for (int i = 0; i < polygonizerVertices.size(); i++) {
        if (dist(mouseX, mouseY, polygonizerVertices.get(i).x, polygonizerVertices.get(i).y) < 20) {
          /* Handle Adding First Segment to Simple Polygon */
          if (builtPolygon.size() == 0) {
            builtPolygon.add(polygonizerVertices.get(i));
            mostRecentlyAddedVertex = polygonizerVertices.get(i);
            polygonizerVertices.remove(i);
            strokeWeight(1);
            fill(0, 200, 255);
            rect(10, 10, 270, 20);
            fill(0, 0, 0);
            textSize(15);
            text("Remove Most Recently Added Vertex", 15, 23);
          } else {
            /* Add New Edge to Simple Polygon if it does not intersect edges added prior */
            boolean intersect = checkIntersections(builtPolygon.get(builtPolygon.size()-1).x, builtPolygon.get(builtPolygon.size()-1).y, polygonizerVertices.get(i).x, polygonizerVertices.get(i).y);
            if (intersect == true) {
              fill(0, 0, 0);
              textSize(25);
              text("Cannot Add Intersecting Line to Simple Polygon", 100, 100);
              return;
            }
            stroke(255, 0, 0);
            strokeWeight(4);
            line(builtPolygon.get(builtPolygon.size()-1).x, builtPolygon.get(builtPolygon.size()-1).y, polygonizerVertices.get(i).x, polygonizerVertices.get(i).y);
            builtPolygon.add(polygonizerVertices.get(i));
            secondMostRecentlyAddedVertex = mostRecentlyAddedVertex;
            mostRecentlyAddedVertex = polygonizerVertices.get(i);
            polygonizerVertices.remove(i);
          }
        }
      }
    }
  }

  /* Check that Line Segment Does Not Intersect any of the Polygon's Edges */
  boolean checkIntersections(float x1, float y1, float x2, float y2) {
    for (int i = 1; i < builtPolygon.size() - 1; i++) {
      if (!(lastEdge == true && i == 1)) { 
        Vertex a = new Vertex(x1, y1);
        Vertex b = new Vertex(x2, y2);
        boolean result = lineintersection(a, b, builtPolygon.get(i-1), builtPolygon.get(i));
        if (result == true) {
          return true;
        }
      }
    }
    return false;
  }

  public void draw() {
  }
}
