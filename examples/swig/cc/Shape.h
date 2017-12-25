#ifndef SHAPE_H
#define SHAPE_H

class Shape {
public:
  virtual ~Shape() {}
  double  x, y;
  void    move(double dx, double dy);
  virtual double area() = 0;
  virtual double perimeter() = 0;
};

#endif /* end of include guard */
