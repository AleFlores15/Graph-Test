import 'package:flutter/material.dart';

class CambiarPesoDialog extends StatefulWidget {
  final int pesoActual;

  const CambiarPesoDialog({Key? key, required this.pesoActual}) : super(key: key);

  @override
  _CambiarPesoDialogState createState() => _CambiarPesoDialogState();
}

class _CambiarPesoDialogState extends State<CambiarPesoDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.pesoActual.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cambiar Peso de la Arista'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Nuevo Peso'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un valor';
                  }
                  if (value != '0' && value != '1') {
                    return 'Por favor ingrese solo 0 o 1';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              int nuevoPeso = int.tryParse(_controller.text) ?? widget.pesoActual;
              Navigator.of(context).pop(nuevoPeso);
            }
          },
          child: Text('Aceptar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
