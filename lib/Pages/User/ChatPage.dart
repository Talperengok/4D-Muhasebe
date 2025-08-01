import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../Components/CustomDrawer.dart';
import '../../Components/FileCard.dart';
import 'CompanyDetailsPage.dart';
import 'TaxCalculator.dart';
import 'main_menu.dart';
import '../../Services/Database/DatabaseHelper.dart';
import '../../widget/loading_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Gets json from database and returns it as message Map
List<Map<String, dynamic>> jsonStringToMessageList(String jsonString) {
  var decoded = jsonDecode(jsonString);
  return List<Map<String, dynamic>>.from(decoded);
}

// Gets messages list and converts it to json string
String messageListToJsonString(List<Map<String, dynamic>> messageList) {
  return jsonEncode(messageList);
}

//Format dates to get better strings
String formatDateTime(dynamic value) {
  if (value is DateTime) {
    return "${value.day.toString().padLeft(2, '0')}.${value.month.toString().padLeft(2, '0')}.${value.year} - ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}";
  } else if (value is String) {
    DateTime dateTime = DateTime.parse(value);
    return "${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  } else if (value is int) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(value);
    return "${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} - ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  } else {
    return "Geçersiz Tarih";
  }
}

///THE CHAT PAGE BETWEEN ACCOUNTANT AND CLIENT. ALLOWS FILE SHARING

class ChatPage extends StatefulWidget {
  final String currentUserID; // Current Viewer User
  final String companyID; // Message's client side
  final String adminID; // Message's accountant side

  const ChatPage({
    Key? key,
    required this.currentUserID,
    required this.companyID,
    required this.adminID,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  Map<String, dynamic> adminData = {}; // Accountant Data
  Map<String, dynamic> companyData = {}; // Client Data
  late Timer _timer; // Timer for reload
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  final TextEditingController _messageController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchData();
    _startPolling();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo( _scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut, );
    }
  }

