import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Douceur',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.light(
          primary: Color(0xFFE1BEE7), // Lavande clair
          secondary: Color(0xFFF8BBD0), // Rose poudré
          surface: Colors.white,
          background: Color(0xFFFAF5FF), // Blanc chaud légèrement teinté
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

class _PomodoroHomePageState extends State<PomodoroHomePage> with SingleTickerProviderStateMixin {
  static const int workDuration = 25 * 60; // 25 minutes en secondes
  static const int shortBreak = 5 * 60;    // 5 minutes
  static const int longBreak = 15 * 60;    // 15 minutes

  int secondsRemaining = workDuration;
  bool isActive = false;
  late Timer timer;
  int currentRound = 0;
  final int roundsBeforeLongBreak = 4;

  @override
  void initState() {
    super.initState();
    resetTimer();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void startTimer() {
    if (isActive) {
      timer.cancel();
    } else {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (secondsRemaining > 0) {
            secondsRemaining--;
          } else {
            timer.cancel();
            isActive = false;
            // Gérer la fin du timer
            if (currentRound % 2 == 0) {
              // C'était une période de travail
              currentRound++;
              secondsRemaining = (currentRound ~/ 2 + 1) % roundsBeforeLongBreak == 0 
                  ? longBreak 
                  : shortBreak;
            } else {
              // C'était une pause
              currentRound++;
              secondsRemaining = workDuration;
            }
          }
        });
      });
    }
    setState(() => isActive = !isActive);
  }

  void resetTimer() {
    timer.cancel();
    setState(() {
      isActive = false;
      secondsRemaining = workDuration;
    });
  }

  String formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final progress = 1 - (secondsRemaining / workDuration);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Titre
              Text(
                'Pomodoro Douceur',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ),
              ),
              
              // Compte à rebours circulaire
              Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle de fond
                  SizedBox(
                    width: size.width * 0.7,
                    height: size.width * 0.7,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                  
                  // Cercle intérieur
                  Container(
                    width: size.width * 0.6,
                    height: size.width * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatTime(secondsRemaining),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6A4C93),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isActive ? 'Travail en cours...' : 'Prêt à se concentrer',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Boutons de contrôle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Bouton Réinitialiser
                  FloatingActionButton(
                    heroTag: 'reset',
                    onPressed: resetTimer,
                    backgroundColor: Colors.white,
                    elevation: 2,
                    child: Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(width: 32),
                  
                  // Bouton Play/Pause
                  FloatingActionButton(
                    heroTag: 'playPause',
                    onPressed: startTimer,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 4,
                    child: Icon(
                      isActive ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
              
              // Indicateur de session
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Session ${(currentRound ~/ 2) + 1} • ${currentRound % 2 == 0 ? 'Travail' : 'Pause'}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
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
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
