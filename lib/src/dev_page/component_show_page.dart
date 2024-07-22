import 'package:flutter/material.dart';
import 'package:mymangatheque/src/components/my_button.dart';
import 'package:mymangatheque/src/components/my_line.dart';
import 'package:mymangatheque/src/components/my_picture_display.dart';
import 'package:mymangatheque/src/components/my_textfield.dart';
import 'package:mymangatheque/src/components/my_tome_number_show.dart';
import 'package:mymangatheque/src/components/square_tile.dart';

class ComponentShowPage extends StatelessWidget {
  const ComponentShowPage({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Show Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('My Button : (text: "text", onTap: () {}, bgColor: bgColor, textColor: textColor)'),
            Padding(
              padding: const EdgeInsets.all(10),
              child: MyButton(
                  text: 'text',
                  onTap: () {},
                  bgColor: Colors.black,
                  textColor: Colors.white
              ),
            ),
            const Text('My line (width: width, vertical: vertical int for vertical padding)'),
            Padding(
              padding: const EdgeInsets.all(10),
              child: MyLine(
                  width: MediaQuery.of(context).size.width,
                  vertical: 5
              ),
            ),
            const Text("MyPictureDisplay(pictureUrl: url of the image (only network image)"),
            const Padding(
              padding: EdgeInsets.all(10),
              child: MyPictureDisplay(
                pictureUrl: "https://cdn.statically.io/gh/CreeperFarm/AppManga/main/ac.jpg",
              ),
            ),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('MyTabBarItem(tabText: text, colorIn: colorIn, colorOut: colorOut), should be in tab bar item then tab'),
            ),
            const Text('MyTextField(controller: controller, labelText: labelText, obscureText: obscureText boolean to show or not text, errorMessage: errorMessage to show when nothing inside, textColor: textColor)'),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  MyTextField(controller: controller, labelText: "labelText obscure text false", obscureText: false, errorMessage: 'errorMessage', textColor: Colors.white),
                  MyTextField(controller: controller, labelText: "labelText obscure text true", obscureText: true, errorMessage: 'errorMessage', textColor: Colors.white)
                ],
              )
            ),
            const Text('MyTomeNumberShow(tomeTotal: string of the number of tome, editionTotal: string of the number of edition)'),
            const Padding(
              padding: EdgeInsets.all(10),
              child: MyTomeNumberShow(
                tomeTotal: '22',
                editionTotal: '18',
              ),
            ),
            const Text('SquareTile(imagePath: imagePath (in local storage), onTap: () {})'),
            Padding(
              padding: const EdgeInsets.all(10),
              child: SquareTile(imagePath: 'assets/images/google.png', onTap: () {}
              )
            ),
          ],
        )
      ),
    );
  }
}
