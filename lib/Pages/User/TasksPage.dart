import 'package:flutter/material.dart';
import '../../../Services/Database/DatabaseHelper.dart';

class TasksDialog extends StatefulWidget {
  final String companyId;

  const TasksDialog({Key? key, required this.companyId}) : super(key: key);

  @override
  State<TasksDialog> createState() => _TasksDialogState();
}

class _TasksDialogState extends State<TasksDialog> {
  List<Map<String, dynamic>> fileRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    try {
      final requests = await DatabaseHelper().getFileRequestsForCompany(widget.companyId);
      setState(() {
        fileRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      print("Hata: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markTaskCompleted(String requestId) async {
    try {
      final result = await DatabaseHelper().markFileRequestCompleted(requestId);
      if (result == 'success') {
        await loadRequests();
      } else {
        print("Görev güncellenemedi: $result");
      }
    } catch (e) {
      print("Hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Görevler"),
      content: SizedBox(
        width: double.maxFinite,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : fileRequests.isEmpty
                ? const Text("Görev bulunamadı.")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: fileRequests.length,
                    itemBuilder: (context, index) {
                      final task = fileRequests[index];
                      final requestedFiles = (task["requestedFiles"] as String?)?.split(",") ?? [];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.task),
                        title: const Text("Görev"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: requestedFiles.map((file) => Text("• ${file.trim()}")).toList(),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            task["status"] == "tamamlandı"
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: task["status"] == "tamamlandı"
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onPressed: () {
                            if (task["status"] != "tamamlandı") {
                              _markTaskCompleted(task["requestID"].toString());
                            }
                          },
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Kapat"),
        ),
      ],
    );
  }
}