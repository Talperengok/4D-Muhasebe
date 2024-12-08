import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  // Bu URL, Back 0 tamamlandıktan sonra atanacaktır.
  String ROOT = "http://188.245.203.49/api.php";

  // İngilizce karaktere çevirme fonksiyonu
  String _toEnglishChar(String input) {
    return input
        .replaceAll('İ', 'I')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G');
  }

  String generateUID(String value) {
    String eng = _toEnglishChar(value);
    List<String> words = eng.split(" ");
    String prefix = "";
    for (var w in words) {
      if (w.length >= 2) {
        prefix += w.substring(0, 2);
      } else {
        prefix += w;
      }
    }

    // 9 haneli rastgele sayı üret
    final random = Random();
    int number = random.nextInt(999999999); // 0-999999999 arası
    String numberStr = number.toString().padLeft(9, '0');

    return prefix + numberStr;
  }

  //------------------ ADMINS ------------------//
  Future<String> createAdmin(String adminName, String adminCompanies, String adminExpiryDate, String adminPassword, String adminFiles, String adminMessages) async {
    String uid = generateUID(adminName);
    var map = <String, dynamic>{
      'action': 'CREATE_ADMIN',
      'adminID': uid,
      'adminName': adminName,
      'adminCompanies': adminCompanies,
      'adminExpiryDate': adminExpiryDate,
      'adminPassword': adminPassword,
      'adminFiles': adminFiles,
      'adminMessages': adminMessages,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> updateAdminDetails(String adminID, String adminName, String adminPassword) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_DETAILS',
      'adminID': adminID,
      'adminName': adminName,
      'adminPassword': adminPassword,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> updateAdminCompanies(String adminID, String adminCompanies) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_COMPANIES',
      'adminID': adminID,
      'adminCompanies': adminCompanies,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> updateAdminFiles(String adminID, String adminFiles) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_FILES',
      'adminID': adminID,
      'adminFiles': adminFiles,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> updateAdminMessages(String adminID, String adminMessages) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_MESSAGES',
      'adminID': adminID,
      'adminMessages': adminMessages,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> updateAdminExpiryDate(String adminID, String adminExpiryDate) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_EXPIRYDATE',
      'adminID': adminID,
      'adminExpiryDate': adminExpiryDate,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<List<Map<String, dynamic>>> getAdmins() async {
    var map = <String, dynamic>{ 'action': 'GET_ADMINS' };
    var response = await http.post(Uri.parse(ROOT), body: map);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // Eğer data bir Map ise, hata ya da beklenmeyen format olabilir.
      if (data is Map<String, dynamic>) {
        // Burada error veya başka bir durum kontrol edebilirsiniz.
        if (data.containsKey('error')) {
          // Hata durumunda boş liste döndürebilirsiniz veya hata fırlatabilirsiniz.
          return [];
        } else {
          // Beklenmedik bir map verisi. Kontrol etmek lazım.
          return [];
        }
      } else if (data is List) {
        // Beklenen durum: data bir liste
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        // Beklenmedik durum
        return [];
      }
    } else {
      // HTTP hatası
      return [];
    }
  }


  Future<Map<String, dynamic>?> getAdminDetails(String adminID) async {
    var map = <String, dynamic>{
      'action': 'GET_ADMIN_DETAILS',
      'adminID': adminID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      if (response.body.trim() == "[]") return null;
      var data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return null;
  }

  //------------------ COMPANIES ------------------//
  Future<String> createCompany(String companyName, String companyAdmin, String companyMessage, String companyPassword, String companyFiles) async {
    String uid = generateUID(companyName);
    var map = <String, dynamic>{
      'action': 'CREATE_COMPANY',
      'companyID': uid,
      'companyName': companyName,
      'companyAdmin': companyAdmin,
      'companyMessage': companyMessage,
      'companyPassword': companyPassword,
      'companyFiles': companyFiles,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> updateCompanyDetails(String companyID, String companyName, String companyPassword) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_COMPANY_DETAILS',
      'companyID': companyID,
      'companyName': companyName,
      'companyPassword': companyPassword,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> updateCompanyAdmin(String companyID, String companyAdmin) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_COMPANY_ADMIN',
      'companyID': companyID,
      'companyAdmin': companyAdmin,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> updateCompanyFiles(String companyID, String companyFiles) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_COMPANY_FILES',
      'companyID': companyID,
      'companyFiles': companyFiles,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> updateCompanyMessage(String companyID, String companyMessage) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_COMPANY_MESSAGE',
      'companyID': companyID,
      'companyMessage': companyMessage,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<List<Map<String, dynamic>>> getCompanies() async {
    var map = <String, dynamic>{
      'action': 'GET_COMPANIES',
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCompanyDetails(String companyID) async {
    var map = <String, dynamic>{
      'action': 'GET_COMPANY_DETAILS',
      'companyID': companyID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      if (response.body.trim() == "[]") return null;
      var data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return null;
  }

  //------------------ FILES ------------------//
  // CREATE_FILE dosya upload ettiği için normal bir POST'tan farklı olacaktır.
  // Ancak Back0'da bu işlemin POST ile gerçekleştiği belirtildi.
  // Burada http paketini kullanırken multipart istek yapmamız gerekebilir.

  Future<String> createFile(
      String fileName,
      String fileType,
      String filePassword,
      String fileUploader,
      String fileOwners,
      List<int> fileBytes,
      String fileFieldName
      ) async {
    String uid = generateUID(fileName);

    var request = http.MultipartRequest('POST', Uri.parse(ROOT));
    request.fields['action'] = 'CREATE_FILE';
    request.fields['fileID'] = uid;
    request.fields['fileName'] = fileName;
    request.fields['fileType'] = fileType;
    request.fields['filePassword'] = filePassword;
    request.fields['fileUploader'] = fileUploader;
    request.fields['fileOwners'] = fileOwners;

    request.files.add(http.MultipartFile.fromBytes(
        fileFieldName,
        fileBytes,
        filename: "$fileName.$fileType"
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse["status"] == "success") {
        return uid;
      } else {
        print(jsonResponse);
        throw Exception(jsonResponse["message"]);
      }
    } else {
      throw Exception("Error uploading file");
    }
  }


  Future<String> updateFileDetails(String fileID, String fileName, String fileType, String filePassword, String fileOwners) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_FILE_DETAILS',
      'fileID': fileID,
      'fileName': fileName,
      'fileType': fileType,
      'filePassword': filePassword,
      'fileOwners': fileOwners,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> deleteFile(String fileID) async {
    var map = <String, dynamic>{
      'action': 'DELETE_FILE',
      'fileID': fileID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<List<Map<String, dynamic>>> getFiles(String fileOwner) async {
    var map = <String, dynamic>{
      'action': 'GET_FILES',
      'fileOwner': fileOwner,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getFile(String fileID) async {
    var map = <String, dynamic>{
      'action': 'GET_FILE',
      'fileID': fileID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      if (response.body.trim() == "[]") return null;
      var data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return null;
  }

  //------------------ MESSAGES ------------------//
  Future<String> createConversation(String messageCompany, String messageAdmin, String messageList) async {
    String uid = generateUID(messageCompany);
    var map = <String, dynamic>{
      'action': 'CREATE_CONVERSATION',
      'messageUID': uid,
      'messageCompany': messageCompany,
      'messageAdmin': messageAdmin,
      'messageList': messageList,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> updateConversationMessages(String messageUID, String messageList) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_CONVERSATION_MESSAGES',
      'messageUID': messageUID,
      'messageList': messageList,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  Future<String> deleteConversation(String messageUID) async {
    var map = <String, dynamic>{
      'action': 'DELETE_CONVERSATION',
      'messageUID': messageUID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  //------------------ AUTHENTICATE_USER ------------------//
  Future<bool> authenticateUser(String type, String id, String password) async {
    var map = <String, dynamic>{
      'action': 'AUTHENTICATE_USER',
      'type': type,
      'id': id,
      'password': password,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      var data = jsonDecode(response.body);
      // {"status":"true"} veya {"status":"false"} dönecek
      if (data is Map && data.containsKey('status')) {
        return data['status'] == 'true';
      }
    }
    return false;
  }
}
