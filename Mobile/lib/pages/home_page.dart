import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  final double horizontalPadding = 40.0;
  final double verticalPadding = 25.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding,vertical: verticalPadding),
            child: Row(children: [
              Image.asset(
                  'lib/icons/points.png',
                  height: 30,
                  color: Colors.grey[800]),
            ],),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome Home,", style: TextStyle(fontSize: 20, color: Colors.grey[700]),),
                Text("YuGiOh! FAN!", style: GoogleFonts.bebasNeue(fontSize: 72),)
              ],
            ),
          ),

          const SizedBox(height: 1,),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
            child: Divider(color: Colors.grey[400], thickness: 1),
          ),
          const SizedBox(height: 25,),
        ],
      ),)
    );
  }
}