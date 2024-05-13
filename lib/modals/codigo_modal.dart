import 'package:flutter/material.dart';

class NuevoCodigoDialog extends StatefulWidget {
  @override
  _NuevoCodigoDialogState createState() => _NuevoCodigoDialogState();
}

class _NuevoCodigoDialogState extends State<NuevoCodigoDialog> {
  TextEditingController codigoController = TextEditingController();
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Nuevo Código'),
      content: TextField(
        controller: codigoController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Código',
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
            String codigo = codigoController.text;
            int codigoInt = int.tryParse(codigo) ?? 0;
            bool contieneCero = false;
            bool contieneUno = false;

            for (int i = 0; i < codigo.length; i++) {
              if (codigo[i] != '0' && codigo[i] != '1') {
                codigoInt = -1;
                break;
              }
              if (codigo[i] == '0') {
                contieneCero = true;
              } else if (codigo[i] == '1') {
                contieneUno = true;
              }
              if (contieneCero && contieneUno) {
                break;
              }
            }
            if (codigoInt == -1 || !contieneCero || !contieneUno) {
              setState(() {
                errorMessage = 'El código debe contener solo 0 y 1 y al menos un 0 y un 1';
              });
            } else {
              Navigator.of(context).pop(codigo);
            }

          },
          child: Text('Aceptar'),
        ),
      ],
    );
  }

}
