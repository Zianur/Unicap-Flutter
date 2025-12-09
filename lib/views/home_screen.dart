import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:provider/provider.dart';
import 'package:unicap_cg/controllers/auth_controller.dart';
import 'package:unicap_cg/controllers/diary_controller.dart';
import 'package:unicap_cg/helper/network_info.dart';
import 'package:unicap_cg/views/caption_category_screen.dart';
import 'package:unicap_cg/views/fav_caption_screen.dart';
import '../controllers/caption_category_controller.dart';
import 'diary_list_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String userId = 'guest';
  DateTime? _currentBackPressTime;

  @override
  void initState() {
    super.initState();

    NetworkInfo.checkConnectivity(context);

    _tabController = TabController(length: 4, vsync: this);

    loadData();

    // Get userId first, then fetch notes
    // Future.delayed(Duration.zero, () async {
    //   await loadData();
    // });

    _checkVersion();
  }

  Future<void> loadData() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    /// Getting user object from firebase
    authController.getCurrentUser();
    userId = authController.user?.uid ?? 'guest';

    await Provider.of<DiaryController>(context, listen: false).fetchAndSaveNotes(userId);
    await Provider.of<CaptionCategoryController>(context, listen: false).loadCategories();
  }

  Future<void> _checkVersion() async {
    final newVersion = NewVersionPlus(
      // iOSId: 'com.example.yourapp',
      androidId: 'com.omniacaptionsandnotes',
    );

    final status = await newVersion.getVersionStatus();

    if (status != null && status.canUpdate) {
      newVersion.showUpdateDialog(
        context: context,
        versionStatus: status,
        dialogTitle: 'Update Available',
        dialogText: 'A new version of the app is available! Please update to enjoy the latest features.',
        updateButtonText: 'Update Now',
        dismissButtonText: 'Later',
        dismissAction: () {
          Navigator.pop(context);
        },
      );
    }
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }



  Future<bool> _handleBackPress() async {
    // If not on the first tab, go to previous tab
    if (_tabController.index > 0) {
      _tabController.animateTo(0);
      return false; // Don't exit app
    }

    // If on first tab, check for double tap to exit
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > Duration(seconds: 2)) {
      _currentBackPressTime = now;

      // Show snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit', textAlign: TextAlign.center),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Don't exit on first press
    }

    return true; // Exit app on second press
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _handleBackPress();
          if (shouldPop) {
            SystemNavigator.pop();
          } else {
            return;
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.deepPurpleAccent,
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              DiaryListScreen(),
              CaptionCategoryView(),
              FavCaptionScreen(),
              LoginScreen(),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(icon: Icon(Icons.book), text: 'Diary '),
                Tab(icon: Icon(Icons.category ), text: 'Captions'),
                Tab(icon: Icon(Icons.favorite), text: 'Favorite'),
                Tab(icon: Icon(Icons.person), text: 'Profile'),
              ],
            ),
          )),
      ),
    );
  }
}