  // Reload messages per 5 seconds
  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkForNewMessages();
    });
  }

  // Check if new messages came. Gets all messages between sides.
  Future<void> _checkForNewMessages() async {
    try {
      Map<String, dynamic> messageData = await DatabaseHelper().getMessage(
          companyData["companyMessage"]);
      String incomingJsonMessages = messageData["messageList"];
      List<Map<String, dynamic>> newMessages = jsonStringToMessageList(incomingJsonMessages);
      print("New" + newMessages.length.toString() + "  ----- Old: " + _messages.length.toString());
      if (newMessages.length > _messages.length) {
        setState(() {
          _messages = newMessages;
          _scrollToBottom();
        });
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  //Gets accountant and client details; also if there were no messages between them yet, creates a chat room.
  Future<void> fetchData() async {
    setState(() {
      _loading = true;
    });

    adminData = (await DatabaseHelper().getAdminDetails(widget.adminID))!;
    companyData = (await DatabaseHelper().getCompanyDetails(widget.companyID))!;
    String currentName = widget.currentUserID == widget.adminID ? adminData["adminName"] : companyData["companyName"];
    String otherName = widget.currentUserID == widget.adminID ? companyData["companyName"] :  adminData["adminName"];

    //Check if there were any chat room before. If not, create one.
    if(companyData["companyMessage"] == ""){
      String firstMessage = '[{"sentDate":"2024-12-08T12:00:00","sender":"${widget.currentUserID}",'
          '"message":"Merhaba, $otherName. $currentName olarak bu sohbet odasını oluşturduk.","messageType":"text"}]';
      String s = await DatabaseHelper().createConversation(
          widget.companyID,
          widget.adminID,
          firstMessage
          );
      if(s != "error"){
        await DatabaseHelper().updateCompanyMessage(widget.companyID, s);
        String adminMessages = adminData["adminMessages"];
        List<String> adMessageList = adminMessages.split(",");
        adMessageList.add(s);
        await DatabaseHelper().updateAdminMessages(widget.adminID, adMessageList.join(","));
        companyData["companyMessage"] = s;
        _messages = jsonStringToMessageList(firstMessage);
        _checkForNewMessages();
      }
    }
    //...If there were, get older messages
    else {
      Map<String, dynamic> messageData = await DatabaseHelper().getMessage(
          companyData["companyMessage"]);
      String incomingJsonMessages = messageData["messageList"];
      _messages = jsonStringToMessageList(incomingJsonMessages);
    }
    setState(() {
      _scrollToBottom();
      _loading = false;
    });
  }

  //Message widget. Given shape for both file messages and text messages
  Widget _buildMessageItem(Map<String, dynamic> message) {
    String sentDate = message["sentDate"];
    String sender = message["sender"];
    String messageContent = message["message"];
    String messageType = message["messageType"];
    bool isMine = sender == widget.currentUserID;
    String senderName;

    //Check senders and ownership of messages
    if (sender == widget.adminID) {
      senderName = adminData["adminName"] ?? "Admin";
    } else if (sender == widget.companyID) {
      senderName = companyData["companyName"] ?? "Company";
    } else {
      senderName = "Unknown Sender";
    }

    // If text message, show:
    if (messageType == "text") {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: sender == widget.currentUserID ? Colors.blue[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(messageContent),
            ),
            const SizedBox(height: 2),
            Text(formatDateTime(sentDate), style: TextStyle(fontSize: 10, color: Colors.grey[800])),
          ],
        ),
      );
    }
    //If file message, show:
    else if (messageType == "file") {
      String fileID = messageContent;
      return FutureBuilder<Map<String, dynamic>>(
        future: DatabaseHelper().getFile(fileID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 2),
                  Text(sentDate, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Text("Dosya bilgisi alınamadı."),
            );
          } else {
            var fileData = snapshot.data!;
            String fileType = fileData["fileType"];
            String imagePath = fileType == "personel" ? "assets/images/personel_logo.png"
                : fileType == "declaration" ? "assets/images/beyanname.png"
                : "assets/images/sigorta.png";
            String filePath = fileData['filePath'] ?? 'UnknownFilePath';
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(senderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    height: 120,
                    child: FileCard(
                      gradient1: const Color(0xFF3D5A80),
                      gradient2: const Color(0xFF2E4A66),
                      buttonColor: const Color(0xFF1E3A5F),
                      iconColor: Color(0xFFEFEFEF),
                      filePath: filePath,
                      imagePath: imagePath,
                      showInfo: () {
                        showInfo(fileData);
                      },
                      downloadFile: () {
                        downloadFile(fileData);
                      },
                      shareFile: () {
                        shareFile(fileData);
                      },
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(sentDate, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
            );
          }
        },
      );
    }
    else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text("Unsupported message type"),
      );
    }
  }

  //Show Info Function For FileCard
  void showInfo(Map<String, dynamic> document) {
    Map<String, String> fileTypeMap = {"decleration": "Beyanname", "personel" : "Özlük", "insurance" : "Sigorta"};
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dosya Bilgileri'),
        content: Text(
            'Dosya İsmi : ' + document["fileName"].toString() + "\n\n" +
                'U.S. Dosya Numarası : ' + document["fileID"].toString() + "\n\n" +
                'Dosya Türü : ' + fileTypeMap[document["fileType"]].toString() + "\n\n" +
                'Dosyaya Erişimi Olanlar : ' + document["fileOwners"].toString() + "\n\n" +
                'Dosyayı Yükleyen : ' + document["fileUploader"].toString() + "\n\n"
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  //Download Function For FileCard
  void downloadFile(Map<String, dynamic> document) async {
    final uri = Uri.parse(document["filePath"]);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  //Share Function For FileCard
  Future<void> shareFile(Map<String, dynamic> document) async{
    String fileUrl = document["filePath"] ?? "";
    if (fileUrl.isEmpty) {
      print("Dosya yolu bulunamadı.");
      return;
    }
    String savePath = "";
    try {
      Directory? appDocDir = await getDownloadsDirectory();
      String fileName = fileUrl.split('/').last;
      savePath = "${appDocDir!.path}/$fileName";
      Dio dio = Dio();
      await dio.download(fileUrl, savePath);

      print("Dosya indirildi: $savePath");

    } catch (e) {
      print("Dosya indirilemedi: $e");
    }    Share.shareXFiles([XFile(savePath)], text: document["fileName"]);
  }

  //Send Message to Other Side
  void _sendMessage() async {
    String newMessage = _messageController.text.trim();
    if (newMessage.isNotEmpty) {
      List<Map<String, dynamic>> messagesTemp = [];
      for(int i = 0; i<_messages.length ; i++) {
        messagesTemp.add(_messages[i]);
      }
      messagesTemp.add({
        "sentDate": DateTime.now().toIso8601String(),
        "sender": widget.currentUserID,
        "message": newMessage,
        "messageType": "text"
      });
      await DatabaseHelper().updateConversationMessages(
          companyData["companyMessage"], messageListToJsonString(messagesTemp));
      _checkForNewMessages();
      setState(() {
        _messageController.clear();
      });
    }
  }

  //Show File Upload Modal
  Future<void> showUploadFileModalBottomSheet(BuildContext context) async {
    File? selectedFile;
    String fileName = '';
    String filePassword = '';
    String selectedType = 'personel';
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _executeController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {

              //Pick file and get its path
              Future<void> pickFile() async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.any,
                );

                if (result != null && result.files.single.path != null) {
                  setState(() {
                    selectedFile = File(result.files.single.path!);
                    fileName = result.files.single.name;
                    List<String> dots = fileName.split(".");
                    String execute = dots.last;
                    dots.remove(execute);
                    _nameController.text = dots.length > 1 ? dots.join(".") : dots[0];
                    _executeController.text = execute;
                  });
                }
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Dosya Yükle',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Dosya Seç'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (selectedFile != null) ...[
                      Text(
                        'Seçilen Dosya: ${selectedFile!.path.split('/').last}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Dosya İsmi',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  fileName = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 2,),
                          const Text("."),
                          const SizedBox(width: 2,),
                          Expanded(
                            child: TextField(
                              controller: _executeController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Uzantı',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  fileName = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Dosya Şifresi (Opsiyonel)',
                        border: const OutlineInputBorder(),
                        suffixIcon: _passwordController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _passwordController.clear();
                              filePassword = '';
                            });
                          },
                        )
                            : null,
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          filePassword = value;
                        });
                      },
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: (){
                            selectedType = "personel";
                            setState((){});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedType == "personel" ? const Color(0xFFAAB6C8) : const Color(0xFF0D1B2A),
                          ),
                          child: const Text("Özlük", style: TextStyle(color: Color(0xFFEFEFEF))),
                        ),
                        ElevatedButton(
                          onPressed: (){
                            selectedType = "decleration";
                            setState((){});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedType == "decleration" ? const Color(0xFFAAB6C8) : const Color(0xFF0D1B2A),
                          ),
                          child: const Text("Beyanname", style: TextStyle(color: Color(0xFFEFEFEF))),
                        ),
                        ElevatedButton(
                          onPressed: (){
                            selectedType = "insurance";
                            setState((){});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedType == "insurance" ? const Color(0xFFAAB6C8) : const Color(0xFF0D1B2A),
                          ),
                          child: const Text("Sigorta", style: TextStyle(color: Color(0xFFEFEFEF))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: selectedFile != null
                          ? () async {

                        ///UPLOAD FILE TO SERVER AND SET IT TO CLIENT'S AND ACCOUNTANT'S FILES
                        LoadingIndicator(context).showLoading();
                        String fileType = selectedType;
                        var file = await selectedFile!.readAsBytes();
                        String fileNewName = _nameController.text + "." + _executeController.text;
                        var f = await DatabaseHelper().createFile(
                            fileNewName, fileType, filePassword, widget.currentUserID, [widget.companyID, widget.adminID].join(","), file, "file"
                        );
                        var comDetails = await DatabaseHelper().getCompanyDetails(widget.companyID);
                        var adminDetails = await DatabaseHelper().getAdminDetails(widget.adminID);
                        String comFiles = comDetails!["companyFiles"];
                        List<String> companyFiles = comFiles.split(",");
                        String admFiles = adminDetails!["adminFiles"];
                        List<String> adminFiles = admFiles.split(",");
                        companyFiles.add(f);
                        adminFiles.add(f);
                        await DatabaseHelper().updateCompanyFiles(widget.companyID, companyFiles.join(","));
                        await DatabaseHelper().updateAdminFiles(widget.adminID, adminFiles.join(","));
                        List<Map<String, dynamic>> messagesTemp = [];
                        for(int i = 0; i< _messages.length ; i++) {
                          messagesTemp.add(_messages[i]);
                        }
                        messagesTemp.add({
                          "sentDate": DateTime.now().toIso8601String(),
                          "sender": widget.currentUserID,
                          "message": f,
                          "messageType": "file"
                        });
                        print(_messages.length);
                        await DatabaseHelper().updateConversationMessages(companyData["companyMessage"], messageListToJsonString(messagesTemp));
                        await _checkForNewMessages();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                          : null,
                      child: const Text('Karşıya Yükle ve Gönder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D1B2A),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: widget.adminID == widget.currentUserID
            ? IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back), color: const Color(0xFFEFEFEF),)
            : IconButton(
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          icon: const Icon(Icons.menu), color: const Color(0xFFEFEFEF),),
        title: const Text('Sohbet',
          style: TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),),
        backgroundColor: const Color(0xFF0D1B2A),
      ),
      backgroundColor: const Color(0xFFAAB6C8),
        drawer: ClientDrawer(
          onButton1Pressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MainMenu(
                  currentUserId: widget.companyID,
                  isAdmin: false,
                  companyID: widget.companyID,
                ),
              ),
            );
          },
          onButton2Pressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TaxCalculationPage(companyId: widget.companyID),
              ),
            );
          },
          onButton3Pressed: () async {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  currentUserID: widget.companyID,
                  companyID: widget.companyID,
                  adminID: companyData["companyAdmin"],
                ),
              ),
            );
          },
          onButton4Pressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CompanyUpdatePage(companyID: widget.companyID),
              ),
            );
          },
          page: 3,
        ),
        body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var message = _messages[index];
                return _buildMessageItem(message);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            color: const Color(0xFFEFEFEF),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      showUploadFileModalBottomSheet(context);
                    },
                    icon: const Icon(Icons.attach_file)
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Mesaj yaz...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B2A),
                  ),
                  child: const Text("Gönder", style: TextStyle(color: Color(0xFFEFEFEF))),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
