import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyB0U_0oapYhrXa_f_5dq2FOagWkWwNxUWs",
      appId: "1:1065757824768:web:b3a4e0a65aa48e500a05e5",
      messagingSenderId: "1065757824768",
      projectId: "spacenews-webground",
    ),
  );
  
  runApp(const SpaceNewsApp());
}

const Color kPrimaryColor = Color(0xFF0A5C9A); 
const Color kBackgroundColor = Color(0xFFF4F7F6); 
const Color kSurfaceColor = Colors.white;
const Color kSecondaryTextColor = Color(0xFF718096); 

class SpaceNewsApp extends StatelessWidget {
  const SpaceNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceNews Core',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Update Tema Warna Global agar tidak kaku
        primaryColor: kPrimaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryColor),
        scaffoldBackgroundColor: kBackgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: kSurfaceColor,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurfaceColor,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          prefixIconColor: kPrimaryColor,
          labelStyle: const TextStyle(color: kSecondaryTextColor),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    await Future.delayed(const Duration(seconds: 3));
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn && FirebaseAuth.instance.currentUser != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://img.freepik.com/free-vector/shopping-cart-logo-design-template_474888-2009.jpg', 
              width: 150,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.rocket_launch, size: 100, color: kPrimaryColor.withOpacity(0.5)),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(color: kPrimaryColor),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua kolom harus diisi!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pendaftaran Berhasil! Silakan Login.')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://img.freepik.com/free-vector/shopping-cart-logo-design-template_474888-2009.jpg', 
                  width: 90,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.rocket_launch, size: 70, color: kPrimaryColor.withOpacity(0.5)),
                ),
                const SizedBox(height: 24),
                const Text('Create Account', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                const Text('Sign up to join SpaceNews Core', style: TextStyle(color: kSecondaryTextColor)),
                const SizedBox(height: 48),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 16),
                TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register, 
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Daftar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())), 
                  child: const Text('Sudah punya akun? Login di sini', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold))
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(title: const Text('Reset Password'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.lock_reset, size: 80, color: kPrimaryColor),
            const SizedBox(height: 16),
            const Text('Masukkan email yang terdaftar untuk menerima tautan reset password.', textAlign: TextAlign.center, style: TextStyle(color: kSecondaryTextColor, fontSize: 15)),
            const SizedBox(height: 40),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap masukkan email yang valid!')));
                    return;
                  }
                  FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent to email!')));
                  Navigator.pop(context); 
                },
                child: const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(); 
  final _passwordController = TextEditingController(); 
  bool _isLoading = false;

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email dan Password wajib diisi!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const WelcomeScreen()));
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Gagal: Periksa kembali email & password.')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://img.freepik.com/free-vector/shopping-cart-logo-design-template_474888-2009.jpg', 
                  width: 90,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.rocket_launch, size: 70, color: kPrimaryColor.withOpacity(0.5)),
                ),
                const SizedBox(height: 24),
                const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 8),
                const Text('Sign in to continue to SpaceNews', style: TextStyle(color: kSecondaryTextColor)),
                const SizedBox(height: 48),
                TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 16),
                TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordScreen())), 
                    child: const Text('Forgot Password?', style: TextStyle(color: kPrimaryColor))
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login, 
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RegisterScreen())), 
                  child: const Text('Belum punya akun? Daftar Sekarang', style: TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold))
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://img.freepik.com/free-vector/news-concept-illustration_114360-5192.jpg', 
                width: 280,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.newspaper, size: 120, color: kPrimaryColor.withOpacity(0.3)),
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome to SpaceNews Core Application', 
                textAlign: TextAlign.center, 
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.black87, height: 1.2)
              ),
              const SizedBox(height: 16),
              const Text(
                'Explore the latest updates and advanced international news from the universe.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kSecondaryTextColor),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: 220,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation())), 
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                  ),
                  child: const Text('Explore Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const FavoritePage(), 
    const NotificationPage(), 
    const ProfilePage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kSecondaryTextColor.withOpacity(0.7),
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: kSurfaceColor,
          onTap: (idx) => setState(() => _currentIndex = idx),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), activeIcon: Icon(Icons.home_rounded), label: 'Home'), 
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), activeIcon: Icon(Icons.favorite_rounded), label: 'Saved'), 
            BottomNavigationBarItem(icon: Icon(Icons.notifications_none_rounded), activeIcon: Icon(Icons.notifications_rounded), label: 'Notif'), 
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profile'), 
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  void _fetchNews() async {
    try {
      final dio = Dio();
      final response = await dio.get('https://api.spaceflightnewsapi.net/v4/articles/?limit=20');
      if (mounted) {
        setState(() {
          articles = response.data['results'];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator(color: kPrimaryColor)));
    if (articles.isEmpty) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Tidak ada berita.')));

    final headline = articles[0]; 
    final feed = articles.sublist(1); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpaceNews Core'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(article: headline))),
              child: Container(
                margin: const EdgeInsets.all(16),
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                  image: DecorationImage(
                    image: NetworkImage(headline['image_url']), 
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.45), BlendMode.darken),
                  ),
                ),
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: kSurfaceColor.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                        child: const Text('HEADLINE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                      const SizedBox(height: 8),
                      Text(headline['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Latest News', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: feed.length,
              itemBuilder: (context, index) {
                final item = feed[index];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(article: item))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: kSurfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                          child: Image.network(
                            item['image_url'], width: 110, height: 110, fit: BoxFit.cover, 
                            errorBuilder: (c, e, s) => Container(width: 110, height: 110, color: Colors.grey.shade100, child: Icon(Icons.image, color: Colors.grey.shade400)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['news_site'], style: const TextStyle(color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(item['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3)),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


class DetailPage extends StatelessWidget {
  final dynamic article;
  const DetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final docId = '${user?.uid}_${article['id']}'; 

    return Scaffold(
      backgroundColor: kSurfaceColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: kPrimaryColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: kSurfaceColor.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: kSurfaceColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: kSurfaceColor.withOpacity(0.3),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('favorites').doc(docId).snapshots(),
                    builder: (context, snapshot) {
                      bool isFav = snapshot.hasData && snapshot.data!.exists;
                      return IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border_rounded, 
                          color: isFav ? Colors.red : kSurfaceColor
                        ),
                        onPressed: () async {
                          if (user == null) return;
                          final docRef = FirebaseFirestore.instance.collection('favorites').doc(docId);
                          if (isFav) {
                            await docRef.delete(); 
                          } else {
                            await docRef.set({
                              'user_id': user.uid,
                              'article_id': article['id'],
                              'title': article['title'],
                              'news_site': article['news_site'],
                              'image_url': article['image_url'],
                              'saved_at': FieldValue.serverTimestamp(),
                            });
                          }
                        },
                      );
                    }
                  ),
                ),
              ),
            ],
 flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                article['image_url'], 
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200, child: Icon(Icons.image, size: 100, color: Colors.grey.shade400)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      article['news_site'].toString().toUpperCase(), 
                      style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.8)
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article['title'], 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87, height: 1.2)
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.black12, height: 1),
                  const SizedBox(height: 20),
                  const Text('SUMMARY', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  Text(
                    article['summary'], 
                    style: const TextStyle(fontSize: 16, color: Color(0xFF4A5568), height: 1.6, letterSpacing: 0.1)
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Articles')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('user_id', isEqualTo: user?.uid)
            .orderBy('saved_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Belum ada artikel yang disimpan', style: TextStyle(color: kSecondaryTextColor.withOpacity(0.8), fontSize: 16)),
                ],
              )
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var favData = snapshot.data!.docs[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: kSurfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      favData['image_url'], 
                      width: 80, height: 80, fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(width: 80, height: 80, color: Colors.grey.shade100, child: Icon(Icons.image, color: Colors.grey.shade400)),
                    ),
                  ),
                  title: Text(favData['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(favData['news_site'], style: const TextStyle(color: kPrimaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    onPressed: () => FirebaseFirestore.instance.collection('favorites').doc(favData.id).delete(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {'title': 'Peluncuran Roket Falcon 9', 'time': 'Baru saja', 'desc': 'SpaceX berhasil meluncurkan satelit terbaru ke orbit bumi rendah.'},
      {'title': 'Penemuan Planet Baru', 'time': '2 jam yang lalu', 'desc': 'Teleskop James Webb menemukan exoplanet seukuran bumi yang berpotensi memiliki air.'},
      {'title': 'Update Misi Artemis', 'time': '1 hari yang lalu', 'desc': 'NASA mengumumkan jadwal terbaru untuk pendaratan astronot di bulan.'},
      {'title': 'Fenomena Gerhana Matahari', 'time': '3 hari yang lalu', 'desc': 'Jangan lewatkan gerhana matahari total yang akan terlihat di beberapa wilayah.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: kSurfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: kPrimaryColor.withOpacity(0.08),
                child: const Icon(Icons.rocket_launch, color: kPrimaryColor),
              ),
              title: Text(notif['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(notif['desc']!, style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568), height: 1.3)),
                  const SizedBox(height: 10),
                  Text(notif['time']!, style: const TextStyle(fontSize: 11, color: kPrimaryColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context, 
      MaterialPageRoute(builder: (_) => const RegisterScreen()), 
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Profile')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
          }
          
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Data profil tidak ditemukan.'));
          }

          var userData = snapshot.data!;
          
          String name = userData['name'] ?? 'User';
          String email = userData['email'] ?? 'No Email';
          
          bool hasIg = userData.data().toString().contains('instagram');
          String instagram = hasIg ? userData['instagram'] : '@alteregoesports'; 
          
          String profilePic = 'https://upload.wikimedia.org/wikipedia/id/thumb/d/d1/Alter_Ego_Esports_logo.png/640px-Alter_Ego_Esports_logo.png';

          return Stack(
            children: [

              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, Color(0xFF152A3C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                  
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kSurfaceColor,
                        ),
                        child: CircleAvatar(
                          radius: 70, 
                          backgroundImage: NetworkImage(profilePic),
                          backgroundColor: Colors.grey.shade100,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black87)),
                    const SizedBox(height: 40),
                    
                    // Komponen: Informasi Pengguna Terkotak-kotak No 10
                    _buildInfoCard(
                      icon: Icons.person_rounded,
                      color: const Color(0xFFEDF2F7),
                      iconColor: kPrimaryColor,
                      label: 'Account Name',
                      value: name,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.alternate_email_rounded,
                      color: const Color(0xFFFFF5F5),
                      iconColor: Colors.orangeAccent,
                      label: 'Registered Email',
                      value: email,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.linked_camera_rounded,
                      color: const Color(0xFFFDF2F8),
                      iconColor: Colors.pinkAccent,
                      label: 'Connect Instagram',
                      value: instagram,
                    ),
                    const SizedBox(height: 60),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent),
                        label: const Text('Logout Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF5F5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required Color color, required Color iconColor, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: kSecondaryTextColor)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}