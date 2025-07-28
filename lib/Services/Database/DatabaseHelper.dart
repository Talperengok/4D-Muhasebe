import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  String ROOT = "http://188.245.203.49/api.php"; //ROOT URL

  //CHANGE TURKISH CHARS TO ENGLISH ONES
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

  //GENERATE RANDOMIZED UID
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

    final random = Random();
    int number = random.nextInt(999999999);
    String numberStr = number.toString().padLeft(9, '0');

    return prefix + numberStr;
  }

  //------------------ ADMINS ------------------//

  //CREATE ACCOUNTANT ACCOUNT
  Future<String> createAdmin(String adminID, String adminName, String adminCompanies, String adminExpiryDate, String adminPassword, String adminFiles, String adminMessages) async {
    String uid = generateUID(adminName);
    var map = <String, dynamic>{
      'action': 'CREATE_ADMIN',
      'adminID': adminID,
      'UID': uid,
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

  //GET ACCOUNTANT DETAILS
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

  //UPDATE IS ACCOUNTANT ACCOUNT VISIBLE
  Future<String> updateAdminConfirmed(String adminID, bool confirmed) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_CONFIRMED',
      'adminID': adminID,
      'confirmed': confirmed ? "YES" : "NO",
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  //UPDATE ACCOUNTANT CLIENTS
  Future<String> updateAdminCompanies(String adminID, String adminCompanies) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_COMPANIES',
      'adminID': adminID,
      'adminCompanies': adminCompanies,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  //UPDATE ACCOUNTANT FILES
  Future<String> updateAdminFiles(String adminID, String adminFiles) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_FILES',
      'adminID': adminID,
      'adminFiles': adminFiles,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  //UPDATE ACCOUNTANT MESSAGES
  Future<String> updateAdminMessages(String adminID, String adminMessages) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_MESSAGES',
      'adminID': adminID,
      'adminMessages': adminMessages,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }
  //archive client
  Future<String> archiveClient(String companyID) async {
    var map = <String, dynamic>{
      'action': 'ARCHIVE_CLIENT',
      'companyID': companyID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  //UPDATE CLIENT ARCHIVE STATUS
  Future<String> updateCompanyArchiveStatus(String companyID, bool isArchived) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_COMPANY_ARCHIVE',
      'companyID': companyID,
      'isArchived': isArchived ? '1' : '0',
    };

    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('status')) {
        return data['status']; // success or error
      }
    }
    return 'error';
  }
  
  //GET Active Companies 
  Future<List<Map<String, dynamic>>> getActiveCompanies() async {
    var map = {'action': 'GET_ACTIVE_COMPANIES'};
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  //GET Archived Companies
  Future<List<Map<String, dynamic>>> getArchivedCompanies() async {
    var map = {'action': 'GET_ARCHIVED_COMPANIES'};
    var response = await http.post(Uri.parse(ROOT), body: map);
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  //Müvekkile dosya talebi gönderme
  Future<void> sendFileRequest({
    required String adminID,
    required String companyID,
    required List<String> requestedFiles,
  }) async {
    var map = <String, dynamic>{
      'action': 'SEND_FILE_REQUEST',
      'adminID': adminID,
      'companyID': companyID,
      'requestedFiles': requestedFiles.join(','), // Virgülle ayır
    };

    var response = await http.post(Uri.parse(ROOT), body: map);

    if (response.statusCode == 200) {
      if (response.body.trim() == 'success') {
        return;
      } else {
        throw Exception("Dosya talebi başarısız: ${response.body}");
      }
    } else {
      throw Exception("Sunucu hatası: ${response.statusCode}");
    }
  }

  //Muhasebe tarafından gönderilen dosya taleplerini alma
  Future<List<Map<String, dynamic>>> getFileRequestsForCompany(String companyID) async {
    var map = <String, dynamic>{
      'action': 'GET_FILE_REQUESTS',
      'companyID': companyID,
    };

    var response = await http.post(Uri.parse(ROOT), body: map);

    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else {
          throw Exception("Gelen veri liste değil");
        }
      } catch (e) {
        throw Exception("JSON çözümlenemedi: $e");
      }
    } else {
      throw Exception("Talepler alınamadı (HTTP ${response.statusCode})");
    }
  }

  //UPDATE ACCOUNTANT SUBSCRIPTION EXPIRY DATE
  Future<String> updateAdminExpiryDate(String adminID, String adminExpiryDate) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_EXPIRYDATE',
      'adminID': adminID,
      'adminExpiryDate': adminExpiryDate,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  // GET ALL ACCOUNTANTS
  Future<List<Map<String, dynamic>>> getAdmins() async {
    var map = <String, dynamic>{ 'action': 'GET_ADMINS' };
    var response = await http.post(Uri.parse(ROOT), body: map);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          return [];
        } else {
          return [];
        }
      } else if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  //GET SPECIFIC ACCOUNTANT DETAILS
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

  //UPDATE ACCOUNTANT PASSWORD
  Future<String> updateAdminPassword(String adminID, String newPassword) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_ADMIN_PASSWORD',
      'adminID': adminID,
      'newPassword': newPassword,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('status')) {
        return data['status'] == 'success' ? 'success' : 'error';
      } else {
        return 'error';
      }
    } else {
      return 'error';
    }
  } 
  
  //------------------ COMPANIES ------------------//
  //CREATE CLIENT ACCOUNT
  Future<String> createCompany(String uid, String companyName, String companyAdmin, String companyMessage, String companyPassword, String companyFiles) async {
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

  //UPDATE CLIENT DETAILS
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

  //UPDATE CLIENT'S ADMIN
  Future<String> updateCompanyAdmin(String companyID, String companyAdmin) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_COMPANY_ADMIN',
      'companyID': companyID,
      'companyAdmin': companyAdmin,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  //UPDATE CLIENT FILES
  Future<String> updateCompanyFiles(String companyID, String companyFiles) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_COMPANY_FILES',
      'companyID': companyID,
      'companyFiles': companyFiles,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  // UPDATE CLIENT MESSAGE
  Future<String> updateCompanyMessage(String companyID, String companyMessage) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_COMPANY_MESSAGE',
      'companyID': companyID,
      'companyMessage': companyMessage,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  //GET ALL CLIENTS
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

  //GET SPECIFIC CLIENT DETAILS
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

  //DELETE THE GIVEN CLIENT
  Future<String> deleteCompany(String companyID) async {
    var map = <String, dynamic>{
      'action': 'DELETE_COMPANY',
      'companyID': companyID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }


  //------------------ FILES ------------------//
  // CREATE_FILE dosya upload ettiği için normal bir POST'tan farklı olacaktır.
  // Burada http paketini kullanırken multipart istek yapmamız gerekebilir.

  //UPLOAD FILE AND ADD TO ITS ACCOUNTANT AND CLIENT
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

  //UPDATE FILE DETAILS
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

  //DELETE THE GIVEN FILE
  Future<String> deleteFile(String fileID) async {
    var map = <String, dynamic>{
      'action': 'DELETE_FILE',
      'fileID': fileID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  //GET ALL FILES
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

  // GET SPECIFIC FILE DETAILS
  Future<Map<String, dynamic>> getFile(String fileID) async {
    var map = <String, dynamic>{
      'action': 'GET_FILE',
      'fileID': fileID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      if (response.body.trim() == "[]") return {};
      var data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return {};
  }

  //------------------ MESSAGES ------------------//

  //CREATE CHAT ROOM BETWEEN CLIENT AND ACCOUNTANT
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
    return response.statusCode == 200 ? uid : 'error';
  }

  //UPDATE MESSAGES OF CHAT ROOM
  Future<String> updateConversationMessages(String messageUID, String messageList) async {
    var map = <String, dynamic>{
      'action': 'UPDATE_CONVERSATION_MESSAGES',
      'messageUID': messageUID,
      'messageList': messageList,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  //DELETE CHAT ROOM
  Future<String> deleteConversation(String messageUID) async {
    var map = <String, dynamic>{
      'action': 'DELETE_CONVERSATION',
      'messageUID': messageUID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    return response.statusCode == 200 ? response.body : 'error';
  }

  //GET ALL CHAT ROOMS
  Future<List<Map<String, dynamic>>> getMessages() async {
    var map = <String, dynamic>{
      'action': 'GET_MESSAGES',
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      return [];
    }
  }

  //GET SPECIFIC CHAT ROOM
  Future<Map<String, dynamic>> getMessage(String messageID) async {
    var map = <String, dynamic>{
      'action': 'GET_MESSAGE_DETAILS',
      'messageID': messageID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      if (response.body.trim() == "[]") return {};
      var data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) {
        return data;
      }
    }
    return {};
  }

  // Muhasebeciden gelen okunmamış mesaj var mı diye kontrol eder
  Future<bool> hasUnreadMessagesFromAccountant(String companyID) async {
    var map = <String, dynamic>{
      'action': 'CHECK_UNREAD_MESSAGES_FROM_ACCOUNTANT',
      'companyID': companyID,
    };
    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      try {
        var data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data.containsKey('unreadCount')) {
          return (data['unreadCount'] as int) > 0;
        }
      } catch (e) {
        print("JSON parsing error in hasUnreadMessagesFromAccountant: $e");
      }
    }
    return false;
  }


  //------------------ AUTHENTICATE_USER ------------------//
  //CHECKS USER CREDENTIALS
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
      if (data is Map && data.containsKey('status')) {
        return data['status'] == 'true';
      }
    }
    return false;
  }
  // Mark a file request as completed
  Future<String> markFileRequestCompleted(String requestId) async {
    var map = <String, dynamic>{
      'action': 'MARK_FILE_REQUEST_COMPLETED',
      'requestID': requestId,
    };

    var response = await http.post(Uri.parse(ROOT), body: map);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('status')) {
        return data['status'];
      }
    }
    return 'error';
  }
}