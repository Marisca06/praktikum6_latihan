import 'package:flutter/material.dart'; // Mengimpor paket flutter material
import 'dart:convert'; //  // Mengimpor paket dart convert untuk mengonversi data
import 'package:http/http.dart' as http; // Mengimpor paket http dengan alias http
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor paket flutter bloc

// Model untuk menyimpan data universitas
class University {
  final String name; // Nama universitas
  final List<String> webPages; // Daftar halaman web universitas

  University({
    required this.name,
    required this.webPages,
  });

  // Factory method untuk membuat instance University dari JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      webPages: List<String>.from(json['web_pages']),
    );
  }
}

// Events
abstract class UniversityEvent {} // Abstract class untuk event pada Bloc

class FetchUniversitiesEvent extends UniversityEvent {
  final String country; // Event untuk memuat universitas dari negara tertentu
  FetchUniversitiesEvent(this.country);
}

// Bloc
class UniversityBloc extends Bloc<UniversityEvent, List<University>> {
  UniversityBloc() : super([]) { // Konstruktor untuk UniversityBloc
    on<FetchUniversitiesEvent>(_fetchUniversities); // Meng-handle event FetchUniversitiesEvent
  }

  // Method untuk memuat daftar universitas dari API
  Future<void> _fetchUniversities(
    FetchUniversitiesEvent event,
    Emitter<List<University>> emit,
  ) async {
    try {
      final universities = await _fetchUniversitiesFromApi(event.country);
      emit(universities); 
    } catch (e) {
      print('Error: $e'); // Menangani kesalahan jika terjadi
      emit([]); // Memancarkan daftar kosong jika terjadi kesalahan
    }
  }

  // Method untuk melakukan permintaan HTTP ke API
  Future<List<University>> _fetchUniversitiesFromApi(String country) async {
    final response = await http.get(
        Uri.parse('http://universities.hipolabs.com/search?country=$country')); // Membuat permintaan HTTP ke API

    if (response.statusCode == 200) { 
      final List<dynamic> data = jsonDecode(response.body); // Mendapatkan data JSON
      return data.map((json) => University.fromJson(json)).toList(); // Mengonversi data JSON ke daftar objek University.
    } else {
      throw Exception('Failed to load universities'); // Melemparkan exception jika gagal memuat universitas
    }
  }
}

// Method main untuk menjalankan aplikasi Flutter
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => UniversityBloc(), // Membuat instance UniversityBloc dan menyediakan sebagai BlocProvider
        child: UniversitiesPage(), // Menampilkan halaman daftar universitas
      ),
    );
  }
}

// Class UniversitiesPage adalah StatefulWidget untuk menampilkan halaman daftar universitas
class UniversitiesPage extends StatefulWidget {
  @override
  _UniversitiesPageState createState() => _UniversitiesPageState();
}

// _UniversitiesPageState adalah class State dari UniversitiesPage
class _UniversitiesPageState extends State<UniversitiesPage> {
  final List<String> _aseanCountries = [ // Daftar negara ASEAN
    'Indonesia',
    'Singapore',
    'Malaysia',
    'Thailand',
    'Philippines',
    'Vietnam'
  ];

  String _selectedCountry = 'Indonesia'; // Negara ASEAN yang dipilih secara default

  @override
  void initState() {
    super.initState();
    context
        .read<UniversityBloc>()
        .add(FetchUniversitiesEvent(_selectedCountry)); // Memuat daftar universitas dari negara yang dipilih
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas ASEAN'), // Judul AppBar
        centerTitle: true, 
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: _selectedCountry, // Nilai terpilih pada ComboBox
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountry = newValue!; // Mengubah nilai negara yang dipilih
                  context
                      .read<UniversityBloc>()
                      .add(FetchUniversitiesEvent(newValue)); // Memuat daftar universitas dari negara yang baru dipilih
                });
              },
              items:
                  _aseanCountries.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: BlocBuilder<UniversityBloc, List<University>>(
              builder: (context, universities) {
                if (universities.isEmpty) { // Jika daftar universitas kosong, tampilkan indikator loading
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: universities.length,
                  itemBuilder: (context, index) {
                    final university = universities[index]; // Universitas pada indeks tertentu
                    return Card(
                      elevation: 4, // Efek bayangan 
                      margin: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: ListTile(
                        title: Text(
                          university.name,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          university.webPages.first,
                        ),
                        leading: CircleAvatar(
                          child: Icon(Icons.school), // Menampilkan ikon 
                          backgroundColor: Color(0xFFFFE0B5), // Warna latar belakang avatar
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
