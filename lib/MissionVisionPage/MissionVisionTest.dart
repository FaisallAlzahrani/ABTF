import 'package:flutter/material.dart';

class MissionVisionPage extends StatefulWidget {
  const MissionVisionPage({super.key});

  @override
  State<MissionVisionPage> createState() => _MissionVisionPageState();
}

class _MissionVisionPageState extends State<MissionVisionPage> {
  void showDialogText(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        content: Text(
          content,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            child: const Text("Close", style: TextStyle(color: Colors.blue)),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const missionText =
        "To provide innovative, high-quality lighting products with flexible, "
        "smarter and greener solutions that provide superior performance "
        "and greater value to meet our customers expectations.";

    const visionText =
        "To become the preferred and most trusted partner while increasing "
        "market share and shareholder value.";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text(
          'Mission and Vision',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assest/images/r7.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mission button
              MaterialButton(
                elevation: 2,
                color: Colors.white70,
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 140),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                onPressed: () => showDialogText("Mission", missionText),
                child: const Text(
                  "Mission",
                  style: TextStyle(
                      color: Color(0xFF104164),
                      fontWeight: FontWeight.bold,
                      fontSize: 19),
                ),
              ),

              const SizedBox(height: 20),

              // Vision button
              MaterialButton(
                elevation: 2,
                color: Colors.white70,
                padding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 140),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                onPressed: () => showDialogText("Vision", visionText),
                child: const Text(
                  "Vision",
                  style: TextStyle(
                      color: Color(0xFF104164),
                      fontWeight: FontWeight.bold,
                      fontSize: 19),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
