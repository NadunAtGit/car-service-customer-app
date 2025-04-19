import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Assistantscreen extends StatefulWidget {
  const Assistantscreen({super.key});

  @override
  State<Assistantscreen> createState() => _AssistantscreenState();
}

class _AssistantscreenState extends State<Assistantscreen> {
  final Color primaryColor = Color(0xFFD9BAF4); // Light purple
  final Color secondaryColor = Color(0xFF944EF8); // Darker purple for contrast
  final Color backgroundColor = Color(0xFFF8F5FD); // Very light purple background

  // Sample messages for demonstration
  final List<Map<String, dynamic>> messages = [
    {
      'text': 'Hello! How can I help you with your vehicle today?',
      'isUser': false,
      'time': '10:30 AM'
    },
    {
      'text': 'My car is making a strange noise when I brake.',
      'isUser': true,
      'time': '10:32 AM'
    },
    {
      'text': 'That could be related to your brake pads or rotors. When did you last have them checked?',
      'isUser': false,
      'time': '10:33 AM'
    },
    {
      'text': 'I think it was about 8 months ago during my last service.',
      'isUser': true,
      'time': '10:35 AM'
    },
    {
      'text': 'I recommend scheduling a brake inspection soon. I can help you book an appointment for your Subaru WRX.',
      'isUser': false,
      'time': '10:36 AM'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _buildChatMessages(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 20,
            child: Icon(
              Icons.support_agent,
              color: secondaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service Assistant',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Online',
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildChatMessages() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        itemCount: messages.length,
        reverse: false,
        itemBuilder: (context, index) {
          final message = messages[index];
          return _buildMessageBubble(
            message['text'],
            message['isUser'],
            message['time'],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(String message, bool isUser, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAssistantAvatar(),
          if (!isUser) SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? secondaryColor : primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: isUser ? Radius.circular(20) : Radius.circular(0),
                  bottomRight: isUser ? Radius.circular(0) : Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: GoogleFonts.poppins(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      color: isUser ? Colors.white70 : Colors.black54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) SizedBox(width: 8),
          if (isUser) _buildUserAvatar(),
        ],
      ),
    );
  }

  Widget _buildAssistantAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Colors.white,
      child: Icon(
        Icons.support_agent,
        size: 18,
        color: secondaryColor,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: secondaryColor,
      child: Icon(
        Icons.person,
        size: 18,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.mic, color: secondaryColor),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: primaryColor.withOpacity(0.5)),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(color: Colors.black38),
                  border: InputBorder.none,
                ),
                style: GoogleFonts.poppins(),
              ),
            ),
          ),
          SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: secondaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}