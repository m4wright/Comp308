# include <GL/glut.h>
# include <math.h>
# include <stdio.h>

# define CIRCLE_RAD 0.1


/*
To compile:
   gcc a3q2.c -lglut -lGL -lm -o a3q2
*/

typedef struct
{
   int red;
   int green;
   int blue;
} color;

typedef struct
{
   double x;
   double y;
} point;



void drawCircle(point p, double radius, color c);
void drawLine(point p1, point p2, double lineWidth, color c);
void drawSun(point p);
void drawRectangle(point p1, point p2, color c);


// void drawTriangle()
// {
//    glClearColor(0.4, 0.4, 0.4, 0.4);
//    glClear(GL_COLOR_BUFFER_BIT);

//    glColor3f(1.0, 1.0, 1.0);
//    glOrtho(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0);

//        glBegin(GL_TRIANGLES);
//                glVertex3f(-0.7, 0.7, 0);
//                glVertex3f(0.7, 0.7, 0);
//                glVertex3f(0, -1, 0);
//        glEnd();

//    glFlush();
// }

void drawCircle(point p, double radius, color c)
{
    int i;
    int triangleCount = 20;

    
    glBegin(GL_TRIANGLE_FAN);
        glColor3b(c.red, c.green, c.blue);
        glVertex2f(p.x, p.y);
        for (int i = 0; i <= triangleCount; i++) {
            glVertex2f(
                p.x + (radius * cos(i * 2.0*M_PI / triangleCount)),
                p.y + (radius * sin(i * 2.0*M_PI / triangleCount))
            );
        }
    glEnd();
    glFlush();
}

void drawRectangle(point p1, point p2, color c)
{
    glColor3b(c.red, c.green, c.blue);
    glRectd(p1.x, p1.y, p2.x, p2.y);
}

void drawTriangle(point p1, point p2, point p3, color c)
{
    glColor3b(c.red, c.green, c.blue);
    glBegin(GL_TRIANGLES);
            glVertex3f(p1.x, p1.y, 0);
            glVertex3f(p2.x, p2.y, 0);
            glVertex3f(p3.x, p3.y, 0);
    glEnd();
}

void drawLine(point p1, point p2, double lineWidth, color c)
{
   glColor3b(c.red, c.green, c.blue);
   glLineWidth(lineWidth);
   glBegin(GL_LINES);
       glVertex3f(p1.x, p1.y, 0);
       glVertex3f(p2.x, p2.y, 0);
   glEnd();
}





void drawSun(point p)
{
    color yellow = {127, 127, 0};
    drawCircle(p, CIRCLE_RAD, yellow);
    int numLines = 7;

    for (int i = 0; i < numLines; i++)
    {
        double angle = (2.0*M_PI*i) / numLines;
        double x1 = p.x + ((CIRCLE_RAD + 0.05) * cos(angle));
        double y1 = p.y + ((CIRCLE_RAD + 0.05) * sin(angle));
        point p1 = {x1, y1};

        double x2 = p.x + ((CIRCLE_RAD + 0.2) * cos(angle));
        double y2 = p.y + ((CIRCLE_RAD + 0.2) * sin(angle));
        point p2 = {x2, y2};
        drawLine(p1, p2, 3, yellow);
    }
}



void drawPerson(point location)
{
    double headRadius = 0.07;
    point head = {location.x - headRadius, location.y - headRadius};
    color black = {0,0,0};
    drawCircle(head, headRadius, black);

    point bodyTop = {head.x, head.y - headRadius};
    double bodyLength = 0.2;
    point bodyBottom = {head.x, head.y - headRadius - bodyLength};

    drawLine(bodyTop, bodyBottom, 3, black);

    point armsStart = {bodyTop.x, bodyTop.y - 0.05};
    double armsEndHeight = armsStart.y - 0.05;
    point leftArm = {armsStart.x - 0.08, armsEndHeight};
    point rightArm = {armsStart.x + 0.08, armsEndHeight};

    drawLine(armsStart, leftArm, 3, black);
    drawLine(armsStart, rightArm, 3, black);

    point legsStart = {bodyTop.x, bodyBottom.y};
    double legsEndHeight = legsStart.y - 0.12;
    point leftLeg = {legsStart.x - 0.1, legsEndHeight};
    point rightLeg = {legsStart.x + 0.1, legsEndHeight};

    drawLine(legsStart, leftLeg, 3, black);
    drawLine(legsStart, rightLeg, 3, black);
}

void drawHouse(point bottomLeft, point bottomRight, double height, color houseColor)
{
    double mainHeight = 0.6 * height;
    double roofHeight = height - mainHeight;

    point mainTopLeft = {bottomLeft.x, bottomLeft.y + mainHeight};
    point mainTopRight = {bottomRight.x, bottomRight.y + mainHeight};
   
    point topRoof = {(bottomLeft.x + bottomRight.x) / 2.0, roofHeight + mainTopLeft.y};
    
    
    // glColor3b(houseColor.red, houseColor.green, houseColor.blue);
    // double lineWidth = 0.012;
    // glLineWidth(100);
    // glBegin(GL_LINES);
    //     glVertex2f(bottomLeft.x - lineWidth, bottomLeft.y);
    //     glVertex2f(bottomRight.x + lineWidth + 0.001, bottomRight.y);

    //     glVertex2f(bottomRight.x, bottomRight.y);
    //     glVertex2f(mainTopRight.x, mainTopRight.y);

    //     // glVertex2f(mainTopRight.x + lineWidth + 0.001, mainTopRight.y);
    //     // glVertex2f(mainTopLeft.x - lineWidth - 0.001, mainTopLeft.y);

    //     glVertex2f(mainTopLeft.x, mainTopLeft.y);
    //     glVertex2f(bottomLeft.x, bottomLeft.y);
    // glEnd();

    drawRectangle(bottomLeft, mainTopRight, houseColor);

    double roofOverShoot = 0.1;
    mainTopLeft.x -= roofOverShoot;
    mainTopRight.x += roofOverShoot;

    // mainTopLeft.y -= roofOverShoot;
    // mainTopRight.y -= roofOverShoot;


    drawTriangle(mainTopLeft, mainTopRight, topRoof, houseColor);
    
}

void draw()
{
    glClearColor(0.45, 0.65, 0.91, 0.4);            // draw the background color
    glClear(GL_COLOR_BUFFER_BIT);

    point grassTopLeft = {-1, -0.3};
    point grassBottomRight = {1, -1};
    color green = {20,120,25};
    drawRectangle(grassTopLeft, grassBottomRight, green);       // draw the grass

    point sunCenter = {-0.65, 0.65};
    drawSun(sunCenter);

    point personLocation = {-0.2, -0.4};
    drawPerson(personLocation);

    point houseBottomLeft = {0.2, -0.4};
    point houseBottomRight = {0.8, -0.4};
    double houseHeight = 0.7;
    color black = {0,0,0};
    drawHouse(houseBottomLeft, houseBottomRight, houseHeight, black);

    glFlush();
}

int main(int argc, char **argv)
{
   glutInit(&argc, argv);
   glutInitDisplayMode(GLUT_SINGLE);
   glutInitWindowSize(750, 750);
   glutInitWindowPosition(100, 100);
   glutCreateWindow("OpenGL - Creating a triangle");
   glutDisplayFunc(draw);
   glutMainLoop();
   return 0;
}

