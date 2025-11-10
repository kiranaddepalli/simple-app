import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/credentials_screen.dart';
import 'screens/health_agent_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth provider
  final authProvider = AuthProvider();
  await authProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CVS Health Wallet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFCC0000),
          secondary: const Color(0xFF17447C),
          error: Colors.red,
          tertiary: Colors.blue,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFCC0000),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const WalletApp(),
    );
  }
}

class WalletApp extends StatefulWidget {
  const WalletApp({super.key});

  @override
  State<WalletApp> createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  bool _showWelcome = true;
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show welcome screen first
        if (_showWelcome && !authProvider.isAuthenticated) {
          return WelcomeScreen(
            onGetStarted: () {
              setState(() {
                _showWelcome = false;
                _isVerifying = false;
              });
            },
            onVerify: () {
              setState(() {
                _showWelcome = false;
                _isVerifying = true;
              });
            },
          );
        }

        // Show sign-in if not authenticated
        if (!authProvider.isAuthenticated) {
          return SignInScreen(
            authProvider: authProvider,
            isVerifyMode: _isVerifying,
            onAuthenticated: () {
              // Rebuild when authenticated
              setState(() {
                _showWelcome = false;
              });
            },
            onBackToWelcome: () {
              setState(() {
                _showWelcome = true;
              });
            },
          );
        }

        // Show main wallet app when authenticated
        return MainWalletApp(
          onLogout: () {
            setState(() {
              _showWelcome = true;
            });
          },
        );
      },
    );
  }
}

class MainWalletApp extends StatefulWidget {
  final Function? onLogout;

  const MainWalletApp({
    super.key,
    this.onLogout,
  });

  @override
  State<MainWalletApp> createState() => _MainWalletAppState();
}

class _MainWalletAppState extends State<MainWalletApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer2<WalletProvider, AuthProvider>(
      builder: (context, walletProvider, authProvider, _) {
        final screens = [
          HomeScreen(
            credentials: walletProvider.credentials,
          ),
          CredentialsScreen(
            credentials: walletProvider.credentials,
            onAddCredential: _handleAddCredential,
          ),
          HealthAgentScreen(
            did: authProvider.getDID(),
            onAppointmentBooked: (credential) => walletProvider.addCredential(credential),
          ),
          SettingsScreen(
            authProvider: authProvider,
            onLogout: _handleLogout,
          ),
        ];

        return Scaffold(
          body: screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFFCC0000),
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_membership),
                label: 'Credentials',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety),
                label: 'Health Agent',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout() {
    // Call parent's onLogout callback which will navigate back to welcome
    if (widget.onLogout != null) {
      widget.onLogout!();
    }
  }

  Future<void> _handleAddCredential(String qrData) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VerificationScreen(
        onVerify: () => context.read<WalletProvider>().scanAndAddCredential(qrData),
        verificationMessage: 'Adding new credential...',
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credential added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
