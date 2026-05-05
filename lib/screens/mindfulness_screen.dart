import 'package:flutter/material.dart';
import 'package:mental_zen/models/mindfulness_model.dart';
import 'package:mental_zen/services/mindfulness_service.dart';
import 'package:mental_zen/screens/resource_detail_screen.dart';

class MindfulnessScreen extends StatefulWidget {
  const MindfulnessScreen({super.key});

  @override
  State<MindfulnessScreen> createState() => _MindfulnessScreenState();
}

class _MindfulnessScreenState extends State<MindfulnessScreen> {
  final MindfulnessService _mindfulnessService = MindfulnessService();
  MindfulnessCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mindfulness Library',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore curated resources for your mental wellness',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search resources...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            // Category filter
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('All', null),
                  ...MindfulnessCategory.values.map((category) {
                    return _buildCategoryChip(
                      _getCategoryLabel(category),
                      category,
                    );
                  }),
                ],
              ),
            ),

            // Resources grid
            Expanded(
              child: StreamBuilder<List<MindfulnessResource>>(
                stream: _selectedCategory != null
                    ? _mindfulnessService
                        .getResourcesByCategory(_selectedCategory!)
                    : _mindfulnessService.getResourcesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.self_improvement,
                              size: 64, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No resources found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  var resources = snapshot.data!;
                  
                  // Apply search filter
                  if (_searchQuery.isNotEmpty) {
                    resources = resources.where((r) {
                      return r.title.toLowerCase().contains(_searchQuery) ||
                          r.description.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (resources.isEmpty) {
                    return Center(
                      child: Text(
                        'No results for "$_searchQuery"',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: resources.length,
                    itemBuilder: (context, index) {
                      return _buildResourceCard(resources[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, MindfulnessCategory? category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: Colors.white,
        checkmarkColor: const Color(0xFF667EEA),
        backgroundColor: Colors.white.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF667EEA) : Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildResourceCard(MindfulnessResource resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _mindfulnessService.incrementViewCount(resource.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResourceDetailScreen(resource: resource),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon based on type
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  resource.type == MindfulnessType.video
                      ? Icons.play_circle_filled
                      : Icons.headphones,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resource.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(resource.categoryIcon, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          resource.categoryLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.timer, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          resource.formattedDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryLabel(MindfulnessCategory category) {
    return MindfulnessResource(
      id: '',
      title: '',
      description: '',
      type: MindfulnessType.audio,
      category: category,
      fileUrl: '',
      durationSeconds: 0,
      createdAt: DateTime.now(),
    ).categoryLabel;
  }
}