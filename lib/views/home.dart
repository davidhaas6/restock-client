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
  List<Product> _productList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      AppContext appContext = Provider.of<AppContext>(context);
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
          if (_productList == null) {
            _productList = snapshot.data;

            // List<bool> _isFollowingList = _productList.map((p) => appContext.isFollowing(p));

            // sort to have followed at top
            sortProducts();
          }
          return ListView.builder(
            itemCount: _productList.length,
            itemBuilder: (context, i) => _buildProductTile(i),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: SpinKitRotatingCircle(color: Colors.white, size: 50.0),
        );
      },
    );
  }

  Widget _buildProductTile(int productIndex) {
    AppContext appContext = Provider.of<AppContext>(context);

    Product product = _productList[productIndex];
    bool isFollowing = appContext.isFollowing(product);

    return Card(
      child: SwitchListTile.adaptive(
        title: Text(
          '${product.name}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        value: isFollowing,
        secondary: SizedBox(
          height: 40,
          child: Image.asset(Product.getIcon(product.type)),
        ),
        onChanged: (bool value) {

          // actually (un)follow the product
          setState(() {
            if (isFollowing)
              appContext.unfollowProduct(product);
            else {
              appContext.followProduct(product);
            }
          });

          final cachedProducts = List.from(_productList);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (cachedProducts == _productList) {
              print("No change to product list between call and execution");
            } else {
              print("Product list changed between tap and execution");
            }
            setState(() {
              sortProducts();
              // updateProductList(productIndex, !isFollowing);
            });
          });
        },
      ),
    );
  }


  void sortProducts() {
    /*
    Sort product list so followed products are at top
    */
    AppContext appContext = Provider.of<AppContext>(context);
    Map<Product, bool> isFollowing = Map.fromIterable(
      _productList,
      key: (p) => p,
      value: (p) => appContext.isFollowing(p),
    );

    // sort true then false
    _productList.sort((a, b) {
      if (!(isFollowing[a] ^ isFollowing[b])) {
        // equal
        return 0;
      }

      // sorts low to high --> a should be less than b if a = true and b = false
      return isFollowing[a] && !isFollowing[b] ? -1 : 1;
    });
  }
}
