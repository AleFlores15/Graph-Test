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

  List<String> letras = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

  int modo =-1;
  List<ModeloNodo> vNodo=[];
  List<ModeloNodo> vNodoResuelto = [];
  List<ModeloAristaCurve> aristasResuelto = [];

  int contador=0;
  List<ModeloAristaCurve> aristascurve=[];
  int origentempcurve=-1;
  int destempcurve=-1;
  String ?codigo;
  //matriz del resultado
  List<List<int>> matrizResuelta=[];

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
              botonIcono(8, Icons.chat_bubble_outline_rounded,'Matriz de adyacencia'),
              //boton de ayuda
              botonIcono(9, Icons.help,'Ayuda'),


            ],
          ),
        ),
      ),


    );
  }

  //agregar nodo
  addNodo(des){
    contador++;
    String etiqueta = letras[(contador - 1) % letras.length];
    //vNodo.add(ModeloNodo('$contador', des.globalPosition.dx, des.globalPosition.dy, 40, Colors.amber.shade900));
    vNodo.add(ModeloNodo(etiqueta, des.globalPosition.dx, des.globalPosition.dy, 40, Colors.amber.shade900));
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

          if(mode==7){
            mostrarResultados();
          }
          if (mode == 8) {
            mostrarMatrizAdyacencia();
          }
          if(mode==9){
            mostrarAyuda();
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
        //crear nodos
        for(int i=0; i<codigoIngresado.length+1;i++){
          String etiqueta = letras[i % letras.length];
          vNodoResuelto.add(ModeloNodo(etiqueta, 100.0 + i*100, 500.0, 40, Colors.amber.shade900));
        }

        //101
        int c=0;
        for(c=0; c<codigoIngresado.length;c++){
          //conectar los nodos pero con los digitos del codigo
          aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[c], vNodoResuelto[c+1], int.parse(codigoIngresado[c])));

        }

        //toma en cuenta que el peso es el contrario al primer digito del codigo
        int i=0;
        int contador=0;
        while(i<vNodoResuelto.length-1){
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
          String pesoCont2= pesoContrario.toString();

          //concatenar los pesos de los nodos restantes
          for(int j=i;j<vNodoResuelto.length-1;j++){
            //print('tamno ${vNodoResuelto.length} ');
            //buscar en las aristas la conexion del nodo actual con el siguiente y guardar el peso en una variable
            int pesoSig = aristasResuelto.firstWhere((element) => element.origen.etiqueta == vNodoResuelto[j].etiqueta && element.destino.etiqueta == vNodoResuelto[(j+1)%vNodoResuelto.length].etiqueta).weight;
            codTemp += pesoSig.toString();

          }
        //  print("cadenas totales ${codTemp} ");
          if(verificarSecuencia(codigoIngresado, codTemp)){
            //print('codigo enviado: ${codigoIngresado}  cadena: ${codTemp} ');
             aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[i], vNodoResuelto[i], int.parse(pesoContrario.toString())));
          }else{
            int contador=i-1;
            //codTemp= pesoContrario.toString();
            int x=i;
            while(x>0){
              codTemp= pesoContrario.toString();

              for(int j=contador;j<vNodoResuelto.length-1;j++){
                int pesoSig = aristasResuelto.firstWhere((element) => element.origen.etiqueta == vNodoResuelto[j].etiqueta && element.destino.etiqueta == vNodoResuelto[(j+1)%vNodoResuelto.length].etiqueta).weight;
                codTemp += pesoSig.toString();
              }

              if(verificarSecuencia(codigoIngresado, codTemp)){
                aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[i], vNodoResuelto[contador], int.parse(pesoContrario.toString())));
                break;
              }
              contador--;
              x--;

            }
          }
          i++;
        }

        int p=1;
        String cad = '';
        while(p>=0){
          cad=cad+p.toString();
          for(int h=1;h<vNodoResuelto.length-1;h++){
            int pesoSig = aristasResuelto.firstWhere((element) => element.origen.etiqueta == vNodoResuelto[h].etiqueta && element.destino.etiqueta == vNodoResuelto[(h+1)%vNodoResuelto.length].etiqueta).weight;
            cad += pesoSig.toString();
          }
          print('cad: $cad');
          if(verificarSecuencia(codigoIngresado, cad)) {
            aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[vNodoResuelto.length-1], vNodoResuelto[1], int.parse(p.toString())));
            //conectar con el resultado contrario de p
            aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[vNodoResuelto.length-1], vNodoResuelto[0], int.parse((p==0)?'1':'0')));
            break;

          }else{
            aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[vNodoResuelto.length-1], vNodoResuelto[1], int.parse((p==0)?'1':'0')));
            aristasResuelto.add(ModeloAristaCurve(vNodoResuelto[vNodoResuelto.length-1], vNodoResuelto[0], int.parse(p.toString())));

          }

          p--;
        }




        //imprimirMatrizAdyacencia(vNodoResuelto, aristasResuelto);
        matrizResuelta=construirMatrizAdyacencia(vNodoResuelto, aristasResuelto);

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



  List<List<int>> construirMatrizAdyacencia(List<ModeloNodo> nodos, List<ModeloAristaCurve> aristas) {
    int n = nodos.length;

    // Crear matriz de adyacencia
    List<List<int>> matriz = List.generate(n, (_) => List.filled(n, -1));

    for (var arista in aristas) {
      int origen = nodos.indexOf(arista.origen);
      int destino = nodos.indexOf(arista.destino);
      matriz[origen][destino] = arista.weight;
    }

    return matriz;
  }


  void mostrarMatrizAdyacencia() {
    List<List<int>> matriz = construirMatrizAdyacencia(vNodo, aristascurve);
    List<String> etiquetas = vNodo.map((nodo) => nodo.etiqueta).toList(); // Obtener etiquetas de los nodos

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Matriz de adyacencia'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Encabezado de las etiquetas de los nodos
                Row(
                  children: [
                    SizedBox(width: 40), // Espacio en blanco para la celda vacía en la esquina superior izquierda
                    for (var etiqueta in etiquetas)
                      Expanded(
                        child: Text(
                          etiqueta,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                // Cuerpo de la matriz de adyacencia
                for (int i = 0; i < matriz.length; i++)
                  Row(
                    children: [
                      // Etiqueta del nodo
                      Expanded(
                        child: Text(
                          etiquetas[i],
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Valores de la matriz de adyacencia
                      for (int j = 0; j < matriz[i].length; j++)
                        Expanded(
                          child: Text(
                            matriz[i][j].toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }





  double calcularPorcentajeCompletitud(List<List<int>> matrizUsuario, List<List<int>> matrizPrograma) {
    int totalElementos = matrizPrograma.length * matrizPrograma.length;
    int elementosCoincidentes = 0;

    for (int i = 0; i < matrizUsuario.length; i++) {
      for (int j = 0; j < matrizUsuario[i].length; j++) {
        if (matrizUsuario[i][j] == matrizPrograma[i][j]) {
          elementosCoincidentes++;
        }
      }
    }

    return (elementosCoincidentes / totalElementos) * 100;
  }



  void mostrarResultados () {
    List<List<int>> matrizPrograma = construirMatrizAdyacencia(vNodoResuelto, aristasResuelto);
    List<List<int>> matrizUsuario = construirMatrizAdyacencia(vNodo, aristascurve);

    double porcentajeCompletitud = calcularPorcentajeCompletitud(matrizUsuario, matrizPrograma);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resultados del ejercicio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Porcentaje completado: ${porcentajeCompletitud.toStringAsFixed(2)}%'),
              (porcentajeCompletitud == 100)
                  ? Text('¡Felicidades! Has completado el ejercicio correctamente.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
                  : Text(' '),
              SizedBox(height: 20),
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Aquí puedes mostrar la matriz de adyacencia como lo hiciste anteriormente
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }


  void mostrarAyuda(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ayuda en el ejercicio'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [


              SizedBox(height: 20),
              SingleChildScrollView(
                child: Column(
                  children: [
                    ElevatedButton(onPressed: (){
                      mostrarAyudaInicial();

                    }, child: Text('Ayuda Inicial')),
                    ElevatedButton(onPressed: (){
                      mostrarAyudaMedia();
                    }, child: Text('Ayuda Media')),
                    ElevatedButton(onPressed: (){
                      mostrarAyudaAvanzada();
                    }, child: Text('Ayuda Avanzada')),
                    ElevatedButton(onPressed: (){
                      mostrarSolucion();
                    }, child: Text('Ver solución')),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );

  }

  void mostrarSolucion(){
    List<List<int>> matriz = construirMatrizAdyacencia(vNodoResuelto, aristasResuelto);
    List<String> etiquetas = vNodoResuelto.map((nodo) => nodo.etiqueta).toList();
    showDialog(

      context: context,

      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Matriz de respuesta'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(width: 40),
                    for (var etiqueta in etiquetas)
                      Expanded(
                        child: Text(
                          etiqueta,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
                // Cuerpo de la matriz de adyacencia
                for (int i = 0; i < matriz.length; i++)
                  Row(
                    children: [
                      // Etiqueta del nodo
                      Expanded(
                        child: Text(
                          etiquetas[i],
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Valores de la matriz de adyacencia
                      for (int j = 0; j < matriz[i].length; j++)
                        Expanded(
                          child: Text(
                            matriz[i][j].toString(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }



  void mostrarAyudaInicial(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ayuda inicial'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Número de nodos requeridos: ${vNodoResuelto.length}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void mostrarAyudaMedia(){
    // Obtener la primera secuencia de conexión entre los nodos
    String primeraSecuencia = obtenerPrimeraSecuencia();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ayuda Media'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Primera secuencia de conexión entre nodos:'),
              Text(primeraSecuencia),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }


  void mostrarAyudaAvanzada(){
    // Obtener las conexiones mal hechas del usuario
    List<String> conexionesIncorrectas = obtenerConexionesIncorrectas();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ayuda Avanzada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Conexiones mal hechas por el usuario:'),
              for (var conexion in conexionesIncorrectas)
                Text(conexion),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  String obtenerPrimeraSecuencia() {
    String secuencia = '';
    for (int i = 0; i < vNodoResuelto.length - 1; i++) {
      secuencia += '${vNodoResuelto[i].etiqueta} -> ${vNodoResuelto[i + 1].etiqueta} = ${aristasResuelto[i].weight}, ';
    }
    return secuencia;
  }

  List<String> obtenerConexionesIncorrectas() {
    List<String> conexionesIncorrectas = [];
    List<List<int>> matrizUsuario = construirMatrizAdyacencia(vNodo, aristascurve);
    List<List<int>> matrizResultado = construirMatrizAdyacencia(vNodoResuelto, aristasResuelto);
    for (int i = 0; i < matrizUsuario.length; i++) {
      for (int j = 0; j < matrizUsuario[i].length; j++) {
        if (matrizUsuario[i][j] != matrizResultado[i][j] && (matrizUsuario[i][j] == 0 || matrizUsuario[i][j] == 1)) {
          String nodoOrigen = vNodo[i].etiqueta;
          String nodoDestino = vNodo[j].etiqueta;
          conexionesIncorrectas.add('Conexión mal hecha: $nodoOrigen -> $nodoDestino');
        }
      }
    }

    return conexionesIncorrectas;
  }






}
