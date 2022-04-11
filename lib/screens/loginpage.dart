import 'package:authen/screens/my_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen(
      (User? user) {
        if (user == null) {
          print("User is signed out");
        } else {
          print("User is Signed In");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.green.shade100,
          title: Text("LoginPage")),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                child: Column(
                  children: [
                    SizedBox(
                      height: 100.0,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Enter Email",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Enter Password",
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 3.0),
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        child: Text("Forgot password?"),
                        onTap: forgotPassword,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: Text("Ro'yxatdan o'tish"),
                    onPressed: register,
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0))),
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.google),
                    onPressed: signInWithGoogle,
                  ),
                  ElevatedButton(
                    child: Text("Tizimga Kirish"),
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                        elevation: 0,
                        primary: Colors.cyan,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0))),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              child: Text("Login With OTP"),
              onPressed: loginWithOtp,
              )
          ],
        ),
      ),
    );
  }

  Future loginWithOtp()async{
    await auth.verifyPhoneNumber(
      phoneNumber: emailController.text,

      verificationCompleted: (PhoneAuthCredential credential) async{
        await auth.signInWithCredential(credential);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=> MyHomePage()), (route) => false);
      },
      verificationFailed: (FirebaseAuthException e){
        if(e.code == 'invalid-phone-number'){
          showSnackBar('The provided phone number is not valid', Colors.red);
        }else{
          showSnackBar('Another Error Type!', Colors.red);
        }
      },
      codeSent: (String verificationId, int? resendToken) async{
        String smsCode = '112233';

        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, 
          smsCode: smsCode
        );

        await auth.signInWithCredential(credential);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=> MyHomePage()), (route) => false);
      },

      codeAutoRetrievalTimeout: (String verificationId){},
    );
  }

  Future register() async {
    try{
      UserCredential credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text, 
        password: passwordController.text,
      );
      await auth.currentUser!.sendEmailVerification();
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=> MyHomePage()), (route) => false);
    } on FirebaseAuthException catch (e){
      if(e.code == 'weak-password'){
        showSnackBar("Kiritilgan kod juda oddiy", Colors.red);
      }else if(e.code == 'email-already-in-use'){
        showSnackBar("Bu Email bilan oldir ro'yxatdan o'tilgan", Colors.red);
      }
    }
  }

  Future signIn() async {
    try{
      UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=> MyHomePage()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if(e.code == 'user-not-found'){
        showSnackBar("Bunday Emaildagi akkount mavjud emas", Colors.red);
      } else if(e.code == 'wrong-password'){
        showSnackBar("Noto'g'ri parol terildi", Colors.red);
      }
    }
  }

  Future signInWithGoogle() async {
    try{
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=> MyHomePage()), (route) => false);
    } catch (e){
      showSnackBar("Error Google Sign In", Colors.red);
    }
  }

  Future forgotPassword() async{
    await auth.sendPasswordResetEmail(
      email: emailController.text,
    );
    showSnackBar('Yangi parol uchun link e-mail pochtanggizga jo\'natildi', Colors.orange);
  } 

  showSnackBar(String content, Color color){
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(content),
        backgroundColor: color,
      )
    );
  }

}
















// import 'package:authen/screens/my_home_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({ Key? key }) : super(key: key);
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
// class _LoginPageState extends State<LoginPage> {
//   final FirebaseAuth auth = FirebaseAuth.instance;
//   TextEditingController emailController = TextEditingController();
//   TextEditingController passwordController = TextEditingController();
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     auth.authStateChanges().listen((User? user) {
//       if(user == null){
//         debugPrint('User is currently signed out!');
//       }else{
//         debugPrint('User is signed in!');
//       }
//      });
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text("User Auth"),
//         ),
//         body: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Form(
//                 child: Column(
//                   children: [
//                     TextFormField(controller: emailController,),
//                     TextFormField(controller: passwordController,),
//                   ],
//                 )
//               ),
//             ),
//             ElevatedButton(
//               child: Text("Sign Up"),
//               onPressed: signUp,
//             ),
//             ElevatedButton(
//               child: Text("Sign In"),
//               onPressed: signIn,
//             ),
//             ElevatedButton(
//               child: Text("forgot password"),
//               onPressed: forgotPassword,
//             ),
//             ElevatedButton(
//               child: Text("Sign In with Google"),
//               onPressed: signInWithGoogle,
//             ),
//           ],
//         )
//     );
//   }
  // Future signInWithGoogle() async {
  //   try{
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth?.accessToken,
  //       idToken: googleAuth?.idToken,
  //     );
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //     Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=> MyHomePage()), (route) => false);
  //   } catch (e){
  //     showMySnackBar("Error Google Sign In", Colors.red);
  //   }
  // }


//   Future forgotPassword() async{
//     await auth.sendPasswordResetEmail(
//       email: emailController.text,
//     );
//     showMySnackBar('Password reset link is sent to email!', Colors.orange);
//   }

//   Future signIn()async{
//     try{
//       UserCredential user = await auth.signInWithEmailAndPassword(
//         email: emailController.text,
//         password: passwordController.text,
//       );
//       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=> MyHomePage()), (route) => false);
//     } on FirebaseAuthException catch (e){
//       if(e.code == 'user-not-found'){
//         showMySnackBar('No user found for that email.', Colors.red);
//       } else if(e.code == 'wrong-password'){
//         showMySnackBar('Wrong password provided for that user.', Colors.red);
//       }
//     }
//   }

//   Future signUp() async {
//     try{
//       UserCredential user = await auth.createUserWithEmailAndPassword(
//         email: emailController.text, 
//         password: passwordController.text,
//         );
//         showMySnackBar("Success: ${user.user!.email}", Colors.green); 
//         await auth.currentUser!.sendEmailVerification();
//         // print(auth.currentUser!.emailVerified);
//         Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx)=> MyHomePage()), (route) => false);
//     } on FirebaseAuthException catch (e){
//       if(e.code == 'weak-password'){
//         showMySnackBar('The Password provided is too weak.', Colors.red);
//       } else if(e.code == 'email-already-in-use'){
//         showMySnackBar('THe account already exists for that email.', Colors.red);
//       }
//     } catch(e){
//         showMySnackBar('There is such kind of error', Colors.red);
//     }
//   }
 
//   showMySnackBar(String content, Color color){
//     return ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(content),
//         backgroundColor: color,
//         )
//     );
//   }
// }


