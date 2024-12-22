import 'package:dio/dio.dart';
import 'package:direct_accounting/Components/FileCard.dart';
import 'package:direct_accounting/Services/Database/DatabaseHelper.dart';
import 'package:direct_accounting/widget/loading_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class FileViewPage extends StatefulWidget {
  final List<Map<String, dynamic>> documents;
  final String title;
  final String imagePath;
  final String currentUser;
  final String companyId;
  final String companyAdmin;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    bool isMobile = width < 800;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF080F2B),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back), color: Colors.white,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          slivers: [
            SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                childAspectRatio: 3.3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final doc = widget.documents[index];
                  return FileCard(
                    gradient1: const Color(0xFF474878),
                    gradient2: const Color(0xFF325477),
                    buttonColor: Colors.black,
                    iconColor: Colors.white,
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
                  );
                },
                childCount: widget.documents.length,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color(0xFF908EC0),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          showUploadFileModalBottomSheet(context);
        },
        backgroundColor: Color(0xFF080F2B),
        child: Icon(Icons.add, color: Colors.white,),
      ),
    );
  }

  Future<void> showUploadFileModalBottomSheet(BuildContext context) async {
    File? selectedFile;
    String fileName = '';
    String filePassword = '';
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
                    ElevatedButton(
                      onPressed: selectedFile != null
                          ? () async {
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
                        print(f);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                          : null,
                      child: Text('Karşıya Yükle'),
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
