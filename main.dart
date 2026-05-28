import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext c) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Tugas Praktikum PAB',
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF82DFB0),
      scaffoldBackgroundColor: Colors.red.shade50,
      brightness: Brightness.light,
    ),
    home: const MainNavigator(),
  );
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _i = 1;
  bool _detail = false;
  Map<String, dynamic>? _m;

  @override
  Widget build(BuildContext c) {
    Widget s;
    if (_i == 0) {
      s = const CinemaFrameScreen();
    } else if (_i == 1) {
      s = _detail && _m != null
          ? MovieDetailScreen(movie: _m!, onBack: () => setState(() => _detail = false))
          : MovieGridScreen(onItemTap: (m) => setState(() { _m = m; _detail = true; }));
    } else {
      s = const PraktikumScreen();
    }

    return Scaffold(
      body: s,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1C29),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: _i,
        onTap: (i) => setState(() { if (_i == 1 && i == 1) { _detail = false; _m = null; } _i = i; }),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Movie'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class MovieGridScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onItemTap;
  const MovieGridScreen({super.key, required this.onItemTap});

  @override
  Widget build(BuildContext c) {
    final d = [
      {'title': 'Inception', 'year': '2010', 'rating': '8.8', 'img': 'https://picsum.photos/id/1020/400/600', 'desc': 'Seorang pencuri yang mencuri rahasia perusahaan melalui mimpi diberi tugas untuk menanamkan ide ke dalam pikiran seorang CEO.'},
      {'title': 'Interstellar', 'year': '2014', 'rating': '8.7', 'img': 'https://picsum.photos/id/1015/400/600', 'desc': 'Sekelompok penjelajah melakukan perjalanan melalui lubang cacing di luar angkasa untuk memastikan kelangsungan hidup umat manusia.'},
      {'title': 'Oppenheimer', 'year': '2023', 'rating': '8.3', 'img': 'https://picsum.photos/id/1018/400/600', 'desc': 'Kisah fisikawan J. Robert Oppenheimer dan perannya dalam pengembangan bom atom selama Proyek Manhattan.'},
      {'title': 'The Dark Knight', 'year': '2008', 'rating': '9.0', 'img': 'https://picsum.photos/id/1011/400/600', 'desc': 'Batman menghadapi ancaman baru dalam bentuk Joker, seorang penjahat yang ingin mendorong Gotham ke dalam kekacauan.'},
      {'title': 'Memento', 'year': '2000', 'rating': '8.4', 'img': 'https://picsum.photos/id/1021/400/600', 'desc': 'Pria dengan amnesia jangka pendek menggunakan catatan dan tato untuk memburuh pria yang membunuh istrinya.'},
      {'title': 'Tenet', 'year': '2020', 'rating': '7.3', 'img': 'https://picsum.photos/id/1022/400/600', 'desc': 'Agen rahasia mempelajari teknologi yang memungkinkan waktu berjalan mundur, digunakan untuk mencegah Perang Dunia III.'},
    ];

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text('PRAKTIKUM PAB', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.65,
              ),
              itemCount: d.length,
              itemBuilder: (c, i) {
                return GestureDetector(
                  onTap: () => onItemTap(d[i]),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(d[i]['img']!),
                        fit: BoxFit.cover,
                        colorFilter: const ColorFilter.mode(Colors.black26, BlendMode.darken),
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Center(child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 50)),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                            ),
                            child: Text(d[i]['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MovieDetailScreen extends StatelessWidget {
  final Map<String, dynamic> movie;
  final VoidCallback onBack;
  const MovieDetailScreen({super.key, required this.movie, required this.onBack});

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Image.network(movie['img']!, height: 380, width: double.infinity, fit: BoxFit.cover),
                ),
                Container(
                  height: 380,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87]),
                  ),
                ),
                Positioned(
                  top: 40, left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: onBack),
                  ),
                ),
                const Positioned.fill(child: Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 70))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie['title']!, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("${movie['year']} • ⭐ ${movie['rating']}", style: const TextStyle(color: Colors.white70, fontSize: 15)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow, color: Colors.black),
                      label: const Text('Play', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF82DFB0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Sinopsis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(movie['desc']!, style: const TextStyle(color: Colors.white54, fontSize: 14, height: 1.5)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


class PraktikumScreen extends StatelessWidget {
  const PraktikumScreen({super.key});
  @override
  Widget build(BuildContext c) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              const CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF82DFB0),
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text('KrisenRexni', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              ElevatedButton(
                
                onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (c) => const MyInfoScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF82DFB0),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                  elevation: 4,
                ),
                child: const Text('MASUK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}


class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key});

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Saya', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF82DFB0),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SizedBox(height: 20),
          ListTile(leading: Icon(Icons.person_outline, color: Color(0xFF82DFB0)), title: Text('Nickname'), subtitle: Text('KrisenRexni')),
          ListTile(leading: Icon(Icons.phone, color: Color(0xFF82DFB0)), title: Text('Phone'), subtitle: Text('089623074514')),
          ListTile(leading: Icon(Icons.email, color: Color(0xFF82DFB0)), title: Text('Email'), subtitle: Text('Krisen24rexny@gmail.com')),
          ListTile(leading: Icon(Icons.location_on, color: Color(0xFF82DFB0)), title: Text('Location'), subtitle: Text('Surabaya')),
          ListTile(leading: Icon(Icons.camera_alt, color: Color(0xFF82DFB0)), title: Text('Instagram'), subtitle: Text('@Senkyrk')),
        ],
      ),
    );
  }
}

