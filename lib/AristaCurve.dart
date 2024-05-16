import 'package:examen_maquina_estados/modelos.dart';

class ModeloAristaCurve{
  final ModeloNodo origen;
  final ModeloNodo destino;
  int weight;

  ModeloAristaCurve (this.origen, this.destino, this.weight);
}