import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/src/front/components/my_line.dart';

class MyTomeNumberShow extends StatelessWidget {
  final String tomeTotal;
  final String editionTotal;

  const MyTomeNumberShow(
      {required this.tomeTotal, required this.editionTotal, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$tomeTotal Tomes • $editionTotal Édition",
          textAlign: TextAlign.start,
          style: GoogleFonts.adventPro(
            textStyle: const TextStyle(
              fontSize: 30,
            ),
          ),
        ),
        MyLine(width: MediaQuery.of(context).size.width, vertical: 10),
      ],
    );
  }
}
