#include "Circle.h"

double Circle::area() {
  return radius * radius * 3.14159265358979;
}

double Circle::perimeter() {
  return 2.0 * radius * 3.14159265358979;
}
