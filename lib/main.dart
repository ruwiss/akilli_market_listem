import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'view/list/shopping_list_view.dart';
import 'view/archive/archive_view.dart';
import 'view/product/product_search_view.dart';
import 'viewmodel/shopping_list_view_model.dart';
import 'viewmodel/archive_view_model.dart';
import 'viewmodel/product_search_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  Intl.defaultLocale = 'tr_TR';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ShoppingListViewModel()),
        ChangeNotifierProvider(create: (_) => ArchiveViewModel()),
        ChangeNotifierProvider(create: (_) => ProductSearchViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Akıllı Market Listem',
        theme: AppTheme.lightTheme,
        home: const MainNavigator(),
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    // Başlangıçta verileri yükle
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shoppingListViewModel = context.read<ShoppingListViewModel>();
      await shoppingListViewModel.loadItems();

      if (shoppingListViewModel.items.isEmpty && mounted) {
        setState(() {
          _selectedIndex = 0; // Ürün ekleme sayfasına yönlendir
        });
      }

      context.read<ArchiveViewModel>().loadArchivedLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ProductSearchView(),
          ShoppingListView(),
          ArchiveView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Ürün Ekle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            activeIcon: Icon(Icons.list_alt),
            label: 'Listelerim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.archive_outlined),
            activeIcon: Icon(Icons.archive),
            label: 'Arşiv',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
