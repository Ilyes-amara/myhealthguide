import 'package:flutter/material.dart';
import 'DoctorMapScreen.dart';
import 'ChatBotPage.dart';

class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Quick Actions'),
        backgroundColor: Colors.blue.shade300,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWorkoutArticlesSection(),
            _buildFitnessDoctorsMap(context),
            _buildGymsNearYou(),
            _buildWorkoutChatBot(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutArticlesSection() {
    final List<Map<String, String>> articles = [
      {
        'title': 'How to Build Muscle Fast',
        'image': 'assets/images/workout1.png',
      },
      {
        'title': 'The Ultimate HIIT Workout Guide',
        'image': 'assets/images/workout2.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout Articles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...articles.map(
            (article) => Card(
              child: ListTile(
                leading: Icon(
                  Icons.fitness_center,
                  color: Colors.blue.shade400,
                ),
                title: Text(article['title']!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessDoctorsMap(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fitness Specialists Near You',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            items:
                <String>['All', 'Physical Therapist', 'Sports Medicine'].map((
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
                  'name': 'Dr. Mike Ross',
                  'specialty': 'Sports Medicine',
                  'distance': 1.2,
                },
                {
                  'name': 'Dr. Sarah Lee',
                  'specialty': 'Physical Therapist',
                  'distance': 2.8,
                },
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGymsNearYou() {
    final List<Map<String, dynamic>> gyms = [
      {
        'name': 'FitZone Gym',
        'distance': '0.8 km',
        'rating': 4.5,
        'specialties': ['Weightlifting', 'Cardio', 'Yoga'],
      },
      {
        'name': 'PowerFit Center',
        'distance': '1.5 km',
        'rating': 4.7,
        'specialties': ['CrossFit', 'Boxing', 'Swimming'],
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gyms Near You',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ...gyms.map(
            (gym) => Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.fitness_center, color: Colors.blue.shade400),
                        SizedBox(width: 8),
                        Text(
                          gym['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Text(
                          gym['distance'],
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber.shade300,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text('${gym['rating']}'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children:
                          (gym['specialties'] as List<String>)
                              .map(
                                (specialty) => Chip(
                                  label: Text(
                                    specialty,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.blue.shade50,
                                ),
                              )
                              .toList(),
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

  Widget _buildWorkoutChatBot(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fitness ChatBot',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthChatBot(topic: 'Fitness Coach'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade300,
            ),
            child: Text('Ask Fitness Questions'),
          ),
        ],
      ),
    );
  }
}
