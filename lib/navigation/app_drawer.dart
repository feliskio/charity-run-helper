import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:velocity_x/velocity_x.dart';

class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool signedIn = false;

  initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          signedIn = false;
        });
      } else {
        setState(() {
          signedIn = true;
        });
      }
    });
  }

  String get label {
    if (!signedIn) {
      return 'Welcome';
    }
    return FirebaseAuth.instance.currentUser!.email!;
  }

  String get gravatarUrl {
    final email = FirebaseAuth.instance.currentUser!.email!;
    final emailHash = md5.convert(utf8.encode(email)).toString();
    return 'https://www.gravatar.com/avatar/$emailHash?s=108&d=monsterid';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        'https://images.unsplash.com/photo-1590333748338-d629e4564ad9?w=1000&q=40'),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (signedIn)
                  CircleAvatar(
                    radius: 36,
                    foregroundImage: NetworkImage(gravatarUrl),
                    backgroundColor: Colors.grey,
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => VxNavigator.of(context).replace(Uri(path: '/')),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Events'),
            onTap: () => VxNavigator.of(context).replace(Uri(path: '/events')),
          ),
          if (signedIn)
            ListTile(
              leading: const Icon(Icons.check),
              title: const Text('Participations'),
              onTap: () =>
                  VxNavigator.of(context).replace(Uri(path: '/participations')),
            ),
          if (signedIn)
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Tracker'),
              onTap: () =>
                  VxNavigator.of(context).replace(Uri(path: '/tracker')),
            ),
          const Divider(),
          if (!signedIn)
            ListTile(
              leading: const Icon(Icons.vpn_key),
              title: const Text('Login'),
              onTap: () => VxNavigator.of(context).push(Uri(path: '/auth')),
            )
          else
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => FirebaseAuth.instance.signOut(),
            ),
        ],
      ),
    );
  }
}
