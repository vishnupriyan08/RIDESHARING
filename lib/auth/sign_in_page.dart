import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vivi_ride_app/auth/sign_up_page.dart';
import 'package:vivi_ride_app/pages/home_page.dart';

import '../global.dart';
import '../widgets/loading_dialog.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();


  validateSignInForm()
  {
    if(!emailtextEditingController.text.contains("@"))
    {
      associateMethods.showSnackBarMsg("email is not valid", context);
    }
    else if(passwordtextEditingController.text.trim().length < 6)
    {
      associateMethods.showSnackBarMsg("Password must be atleast 6 or more characters", context);
    }
    else
    {
      signIpUserNow();
    }
  }

  signIpUserNow() async {

    showDialog(context: context,
        builder: (BuildContext context) => LoadingDialog(messageTxt: "please wait... ")
    );
    try
    {
      final User? firebaseUser = (
          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: emailtextEditingController.text.trim(),
              password: passwordtextEditingController.text.trim()
          ).catchError((onError)
          {
            Navigator.pop(context);
            associateMethods.showSnackBarMsg(onError.toString(), context);
          })
      ).user;

      if(firebaseUser != null)
      {
        DatabaseReference ref = FirebaseDatabase.instance.ref().child("users").child(firebaseUser.uid);
        await ref.once().then((dataSnapshot)
        {
          if(dataSnapshot.snapshot.value != null)
          {
            if((dataSnapshot.snapshot.value as Map)["blockStatus"] == "no")
            {
              userName = (dataSnapshot.snapshot.value as Map)["name"];
              userPhone = (dataSnapshot.snapshot.value as Map)["phone"];

              Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));

              associateMethods.showSnackBarMsg("signed in successfully.", context);
            }
            else
            {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              associateMethods.showSnackBarMsg("you are blocked contact vivigroup.inc@gmail.com", context);

            }

          }
          else
            {
              Navigator.pop(context);
              FirebaseAuth.instance.signOut();
              associateMethods.showSnackBarMsg("your record do not exist as a User ", context);
            }


        });
      }

    }
    on FirebaseAuthException catch(e)
    {
      FirebaseAuth.instance.signOut();
      Navigator.pop(context);
      associateMethods.showSnackBarMsg(e.toString(), context);
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const SizedBox(height: 122,),

              Image.asset("assets/images/ridesharing-high-resolution-logo-black-transparent.png",width: MediaQuery.of(context).size.width * .6,
              ),

              const SizedBox(height: 20,),

              const Text(
                "Login as  User",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

          Padding(padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: emailtextEditingController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "User Email",
                    labelStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 22,),

                TextField(
                  controller: passwordtextEditingController,
                  obscureText: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 32,),
                
                ElevatedButton(onPressed: ()
                {
                  validateSignInForm();
                },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 80,vertical: 10),
                  ),
                  child: const Text("Login",style: TextStyle(color: Colors.black),),
                ),

              ],
            ),
          ),

              const SizedBox(height: 12,),

              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (c) => const SignUpPage()));
              },
                  child: const Text(
                      "Don't have an Account? Sign Up here",
                    style: TextStyle(
                      color: Colors.grey
                    ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
