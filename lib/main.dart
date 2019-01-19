import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

List _shapes = ["Circle", "Oval", "Square", "Rectangle"];
List _colors = ["blue", "black", "green", "grey", "red", "yellow"];

void main() async {
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  runApp(new MaterialApp(
    title: "Shapes Builder",
    debugShowCheckedModeBanner: false,
    home: new ShapesBuilder(),
  ));
}

class ShapesBuilder extends StatefulWidget {
  @override
  ShapesBuilderState createState() => new ShapesBuilderState();
}

class ShapesBuilderState extends State<ShapesBuilder> {
  List<DropdownMenuItem<String>> _listShapes;
  List<DropdownMenuItem<String>> _listColors;
  String _currentShape;
  String _currentColor;
  double _sizeWidth = 100.0;
  double _sizeHeight = 100.0;
  double _posX = 0.0;
  double _posY = 0.0;
  bool _initialState = true;

  @override
  void initState() {
    _listShapes = _buildShapes();
    _listColors = _buildColors();
    _currentShape = _shapes[0];
    _currentColor = _colors[0];

    super.initState();
  }

  List<DropdownMenuItem<String>> _buildShapes() {
    List<DropdownMenuItem<String>> items = new List();
    for (String shape in _shapes) {
      items.add(new DropdownMenuItem(value: shape, child: new Text(shape)));
    }
    return items;
  }

  List<DropdownMenuItem<String>> _buildColors() {
    List<DropdownMenuItem<String>> items = new List();
    for (String color in _colors) {
      items.add(new DropdownMenuItem(
          value: color,
          child:
              new Text(color, style: new TextStyle(color: _toColor(color)))));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_initialState) {
      _centralizeShape(context);
    }

    return Scaffold(
        appBar: new AppBar(
            elevation: 0.0,
            title: new Text(
              "Shapes Builder",
              style: new TextStyle(
                  color: Colors.white,
                  fontFamily: 'Nunito',
                  letterSpacing: 1.0),
            ),
            backgroundColor: Colors.blue,
            centerTitle: true),
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Text("Shape",
                            style: TextStyle(fontSize: 25.0))),
                    new Container(
                        alignment: Alignment.center,
                        child: new DropdownButton(
                            value: _currentShape,
                            items: _listShapes,
                            onChanged: _buildShape))
                  ],
                )),
            new Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                child: new Row(
                  children: <Widget>[
                    new Expanded(
                        child: new Text("Color",
                            style: TextStyle(fontSize: 25.0))),
                    new Container(
                        child: new DropdownButton(
                            value: _currentColor,
                            items: _listColors,
                            onChanged: _buildColor))
                  ],
                )),
            new Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: _buildPainterContainer())
          ],
        ));
  }

  void _centralizeShape(BuildContext context) {
    setState(() {
      _posX = (MediaQuery.of(context).size.width / 2) - _sizeWidth;
      _posY = (MediaQuery.of(context).size.height / 2) - _sizeHeight - 100;
      _initialState = false;
    });
  }

  Widget _buildShape(String selected) {
    setState(() {
      _currentShape = selected;

      switch (selected) {
        case "Rectangle":
          _sizeWidth = 150.0;
          _sizeHeight = 100.0;
          break;
        case "Oval":
          _sizeWidth = 100.0;
          _sizeHeight = 150.0;
          break;
        default:
          _sizeWidth = 100.0;
          _sizeHeight = 100.0;
      }
    });

    return _buildPainterContainer();
  }

  Widget _buildColor(String selected) {
    setState(() {
      _currentColor = selected;
    });

    return _buildPainterContainer();
  }

  Widget _buildPainterContainer() {
    return new Center(
        child: new Container(
      width: 300.0,
      height: 400.0,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 7.0)),
      child: new Padding(
          padding: EdgeInsets.all(10.0),
          child: new Stack(children: <Widget>[
            new Positioned(
                left: _posX,
                top: _posY,
                child: new Container(
                    width: _sizeWidth,
                    height: _sizeHeight,
                    child: new GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _posY += details.delta.dy;
                            _posX += details.delta.dx;
                          });
                        },
                        child: new CustomPaint(
                          painter: new MyPainter(
                              color: _toColor(_currentColor),
                              shape: _currentShape),
                        ))))
          ])),
    ));
  }

  Color _toColor(String color) {
    switch (color) {
      case "black":
        return Colors.black;
        break;
      case "blue":
        return Colors.blue;
        break;
      case "green":
        return Colors.green;
        break;
      case "grey":
        return Colors.grey;
        break;
      case "red":
        return Colors.red;
        break;
      case "yellow":
        return Colors.yellow;
        break;
    }
    return Colors.black;
  }
}

class MyPainter extends CustomPainter {
  Color color;
  String shape;

  MyPainter({this.color, this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    var shaped = ShapeFactory.create(shape, color, size);
    shaped.draw(canvas);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class ShapeFactory {
  static Shape create(String shape, Color color, Size size) {
    switch (shape) {
      case "Circle":
        return new Circle(color, size.width, size.height);
      case "Oval":
        return new Oval(color, size.width, size.height);
      case "Square":
        return new Square(color, size.width, size.height);
      case "Rectangle":
        return new Rectangle(color, size.width, size.height);
    }
  }
}

abstract class Shape {
  Color _color;
  double _sizeWidth;
  double _sizeHeight;
  TextPainter _textPainter;
  Paint _paint;

  Shape();

  Shape._with(this._color, this._sizeWidth, this._sizeHeight) {
    _paint = new Paint()
      ..color = _color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    TextSpan _span = new TextSpan(text: "drag me");
    _textPainter = new TextPainter(
        text: _span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    _textPainter.layout();
  }

  void draw(Canvas canvas);
}

class Circle extends Shape {
  double _radius;

  Circle(Color color, double sizeWidth, double sizeHeight)
      : super._with(color, sizeWidth, sizeHeight) {
    _radius = 50.0;
  }

  @override
  void draw(Canvas canvas) {
    Offset center = new Offset(_sizeWidth / 2, _sizeHeight / 2);
    canvas.drawCircle(center, _radius, _paint);
    _textPainter.paint(canvas, new Offset(center.dx - 25.0, center.dy - 5.0));
  }
}

class Oval extends Shape {
  Oval(Color color, double sizeWidth, double sizeHeight)
      : super._with(color, sizeWidth, sizeHeight);

  @override
  void draw(Canvas canvas) {
    Offset center = new Offset(_sizeWidth / 2, _sizeHeight / 2);
    canvas.drawOval(
        new Rect.fromLTWH(0.0, 0.0, _sizeWidth, _sizeHeight), _paint);
    _textPainter.paint(canvas, new Offset(center.dx - 25.0, center.dy));
  }
}

class Square extends Shape {
  Square(Color color, double sizeWidth, double sizeHeight)
      : super._with(color, sizeWidth, sizeHeight);

  @override
  void draw(Canvas canvas) {
    canvas.drawRect(
        new Rect.fromPoints(
            new Offset(0, 0), new Offset(_sizeWidth, _sizeHeight)),
        _paint);
    _textPainter.paint(canvas, new Offset(25.0, 40.0));
  }
}

class Rectangle extends Shape {
  Rectangle(Color color, double sizeWidth, double sizeHeight)
      : super._with(color, sizeWidth, sizeHeight);

  @override
  void draw(Canvas canvas) {
    canvas.drawRect(
        new Rect.fromPoints(
            new Offset(0, 0), new Offset(_sizeWidth, _sizeHeight)),
        _paint);
    _textPainter.paint(canvas, new Offset(50.0, 40.0));
  }
}
