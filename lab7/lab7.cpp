
#include <GL/glut.h>
#include <unistd.h>
#include <cmath>
#include <vector>
#include <array>
#include <cstdlib>



#define WINDOW_X 750
#define WINDOW_Y 750


struct vertex {
    double x;
    double y;

    vertex(double x=0, double y=0): x(x), y(y) {}
};

struct color {
    int red;
    int green;
    int blue;

    color(int red, int green, int blue): red(red), green(green), blue(blue) {}
};


class circle {
public:
    double x, y;
    double radius;
    color c;

    circle(double x, double y, double radius, color c): 
        x(x), y(y), radius(radius), c(c) {}

    void draw() {
        int i;
        int triangleCount = 20;

        
        glBegin(GL_TRIANGLE_FAN);
            glColor3b(c.red, c.green, c.blue);
            glVertex2f(x, y);
            for (int i = 0; i <= triangleCount; i++) {
                glVertex2f(
                    x + (radius * cos(i * 2*M_PI / triangleCount)),
                    y + (radius * sin(i * 2*M_PI / triangleCount))
                );
            }
        glEnd();
        glFlush();
    }

    void update(double x, double y) {
        this->x = x;
        this->y = y;
        draw();
    }
};



class triangle {
private:
    std::array<vertex, 3> points;
    color c;

public:
    triangle(vertex v1, vertex v2, vertex v3, color c): c(c) {
        points[0] = v1;
        points[1] = v2;
        points[2] = v3;
    }

    void draw() {
        glColor3b(c.red, c.blue, c.green);
        glBegin(GL_TRIANGLES);
            for (vertex p: points) {
                glVertex3f(p.x, p.y, 0);
            }
        glEnd();
        glFlush();
    }
};

class mountain {
private:
    std::vector<triangle> triangles;
    double length = 0.8;


public:
    mountain() {
        for (double x = -(1 + 0.6*length); x <= 1 + 0.5*length; x += 0.7*length) {
            triangles.push_back({
                {x,-1},
                {x+length/2, (double)rand() / RAND_MAX*1.5 - 1},
                {x + length, -1},
                {30,30,30}
            });
        }
    }

    void draw() {
       for (triangle t: triangles) {
           t.draw();
       }
    }
};

color yellow(127,127,0);
circle sun(-1.0, 0.0, 0.125, yellow);
mountain mountain_range;
double update_x = 0.005;




void update() {
    double x = sun.x + update_x;
    if (x >= (1 + 2*sun.radius)) x = -(1 + 2*sun.radius);
    
    double y = sqrt(3 - sun.x*sun.x) - 1;
    double red = -0.3*x + 0.4;
    double green = -0.35*x + 0.45;
    double blue = -0.225*x + 0.725;
    printf("%f, %f, %f\n", red, green, blue);
    glClearColor(red, green, blue, 0.6);
    // glClearColor(0.7, 0.8, 0.95, 0.6);
    glClear(GL_COLOR_BUFFER_BIT);
    sun.update(x,y);
    mountain_range.draw();
    usleep(1000 * 1000/30);
}




int main(int argc, char **argv)
{
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_SINGLE);
    glutInitWindowSize(WINDOW_X, WINDOW_Y);
    glutInitWindowPosition(100, 100);
    glutCreateWindow("Lab 7");


    glutIdleFunc(update);
    glutMainLoop();
    return 0;
}