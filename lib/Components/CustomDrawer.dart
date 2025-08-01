import 'package:flutter/material.dart';
///THE DRAWER WIDGET OF CLIENT SECTION

class ClientDrawer extends StatelessWidget {
  final Function() onButton1Pressed;
  final Function() onButton2Pressed;
  final Function() onButton3Pressed;
  final Function() onButton4Pressed;
  final int page;

  const ClientDrawer({
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
      child: Container(
        color: const Color(0xFF1E293B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0F172A),
              ),
              child: Text(
                'Müvekkil Menüsü',
                style: TextStyle(
                  color: Color(0xFFEFEFEF),
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: page == 1 ? Colors.lightBlueAccent : Colors.white,),
              title: Text('Ana Sayfa', style: TextStyle(color: page == 1 ? Colors.lightBlueAccent : Colors.white),),
              onTap: page != 1 ? onButton1Pressed : null,
            ),
            ListTile(
              leading: Icon(Icons.calculate, color: page == 2 ? Colors.lightBlueAccent : Colors.orangeAccent),
              title: Text('Vergi Hesaplayıcı', style: TextStyle(color: page == 2 ? Colors.lightBlueAccent : Colors.white),),
              onTap:  page != 2 ? onButton2Pressed : null,
            ),
            ListTile(
              leading: Icon(Icons.chat, color: page == 3 ? Colors.lightBlueAccent : Colors.greenAccent),
              title: Text("Mesajlar", style: TextStyle(color: page == 3 ? Colors.lightBlueAccent : Colors.white),),
              onTap:  page != 3 ? onButton3Pressed : null,
            ),
            ListTile(
              leading: Icon(Icons.edit, color: page == 4 ? Colors.lightBlueAccent : Colors.lightBlueAccent),
              title: Text('Bilgileri Güncelle', style: TextStyle(color: page == 4 ? Colors.lightBlueAccent : Colors.white),),
              onTap:  page != 4 ? onButton4Pressed : null,
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDrawer extends StatelessWidget {
  final Function() onButton1Pressed;
  final Function() onButton2Pressed;
  final Function() onButton3Pressed;
  final Function() onButton4Pressed;
  final Function() onButton5Pressed;
  final Function() onButton6Pressed;
  final int page;

  const AdminDrawer({
    Key? key,
    required this.onButton1Pressed,
    required this.onButton2Pressed,
    required this.onButton3Pressed,
    required this.onButton4Pressed,
    required this.onButton5Pressed,
    required this.onButton6Pressed,
    required this.page,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF1E293B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF0D1B2A),
            ),
            child: Text(
              '4D Muhasebe\nMuhasebeci - Menü',
              style: TextStyle(
                color: Color(0xFFEFEFEF),
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: page == 1 ? Colors.lightBlueAccent : Colors.white),
            title: Text('Ana Menü', style: TextStyle(color: page == 1 ? Colors.lightBlueAccent : Colors.white),),
            onTap: page != 1 ? onButton1Pressed : null,
          ),
          ListTile(
            leading: Icon(Icons.calculate, color: page == 2 ? Colors.lightBlueAccent : Colors.orangeAccent),
            title: Text('Vergi Hesaplayıcı', style: TextStyle(color: page == 2 ? Colors.lightBlueAccent : Colors.white),),
            onTap:  page != 2 ? onButton2Pressed : null,
          ),
          ListTile(
            leading: Icon(Icons.archive, color: page == 3 ? Colors.lightBlueAccent : Colors.yellowAccent),
            title: Text('Arşivlenmiş Müvekkiller', style: TextStyle(color: page == 3 ? Colors.lightBlueAccent : Colors.white),),
            onTap:  page != 3 ? onButton3Pressed : null,
          ),
          ListTile(
            leading: Icon(Icons.edit, color: page == 4 ? Colors.lightBlueAccent : Colors.lightBlueAccent),
            title: Text('Bilgileri Güncelle', style: TextStyle(color: page == 4 ? Colors.lightBlueAccent : Colors.white),),
            onTap:  page != 4 ? onButton4Pressed : null,
          ),
          ListTile(
            leading: Icon(Icons.star, color: page == 5 ? Colors.lightBlueAccent : Colors.amber),
            title: Text('Premium Yükseltme', style: TextStyle(color: page == 5 ? Colors.lightBlueAccent : Colors.white),),
            onTap: page != 5 ? onButton5Pressed : null,
          ),
          ListTile(
            leading: Icon(Icons.how_to_reg, color: page == 6 ? Colors.lightBlueAccent : Colors.redAccent),
            title: Text('Müvekkil Onayları', style: TextStyle(color: page == 6 ? Colors.lightBlueAccent : Colors.white),),
            onTap: page != 6 ? onButton6Pressed : null,
          ),
          ],
        ),
      ),
    );
  }
}
