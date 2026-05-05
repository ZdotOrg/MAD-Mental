import 'package:flutter/material.dart';
import 'package:mental_zen/models/mindfulness_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceDetailScreen extends StatefulWidget {
  final MindfulnessResource resource;

  const ResourceDetailScreen({
    super.key,
    required this.resource,
  });

  @override
  State<ResourceDetailScreen> createState() => _ResourceDetailScreenState();
}

class _ResourceDetailScreenState extends State<ResourceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.resource.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Play Button
              GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(widget.resource.fileUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Container(
                  height: 200,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_filled, size: 64, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        widget.resource.type == MindfulnessType.video
                            ? 'Tap to Watch on YouTube'
                            : '🎧 Audio Resource',
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content - FIXED: Wrapped in Expanded
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(widget.resource.categoryIcon, color: Colors.white.withOpacity(0.8), size: 20),
                          const SizedBox(width: 8),
                          Text(widget.resource.categoryLabel, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(widget.resource.description, style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9), height: 1.6)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}