import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AristaCurve.dart';
import 'modelos.dart';

class Nodo extends CustomPainter{
  List<ModeloNodo> vNodo;
  List<ModeloAristaCurve> aristascurve;


  Nodo(this.vNodo, this.aristascurve);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.fill;

    vNodo.forEach((element) {
      paint.color = element.color;
      canvas.drawCircle(Offset(element.x,element.y), element.radio, paint);

      //etiqueta del nodo
      TextSpan span = TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 30),
        text: element.etiqueta,
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(element.x - tp.width / 2, element.y - tp.height / 2));
    });





    //para las aristas curveadas
    aristascurve.forEach((element) {
      paint.color = Colors.black;
      paint.strokeWidth = 3; // Establece el ancho de línea
      paint.style = PaintingStyle.stroke; // Configura el estilo de pintura como stroke para que solo se dibuje el contorno

      // Calcular punto de conexión en el borde del nodo origen
      double angleOrigin = atan2(
        element.destino.y - element.origen.y,
        element.destino.x - element.origen.x,
      );
      double originX = element.origen.x + element.origen.radio * cos(angleOrigin);
      double originY = element.origen.y + element.origen.radio * sin(angleOrigin);

      // Calcular punto de conexión en el borde del nodo destino
      double angleDest = atan2(
        element.origen.y - element.destino.y,
        element.origen.x - element.destino.x,
      );
      double destX = element.destino.x + element.destino.radio * cos(angleDest);
      double destY = element.destino.y + element.destino.radio * sin(angleDest);

      // Calcular un punto de control para la curva
      double controlX = (originX + destX) / 2 + (element.destino.y - element.origen.y) / 4;
      double controlY = (originY + destY) / 2 - (element.destino.x - element.origen.x) / 4;

      // Calcular puntos intermedios para la curva
      List<Offset> controlPoints = [];
      for (double t = 0; t <= 1; t += 0.1) {
        double x = (1 - t) * (1 - t) * originX + 2 * (1 - t) * t * controlX + t * t * destX;
        double y = (1 - t) * (1 - t) * originY + 2 * (1 - t) * t * controlY + t * t * destY;
        controlPoints.add(Offset(x, y));
      }

      // Calcular el último punto en la curva (más cercano al nodo de destino)
      Offset lastPoint = controlPoints.last;

      // Calcular la dirección de la flecha desde el último punto en la curva hacia el nodo de destino
      double arrowAngle = atan2(destY - lastPoint.dy, destX - lastPoint.dx);

      // Calcular la posición de la flecha
      double arrowEndX = lastPoint.dx;
      double arrowEndY = lastPoint.dy;

      // Calcular los puntos que forman el triángulo de la flecha
      double arrowBaseLength = 8; // Longitud de la base del triángulo de la flecha
      double arrowAngle1 = arrowAngle + pi / 8; // Ángulo de una de las líneas que forman el triángulo
      double arrowAngle2 = arrowAngle - pi / 8; // Ángulo de la otra línea que forman el triángulo
      double arrowTipX1 = arrowEndX - arrowBaseLength * cos(arrowAngle1);
      double arrowTipY1 = arrowEndY - arrowBaseLength * sin(arrowAngle1);
      double arrowTipX2 = arrowEndX - arrowBaseLength * cos(arrowAngle2);
      double arrowTipY2 = arrowEndY - arrowBaseLength * sin(arrowAngle2);

      // Dibujar curva
      Path path = Path();
      path.moveTo(originX, originY);
      controlPoints.forEach((point) {
        path.lineTo(point.dx, point.dy);
      });
      path.lineTo(destX, destY);

      // Dibujar flecha
      Path arrowPath = Path();
      arrowPath.moveTo(arrowEndX, arrowEndY);
      arrowPath.lineTo(arrowTipX1, arrowTipY1);
      arrowPath.lineTo(arrowTipX2, arrowTipY2);
      arrowPath.close();
      canvas.drawPath(arrowPath, paint);

      // Dibujar la arista
      canvas.drawPath(path, paint);

      // Dibujar peso de la arista
      TextSpan span = TextSpan(
        style: TextStyle(color: Colors.black, fontSize: 25),
        text: element.weight.toString(),
      );
      TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();

      // Calcular un punto intermedio a lo largo de la curva para dibujar el peso
      Offset midpoint = controlPoints[controlPoints.length ~/ 2]; // Punto medio de la curva
      double labelX = midpoint.dx - tp.width / 2-9;
      double labelY = midpoint.dy - tp.height / 2-9;

      tp.paint(canvas, Offset(labelX, labelY));
    });

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;

  }

}