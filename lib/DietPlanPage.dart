import 'package:flutter/material.dart';
import 'DoctorMapScreen.dart';
import 'ChatBotPage.dart';

class DietPlanPage extends StatelessWidget {
  const DietPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan'),
        backgroundColor: Colors.purple.shade300,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDietPlanSection(),
            _buildNutritionSpecialistsMap(context),
            _buildHealthyMealsSection(),
            _buildNutritionChatBot(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDietPlanSection() {
    final List<Map<String, String>> dietPlans = [
      {
        'title': 'Mediterranean Diet Plan',
        'description':
            'Rich in fruits, vegetables, whole grains, and healthy fats',
      },
      {
        'title': 'Ketogenic Diet Plan',
        'description':
            'Low in carbs, moderate in protein, and high in healthy fats',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diet Plans',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...dietPlans.map(
            (plan) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan['description']!,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade200,
                      ),
                      child: const Text('View Full Plan'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSpecialistsMap(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition Specialists Near You',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            items:
                <String>['All', 'Nutritionist', 'Dietitian'].map((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (_) {},
            hint: const Text('Filter by Specialty'),
          ),
          SizedBox(
            height: 200,
            child: DoctorMapScreen(
              doctors: [
                {
                  'name': 'Dr. Emma Wilson',
                  'specialty': 'Nutritionist',
                  'distance': 1.8,
                },
                {
                  'name': 'Dr. Robert Brown',
                  'specialty': 'Dietitian',
                  'distance': 2.2,
                },
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthyMealsSection() {
    final List<Map<String, dynamic>> meals = [
      {
        'name': 'Greek Yogurt Parfait',
        'calories': 320,
        'nutrients': ['Protein', 'Calcium', 'Probiotics'],
        'type': 'Breakfast',
      },
      {
        'name': 'Grilled Salmon with Quinoa',
        'calories': 450,
        'nutrients': ['Omega-3', 'Protein', 'Fiber'],
        'type': 'Lunch/Dinner',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Healthy Meal Suggestions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...meals.map(
            (meal) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          color: Colors.purple.shade300,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Type: ${meal['type']}',
                                overflow: TextOverflow.visible,
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${meal['calories']} cal',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children:
                            (meal['nutrients'] as List<String>)
                                .map(
                                  (nutrient) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Chip(
                                      label: Text(
                                        nutrient,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      backgroundColor: Colors.purple.shade50,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionChatBot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nutrition ChatBot',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthChatBot(topic: 'Nutrition Coach'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade300,
            ),
            child: const Text('Ask Nutrition Questions'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
