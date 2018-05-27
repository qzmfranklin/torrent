#include "Shape.h"

double Circle::area() const {
  return radius * radius * 3.14159265358979;
}

double Circle::perimeter() const {
  return 2.0 * radius * 3.14159265358979;
}

double Square::area() const {
  return width * width;
}

double Square::perimeter() const {
  return width * 4.0;
}
