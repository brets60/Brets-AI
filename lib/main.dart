import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/call_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_screen.dart';
import 'models/models.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BretaAiApp());
}

class BretaAiApp extends StatelessWidget {
  const BretaAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brets AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  String _activeScenario = 'Talk about anything';
  List<FeedbackItem> _currentSessionMistakes = [];

  // Authentication State
  bool _isAuthenticated = false;
  String _userName = '';
  String _userEmail = '';
  String _authProvider = '';

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _startCallWithScenario(String scenario) {
    setState(() {
      _activeScenario = scenario;
      _currentSessionMistakes = [];
      _currentIndex = 1; // Go to Call screen
    });
  }

  void _endCallToFeedback(List<FeedbackItem> mistakes) {
    setState(() {
      _currentSessionMistakes = mistakes;
      _currentIndex = 2; // Go to Feedback screen
    });
  }

  void _handleAuthSuccess(String name, String email, String provider) {
    setState(() {
      _userName = name;
      _userEmail = email;
      _authProvider = provider;
      _isAuthenticated = true;
      _currentIndex = 0;
    });
  }

  void _handleSignOut() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If not authenticated, render Login & Registration Screen
    if (!_isAuthenticated) {
      return AuthScreen(onAuthSuccess: _handleAuthSuccess);
    }

    final List<Widget> screens = [
      HomeScreen(
        userName: _userName,
        onNavigate: _onTabSelected,
        onStartCall: _startCallWithScenario,
      ),
      CallScreen(
        userName: _userName,
        scenarioTitle: _activeScenario,
        onEndCallWithMistakes: _endCallToFeedback,
        onBack: () => _onTabSelected(0),
      ),
      FeedbackScreen(
        onViewProgress: () => _onTabSelected(3),
        sessionMistakes: _currentSessionMistakes,
      ),
      ProgressScreen(
        onBackToHome: () => _onTabSelected(0),
      ),
      ProfileScreen(
        userName: _userName,
        userEmail: _userEmail,
        authProvider: _authProvider,
        onSignOut: _handleSignOut,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0F121F),
          border: Border(
            top: BorderSide(color: Color(0xFF1E2438), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabSelected,
          backgroundColor: const Color(0xFF0F121F),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.phone_in_talk_rounded),
              activeIcon: Icon(Icons.phone_in_talk_rounded),
              label: 'Live Call',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_rounded),
              activeIcon: Icon(Icons.fact_check_rounded),
              label: 'Feedback',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_rounded),
              activeIcon: Icon(Icons.insights_rounded),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
