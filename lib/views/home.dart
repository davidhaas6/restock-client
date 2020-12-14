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

  final List<String> _tabNames = ['All', 'GPUs', 'CPUs', 'Consoles'];
  List _tabMembership = [
    (product) => true,
    (product) => product.type == ProductType.GPU,
    (product) => product.type == ProductType.CPU,
    (product) => product.type == ProductType.Console,
  ]; // membership tests for the contents of each tab

  // List<ProductType>

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
    return DefaultTabController(
      length: _tabNames.length,
      child: Scaffold(
        // backgroundColor: Color.fromRGBO(41, 60, 79, 1),
        body: NestedScrollView(
          headerSliverBuilder: _buildAppBar,
          body: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        _buildContent(),
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
        backgroundColor: Color.fromRGBO(41, 60, 79, 1),
        shadowColor: Color.fromRGBO(41, 60, 79, 1),
        floating: false,
        pinned: true,
        title: Text(
          "Restocker",
          style: TextStyle(color: Colors.white, fontSize: 22.0),
        ),
        flexibleSpace: FlexibleSpaceBar(
          centerTitle: false,
          background: _buildHeaderVisual(),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: Icon(Icons.search, size: 25),
              tooltip: 'Search for products',
              onPressed: () {},
            ),
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.menu, size: 25),
          onPressed: () {},
        ),
        bottom: TabBar(tabs: _tabNames.map((name) => Tab(text: name)).toList()),
      ),
    ];
  }

  Widget _buildHeaderVisual() {
    //TODO: Graphs?
    return Image.network(
      "https://www.nvidia.com/content/dam/en-zz/Solutions/homepage/sfg/geforce-ampere-rtx-30-series-learn-nv-sfg-295x166@2x.jpg",
      fit: BoxFit.cover,
    );
  }

  Widget _buildContent() {
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
          // intialize a new product list
          if (_productList == null) {
            _productList = snapshot.data;
            sortProducts(); // sort to have followed at top
          }

          return _buildProductTabs();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Center(
          child: SpinKitRotatingCircle(color: Colors.white, size: 50.0),
        );
      },
    );
  }

  Widget _buildProductTabs() {
    List<Widget> tabs = List();
    for (int i = 0; i < _tabMembership.length; i++) {
      var belongsInTab = _tabMembership[i];
      List tabProducts =
          _productList.where((product) => belongsInTab(product)).toList();

      var tab = ListView.builder(
        itemCount: tabProducts.length,
        itemBuilder: (context, i) => _buildProductTile(tabProducts[i]),
      );
      tabs.add(tab);
    }

    return TabBarView(children: tabs);
  }

  Widget _buildProductTile(Product product) {
    AppContext appContext = Provider.of<AppContext>(context);

    // Product product = _productList[productIndex];
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
        onChanged: (bool value) async {
          // actually (un)follow the product
          setState(() {
            if (isFollowing)
              appContext.unfollowProduct(product);
            else {
              appContext.followProduct(product);
            }
          });

          // update ordering of product list
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              sortProducts();
            });
          });
        },
      ),
    );
  }

  void sortProducts() {
    /* Sort product list so followed products are at top
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
