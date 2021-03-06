import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../events/event_tile.dart';
import '../../models/event.dart';
import '../../navigation/app_drawer.dart';
import '../../ui/error_message.dart';
import '../../utils/build_snapshot.dart';

class EventsOverviewPage extends StatelessWidget {
  final _eventsStream = FirebaseFirestore.instance
      .collection('events')
      .orderBy('startTime')
      .withConverter<Event>(
        fromFirestore: (snapshot, _) =>
            Event.fromJson({'id': snapshot.id, ...snapshot.data()!}),
        toFirestore: (event, _) => event.toJson(),
      )
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('All Events'),
        ),
        drawer: AppDrawer(),
        floatingActionButton: FirebaseAuth.instance.currentUser != null
            ? FloatingActionButton.extended(
                onPressed: () =>
                    VxNavigator.of(context).push(Uri(path: '/events/new')),
                icon: const Icon(Icons.add),
                label: const Text('New'),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder<QuerySnapshot<Event>>(
            stream: _eventsStream,
            builder: buildSnapshot(
                childLoading: const Center(
                  child: CircularProgressIndicator(),
                ),
                childError: Center(
                  child: ErrorMessage(),
                ),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Event>> snapshot) {
                  final docs =
                      snapshot.data!.docs.map((doc) => doc.data()).toList();

                  if (docs.length == 0) {
                    return const Center(
                        child: ErrorMessage(message: 'No event available'));
                  }

                  return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (ctx, index) {
                        final doc = docs[index];
                        return EventTile(doc);
                      });
                }),
          ),
        ));
  }
}
