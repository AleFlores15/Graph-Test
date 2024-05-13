import 'package:flutter/material.dart';

class PesoDialog extends StatefulWidget {
  @override
  _PesoDialogState createState() => _PesoDialogState();
}

class _PesoDialogState extends State<PesoDialog> {
  TextEditingController pesoController = TextEditingController();
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ingrese el peso de la arista curva'),
      content: TextField(
        controller: pesoController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            labelText: 'Peso',
            errorText: errorMessage.isNotEmpty ? errorMessage : null,
        ),
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
            if (pesoArista == 0 || pesoArista == 1) {
              Navigator.of(context).pop(pesoArista);
            } else {
              setState(() {
                errorMessage = 'Ingrese números válidos (0 o 1)';
              });
            }
            },
          child: Text('Aceptar'),
        ),
      ],
    );
  }
}
