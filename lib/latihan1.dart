import 'dart:convert'; // Mengimpor paket dart convert untuk mengonversi data
import 'package:flutter/material.dart'; // Mengimpor paket flutter material
import 'package:http/http.dart' as http; // Mengimpor paket http dengan alias http
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor paket flutter bloc

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas ASEAN',
      home: BlocProvider(
        create: (context) => UniversityCubit(), // Membuat instance dari UniversityCubit
        child: UniversityList(), // Menampilkan UniversityList sebagai home
      ),
    );
  }
}

class UniversityCubit extends Cubit<List<dynamic>> {
  UniversityCubit() : super([]); // Konstruktor untuk UniversityCubit

  Future<void> fetchUniversities(String country) async {
    // Metode untuk memuat data universitas
    final response = await http.get(
      // Melakukan permintaan HTTP untuk mendapatkan data universitas
      Uri.parse('http://universities.hipolabs.com/search?country=$country'),
    );

    if (response.statusCode == 200) {
      // Jika permintaan berhasil
      emit(json.decode(response.body)); // Mengeluarkan data universitas
    } else {
      // Jika permintaan gagal
      throw Exception(
          'Gagal memuat universitas: ${response.reasonPhrase}'); // Pesan error
    }
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universityCubit = BlocProvider.of<UniversityCubit>(
        context); // Mendapatkan instance dari UniversityCubit

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas ASEAN'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          BlocBuilder<UniversityCubit, List<dynamic>>(
            builder: (context, universities) {
              return DropdownButton<String>(
                value: 'Indonesia', // Nilai default
                onChanged: (newValue) {
                  universityCubit.fetchUniversities(
                      newValue!); // Memuat data universitas saat negara dipilih
                },
                items: <String>[
                  'Indonesia',
                  'Singapore',
                  'Malaysia',
                  'Thailand',
                  'Philippines',
                  'Vietnam'
                  // Tambahkan negara ASEAN lainnya di sini
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<UniversityCubit, List<dynamic>>(
              builder: (context, universities) {
                return universities.isNotEmpty
                    ? ListView.builder(
                        itemCount: universities.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 4,
                            margin: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: ListTile(
                              title: Text(
                                universities[index]['name'], // Menampilkan nama universitas
                                style: TextStyle(fontSize: 18),
                              ),
                              subtitle: Text(
                                universities[index]['web_pages'][0], // Menampilkan halaman web universitas
                              ),
                              leading: CircleAvatar(
                                child: Icon(Icons.school), // Menampilkan ikon 
                                backgroundColor: Color(0xFFFFE0B5), // Warna latar belakang avatar
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(), // Menampilkan indikator loading
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
