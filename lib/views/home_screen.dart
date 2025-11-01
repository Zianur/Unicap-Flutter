import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();

    NetworkInfo.checkConnectivity(context);

    _tabController = TabController(length: 4, vsync: this);

    // Get userId first, then fetch notes
    Future.delayed(Duration.zero, () async {
      final authController = Provider.of<AuthController>(context, listen: false);
      /// Getting user object from firebase
      authController.getCurrentUser();
      userId = authController.user?.uid ?? 'guest';

      Provider.of<DiaryController>(context, listen: false).fetchAndSaveNotes(userId);
      Provider.of<CaptionCategoryController>(context, listen: false).loadCategories();
    });

    _checkVersion();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.deepPurpleAccent,
        body: TabBarView(
          controller: _tabController,
          children: [
            DiaryListScreen(),
            CaptionCategoryView(),
            FavCaptionScreen(),
            LoginScreen(),
          ],
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
