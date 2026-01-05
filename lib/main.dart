import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Timer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: const Color(0xFFE1BEE7), // Light Lavender
          secondary: const Color(0xFFF8BBD0), // Pink
          surface: const Color(0xFFFFF9C4), // Light Yellow
          background: const Color(0xFFFFF5F5), // Warm White
          onBackground: const Color(0xFF6A1B9A), // Deep Purple
          onSurface: const Color(0xFF6A1B9A), // Deep Purple
        ),
        textTheme: GoogleFonts.nunitoTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: const Color(0xFF6A1B9A),
            displayColor: const Color(0xFF6A1B9A),
          ),
        ),
        useMaterial3: true,
      ),
      home: const PomodoroHomePage(),
    );
  }
}

class PomodoroHomePage extends StatefulWidget {
  const PomodoroHomePage({super.key});

  @override
  State<PomodoroHomePage> createState() => _PomodoroHomePageState();
}

class _PomodoroHomePageState extends State<PomodoroHomePage> {
  final CountDownController _controller = CountDownController();
  bool _isRunning = false;
  final int _workDuration = 25 * 60; // 25 minutes in seconds
  final int _breakDuration = 5 * 60; // 5 minutes in seconds
  bool _isWorkTime = true;

  String _formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onComplete() {
    Vibration.vibrate(duration: 1000);
    setState(() {
      _isRunning = false;
      _isWorkTime = !_isWorkTime;
    });
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _isWorkTime ? 'Heure de la pause!' : 'Temps de travail!',
            style: const TextStyle(
              color: Color(0xFF6A1B9A),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            _isWorkTime
                ? 'Faites une petite pause !'
                : 'Il est temps de se concentrer ! Votre pause est terminée.',
            style: const TextStyle(color: Color(0xFF6A1B9A)),
            textAlign: TextAlign.center,
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _controller.restart(
                    duration: _isWorkTime ? _workDuration : _breakDuration,
                  );
                  setState(() {
                    _isRunning = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE1BEE7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'COMMENCER',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Title
            Text(
              _isWorkTime ? 'Temps de concentration' : 'Temps de pause',
              style: GoogleFonts.nunito(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),

            // Circular Timer
            Container(
              padding: const EdgeInsets.all(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),

                  // Timer
                  CircularCountDownTimer(
                    duration: _isWorkTime ? _workDuration : _breakDuration,
                    initialDuration: 0,
                    controller: _controller,
                    width: 250,
                    height: 250,
                    ringColor: Colors.grey[300]!,
                    fillColor: _isWorkTime
                        ? const Color(0xFFE1BEE7).withOpacity(0.8)
                        : const Color(0xFFF8BBD0).withOpacity(0.8),
                    backgroundColor: Colors.transparent,
                    strokeWidth: 15,
                    strokeCap: StrokeCap.round,
                    textStyle: GoogleFonts.nunito(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                    textFormat: CountdownTextFormat.MM_SS,
                    isReverse: true,
                    onComplete: _onComplete,
                    autoStart: false,
                  ),
                ],
              ),
            ),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Reset Button
                _buildButton(
                  icon: Icons.refresh,
                  onPressed: () {
                    _controller.restart(
                      duration: _isWorkTime ? _workDuration : _breakDuration,
                    );
                    setState(() {
                      _isRunning = false;
                    });
                  },
                ),

                // Play/Pause Button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _isRunning
                            ? const Color(0xFFF8BBD0).withOpacity(0.5)
                            : const Color(0xFFE1BEE7).withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: FloatingActionButton.large(
                    onPressed: () {
                      if (_isRunning) {
                        _controller.pause();
                      } else {
                        _controller.resume();
                      }
                      setState(() {
                        _isRunning = !_isRunning;
                      });
                    },
                    backgroundColor: _isRunning
                        ? const Color(0xFFF8BBD0)
                        : const Color(0xFFE1BEE7),
                    child: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Skip Button
                _buildButton(
                  icon: Icons.skip_next,
                  onPressed: () {
                    _controller.pause();
                    setState(() {
                      _isRunning = false;
                      _isWorkTime = !_isWorkTime;
                    });
                    _controller.restart(
                      duration: _isWorkTime ? _workDuration : _breakDuration,
                    );
                  },
                ),
              ],
            ),

            // Status Text
            Text(
              _isWorkTime ? 'Concentrez-vous sur votre tâche !' : 'Faites une pause !',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 32,
        color: Theme.of(context).colorScheme.onBackground,
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(15),
        shape: const CircleBorder(),
      ),
    );
  }
}
