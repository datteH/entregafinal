import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/pages/tienda_page.dart';

class RestaurantesPage extends StatefulWidget {
  final String categoriaId;

  RestaurantesPage({required this.categoriaId});

  @override
  _RestaurantesPageState createState() => _RestaurantesPageState();
}

class _RestaurantesPageState extends State<RestaurantesPage> {
  late Stream<QuerySnapshot> _restaurantesStream;

  @override
  void initState() {
    super.initState();
    _restaurantesStream = FirebaseFirestore.instance
        .collection('restaurantes')
        .where('categoria', isEqualTo: widget.categoriaId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurantes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _restaurantesStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final restaurantes = snapshot.data!.docs;
            final categorias = snapshot.data!.docs;
            restaurantes.sort((a, b) => a['tienda'].compareTo(b['tienda']));

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
              ),
              itemCount: restaurantes.length,
              itemBuilder: (context, index) {
                final restaurante = restaurantes[index];
                final tienda = restaurante['tienda'];
                final estrellas = restaurante['estrellas'];
                final imagen = restaurante['imagen'];
                final descripcion = restaurante['descripcion'];
                final pagina = restaurante['pagina'];
                final telefono = restaurante['telefono'];
                final ubicacion = restaurante['ubicacion'];
                final id = categorias[index].id;
                return RestaurantCard(
                  tienda: tienda,
                  estrellas: estrellas,
                  imagen: imagen,
                  descripcion: descripcion,
                  pagina: pagina,
                  telefono: telefono,
                  ubicacion: ubicacion,
                  id: id,
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error al cargar los datos');
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String tienda;
  final int estrellas;
  final String imagen;
  final String descripcion;
  final String pagina;
  final String telefono;
  final String ubicacion;
  final String id;

  const RestaurantCard(
      {required this.tienda,
      required this.estrellas,
      required this.imagen,
      required this.descripcion,
      required this.pagina,
      required this.telefono,
      required this.ubicacion,
      required this.id});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TiendaPage(
                tienda: tienda,
                estrellas: estrellas,
                imagen: imagen,
                descripcion: descripcion,
                pagina: pagina,
                telefono: telefono,
                ubicacion: ubicacion,
                categoriaId: id),
          ),
        );
      },
      child: Card(
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                'assets/images/$imagen',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    tienda,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Estrellas: $estrellas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String id;
  final String titulo;
  final String imagen;

  const CategoryCard({
    required this.id,
    required this.titulo,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantesPage(categoriaId: id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage('assets/images/$imagen'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Center(
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
