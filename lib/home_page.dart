import 'package:charcha/ModelUsed/chatroom_model.dart';
import 'package:charcha/ModelUsed/user_model.dart';
import 'package:charcha/profile_page.dart';
import 'package:charcha/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'ModelUsed/firebasehelper.dart';
import 'chatroom.dart';
import 'firebase_options.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    ),
  );
}

class HomePage extends StatefulWidget {
  final User? user;
  final UserModel? userModel;
  final ChatRoomModel? chatRoom;

  // final Image imageFile;

  const HomePage({super.key, this.user, this.userModel, this.chatRoom});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // widget.chatRoom!.chatCreatedOn = DateTime.now();

    // Debug log to check the chatroom initialization
    debugPrint('HomePage initialized with chatroom');
    debugPrint('userModel uid: ${widget.userModel?.uid}');
    // setState(() {});
  }

  Future showChatRoomDeleteOptions(String? chatRoomId) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Edit Options"),
          content: SizedBox(
            height: 50,
            width: 800,
            child: ListView(
              children: [
                ListTile(
                  selectedTileColor: Colors.white70,
                  leading: const Icon(Icons.delete),
                  title: const Text("Delete chat"),
                  onTap: () async {
                    Navigator.pop(context);

                    try {
                      // Attempt to delete the chatroom
                      FirebaseFirestore.instance
                          .collection("chatrooms")
                          .doc(chatRoomId)
                          .delete()
                          .then((_) {
                        // Confirm deletion
                        debugPrint("Chatroom deleted successfully");
                        setState(() {}); // Update the UI
                      });
                    } catch (error) {
                      debugPrint("Failed to delete chatroom: $error");
                      // Show an error message if needed
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black.withOpacity(0.2),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              tooltip: 'User Profile',
              color: Colors.white,
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                    context,
                    PageTransition(
                        child: ProfilePage(
                          userModel: widget.userModel,
                          user: widget.user,
                        ),
                        type: PageTransitionType.fade,
                        duration: const Duration(milliseconds: 600)));
              }),
          IconButton(
              tooltip: 'Logout',
              color: Colors.white,
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                    context,
                    PageTransition(
                        child: const LoginPage(),
                        type: PageTransitionType.fade,
                        duration: const Duration(milliseconds: 600)));
              },
              icon: const Icon(Icons.logout))
          // PopupMenuButton<String>(onSelected: (value) {
          //   debugPrint(value);
          // }, itemBuilder: (BuildContext context) {
          //   return [
          //     PopupMenuItem(
          //       onTap: () {
          //         Navigator.popUntil(context, (route) => route.isFirst);
          //         Navigator.pushReplacement(
          //             context,
          //             PageTransition(
          //                 child: const LoginPage(),
          //                 type: PageTransitionType.fade,
          //                 duration: const Duration(milliseconds: 600)));
          //       },
          //       value: "Logout",
          //       child: const Text("Logout"),
          //     ),
          //     const PopupMenuItem(
          //       value: "Language",
          //       child: Text("Language"),
          //     ),
          //   ];
          // })
        ],
        title: const Text(
          "Charcha",
          style: TextStyle(
            fontSize: 35,
            fontFamily: "Dosis",
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        // backgroundColor: Colors.blueGrey,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white70
                  // image: DecorationImage(
                  //   image: AssetImage("assets/images/charchaBgImage13.jpg"),
                  //   // colorFilter:
                  //   //     ColorFilter.mode(Colors.black, BlendMode.softLight),
                  //   fit: BoxFit.cover,
                  // ),
                  ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatrooms")
                  .where("users", arrayContains: widget.userModel!.uid)
                  .orderBy("chatCreatedOn", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasError) {
                    return const Text("Some error occurred");
                  } else {
                    if (snapshot.hasData) {
                      QuerySnapshot chatRoomSnapshot =
                          snapshot.data! as QuerySnapshot;
                      // Fetch participant data for sorting
                      // List<ChatRoomModel> chatRooms =
                      //     chatRoomSnapshot.docs.map((doc) {
                      //   return ChatRoomModel.fromMap(
                      //       doc.data() as Map<String, dynamic>);
                      // }).toList();
                      //
                      // // Sort chatRooms by participant's chatCreatedOn
                      // chatRooms.sort((a, b) {
                      //   DateTime aDate = a.chatCreatedOn ?? DateTime.now();
                      //   DateTime bDate = b.chatCreatedOn ?? DateTime.now();
                      //   return bDate.compareTo(aDate);
                      // });

                      return ListView.separated(
                        itemBuilder: (BuildContext context, int index) {
                          ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                              chatRoomSnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                          Map<String, dynamic>? participant =
                              chatRoomModel.participant;
                          List<String> participantKeys =
                              participant!.keys.toList();
                          participantKeys.remove(widget.userModel!.uid);

                          return FutureBuilder(
                            future: FirebaseHelper.getUserModelById(
                                participantKeys[0]),
                            builder: (context, userdata) {
                              if (userdata.connectionState ==
                                  ConnectionState.done) {
                                if (userdata.data != null) {
                                  UserModel targetUser =
                                      userdata.data as UserModel;
                                  return ListTile(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          child: ChatRoomPage(
                                            userModel: widget.userModel,
                                            user: widget.user,
                                            chatroom: chatRoomModel,
                                            targetUser: targetUser,
                                          ),
                                          type: PageTransitionType
                                              .rightToLeftWithFade,
                                          duration:
                                              const Duration(milliseconds: 300),
                                        ),
                                      );
                                    },
                                    onLongPress: () {
                                      showChatRoomDeleteOptions(
                                          chatRoomModel.chatRoomId);
                                    },
                                    leading: CircleAvatar(
                                      backgroundImage: (targetUser.profilePic !=
                                                  null &&
                                              targetUser.profilePic!.isNotEmpty)
                                          ? NetworkImage(
                                              targetUser.profilePic.toString())
                                          : null,
                                      backgroundColor: Colors.grey[400],
                                      child: (targetUser.profilePic == null ||
                                              targetUser.profilePic!.isEmpty)
                                          ? Icon(
                                              Icons.person,
                                              color: Colors.grey[700],
                                            )
                                          : null,
                                    ),
                                    title: (targetUser.name!.isNotEmpty)
                                        ? Text(
                                            targetUser.name.toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          )
                                        : Text(
                                            targetUser.email.toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                    subtitle: (chatRoomModel.lastMsg?.isEmpty ??
                                            true)
                                        ? const Text(
                                            "No message yet",
                                            style: TextStyle(
                                                color: Colors.blueGrey,fontWeight: FontWeight.bold),
                                          )
                                        : Text(
                                            chatRoomModel.lastMsg.toString(),
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                  );
                                } else {
                                  return const CircularProgressIndicator();
                                }
                              } else {
                                return Container();
                              }
                            },
                          );
                        },
                        itemCount: chatRoomSnapshot.docs.length, //item count
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            height: 3,
                            thickness: 1,
                            color: Colors.grey[400],
                          );
                        },
                      );
                    } else {
                      return const Text("No data found");
                    }
                  }
                } else {
                  return const CircularProgressIndicator(
                    color: Colors.white,
                  );
                }
              },
            ),
            Positioned(
              // height: 50,
              // width: 50,
              bottom: 40,
              right: 30,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      child: SearchScreen(
                        user: widget.user,
                        userModel: widget.userModel,
                      ),
                      type: PageTransitionType.rightToLeftWithFade,
                      duration: const Duration(milliseconds: 300),
                    ),
                  );
                },
                backgroundColor: Colors.teal,
                child: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// StreamBuilder(
