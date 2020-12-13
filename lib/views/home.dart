import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:restock_client/controllers/app_context.dart';
import 'package:restock_client/models/product.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _homeScreenText = "Body";
  Future<List> _productsRequest;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var appContext = Provider.of<AppContext>(context);
      setState(() {
        _productsRequest = appContext.pullProducts();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromRGBO(41, 60, 79, 1),
      body: NestedScrollView(
        headerSliverBuilder: _buildAppBar,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildProducts(),
      ],
    );
  }

  List<Widget> _buildAppBar(BuildContext context, bool innerBoxIsScrolled) {
    // TODO: https://material.io/components/app-bars-top#anatomy
    final screenHeight = MediaQuery.of(context).size.height;
    return [
      SliverAppBar(
          expandedHeight: screenHeight * 0.35,
          elevation: 2,
          floating: false,
          pinned: true,
          title: Text("Restocker",
              style: TextStyle(color: Colors.white, fontSize: 24.0)),
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: false,
            background: _buildHeaderVisual(),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Icon(Icons.search, size: 40),
                tooltip: 'Search for products',
                onPressed: () {},
              ),
            ),
          ],
          leading: IconButton(
            icon: Icon(Icons.menu, size: 25),
            onPressed: () {},
          )),
    ];
  }

  Widget _buildHeaderVisual() {
    //TODO: Graphs?
    return Image.network(
      "https://www.nvidia.com/content/dam/en-zz/Solutions/homepage/sfg/geforce-ampere-rtx-30-series-learn-nv-sfg-295x166@2x.jpg",
      fit: BoxFit.cover,
    );
  }

  Widget _buildProducts() {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _productsRequest,
      builder: (context, AsyncSnapshot<List> snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(
            child: Icon(Icons.error, color: Colors.red, size: 50),
          );
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done ||
            snapshot.hasData) {
          List<Product> products = snapshot.data;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, i) => _buildProductTile(products[i]),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: SpinKitRotatingCircle(color: Colors.white, size: 50.0),
        );
      },
    );
  }

  Widget _buildProductTile(Product product) {
    return Card(
      child: SwitchListTile.adaptive(
        title: Text(
          '${product.name}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        value: true,
        secondary: SizedBox(
          height: 40,
          child: Image.asset(Product.getIcon(product.type)),
        ),
        onChanged: (bool value) {
          setState(() {
            // _lights = value;
          });
        },
      ),
    );
  }
}
