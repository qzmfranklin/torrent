#ifndef SHAPE_H
#define SHAPE_H

/* File : example.h */

class Shape {
public:
  virtual ~Shape() {}
  virtual double area() const = 0;
  virtual double perimeter() const = 0;
};

class Circle : public Shape {
public:
  Circle(double r) : radius(r) {};
  virtual ~Circle() {};
  virtual double area() const override;
  virtual double perimeter() const override;
private:
  double radius;
};

class Square : public Shape {
public:
  Square(double w) : width(w) {};
  virtual ~Square() {};
  virtual double area() const override;
  virtual double perimeter() const override;
private:
  double width;
};

#endif /* end of include guard */
