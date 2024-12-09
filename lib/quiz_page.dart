import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_state.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _quizCompleted = false;

  final List<Map<String, dynamic>> _allQuestions = [
    {'question': 'What color is the sky?', 'options': ['Red', 'Green', 'Blue', 'Yellow'], 'answer': 'Blue'},
    {'question': 'How many legs does a spider have?', 'options': ['4', '6', '8', '10'], 'answer': '8'},
    {'question': 'What is 2 + 2?', 'options': ['3', '4', '5', '6'], 'answer': '4'},
    // ...add more questions up to 100 total...
    {'question': 'What is the capital of France?', 'options': ['Berlin', 'London', 'Paris', 'Rome'], 'answer': 'Paris'},
    {'question': 'Which animal is known as the "King of the Jungle"?', 'options': ['Elephant', 'Lion', 'Tiger', 'Giraffe'], 'answer': 'Lion'},
    // Ensure there are 100 questions in total
  ];

  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _generateRandomQuestions();
  }

  void _generateRandomQuestions() {
    _allQuestions.shuffle();
    _questions = _allQuestions.take(5).toList();
  }

  void _checkAnswer(String selectedOption) {
    if (selectedOption == _questions[_currentQuestionIndex]['answer']) {
      _score++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
      // Update quiz progress in AuthState
      context.read<AuthState>().markQuizCompleted();
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _quizCompleted = false;
    });
    _generateRandomQuestions(); // Regenerate random questions on reset
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quiz'),
        backgroundColor: Colors.orange,
      ),
      body: _quizCompleted
          ? _buildQuizResult()
          : _buildQuizQuestion(),
    );
  }

  Widget _buildQuizQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          Text(
            _questions[_currentQuestionIndex]['question'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Column(
            children: _questions[_currentQuestionIndex]['options'].map<Widget>((option) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[400],
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: () => _checkAnswer(option),
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Quiz Completed!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            'Your Score: $_score / ${_questions.length}',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _resetQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[700],
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'Retake Quiz',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
