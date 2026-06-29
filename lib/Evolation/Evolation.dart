import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../login/user_provider.dart';


class EvaluationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF104164);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: brandColor),
        title: const Text(
          'Employee Evaluation',
          style: TextStyle(
            color: brandColor,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: EvaluationForm(),
      ),
    );
  }
}
String? username;
class EvaluationForm extends StatefulWidget {

  @override
  _EvaluationFormState createState() => _EvaluationFormState();
}

class _EvaluationFormState extends State<EvaluationForm> {
  Map<String, int> ratings = {};

  void _setRating(String question, int rating) {
    setState(() {
      ratings[question] = rating;
    });
  }
  void _submitEvaluation() {
    // TODO: Implement the submission logic
    // You can access the ratings map to retrieve the evaluations
  }

  @override
  Widget build(BuildContext context) {
    username = Provider.of<UserProvider>(context).firstName;
    const brandColor = Color(0xFF104164);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double contentWidth = maxWidth.clamp(0, 720);
        final double horizontalPadding = (maxWidth * 0.04).clamp(12.0, 20.0);

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 12),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: brandColor.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: brandColor.withOpacity(0.12)),
                        ),
                        child: const Icon(Icons.fact_check_outlined, color: brandColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: brandColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please rate the following questions from 0 to 5',
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.55),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                EvaluationQuestion(
                  question: 'How would you rate your overall experience using the app ?',
                  rating: ratings['one'] ?? 0,
                  onChanged: (rating) {
                    _setRating('one', rating);
                  },
                ),
                EvaluationQuestion(
                  question: 'Did you encounter any difficulties while using app ?',
                  rating: ratings['two'] ?? 0,
                  onChanged: (rating) {
                    _setRating('two', rating);
                  },
                ),
                EvaluationQuestion(
                  question: 'How do you rate the apps performance in terms of speed and responsiveness? ',
                  rating: ratings['three'] ?? 0,
                  onChanged: (rating) {
                    _setRating('three', rating);
                  },
                ),
                EvaluationQuestion(
                  question: 'Do you feel that the app helps increase your productivity or streamline your daily tasks ? ',
                  rating: ratings['four'] ?? 0,
                  onChanged: (rating) {
                    _setRating('four', rating);
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitEvaluation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EvaluationQuestion extends StatelessWidget {
  final String question;
  final int rating;
  final ValueChanged<int> onChanged;

  const EvaluationQuestion({
    required this.question,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF104164);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.lightBlue[50],
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: brandColor.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: const TextStyle(
                  color: brandColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      onChanged(rating > 0 ? rating - 1 : 0);
                    },
                    icon: const Icon(Icons.remove_circle_outline, color: brandColor),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: brandColor,
                          inactiveTrackColor: brandColor.withOpacity(0.20),
                          thumbColor: brandColor,
                          overlayColor: brandColor.withOpacity(0.10),
                          trackHeight: 4,
                        ),
                        child: Slider(
                          value: rating.toDouble(),
                          min: 0,
                          max: 5,
                          divisions: 5,
                          onChanged: (value) {
                            onChanged(value.round());
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      onChanged(rating < 5 ? rating + 1 : 5);
                    },
                    icon: const Icon(Icons.add_circle_outline, color: brandColor),
                  ),
                  Container(
                    width: 42,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: brandColor.withOpacity(0.12)),
                    ),
                    child: Text(
                      '$rating',
                      style: const TextStyle(
                        color: brandColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
