import 'package:chatapp/component/chat_bubble.dart';
import 'package:chatapp/component/my_text_field.dart';
import 'package:chatapp/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage({
    super.key,
    required this.receiverUserID,
    required this.receiverUserEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  void sendMessage() async {
    // only send message if there is something to send
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      // clear the text controller after sending the message
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade100,
      appBar: AppBar(
        title: Text(widget.receiverUserEmail),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              // child : _buildMessageList(),
              child: StreamBuilder(
        stream: _chatService.getMessages(
            widget.receiverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error${snapshot.error}');
          }
      
          if(snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loding');
          }
      
          return ListView(
              children: snapshot.data!.docs
                  .map((document) => _buildMessageItem(document))
                  .toList());
        },
          ),
              
            ),
      
            // user input
           _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // // build message list
  // Widget _buildMessageList() {
  //   return StreamBuilder(
  //     stream: _chatService.getMessages(
  //         widget.receiverUserID, _firebaseAuth.currentUser!.uid),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         return Text('Error${snapshot.error}');
  //       }

  //       if(snapshot.connectionState == ConnectionState.waiting) {
  //         return const Text('Loding');
  //       }

  //       return ListView(
  //           children: snapshot.data!.docs
  //               .map((document) => _buildMessageItem(document))
  //               .toList());
  //     },
  //   );
  // }

  // build message item
  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    //alignthe messages to right if the sender is the current user, otherwise to the left
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(children: [
        Text(data['senderEmail']),
        ChatBubble(message: data['message']),
        const SizedBox(height: 5,),
      ],),
    );
  }

  // build message input
  Widget _buildMessageInput() {
    return Row(
      children: [
        // textfield
        Expanded(
          child: MyTextField(
            controller: _messageController,
            hintText: 'Enter Message',
            obscureText: false,
          ),
        ),

        // send button
        IconButton(
            onPressed: sendMessage,
            icon: const Icon(
              Icons.send,
              size: 40,
              color: Colors.blue,
            ))
      ],
    );
  }
}
