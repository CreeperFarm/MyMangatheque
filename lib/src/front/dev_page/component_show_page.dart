import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_icon_text_button.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';
import 'package:mymangatheque/src/front/components/my_picture_display.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_square_tile.dart';
import 'package:mymangatheque/src/front/components/my_text_divider.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:mymangatheque/src/front/components/my_tome_number_show.dart';

class ComponentShowPage extends StatelessWidget {
  const ComponentShowPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    var controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Component Show Page')),
      body: MyScrollColumn(
        scrollPadding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          const Text('My Button : (text: "text", onTap: () {})'),
          Padding(
            padding: const EdgeInsets.all(10),
            child: MyButton(text: 'text', onTap: () {}),
          ),
          const Text(
            'My line (width: width, vertical: vertical int for vertical padding)',
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: MyLine(
              width: MediaQuery.of(context).size.width,
              vertical: 5,
            ),
          ),
          const Text(
            "MyPictureDisplay(pictureUrl: url of the image (only network image)",
          ),
          const Padding(
            padding: EdgeInsets.all(10),
            child: MyPictureDisplay(
              pictureUrl:
                  "https://cdn.statically.io/gh/CreeperFarm/AppManga/main/ac.jpg",
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'MyTabBarItem(tabText: text, colorIn: colorIn, colorOut: colorOut), should be in tab bar item then tab',
            ),
          ),
          const Text(
            'MyTextField(controller: controller, labelText: labelText, obscureText: obscureText boolean to show or not text, errorMessage: errorMessage to show when nothing inside)',
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                MyTextField(
                  controller: controller,
                  labelText: "labelText obscure text false",
                  obscureText: false,
                  errorMessage: 'errorMessage',
                ),
                MyTextField(
                  controller: controller,
                  labelText: "labelText obscure text true",
                  obscureText: true,
                  errorMessage: 'errorMessage',
                ),
              ],
            ),
          ),
          const Text(
            'MyTomeNumberShow(tomeTotal: string of the number of tome, editionTotal: string of the number of edition)',
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: MyTomeNumberShow(
              tomeTotal: '22',
              editionTotal: '18',
              localizations: localizations,
            ),
          ),
          const Text(
            'SquareTile(imagePath: imagePath (in local storage), onTap: () {})',
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SquareTile(imagePath: Assets.images.google, onTap: () {}),
          ),
          const Text(
            'MyScrollColumn(children: [list of widgets]) to get a scrolling page column',
          ),
          const Text(
            'MyIconButton(function: Function, color: Color, iconSrc: String), to show a button with an icon and text',
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: MyIconTextButton(
              function: () {},
              color: Colors.blue,
              iconSrc: Assets.icons.home,
              text: 'text',
            ),
          ),
          const Text(
            'MyTextDivider(text: text), to show a text with a divider',
          ),
          const MyTextDivider(text: 'text'),
        ],
      ),
    );
  }
}
