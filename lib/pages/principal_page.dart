import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Restaurantes_Page.dart';
import 'login_page.dart';
import 'dart:async';
import 'tienda_page.dart';

class PrincipalPage extends StatelessWidget {
  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FoodApp'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          RestaurantCarousel(),
          SizedBox(height: 16),
          Text(
            'Categorías',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('categorias').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              final categorias = snapshot.data!.docs;

              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final categoria =
                      categorias[index].data() as Map<String, dynamic>;
                  final titulo = categoria['titulo'] as String;
                  final imagen = categoria['imagen'] as String;
                  final categoriaId = categorias[index].id;
                  return CategoryCard(
                      titulo: titulo, imagen: imagen, id: categoriaId);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class RestaurantCarousel extends StatefulWidget {
  @override
  _RestaurantCarouselState createState() => _RestaurantCarouselState();
}

class _RestaurantCarouselState extends State<RestaurantCarousel> {
  final _pageController = PageController(initialPage: 0);
  final _restaurantCount = 1000000;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentPage < _restaurantCount - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('restaurantes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final restaurants = snapshot.data!.docs;
        final categorias = snapshot.data!.docs;

        return Container(
          height: 100,
          child: PageView.builder(
            scrollDirection: Axis.horizontal,
            controller: _pageController,
            itemCount: _restaurantCount,
            itemBuilder: (context, index) {
              final restaurant = restaurants[index % restaurants.length].data()
                  as Map<String, dynamic>;
              final tienda = restaurant['tienda'] as String;
              final estrellas = restaurant['estrellas'] as int;
              final imagen = restaurant['imagen'] as String;
              final descripcion = restaurant['descripcion'] as String;
              final pagina = restaurant['pagina'] as String;
              final telefono = restaurant['telefono'] as String;
              final ubicacion = restaurant['ubicacion'] as String;
              final id = categorias[index % categorias.length].id;
              return RestaurantCard(
                tienda: tienda,
                imagen: imagen,
                descripcion: descripcion,
                pagina: pagina,
                telefono: telefono,
                ubicacion: ubicacion,
                estrellas: estrellas,
                id: id,
              );
            },
          ),
        );
      },
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String tienda;
  final String imagen;
  final String descripcion;
  final String pagina;
  final String telefono;
  final String ubicacion;
  final int estrellas;
  final String id;

  const RestaurantCard(
      {required this.tienda,
      required this.imagen,
      required this.descripcion,
      required this.pagina,
      required this.telefono,
      required this.ubicacion,
      required this.estrellas,
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
                  imagen: imagen,
                  descripcion: descripcion,
                  pagina: pagina,
                  telefono: telefono,
                  ubicacion: ubicacion,
                  estrellas: estrellas,
                  categoriaId: id)),
        );
      },
      child: Container(
        width: 200,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
          image: DecorationImage(
            image: AssetImage('assets/images/$imagen'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              tienda,
              style: TextStyle(
                  color: Colors.grey[200],
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                estrellas,
                (index) => Icon(
                  Icons.star,
                  color: Colors.yellow,
                ),
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
