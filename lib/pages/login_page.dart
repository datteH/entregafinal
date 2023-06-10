import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registrar_page.dart';
import 'principal_page.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    String usuario = _userController.text;
    String contrasena = _passwordController.text;

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('usuarios')
          .where('usuario', isEqualTo: usuario)
          .where('password', isEqualTo: contrasena)
          .get();

      if (snapshot.size > 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PrincipalPage()),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error de inicio de sesión'),
              content: Text('Credenciales incorrectas.'),
              actions: [
                TextButton(
                  child: Text('Aceptar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 200,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _userController,
            decoration: InputDecoration(
              labelText: 'Usuario',
              prefixIcon: Icon(Icons.person),
            ),
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Entrar'),
            onPressed: () {
              _login(context);
            },
          ),
          TextButton(
            child: Text('Registrarse'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegistrarPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
