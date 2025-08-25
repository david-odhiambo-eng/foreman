import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foreman/models/worker_provider.dart';
import 'package:foreman/views/home/app_bar.dart';
import 'package:foreman/views/home/body_page.dart';
import 'package:foreman/views/home/bottom_navigation.dart';
import 'package:foreman/models/signup_signin.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(),
      body: const BodyPage(),
      
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with user info
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.blue),
                      ),
                      SizedBox(height: 10),
                      FutureBuilder(
                        future: _authService.getUsernameForUser(), 
                        builder: (context, snapshot){
                          if(!snapshot.hasData) return CircularProgressIndicator();
                          return Text('Hello ${snapshot.data}');
                        }),
                      Text(
                        _getUserInfo(),
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                
                // Menu Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(
                        icon: Icons.person,
                        title: 'Profile',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.settings,
                        title: 'Settings',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      _buildDrawerItem(
                        icon: Icons.work,
                        title: 'Jobs',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                ),
                
                // Logout Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      _logoutButton();
                      
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(currentIndex: 0,),
      floatingActionButton: FloatingActionButton(onPressed: (){
        _showMyModalBottomSheet();
      },
      child: Icon(FontAwesomeIcons.wallet),
      ),
    );
  }

  Future _logoutButton()async{
    return showDialog(
      context: context, 
    builder: (_) => AlertDialog(
      title: Text('Are you sure you want to logout?'),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(onPressed: (){
              Navigator.pop(context);
            }, 
            child: Text('Cancel')),
            SizedBox(width: 10,),
            ElevatedButton(onPressed: ()async{
              await _authService.logout(context);
            }, 
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white
            ),
            child: Text('Yes')),
          ],
        )
      ],

    ));
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      onTap: onTap,
    );
  }

  //helper function for total amount
  void _showMyModalBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return FutureBuilder<double>(
        future: Provider.of<WorkerProvider>(context, listen: false)
            .getAllGroupsTotal(),
        builder: (context, snapshot) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'All Groups Totals',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.hasError)
                    const Text('Error loading totals')
                  else
                    Column(
                      children: [
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Grand Total:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Ksh ${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

//getting user info
String _getUserInfo() {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // User is signed in
        return user.email ?? 'No email found';
      } else {
        // No user is signed in
        return 'No user found';
      }
    }
}