class CinemaFrameScreen extends StatelessWidget {
  const CinemaFrameScreen({super.key});

  @override
  Widget build(BuildContext c) {
    final f = [
      {'title': 'Inception', 'year': '2010', 'rating': '8.8', 'genre': ['Sci-Fi', 'Thriller'], 'img': 'https://picsum.photos/id/1020/400/600'},
      {'title': 'Interstellar', 'year': '2014', 'rating': '8.7', 'genre': ['Sci-Fi', 'Drama'], 'img': 'https://picsum.photos/id/1015/400/600'},
      {'title': 'Oppenheimer', 'year': '2023', 'rating': '8.3', 'genre': ['Drama', 'History'], 'img': 'https://picsum.photos/id/1018/400/600'},
      {'title': 'The Dark Knight', 'year': '2008', 'rating': '9.0', 'genre': ['Action', 'Crime'], 'img': 'https://picsum.photos/id/1011/400/600'},
    ];
    final r = [
      {'title': 'Memento', 'year': '2000', 'rating': '8.4', 'img': 'https://picsum.photos/id/1021/400/600'},
      {'title': 'Tenet', 'year': '2020', 'rating': '7.3', 'img': 'https://picsum.photos/id/1022/400/600'},
      {'title': 'Dunkirk', 'year': '2017', 'rating': '7.8', 'img': 'https://picsum.photos/id/1024/400/600'},
      {'title': 'The Prestige', 'year': '2006', 'rating': '8.5', 'img': 'https://picsum.photos/id/1025/400/600'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Cinema Frame', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white)),
        backgroundColor: Colors.transparent, elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black, Color(0xFF1F1F1F)])),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 280, width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(image: NetworkImage('https://picsum.photos/id/1005/800/400'), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 50, backgroundColor: const Color(0xFF82DFB0),
                    backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=500&q=60'),
                  ),
                  const SizedBox(height: 10),
                  const Text('Christopher Nolan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Director | Producer | Screenwriter', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_chip('Sci-Fi'), const SizedBox(width: 8), _chip('Thriller'), const SizedBox(width: 8), _chip('Drama')],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(children: [Icon(Icons.movie_filter_outlined, color: Color(0xFF82DFB0)), SizedBox(width: 8), Text('Film Utama', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.6),
                itemCount: f.length,
                itemBuilder: (c, i) => _mc(f[i]),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 32, 20, 12),
              child: Row(children: [Icon(Icons.recommend_outlined, color: Color(0xFF82DFB0)), SizedBox(width: 8), Text('Rekomendasi Lainnya', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))]),
            ),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: r.length,
                itemBuilder: (c, i) => Container(
                  width: 130, margin: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(r[i]['img']!, height: 160, width: 130, fit: BoxFit.cover)),
                      const SizedBox(height: 8),
                      Text(r[i]['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                      Text("${r[i]['year']} • ⭐ ${r[i]['rating']}", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _mc(Map<String, dynamic> m) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16), color: const Color(0xFF1E1E1E),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(m['img']!, width: double.infinity, fit: BoxFit.cover)),
                Positioned(left: 0, right: 0, bottom: 0, child: Container(height: 80, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87])))),
                Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)), child: Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 2), Text(m['rating']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))]))),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  children: (m['genre'] as List<String>).map((g) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFF82DFB0).withOpacity(0.5)), borderRadius: BorderRadius.circular(4)),
                    child: Text(g, style: const TextStyle(color: Color(0xFF82DFB0), fontSize: 10)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF82DFB0).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF82DFB0)),
      ),
      child: Text(t, style: const TextStyle(color: Color(0xFF82DFB0), fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}