// stream: FirebaseFirestore.instance
//     .collection("chatrooms")
//     .where("participant.${widget.userModel?.uid}",
// isEqualTo: true)
//     .orderBy("chatCreatedOn", descending: true)
//     .snapshots(),
// builder: (context, snapshot) {
// if (snapshot.connectionState == ConnectionState.active) {
// if (snapshot.hasError) {
// return const Text("Some error occurred");
// } else {
// if (snapshot.hasData) {
// debugPrint(Stream.error(e).toString());
// QuerySnapshot chatRoomSnapshot =
// snapshot.data! as QuerySnapshot;
// return ListView.separated(
// itemBuilder: (BuildContext context, int index) {
// ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
// chatRoomSnapshot.docs[index].data()
// as Map<String, dynamic>);
// Map<String, dynamic>? participant =
// chatRoomModel.participant;
// List<String> participantkey =
// participant!.keys.toList();
// participantkey.remove(widget.userModel!.uid);
// return FutureBuilder(
// future: FirebaseHelper.getUserModelById(
// participantkey[0]),
// builder: (context, userdata) {
// if (userdata.connectionState ==
// ConnectionState.done) {
// if (userdata.data != null) {
// UserModel targetUser =
// userdata.data as UserModel;
// return ListTile(
// // hoverColor: Colors.white,
// onTap: () {
// Navigator.push(
// context,
// PageTransition(
// child: ChatRoomPage(
// userModel: widget.userModel,
// user: widget.user,
// chatroom: chatRoomModel,
// targetUser: targetUser,
// ),
// type: PageTransitionType
//     .rightToLeft,
// duration: const Duration(
// milliseconds: 200),
// curve: Curves
//     .fastEaseInToSlowEaseOut));
// },
// onLongPress: () {
// showChatRoomDeleteOptions(
// chatRoomModel.chatRoomId);
// },
// leading: CircleAvatar(
// backgroundImage:
// (targetUser.profilePic != null &&
// targetUser
//     .profilePic!.isNotEmpty)
// ? NetworkImage(targetUser
//     .profilePic
//     .toString())
//     : null,
// backgroundColor: Colors.grey[400],
// child: (targetUser.profilePic == null ||
// targetUser.profilePic!.isEmpty)
// ? const Icon(
// Icons.person,
// color: Colors.white,
// )
//     : null,
// ),
//
// title: Text(
// targetUser.name.toString(),
// style: const TextStyle(
// color: Colors.white,
// fontWeight: FontWeight.bold,
// fontSize: 20,
// ),
// ),
// subtitle: (chatRoomModel
//     .lastMsg!.isEmpty &&
// chatRoomModel.lastMsg == null)
// ? const Text(
// "No message yet",
// style: TextStyle(
// color: Colors.yellowAccent),
// )
//     : Text(
// chatRoomModel.lastMsg.toString(),
// style: const TextStyle(
// color: Colors.white70,
// fontWeight: FontWeight.bold,
// fontSize: 15,
// ),
// ),
// );
// } else {
// return const CircularProgressIndicator();
// }
// } else {
// return Container();
// }
// });
// },
// itemCount: chatRoomSnapshot.docs.length,
// separatorBuilder: (BuildContext context, int index) {
// return const Divider(
// height: 10,
// thickness: 1,
// color: Colors.white70,
// );
// },
// );
// } else {
// return const Text("No data found");
// }
// }
// } else {
// return const CircularProgressIndicator(
// color: Colors.white,
// );
// }
// },
// ),
