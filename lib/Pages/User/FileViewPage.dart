import 'package:dio/dio.dart';
import '../../Components/FileCard.dart';
import '../../Services/Database/DatabaseHelper.dart';
import '../../widget/loading_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

///PAGE TO VIEW, DOWNLOAD AND SHARE FILES CATEGORICALLY

class FileViewPage extends StatefulWidget {
  final List<Map<String, dynamic>> documents; //CLIENT DOCUMENT OF CATEGORY
  final String title; //CATEGORY NAME
  final String imagePath; //CATEGORY IMAGE PATH IN ASSETS
  final String currentUser; //VIEWER USER ID
  final String companyId; //CLIENT ID
  final String companyAdmin; //ACCOUNTANT ID

  const FileViewPage({
    required this.documents,
    required this.title,
    required this.imagePath,
    required this.currentUser,
    required this.companyId,
    required this.companyAdmin,
    Key? key,
  }) : super(key: key);

  @override
  _FileViewPageState createState() => _FileViewPageState();
}

class _FileViewPageState extends State<FileViewPage> {

  List<Map<String, dynamic>> documents = [];

  @override
  void initState() {
    // TODO: implement initState
    documents = widget.documents;
    super.initState();
  }

  //GETS DOCUMENTS AFTER WE UPLOAD NEW ONE
  Future<void> getDocumentsAfterUpload() async {
    String fileTypeDecider = widget.title == "Özlük Dosyaları" ? "personel" : widget.title == "Beyannameler" ? "decleration" : "insurance";
    var compDetails = await DatabaseHelper().getCompanyDetails(widget.companyId);
    List<Map<String, dynamic>> docs = [];
    LoadingIndicator(context).showLoading();
    List<String> fileIds = compDetails!["companyFiles"].toString() != ""
        ? compDetails["companyFiles"].toString().split(",")
        : [];
    for (String file in fileIds) {
      Map<String, dynamic>? fileMap = await DatabaseHelper().getFile(file);
      if (fileMap["fileType"] == fileTypeDecider) {
        docs.add(fileMap);
      }
    }
    documents = docs;
    setState(() {
    });
    Navigator.pop(context);

  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    bool isMobile = width < 800;  //GET SCREEN WIDTH AND CHECK IS MOBILE LAYOUT

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Color(0xFFEFEFEF), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1B2A),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back), color: const Color(0xFFEFEFEF),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          slivers: [
            documents.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 60.0),
                        child: Text(
                          'Henüz bu kategoriye ait dosya yüklenmemiş.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      childAspectRatio: 3.3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final doc = documents[index];
                        return FileCard(
                          gradient1: const Color(0xFF3D5A80),
                          gradient2: const Color(0xFF2E4A66),
                          buttonColor: const Color(0xFF1E3A5F),
                          iconColor: const Color(0xFFEFEFEF),
                          filePath: doc["filePath"],
                          imagePath: widget.imagePath,
                          showInfo: () {
                            showInfo(doc);
                          },
                          downloadFile: () {
                            downloadFile(doc);
                          },
                          shareFile: () {
                            shareFile(doc);
                          },
                          deleteFile: () => deleteFile(doc),
                        );
                      },
                      childCount: documents.length,
                    ),
                  ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFFAAB6C8),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showUploadFileModalBottomSheet(context);
        },
        backgroundColor: const Color(0xFF1E3A5F),
        child: const Icon(Icons.add, color: Color(0xFFEFEFEF),),
      ),
    );
  }

  //FILE UPLOAD MODAL - UPLOAD, NAME AND SAVE
  Future<void> showUploadFileModalBottomSheet(BuildContext context) async {
    File? selectedFile;
    String fileName = '';
    String filePassword = '';
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
                        color: Color(0xFF1A1A1A),
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
                    ElevatedButton(
                      onPressed: selectedFile != null
                          ? () async {

                        //UPLOAD FILE AND SET IT TO ACCOUNTANT'S AND CLIENT'S FILES
                        LoadingIndicator(context).showLoading();
                        String fileType = widget.title == "Özlük Dosyaları" ? "personel" : widget.title == "Beyannameler" ? "decleration" : "insurance";
                        var file = await selectedFile!.readAsBytes();
                        String fileNewName = _nameController.text + "." + _executeController.text;
                        var f = await DatabaseHelper().createFile(
                            fileNewName, fileType, filePassword, widget.currentUser, [widget.companyId, widget.companyAdmin].join(","), file, "file"
                        );
                        var comDetails = await DatabaseHelper().getCompanyDetails(widget.companyId);
                        var adminDetails = await DatabaseHelper().getAdminDetails(widget.companyAdmin);
                        String comFiles = comDetails!["companyFiles"];
                        List<String> companyFiles = comFiles.split(",");
                        String admFiles = adminDetails!["adminFiles"];
                        List<String> adminFiles = admFiles.split(",");

                        companyFiles.add(f);
                        adminFiles.add(f);
                        await DatabaseHelper().updateCompanyFiles(widget.companyId, companyFiles.join(","));
                        await DatabaseHelper().updateAdminFiles(widget.companyAdmin, adminFiles.join(","));
                        getDocumentsAfterUpload();
                        print(f);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                          : null,
                      child: const Text('Karşıya Yükle'),
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

  //SHOW FILE INFO
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

  //DOWNLOAD THE FILE
  void downloadFile(Map<String, dynamic> document) async {
    TextEditingController passController = TextEditingController();
    bool canEnter = false;
    if (document["filePassword"] != "") {
      await showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: const Text('Dosya Şifresini Girin:'),
              content: TextFormField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Dosya Şifresi',),
                obscureText: true,
                controller: passController,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () {
                    if (passController.text == document["filePassword"]) {
                      canEnter = true;
                      Navigator.pop(context);
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Şifre Yanlış")),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Onayla'),
                ),
              ],
            ),
      );
    }
    else {
      canEnter = true;
    }
    if (canEnter) {
      final uri = Uri.parse(document["filePath"]);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  //SHARE FILE
  Future<void> shareFile(Map<String, dynamic> document) async{
    TextEditingController passController = TextEditingController();
    bool canEnter = false;
    if(document["filePassword"] != ""){
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dosya Şifresini Girin:'),
          content: TextFormField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Dosya Şifresi',),
            obscureText: true,
            controller: passController,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if(passController.text == document["filePassword"]){
                  canEnter = true;
                  Navigator.pop(context);
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Şifre Yanlış")),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Onayla'),
            ),
          ],
        ),
      );
    }
    else{
      canEnter = true;
    }
    print(canEnter);
    if(canEnter) {
      String fileUrl = document["filePath"] ?? "";
      if (fileUrl.isEmpty) {
        print("Dosya yolu bulunamadı.");
        return;
      }
      String savePath = "";
      try {
        Directory? appDocDir = await getDownloadsDirectory();
        String fileName = fileUrl
            .split('/')
            .last;
        savePath = "${appDocDir!.path}/$fileName";
        Dio dio = Dio();
        await dio.download(fileUrl, savePath);

        print("Dosya indirildi: $savePath");
      } catch (e) {
        print("Dosya indirilemedi: $e");
      }
      Share.shareXFiles([XFile(savePath)], text: document["fileName"]);
    }
  }
  //Delete file from database and remove it from users
  void deleteFile(Map<String, dynamic> document) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Dosya Sil"),
      content: Text(
        "Bu dosyayı silmek istediğinizden emin misiniz?\n\n${document["fileName"]}"
      ),
      actions: [
        TextButton(
          child: const Text("Vazgeç"),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TextButton(
          child: const Text("Sil", style: TextStyle(color: Colors.red)),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  if (confirm == true) {
    LoadingIndicator(context).showLoading();

    // 1. Veritabanından sil
    await DatabaseHelper().deleteFile(document["fileID"]);

    // 2. Kullanıcılardan bağlantısını kaldır
    var compDetails = await DatabaseHelper().getCompanyDetails(widget.companyId);
    var admDetails = await DatabaseHelper().getAdminDetails(widget.companyAdmin);

    if (compDetails == null || admDetails == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dosya sahip bilgisi alınamadı."))
    );
    Navigator.pop(context); // LoadingIndicator'ı kapat
    return;
    }

    List<String> companyFiles = compDetails["companyFiles"].toString().split(",");
    List<String> adminFiles = admDetails["adminFiles"].toString().split(",");

    companyFiles.remove(document["fileID"]);
    adminFiles.remove(document["fileID"]);

    await DatabaseHelper().updateCompanyFiles(widget.companyId, companyFiles.join(","));
    await DatabaseHelper().updateAdminFiles(widget.companyAdmin, adminFiles.join(","));

    Navigator.pop(context); // Loading'i kapat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Dosya silindi."))
    );

    // Ekranı yenile
    await getDocumentsAfterUpload();
  }
}

  //DATETIME FORMATTER FOR BETTER STRINGS
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
}
