import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:direct_accounting/Components/FileCard.dart';
import 'package:direct_accounting/Services/Database/DatabaseHelper.dart';
import 'package:direct_accounting/widget/loading_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

// Bu fonksiyonları önceki mesajınızda sağlamıştık
List<Map<String, dynamic>> jsonStringToMessageList(String jsonString) {
  var decoded = jsonDecode(jsonString);
  return List<Map<String, dynamic>>.from(decoded);
}

String messageListToJsonString(List<Map<String, dynamic>> messageList) {
  return jsonEncode(messageList);
}

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

class ChatPage extends StatefulWidget {
  final String currentUserID;
  final String companyID;
  final String adminID;

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
  Map<String, dynamic> adminData = {};
  Map<String, dynamic> companyData = {};

  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;

  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      _loading = true;
    });
    adminData = (await DatabaseHelper().getAdminDetails(widget.adminID))!;
    companyData = (await DatabaseHelper().getCompanyDetails(widget.companyID))!;
    String currentName = widget.currentUserID == widget.adminID ? adminData["adminName"] : companyData["companyName"];
    String otherName = widget.currentUserID == widget.adminID ? companyData["companyName"] :  adminData["adminName"];
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
        _messages = jsonStringToMessageList(firstMessage);
      }
      else print("HATA VAR AQ");
    }
    else {
      Map<String, dynamic> messageData = await DatabaseHelper().getMessage(
          companyData["companyMessage"]);
      print(companyData);
      print(messageData);
      String incomingJsonMessages = messageData["messageList"];

      // JSON string'ten listeye çevir
      _messages = jsonStringToMessageList(incomingJsonMessages);
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _buildMessageItem(Map<String, dynamic> message) {
    String sentDate = message["sentDate"];
    String sender = message["sender"];
    String messageContent = message["message"];
    String messageType = message["messageType"];
    bool isMine = sender == widget.currentUserID;
    // Gönderen ismi
    String senderName;
    if (sender == widget.adminID) {
      senderName = adminData["adminName"] ?? "Admin";
    } else if (sender == widget.companyID) {
      senderName = companyData["companyName"] ?? "Company";
    } else {
      senderName = "Unknown Sender";
    }

    if (messageType == "text") {
      // Normal mesaj
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Column(
          crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(senderName, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: sender == widget.currentUserID ? Colors.blue[100] : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(messageContent),
            ),
            SizedBox(height: 2),
            Text(formatDateTime(sentDate), style: TextStyle(fontSize: 10, color: Colors.grey[800])),
          ],
        ),
      );
    } else if (messageType == "file") {
      String fileID = messageContent;
      return FutureBuilder<Map<String, dynamic>>(
        future: DatabaseHelper().getFile(fileID), // File bilgilerini çeken fonksiyon
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Veri yükleniyor
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(senderName, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(),
                  ),
                  SizedBox(height: 2),
                  Text(sentDate, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
            );
          } else if (snapshot.hasError || !snapshot.hasData) {
            // Hata durumunda ya da veri yoksa
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text("Dosya bilgisi alınamadı."),
            );
          } else {
            // Başarılı durum: Dosya verileri geldi
            var fileData = snapshot.data!;
            String fileType = fileData["fileType"];
            String imagePath = fileType == "personel" ? "assets/images/personel_logo.png"
                : fileType == "declaration" ? "assets/images/beyanname.png"
                : "assets/images/sigorta.png";
            String filePath = fileData['filePath'] ?? 'UnknownFilePath';
            return Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(senderName, style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Container(
                    height: 120,
                    child: FileCard(
                      gradient1: Color(0xFF474878),
                      gradient2: Color(0xFF325477),
                      buttonColor: Color(0xFF080F2B),
                      iconColor: Colors.white,
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
                  SizedBox(height: 2),
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
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Text("Unsupported message type"),
      );
    }
  }

  void showInfo(Map<String, dynamic> document) {
    ///
    ///         "fileName" : "bos_sigorta.pdf",
    //         "filePath" : "/data/user/0/com.westsoftpro.direct_accounting/cache/file_picker/1732566649157/bos_sigorta.pdf",
    //         "fileCreated" : DateTime.now().add(Duration(days: -3)),
    //         "fileDownloaded" : DateTime.now,
    //         "fileOwnerClient" : "ABK LTD.",
    //         "fileUploadedBy" : "Admin"

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

  void downloadFile(Map<String, dynamic> document) async {
    final uri = Uri.parse(document["filePath"]);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

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
      // Dosyayı indir
      await dio.download(fileUrl, savePath);

      print("Dosya indirildi: $savePath");

    } catch (e) {
      print("Dosya indirilemedi: $e");
    }    Share.shareXFiles([XFile(savePath)], text: document["fileName"]);
  }

  void _sendMessage() async {
    String newMessage = _messageController.text.trim();
    if (newMessage.isNotEmpty) {
      // Mesaj listesine ekle
      setState(() {
        _messages.add({
          "sentDate": DateTime.now().toIso8601String(),
          "sender": widget.currentUserID,
          "message": newMessage,
          "messageType": "text"
        });
      });
      await DatabaseHelper().updateConversationMessages(companyData["companyMessage"], messageListToJsonString(_messages));
      setState(() {
        _messageController.clear();
      });
    }
  }

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
      isScrollControlled: true, // Modal'ın tam ekran olmasını sağlar
      shape: RoundedRectangleBorder(
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
                    Text(
                      'Dosya Yükle',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: pickFile,
                      icon: Icon(Icons.upload_file),
                      label: Text('Dosya Seç'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF080F2B),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (selectedFile != null) ...[
                      Text(
                        'Seçilen Dosya: ${selectedFile!.path.split('/').last}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
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
                          SizedBox(width: 2,),
                          Text("."),
                          SizedBox(width: 2,),
                          Expanded(
                            child: TextField(
                              controller: _executeController,
                              readOnly: true,
                              decoration: InputDecoration(
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
                      SizedBox(height: 20),
                    ],
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Dosya Şifresi (Opsiyonel)',
                        border: OutlineInputBorder(),
                        suffixIcon: _passwordController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear),
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
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: (){
                            selectedType = "personel";
                            setState((){});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedType == "personel" ? Color(0xFF908EC0) : Color(0xFF080F2B),
                          ),
                          child: Text("Özlük", style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: (){
                            selectedType = "decleration";
                            setState((){});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedType == "decleration" ? Color(0xFF908EC0) : Color(0xFF080F2B),
                          ),
                          child: Text("Beyanname", style: TextStyle(color: Colors.white)),
                        ),
                        ElevatedButton(
                          onPressed: (){
                            selectedType = "insurance";
                            setState((){});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedType == "insurance" ? Color(0xFF908EC0) : Color(0xFF080F2B),
                          ),
                          child: Text("Sigorta", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: selectedFile != null
                          ? () async {
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
                        _messages.add({
                          "sentDate": DateTime.now().toIso8601String(),
                          "sender": widget.currentUserID,
                          "message": f,
                          "messageType": "file"
                        });
                        await DatabaseHelper().updateConversationMessages(companyData["companyMessage"], messageListToJsonString(_messages));
                        setState((){});
                        print(f);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                          : null,
                      child: Text('Karşıya Yükle ve Gönder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF080F2B),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 20),
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
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back), color: Colors.white,),
        title: const Text('Sohbet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFF080F2B),
      ),
      backgroundColor: Color(0xFF908EC0),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                var message = _messages[index];
                return _buildMessageItem(message);
              },
            ),
          ),
          // Mesaj Yazma Alanı
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                    onPressed: () {
                      showUploadFileModalBottomSheet(context);
                    },
                    icon: Icon(Icons.attach_file)
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
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF080F2B),
                  ),
                  child: Text("Gönder", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
