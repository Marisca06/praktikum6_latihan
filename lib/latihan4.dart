import 'package:flutter/material.dart'; // Mengimpor paket flutter material
import 'package:http/http.dart'
    as http; // Mengimpor paket http dengan alias http
import 'dart:convert'; // Mengimpor paket dart convert untuk mengonversi data
import 'package:provider/provider.dart'; // Mengimpor paket provider

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas ASEAN',
      home: ChangeNotifierProvider(
        // Membungkus dengan ChangeNotifierProvider
        create: (context) =>
            UniversityListProvider(), // Membuat instance dari UniversityListProvider
        child: UniversityList(), // Menampilkan UniversityList sebagai home
      ),
    );
  }
}

class UniversityListProvider extends ChangeNotifier {
  List _universities = []; // Variabel untuk menyimpan data universitas
  bool _isLoading = false; // Variabel untuk menentukan status loading
  String _errorMessage = ''; // Variabel untuk menyimpan pesan error
  String _selectedCountry =
      'Indonesia'; // Variabel untuk menyimpan negara yang dipilih (default Indonesia)

  List get universities =>
      _universities; // Getter untuk mendapatkan data universitas
  bool get isLoading => _isLoading; // Getter untuk mendapatkan status loading
  String get errorMessage =>
      _errorMessage; // Getter untuk mendapatkan pesan error
  String get selectedCountry =>
      _selectedCountry; // Getter untuk mendapatkan negara yang dipilih

  void setSelectedCountry(String country) {
    // Metode untuk mengatur negara yang dipilih
    _selectedCountry = country;
    _fetchUniversities();
  }

  Future<void> _fetchUniversities() async {
    // Metode async untuk memuat data universitas
    _isLoading = true; // Mengatur isLoading menjadi true
    _errorMessage = ''; // Menghapus pesan error sebelumnya

    try {
      final response = await http.get(
        // Melakukan permintaan HTTP untuk mendapatkan data universitas
        Uri.parse(
            'http://universities.hipolabs.com/search?country=$_selectedCountry'),
      );

      if (response.statusCode == 200) {
        // Jika permintaan berhasil
        _universities = json
            .decode(response.body); // Mendekode data universitas dari respons
        _isLoading =
            false; // Mengatur isLoading menjadi false setelah selesai memuat
      } else {
        // Jika permintaan gagal
        throw Exception(
            'Gagal memuat universitas: ${response.reasonPhrase}'); // Pesan error
      }
    } catch (error) {
      // Menangani error yang terjadi selama pemrosesan permintaan
      _errorMessage = 'Error: $error'; // Mengatur pesan error
      _isLoading =
          false; // Mengatur isLoading menjadi false setelah selesai memuat
    }

    notifyListeners(); // Memberitahu bahwa ada perubahan data
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas ASEAN'),
        centerTitle: true,
      ),
      body: Consumer<UniversityListProvider>(
        // mendeteksi perubahan pada UniversityListProvider
        builder: (context, provider, child) {
          return provider.isLoading // Jika sedang memuat
              ? const Center(
                  child:
                      CircularProgressIndicator(), // Menampilkan indikator loading
                )
              : provider.errorMessage.isNotEmpty // Jika terdapat pesan error
                  ? Center(
                      child: Text(
                        provider.errorMessage, // Menampilkan pesan error
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        _buildCountrySelector(
                            context, provider), // Widget untuk memilih negara
                        Expanded(
                          child: ListView.builder(
                            // Membangun daftar universitas
                            itemCount: provider.universities.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 4,
                                margin: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 16,
                                ),
                                child: ListTile(
                                  title: Text(
                                    provider.universities[index][
                                        'name'], // Menampilkan nama universitas
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  subtitle: Text(provider.universities[index]
                                          ['web_pages'][
                                      0]), // Menampilkan halaman web universitas
                                  leading: CircleAvatar(
                                    child: Icon(Icons
                                        .school), // Menampilkan ikon 
                                    backgroundColor: Color(
                                        0xFFFFE0B5), // Warna latar belakang avatar
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
        },
      ),
    );
  }

  Widget _buildCountrySelector(
      // Widget untuk membangun dropdown negara
      BuildContext context,
      UniversityListProvider provider) {
    return DropdownButton<String>(
      value: provider.selectedCountry,
      onChanged: (newValue) {
        provider
            .setSelectedCountry(newValue!); // Memperbarui negara yang dipilih
      },
      items: <String>[
        'Indonesia',
        'Singapore',
        'Malaysia',
        'Thailand',
        'Philippines',
        'Vietnam'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
