import 'package:charcha/ModelUsed/chatroom_model.dart';
import 'package:charcha/ModelUsed/user_model.dart';
import 'package:charcha/round_btn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'chatroom.dart';
import 'main.dart';

class SearchScreen extends StatefulWidget {
  final UserModel? userModel;
  final User? user;

  const SearchScreen({super.key, this.userModel, this.user});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("chatrooms")
          .where("participant.${widget.userModel!.uid}", isEqualTo: true)
          .where("participant.${targetUser.uid}", isEqualTo: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Fetch existing chatroom
        var doc = snapshot.docs[0];
        debugPrint("Document data: ${doc.data()}");
        chatRoom = ChatRoomModel.fromMap(doc.data() as Map<String, dynamic>);
        if (chatRoom.chatRoomId == null || chatRoom.chatRoomId!.isEmpty) {
          debugPrint("ChatRoom ID is null or empty, generating a new ID...");
          // chatRoom.chatRoomId = generateNewChatRoomId();
        } else {
          debugPrint("ChatRoom retrieved: ${chatRoom.chatRoomId}");
        }
      } else {
        // Create new chatroom
        debugPrint("Creating new Chatroom...");
        try {
          ChatRoomModel newChatRoom = ChatRoomModel(
            chatRoomId: uuid.v1(),
            lastMsg: "",
            participant: {
              targetUser.uid.toString(): true,
              widget.userModel!.uid.toString(): true
            },
            users: [
              widget.userModel!.uid.toString(),
              targetUser.uid.toString()
            ],
            // chatCreatedOn: DateTime.now(),
          );

          await FirebaseFirestore.instance
              .collection("chatrooms")
              .doc(newChatRoom.chatRoomId)
              .set(newChatRoom.toMap());

          chatRoom = newChatRoom;
        } catch (e) {
          debugPrint(e.toString());
        }
        // debugPrint("New Chatroom created: ${chatRoom.chatRoomId}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return chatRoom;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        //use preferredsize widget in app bar to change height of appbar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.teal,
            title: const SizedBox(height: 30, child: Text("Search....")),
            titleTextStyle: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
          ),
        ),
        body: SafeArea(
          // maintainBottomViewPadding: true,
          // top: false,
          child: Stack(
            children: [
              // Container(
              //   decoration: const BoxDecoration(
              //       image: DecorationImage(
              //           image: AssetImage("assets/images/charchaBgImage13.jpg"),
              //           fit: BoxFit.cover)),
              // ),
              Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 50, right: 30, top: 80),
                    child: TextField(
                      style: const TextStyle(color: Colors.black, fontSize: 20),
                      controller: searchController,
                      cursorColor: Colors.black,
                      decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                            ),
                          ),
                          labelText: 'Search with email',
                          labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  RoundedBtn(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text("Search"),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  StreamBuilder(
                      stream: searchController.text.trim().toString() ==
                              widget.user!.email
                          ? const Stream.empty()
                          : FirebaseFirestore.instance
                              .collection("users")
                              .where("email",
                                  isEqualTo:
                                      searchController.text.trim().toString())
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (searchController.text.trim().toString() ==
                            widget.user!.email) {
                          return const Center(
                            child: Text(
                              "Please don't enter your email",
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold),
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData) {
                            QuerySnapshot qsnap =
                                snapshot.data! as QuerySnapshot;
                            if (qsnap.docs.isNotEmpty) {
                              Map<String, dynamic> userMap =
                                  qsnap.docs[0].data() as Map<String, dynamic>;
                              UserModel searchedUser =
                                  UserModel.fromJson(userMap);
                              return ListTile(
                                tileColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                onTap: () async {
                                  ChatRoomModel? chatRoomModel =
                                      await getChatRoomModel(searchedUser);
                                  if (chatRoomModel != null) {
                                    Navigator.pushReplacement(
                                      context,
                                      PageTransition(
                                        child: ChatRoomPage(
                                          targetUser: searchedUser,
                                          user: widget.user,
                                          userModel: widget.userModel,
                                          chatroom:
                                              chatRoomModel, // Ensure this is correctly initialized
                                        ),
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                  }
                                },
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: (searchedUser.profilePic !=
                                              null &&
                                          searchedUser.profilePic!.isNotEmpty)
                                      ? NetworkImage(
                                          searchedUser.profilePic.toString())
                                      : null,
                                  backgroundColor: Colors.grey[400],
                                  child: searchedUser.profilePic == null || searchedUser.profilePic!.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          color: Colors.grey[800],
                                        )
                                      : null,
                                ),
                                title: (searchedUser.name!.isNotEmpty)
                                    ? Text(
                                        searchedUser.name!,
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      )
                                    : Text(
                                        searchedUser.email!,
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                subtitle: Text(
                                  searchedUser.email!,
                                  style: const TextStyle(
                                      fontSize: 17, color: Colors.black),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_circle_right,
                                  color: Colors.black,
                                ),
                              );
                            } else {
                              return const Text(
                                "No results found",
                                style: TextStyle(
                                    fontSize: 30, color: Colors.black),
                              );
                            }
                          } else if (snapshot.hasError) {
                            debugPrint('Error: ${snapshot.error}');
                            return const Text(
                              "An error occured",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.white),
                            );
                          } else {
                            return const Text(
                              "No results found",
                              style:
                                  TextStyle(fontSize: 30, color: Colors.black),
                            );
                          }
                        } else {
                          return const CircularProgressIndicator(
                            color: Colors.black,
                          );
                        }
                      })
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
