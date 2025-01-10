import 'package:flutter/material.dart';

///THE DRAWER WIDGET OF CLIENT SECTION

class CustomDrawer extends StatelessWidget {
  final Function() onButton1Pressed;
  final Function() onButton2Pressed;
  final Function() onButton3Pressed;
  final Function() onButton4Pressed;
  final int page;

  const CustomDrawer({
    Key? key,
    ///DEFINES FUNCTIONS TO BUTTONS' PRESSES IN ORDER
    required this.onButton1Pressed,
    required this.onButton2Pressed,
    required this.onButton3Pressed,
    required this.onButton4Pressed,
    ///CURRENT PAGE INDEX
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF080F2B),
            ),
            child: Text(
              'Direkt Muhasebe\nMüvekkil - Menü',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.menu_open, color: page == 1 ? Colors.blueGrey : Colors.black,),
            title: Text('Ana Menü', style: TextStyle(color: page == 1 ? Colors.blueGrey : Colors.black),),
            onTap: page != 1 ? onButton1Pressed : null,
          ),
          /*ListTile(
            leading: Icon(Icons.calculate, color: page == 2 ? Colors.blueGrey : Colors.black),
            title: Text('Hesaplamalar', style: TextStyle(color: page == 2 ? Colors.blueGrey : Colors.black),),
            onTap:  page != 2 ? onButton2Pressed : null,
          ),
           */
          ListTile(
            leading: Icon(Icons.chat, color: page == 3 ? Colors.blueGrey : Colors.black),
            title: Text("Muhasebeci'yle Sohbet", style: TextStyle(color: page == 3 ? Colors.blueGrey : Colors.black),),
            onTap:  page != 3 ? onButton3Pressed : null,
          ),
          ListTile(
            leading: Icon(Icons.settings, color: page == 4 ? Colors.blueGrey : Colors.black),
            title: Text('Ayarlar', style: TextStyle(color: page == 4 ? Colors.blueGrey : Colors.black),),
            onTap:  page != 4 ? onButton4Pressed : null,
          ),
        ],
      ),
    );
  }
}
