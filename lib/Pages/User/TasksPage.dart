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
                        trailing: Chip(
                          label: Text(task["status"] ?? "Bekliyor"),
                          backgroundColor: task["status"] == "Tamamlandı"
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
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