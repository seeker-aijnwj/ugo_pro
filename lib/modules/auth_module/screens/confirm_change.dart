import 'package:flutter/material.dart';
import 'package:u_go/app/core/utils/colors.dart';
import 'package:u_go/modules/booking_module/screens/passenger/home_screen.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/widgets/space.dart';
import 'package:u_go/app/widgets/txt_components.dart';

class ConfirmChange extends StatefulWidget {
  const ConfirmChange({super.key});

  @override
  State<ConfirmChange> createState() => _ConfirmChangeState();
}

class _ConfirmChangeState extends State<ConfirmChange> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 150),
              spaceHeight(20),
              TxtComponents(
                txt: "Modificaiton effectué ! ",
                fw: FontWeight.bold,
                family: "Bold",
                txtSize: 28,
              ),
              spaceHeight(20),
              TxtComponents(
                txt: "Votre mot de passe a été modifié avec succes ",
                txtSize: 20,
                txtAlign: TextAlign.center,
              ),
              spaceHeight(20),
              ButtonComponent(
                txtButton: "Acceuil",
                colorButton: mainColor,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
