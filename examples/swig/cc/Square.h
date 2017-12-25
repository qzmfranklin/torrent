#ifndef SQUARE_H
#define SQUARE_H

class Square : public Shape {
private:
  double width;
public:
  Square(double w) : width(w) { };
  virtual double area();
  virtual double perimeter();
};

#endif /* end of include guard */
