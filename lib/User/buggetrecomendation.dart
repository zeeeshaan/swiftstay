import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BudgetRecommendation extends StatefulWidget {
  const BudgetRecommendation({super.key});

  @override
  State<BudgetRecommendation> createState() => _BudgetRecommendationState();
}

class _BudgetRecommendationState extends State<BudgetRecommendation> {
  final TextEditingController _numOfDaysController = TextEditingController();
  final TextEditingController _budgetPerPersonController = TextEditingController();
  final TextEditingController _numOfPeopleController = TextEditingController();

  bool _isLoading = false;
  Map<String, dynamic>? _recommendation;
  Future<void> _fetchRecommendation() async {
    setState(() {
      _isLoading = true;
      _recommendation = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://c18f-103-137-24-87.ngrok-free.app/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'num_of_days': int.parse(_numOfDaysController.text),
          'budget_per_person': int.parse(_budgetPerPersonController.text),
          'num_of_people': int.parse(_numOfPeopleController.text),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      setState(() {
        _isLoading = false;
        if (response.statusCode == 200) {
          _recommendation = jsonDecode(response.body);
        } else {
          _recommendation = {'message': 'Failed to get recommendations.'};
        }
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _recommendation = {'message': 'Error fetching recommendations.'};
      });
    }
  }


  Widget _buildTextField(
      {required String labelText,
        required TextEditingController controller,
        required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.blue),
          prefixIcon: Icon(icon, color: Colors.blue),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _recommendation?['Place'] ?? 'No Recommendation',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            if (_recommendation?['Hotel'] != null)
              Text(
                'Hotel: ${_recommendation!['Hotel'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 8.0),
            if (_recommendation?['EstimatedHotelCostPerNight'] != null)
              Text(
                'Estimated Hotel Cost Per Night: ${_recommendation!['EstimatedHotelCostPerNight'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
            const SizedBox(height: 8.0),
            if (_recommendation?['TotalHotelCost'] != null)
              Text(
                'Total Hotel Cost: ${_recommendation!['TotalHotelCost'] ?? 'N/A'}',
                style: const TextStyle(fontSize: 18),
              ),
            if (_recommendation?['message'] != null)
              Text(
                _recommendation!['message'] ?? '',
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField(
                labelText: 'Number of Days',
                controller: _numOfDaysController,
                icon: Icons.calendar_today,
              ),
              _buildTextField(
                labelText: 'Budget Per Person',
                controller: _budgetPerPersonController,
                icon: Icons.attach_money,
              ),
              _buildTextField(
                labelText: 'Number of People',
                controller: _numOfPeopleController,
                icon: Icons.people,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  onPressed: _fetchRecommendation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Get Recommendation'),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_recommendation != null)
                _buildRecommendationCard(),
            ],
          ),
        ),
      ),
    );
  }
}
