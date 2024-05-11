import 'dart:math';

import 'package:flutter/material.dart';

import 'AristaCurve.dart';
import 'formas.dart';
import 'modelos.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int modo =-1;
  List<ModeloNodo> vNodo=[];
  int contador=0;
  List<ModeloAristaCurve> aristascurve=[];
  int origentempcurve=-1;
  int destempcurve=-1;
  int ?codigo;


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 40.0, left: 10), // Espacio superior para el título
            child: Text(
              (codigo != null)? 'Código: ${codigo}': 'Código: ',
              style: TextStyle(
                fontSize: 35.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          CustomPaint(
            painter: Nodo(vNodo,aristascurve),
          ),
          GestureDetector(
            onPanDown: (des){
              setState(() {
                switch(modo){
                  case 1: addNodo(des);break;
                  case 2: deleteNodo(des);break;
                  //case 3 es el onpanUpdate
                  case 4: connectNodo(des);break;


                }

              });
            },
            //mover los nodos
            onPanUpdate: (des){
              setState(() {
                if(modo==3){
                  int pos = estaSobreElNodo(des.globalPosition.dx, des.globalPosition.dy);
                  if(pos>=0){
                    vNodo[pos].x= des.globalPosition.dx;
                    vNodo[pos].y= des.globalPosition.dy;
                  }
                }
              });

            },

          )


        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.amber.shade200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            botonIcono(1, Icons.add),
            botonIcono(2, Icons.delete),
            botonIcono(3, Icons.moving),
            botonIcono(4, Icons.arrow_right_alt_sharp),
            botonIcono(5, Icons.dangerous),
            botonIcono(6, Icons.new_label),
          //  botonIcono(7, Icons.verified)

          ],
        ),


      ),

    );
  }

  //agregar nodo
  addNodo(des){
    contador++;
    vNodo.add(ModeloNodo('$contador', des.globalPosition.dx, des.globalPosition.dy, 40, Colors.amber.shade900));
  }

  //borrar nodo
  deleteNodo(des){
    int pos = estaSobreElNodo(des.globalPosition.dx, des.globalPosition.dy);
    for(int i=0;i<aristascurve.length;i++){
      if(aristascurve[i].origen.etiqueta == vNodo[pos].etiqueta || aristascurve[i].destino.etiqueta == vNodo[pos].etiqueta){
        aristascurve.removeAt(i);
        i--;
      }
    }
    vNodo.removeAt(pos);
  }

  //conectar Nodo
  connectNodo(des){
    int pos = estaSobreElNodo(des.globalPosition.dx, des.globalPosition.dy);
    if(pos>=0){
      if(origentempcurve==-1){
        origentempcurve=pos;
      }else{
        destempcurve=pos;
        mostrarDialogoPesoCurve();

      }
    }
  }

  //limpiar pantalla
  deleteAll(){
    vNodo.clear();
    aristascurve.clear();
  }

  // verificar si esta sobre el nodo
  int estaSobreElNodo(double xb, double yb){
    int pos=-1,i;
    for(i=0;i< vNodo.length;i++){
      //formula distancia
      double distancia = sqrt(pow(xb-vNodo[i].x,2)  + pow (yb-vNodo[i].y,2));
      if(distancia<= vNodo[i].radio){
        pos=i;
      }
    }
    return pos;
  }

  // widget Icon Button
  Widget botonIcono(int mode, IconData icon) {
    return IconButton(
      onPressed: () {
        setState(() {
          modo = mode;
          if(modo==5){
            deleteAll();
          }
          if(mode==6){
            nuevoLabel();
          }

        });
      },
      icon: CircleAvatar(
        backgroundColor: (modo == mode) ? Colors.green.shade200 : Colors.red
            .shade200,
        child: Icon(
          icon,
          color: (modo == mode) ? Colors.green.shade900 : Colors.red.shade500,
        ),
      ),
    );
  }



  //Dialog para los pesos
  Future<void> mostrarDialogoPesoCurve() async {
    TextEditingController pesoController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingrese el peso de la arista curva'),
          content: TextField(
            controller: pesoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Peso'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                String peso = pesoController.text;
                int pesoArista = int.tryParse(peso) ?? 1;
                // Agregar la arista curva con el peso especificado
                aristascurve.add(ModeloAristaCurve(vNodo[origentempcurve], vNodo[destempcurve], pesoArista));
                // Limpiar los temporales
                origentempcurve = -1;
                destempcurve = -1;
                // Cerrar el diálogo
                Navigator.of(context).pop();
                setState(() {});
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  //Nuevo codigo
  void nuevoLabel() {
    if (vNodo.isNotEmpty) {
      // Si hay nodos en la lista, mostrar un diálogo de confirmación
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmación'),
            content: Text('¿Estás seguro de que deseas continuar? Se perderá tu progreso actual.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  deleteAll();

                  Navigator.of(context).pop();
                  //limpiar la pantalla
                  // Mostrar el diálogo para ingresar el nuevo código
                  mostrarDialogoNuevoCodigo();
                },
                child: Text('Continuar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
    } else {
      // Si no hay nodos en la lista, mostrar directamente el diálogo para ingresar el nuevo código
      mostrarDialogoNuevoCodigo();
    }
  }

// Método para mostrar el diálogo para ingresar el nuevo código
  Future<void> mostrarDialogoNuevoCodigo() async {
    TextEditingController codigoController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nuevo Código'),
          content: TextField(
            controller: codigoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Código'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                String codigo = codigoController.text;
                setState(() {
                  this.codigo = int.tryParse(codigo);
                });
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }



}
