import 'dart:math';

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

import 'AristaCurve.dart';
import 'formas.dart';
import 'modals/codigo_modal.dart';
import 'modals/weight_modal.dart';
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
  String ?codigo;


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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              botonIcono(1, Icons.add,'Agregar Nodo'),
              botonIcono(2, Icons.delete,'Borrar Nodo'),
              botonIcono(3, Icons.moving,'Mover Nodo'),
              botonIcono(4, Icons.arrow_right_alt_sharp,'Conectar Nodo'),
              botonIcono(5, Icons.dangerous,'Borrar Todo'),
              botonIcono(6, Icons.new_label,'Nuevo Codigo'),
              botonIcono(7, Icons.verified,'Verificar ejercicio'),

            ],
          ),
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
        mostrarDialogoPeso();

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
  Widget botonIcono(int mode, IconData icon,String mensaje) {
    return IconButton(
      onPressed: () {
        setState(() {
          modo = mode;
          if(modo==5){
            deleteAll();
          }
          if(mode==6){
            confirmation();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$mensaje'),
              duration: Duration(milliseconds: 500)
            ),
          );

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

  Future<void> mostrarDialogoPeso() async {
    int? peso = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return PesoDialog();
      },
    );
    if (peso != null) {
      aristascurve.add(ModeloAristaCurve(vNodo[origentempcurve], vNodo[destempcurve], peso));
      origentempcurve = -1;
      destempcurve = -1;
      // Cerrar el diálogo
      setState(() {});
    }
  }

  //Nuevo codigo
  void confirmation() {
    if (vNodo.isNotEmpty) {
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
    String? codigoIngresado = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return NuevoCodigoDialog();
      },
    );
    if (codigoIngresado != null) {
      setState(() {
        codigo=codigoIngresado;
        List<ModeloNodo> vNodoResuelto = [];
        List<ModeloAristaCurve> aristasResuelto = [];
        //crear nodos
        for(int i=0; i<codigoIngresado.length+1;i++){
          vNodoResuelto.add(ModeloNodo('$i', 100.0 + i*100, 500.0, 40, Colors.amber.shade900));
        }

        //101
        int c=0;
        for(c=0; c<codigoIngresado.length;c++){
          //conectar los nodos pero con los digitos del codigo
          aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[c], vNodoResuelto[c+1], int.parse(codigoIngresado[c])));

        }

        //imprimirMatrizAdyacencia(vNodoResuelto, aristasResuelto);

        //toma en cuenta que el peso es el contrario al primer digito del codigo
        int i=0;
        while(i<vNodoResuelto.length){
          int peso=1;
          // bucar en las aristas la conexion del nodo actual con el siguiente y guardar el peso en una variable
         // int peso = aristasResuelto.firstWhere((element) => element.origen.etiqueta == vNodoResuelto[i].etiqueta && element.destino.etiqueta == vNodoResuelto[(i+1)%vNodoResuelto.length].etiqueta).weight;
          var aristaEncontrada = aristasResuelto.firstWhereOrNull((element) => element.origen.etiqueta == vNodoResuelto[i].etiqueta && element.destino.etiqueta == vNodoResuelto[(i+1)%vNodoResuelto.length].etiqueta);
          if (aristaEncontrada != null) {
            peso = aristaEncontrada.weight;
          }
          // print('Peso: $peso');
          //guardar el peso contrario en una variable
          int pesoContrario = peso==0?1:0;
          //print('Peso contrario: $pesoContrario');
          String codTemp = pesoContrario.toString();

          //concatenar los pesos de los nodos restantes
          for(int j=i;j<vNodoResuelto.length-1;j++){
            //buscar en las aristas la conexion del nodo actual con el siguiente y guardar el peso en una variable
            int pesoSig = aristasResuelto.firstWhere((element) => element.origen.etiqueta == vNodoResuelto[j].etiqueta && element.destino.etiqueta == vNodoResuelto[(j+1)%vNodoResuelto.length].etiqueta).weight;
            codTemp += pesoSig.toString();

          }
          if(verificarSecuencia(codigoIngresado, codTemp)){
            print('codigo enviado: ${codigoIngresado}  cadena: ${codTemp} ');
             aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[i], vNodoResuelto[i], int.parse(pesoContrario.toString())));
          }

          i++;

        }


        aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[c], vNodoResuelto[0], codigo?[0]=='0'?1:0));
        //conectar el ultimo nodo con el segundo nodo

        aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[c], vNodoResuelto[1], codigo?[1]=='0'?1:0));

        imprimirMatrizAdyacencia(vNodoResuelto, aristasResuelto);


      });
    }
  }

  bool verificarSecuencia(String codigo, String cadena) {
    int index = cadena.indexOf(codigo);
    return index != -1;
  }

  void imprimirMatrizAdyacencia(List<ModeloNodo> nodos, List<ModeloAristaCurve> aristas) {
    int n = nodos.length;

    // Crear matriz de adyacencia
    List<List<int>> matriz = List.generate(n, (_) => List.filled(n, -1));

    // Llenar la matriz con los pesos de las aristas
    for (var arista in aristas) {
      int origen = nodos.indexOf(arista.origen);
      int destino = nodos.indexOf(arista.destino);
      matriz[origen][destino] = arista.weight;
    }

    // Imprimir la matriz
    print("Matriz de Adyacencia:");
    for (int i = 0; i < n; i++) {
      print(matriz[i]);
    }
  }









}
