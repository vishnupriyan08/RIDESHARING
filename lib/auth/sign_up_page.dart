import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:vivi_ride_app/auth/sign_in_page.dart';
import 'package:vivi_ride_app/global.dart';
import 'package:vivi_ride_app/widgets/loading_dialog.dart';

import '../pages/home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  TextEditingController userNametextEditingController = TextEditingController();
  TextEditingController userPhonetextEditingController = TextEditingController();
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();

  validateSignUpForm()
  {
    if(userNametextEditingController.text.trim().length < 3)
      {
        associateMethods.showSnackBarMsg("Name must be atleast 4 or more characters", context);
      }
    else if(userPhonetextEditingController.text.trim().length < 7)
      {
        associateMethods.showSnackBarMsg("Phone number must be 7 or more numbers", context);
      }
    else if(!emailtextEditingController.text.contains("@"))
    {
      associateMethods.showSnackBarMsg("email is not valid", context);
    }
    else if(passwordtextEditingController.text.trim().length < 6)
    {
      associateMethods.showSnackBarMsg("Password must be atleast 6 or more characters", context);
    }
    else
      {
        signUpUserNow();
      }
  }

  signUpUserNow() async
  {

    showDialog(context: context,
        builder: (BuildContext context) => const LoadingDialog(messageTxt: "please wait... ")
    );
    try
    {
      final User? firebaseUser = (
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailtextEditingController.text.trim(),
          password: passwordtextEditingController.text.trim()
      ).catchError((onError)
      {
        Navigator.pop(context);
        associateMethods.showSnackBarMsg(onError.toString(), context);
      })
      ).user;

      Map userDataMap = {
        "name": userNametextEditingController.text.trim(),
        "email": emailtextEditingController.text.trim(),
        "phone": userPhonetextEditingController.text.trim(),
        "id": firebaseUser!.uid,
        "blockStatus": "no",
      };
      FirebaseDatabase.instance.ref().child("users").child(firebaseUser.uid).set(userDataMap);

      Navigator.pop(context);
      associateMethods.showSnackBarMsg("Account created successfully.", context);
      Navigator.push(context, MaterialPageRoute(builder: (c) => const HomePage()));
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
                  "Register New Account",
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
                      controller: userNametextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Name",
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
                      controller: userPhonetextEditingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Phone No",
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

                    ElevatedButton(onPressed: (){
                      validateSignUpForm();
                    },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 80,vertical: 10),
                      ),
                      child: const Text("Sign Up",style: TextStyle(color: Colors.black),),
                    ),

                  ],
                ),
              ),

              const SizedBox(height: 12,),

              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (c) => const SignInPage()));
              },
                child: const Text(
                  "Already have an Account? Sign In here",
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
