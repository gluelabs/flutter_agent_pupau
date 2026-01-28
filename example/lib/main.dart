import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/flutter_agent_pupau.dart';

// Replace with your assistant API key
const String assistantApiKey = 'your-api-key-here';

// Create the configuration for the assistant
final PupauConfig pupauConfig = PupauConfig.createWithApiKey(
  apiKey: assistantApiKey,
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pupau Agent Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff121299)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pupau Agent Example',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Add the PupauAgentAvatar widget with the configuration
            PupauAgentAvatar(
              config: pupauConfig,
            ),
          ],
        ),
      ),
    );
  }
}
