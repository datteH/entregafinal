import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class TiendaPage extends StatelessWidget {
  final String tienda;
  final String imagen;
  final String descripcion;
  final String pagina;
  final String telefono;
  final String ubicacion;
  final int estrellas;
  final String categoriaId;

  const TiendaPage({
    required this.tienda,
    required this.imagen,
    required this.descripcion,
    required this.pagina,
    required this.telefono,
    required this.ubicacion,
    required this.estrellas,
    required this.categoriaId,
  });

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir la URL: $url';
    }
  }

  void _openLocationInMaps(String location) async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$location';
    await launch(googleMapsUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tienda),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              child: Image.asset(
                'assets/images/$imagen',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 16),
            Text(
              tienda,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                estrellas,
                (index) => GestureDetector(
                  onTap: () {
                    _showRatingModal(context, categoriaId);
                  },
                  child: Icon(
                    Icons.star,
                    color: Colors.yellow,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  descripcion,
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('valorar')
                  .where('tienda', isEqualTo: categoriaId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                final valoraciones = snapshot.data!.docs;
                return Column(
                  children: valoraciones.map((valoracion) {
                    final comentario = valoracion['comentario'];
                    final estrellas = valoracion['estrellas'];
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: valoraciones.length,
                      itemBuilder: (context, index) {
                        final comentario = valoraciones[index]['comentario'];
                        final estrellas = valoraciones[index]['estrellas'];
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Comentario: $comentario',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  estrellas,
                                  (index) => Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.language),
            label: 'Página',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone),
            label: 'Teléfono',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Ubicación',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              _launchURL(pagina);
              break;
            case 1:
              _launchURL('tel:$telefono');
              break;
            case 2:
              _openLocationInMaps(ubicacion);
              break;
          }
        },
      ),
    );
  }
}

void _showRatingModal(BuildContext context, String idTienda) {
  showDialog(
    context: context,
    builder: (context) {
      String comentario = '';
      int estrellas = 0;

      return AlertDialog(
        title: Text('Valorar tienda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                comentario = value;
              },
              decoration: InputDecoration(
                labelText: 'Comentario',
              ),
            ),
            SizedBox(height: 16),
            RatingBar.builder(
              initialRating: estrellas.toDouble(),
              minRating: 0,
              maxRating: 5,
              itemCount: 5,
              itemSize: 30,
              itemBuilder: (context, index) {
                return Icon(
                  Icons.star,
                  color: Colors.amber,
                );
              },
              onRatingUpdate: (rating) {
                estrellas = rating.toInt();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              _guardarValoracion(comentario, estrellas, idTienda);
              Navigator.pop(context);
            },
            child: Text('Enviar'),
          ),
        ],
      );
    },
  );
}

void _guardarValoracion(String comentario, int estrellas, String idTienda) {
  String idUsuario = 'id_usuario_logueado';
  FirebaseFirestore.instance.collection('valorar').add({
    'comentario': comentario,
    'estrellas': estrellas,
    'tienda': idTienda,
    'usuario': idUsuario,
  }).then((DocumentReference document) {
    String idValoracion = document.id;
    print('ID del documento de la valoración: $idValoracion');
  });
}
