import 'package:flutter/material.dart';
import 'DoctorMapScreen.dart';
import 'ChatBotPage.dart';

class DietPlantPage extends StatelessWidget {
  final List<Map<String, String>> articles = [
    {
      'title': 'Benefits of a Balanced Diet',
      'image': 'assets/images/diet1.png',
    },
    {'title': 'Top 10 Superfoods', 'image': 'assets/images/diet2.png'},
  ];

  final List<Map<String, String>> foodSuggestions = [
    {'name': 'Avocado Toast', 'image': 'assets/images/food1.png'},
    {'name': 'Quinoa Salad', 'image': 'assets/images/food2.png'},
  ];

  DietPlantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diet Quick Actions'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDietArticlesSection(),
            _buildNutritionDoctorsMap(context),
            _buildHealthyFoodSuggestions(),
            _buildNutritionChatBot(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDietArticlesSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diet Articles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...articles.map(
            (article) => Card(
              child: ListTile(
                leading: Image.asset(article['image']!),
                title: Text(article['title']!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionDoctorsMap(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Doctors Near You',
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
            hint: Text('Filter by Specialty'),
          ),
          SizedBox(
            height: 200,
            child: DoctorMapScreen(
              doctors: [
                {
                  'name': 'Dr. Smith',
                  'specialty': 'Nutritionist',
                  'distance': 2.5,
                },
                {
                  'name': 'Dr. Johnson',
                  'specialty': 'Dietitian',
                  'distance': 3.0,
                },
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthyFoodSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Healthy Food Suggestions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...foodSuggestions.map(
            (food) => Card(
              child: ListTile(
                leading: Image.asset(food['image']!),
                title: Text(food['name']!),
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
          Text(
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
            child: Text('Open ChatBot'),
          ),
        ],
      ),
    );
  }
}
