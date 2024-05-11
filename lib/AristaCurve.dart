import 'package:examen_maquina_estados/modelos.dart';

class ModeloAristaCurve{
  final ModeloNodo origen;
  final ModeloNodo destino;
  final int weight;

  ModeloAristaCurve (this.origen, this.destino, this.weight);
}