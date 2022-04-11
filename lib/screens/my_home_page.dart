import 'package:authen/screens/loginpage.dart';
import 'package:authen/screens/providers/random_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Color? color;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.green.shade100,
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: UserAccountsDrawerHeader(
                currentAccountPictureSize: Size.square(70),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      'https://source.unsplash.com/random'),
                ),
                accountName: Text("Your Account"),
                accountEmail: Text(
                    "${auth.currentUser!.email ?? auth.currentUser!.phoneNumber}"),
              ),
            ),
            Expanded(
                flex: 7,
                child: Container(
                  child: Column(children: [
                    Text(
                      "User Settings",
                      style: TextStyle(fontSize: 25),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.delete),
                      title: Text("Delete Account"),
                      trailing: Icon(Icons.chevron_right_outlined),
                      onTap: deleteAcc,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text("Log Out"),
                      trailing: Icon(Icons.chevron_right_outlined),
                      onTap: logOut,
                    ),
                    Divider(),
                  ]),
                ))
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        title: Text("FindNum Game"),
        backgroundColor: Colors.green.shade100,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.5,
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10),
                  itemBuilder: (context, i) {
                    return InkWell(
                      child: Container(
                        color: context.watch<RandomProvider>().onTap[i]
                            ? Colors.amber.withOpacity(0.3)
                            : Colors.amber,
                        alignment: Alignment.center,
                        child: Text(
                          "${context.watch<RandomProvider>().randoms[i]}",
                          style: TextStyle(
                              color:
                                  context.watch<RandomProvider>().isVisible ==
                                          true
                                      ? Colors.white
                                      : Colors.amber,
                              fontSize: 30),
                        ),
                      ),
                      onTap: () {
                        context.read<RandomProvider>().delete(i);
                      },
                    );
                  },
                  itemCount: context.watch<RandomProvider>().randoms.length),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: Text("Start"),
        backgroundColor: Colors.amber,
        onPressed: () {
          context.read<RandomProvider>().showRandoms();
          context.read<RandomProvider>().randomize();
        },
      ),
    );
  }

  Future deleteAcc() async {
    try {
      await FirebaseAuth.instance.currentUser!.delete();
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (ctx) => LoginPage()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
            "Ushbu operatsiyadan oldin foydalanuvchi qayta ro'yxatdan  o'tgan bo'lishi kerak");
      }
    }
  }

  Future logOut() async {
    try {
      await auth.signOut();
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (ctx) => LoginPage()), (route) => false);
    } on FirebaseAuthException catch (e) {
      print("Xatolik yuz berdi");
    }
  }
}
