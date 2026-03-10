import 'package:flutter/material.dart';
import 'package:u_go/modules/auth_module/screens/confirm_change.dart';
import 'package:u_go/app/widgets/button_component.dart';
import 'package:u_go/app/widgets/form_component.dart';
import 'package:u_go/app/widgets/space.dart';
import 'package:u_go/app/widgets/txt_components.dart';
import 'package:url_launcher/url_launcher.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool agree = false;
  bool hidePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // AppBar personnalisé
              SizedBox(
                height: 110,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Center(
                      child: TxtComponents(
                        txt: "",
                        txtSize: 50,
                        family: "Agbalumo",
                        txtAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 240,
                width: double.infinity,
                child: const Center(
                  child: TxtComponents(
                    txt: "Modifier mon mot de passe",
                    txtSize: 50,
                    family: "Agbalumo",
                    txtAlign: TextAlign.center,
                  ),
                ),
              ),
              spaceHeight(20),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormComponent(
                          label: "Mot de passe",
                          placeholder: "********",
                          hide: hidePassword,
                          textInputType: TextInputType.visiblePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          ),
                        ),
                        spaceHeight(20),
                        FormComponent(
                          label: "Confirmer le mot de passe",
                          placeholder: "********",
                          hide: hidePassword,
                          textInputType: TextInputType.visiblePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          ),
                        ),
                        spaceHeight(20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: agree,
                              onChanged: (value) {
                                setState(() {
                                  agree = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Wrap(
                                children: [
                                  const Text(
                                    "J'accepte et je me conforme à la politique de ce site tout en acceptant tout ce qui pourra en découler. ",
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      final url = Uri.parse(
                                        'https://tonsite.com/politique',
                                      );
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(
                                          url,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Impossible d'ouvrir le lien",
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      "Politique du site",
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        spaceHeight(40),
                        ButtonComponent(
                          txtButton: "Confirmer",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConfirmChange(),
                              ),
                            );
                          },
                        ),
                        spaceHeight(20),
                      ],
                    ),
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
