import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tubes_progress/components/page_comp.dart';
import 'package:tubes_progress/pages/edit_profile_page.dart';
import 'package:tubes_progress/pages/order_tiket_page.dart';
import 'package:tubes_progress/theme.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageComp(
      showBottomNavbar: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeaderWithSearch(),
          SizedBox(height: 15),
          BannerSlider(),
          SizedBox(height: 15),
          Text(
            "Pilihlah kebutuhan anda disini, sesuai dengan layanan yang kami berikan untuk anda!",
            textAlign: TextAlign.center,
            style: textBold.copyWith(color: Colors.white),
          ),
          SizedBox(height: 15),
          TabAndForm(),
          SizedBox(height: 15),
          Text(
            "Cara mudah pesan tiket dan kirim barang",
            textAlign: TextAlign.left,
            style: TextStyle(),
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              image: DecorationImage(
                image: AssetImage(
                  'assets/images/tutorial1.jpg',
                ), // Ganti dengan path gambar kamu
                fit:
                    BoxFit
                        .cover, // Pilihan lainnya: BoxFit.fill, BoxFit.contain, dll.
              ),
            ),
          ),
          SizedBox(height: 50),
          Align(
            alignment: Alignment.center,
            child: Image.asset("assets/images/logo.png", width: 200),
          ),
        ],
      ),
    );
  }
}

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final List<String> imagePaths = [
    'assets/images/timeline.jpg',
    'assets/images/2.jpg',
    'assets/images/3.jpg',
  ];

  int _currentIndex = 0;
  final CarouselSliderControllerImpl _controller =
      CarouselSliderControllerImpl();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: imagePaths.length,
          itemBuilder: (context, index, realIdx) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                imagePaths[index],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          },
          carouselController: _controller,
          options: CarouselOptions(
            height: 150,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              imagePaths.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentIndex == entry.key
                              ? Colors.blueAccent
                              : Colors.grey,
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}

class TabAndForm extends StatefulWidget {
  @override
  State<TabAndForm> createState() => _TabAndFormState();
}

class _TabAndFormState extends State<TabAndForm> {
  int selectedTabIndex = 0;
  // 0 = Travel, 1 = Buss, 2 = Paket
  final List<String> tabLabels = ['Travel', 'Bus', 'Paket'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Tab Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(tabLabels.length, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedTabIndex = index;
                });
              },
              child: TabOption(
                label: tabLabels[index],
                isSelected: selectedTabIndex == index,
              ),
            );
          }),
        ),

        const SizedBox(height: 20),

        // Dynamic content area
        SizedBox(
          height: 400, // Atau sesuai tinggi yang kamu mau
          child: IndexedStack(
            index: selectedTabIndex,
            children: const [
              TravelAndBusForm(type: 'Travel'),
              TravelAndBusForm(type: 'Bus'),
              PaketForm(),
            ],
          ),
        ),
      ],
    );
  }
}

// Komponen Header dengan Search Bar
class HeaderWithSearch extends StatefulWidget {
  const HeaderWithSearch({Key? key}) : super(key: key);

  @override
  State<HeaderWithSearch> createState() => _HeaderWithSearchState();
}

class _HeaderWithSearchState extends State<HeaderWithSearch> {
  String? userId;
  String? imagePath;
  File? imageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final storage = FlutterSecureStorage();
      final token = await storage.read(key: 'token');

      if (token != null) {
        final uri = Uri.https('pegi-backend.vercel.app', 'api/user');
        final response = await http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': '*/*',
          },
        );

        if (response.statusCode == 200) {
          final userData = jsonDecode(response.body);
          userId = userData['id'];
          imagePath = userData['image'];

          if (imagePath != null && imagePath!.isNotEmpty) {
            await _loadProfileImage();
          }
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadProfileImage() async {
    if (imagePath == null || imagePath!.isEmpty) return;

    try {
      Uint8List imageBytes = await Supabase.instance.client.storage
          .from('images')
          .download(imagePath!);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${imagePath!.split('/').last}');
      await file.create(recursive: true);
      await file.writeAsBytes(imageBytes);

      if (mounted) {
        setState(() {
          imageFile = file;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo.png', width: 150),
                  const Text("Just order and you go"),
                ],
              ),
              // Profile Avatar with properly loaded image
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditProfilePage()),
                  ).then((_) {
                    // Refresh user data when returning from EditProfilePage
                    _fetchUserData();
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: ClipOval(
                    child:
                        isLoading
                            ? const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : imageFile != null
                            ? Image.file(
                              imageFile!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                            : Image.asset(
                              "assets/images/profile.png",
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Tab Option Button
class TabOption extends StatelessWidget {
  final String label;
  final bool isSelected;

  const TabOption({super.key, required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class TravelAndBusForm extends StatefulWidget {
  const TravelAndBusForm({super.key, required this.type});
  final String type; // 'travel' or 'bus'

  @override
  State<TravelAndBusForm> createState() => _TravelAndBusFormState();
}

class _TravelAndBusFormState extends State<TravelAndBusForm> {
  List<String> cities = [];
  Map<String, String> cityId = {};
  String? selectedFrom;
  String? selectedTo;
  DateTime? selectedDate;
  String get type => widget.type;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  // Fetch cities from API
  Future<void> fetchCities() async {
    try {
      final uri = Uri.https('pegi-backend.vercel.app', '/api/city');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<String> cityNames =
            data.map((city) => city['name'].toString()).toList();

        final cityMap = Map<String, String>.from(
          data.asMap().map((index, city) => MapEntry(city['name'], city['id'])),
        );

        if (!mounted) return; // Check if widget is still mounted
        setState(() {
          cities = cityNames;
          cityId = cityMap;
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      print('Error fetching cities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil daftar kota'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void orderPage(type) {
    String? departureCityId = cityId[selectedFrom];
    String? arrivalCityId = cityId[selectedTo];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderTiketPage(
              departureCityId: departureCityId ?? '',
              arrivalCityId: arrivalCityId ?? '',
              selectedDate: selectedDate ?? DateTime.now(),
              type: type,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Dropdown "Berangkat Dari"
            DropdownInput(
              icon: Icons.arrow_upward,
              iconColor: Colors.green,
              label: "Berangkat Dari",
              value: selectedFrom,
              items: cities,
              onChanged: (val) => setState(() => selectedFrom = val),
            ),
            const SizedBox(height: 16),

            // Dropdown "Tujuan"
            DropdownInput(
              icon: Icons.arrow_downward,
              iconColor: Colors.red,
              label: "Tujuan",
              value: selectedTo,
              items: cities,
              onChanged: (val) => setState(() => selectedTo = val),
            ),
            const SizedBox(height: 16),

            // Tanggal Picker
            GestureDetector(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() {
                    selectedDate = picked;
                  });
                }
              },
              child: InputItem(
                icon: Icons.calendar_month,
                iconColor: Colors.blue,
                label: "Tanggal Pergi",
                value:
                    selectedDate != null
                        ? "${_formatDate(selectedDate!)}"
                        : "Pilih tanggal",
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (selectedFrom == null ||
                      selectedTo == null ||
                      selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Silakan lengkapi semua field'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  orderPage(type);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Cari Tiket",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${_getDayName(date.weekday)}, ${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getDayName(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[(weekday - 1) % 7];
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[(month - 1) % 12];
  }
}

class DropdownInput extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  const DropdownInput({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              hint: Text("Pilih $label"),
              decoration: const InputDecoration.collapsed(hintText: ''),
              items:
                  items.map((String item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class InputItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const InputItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaketForm extends StatefulWidget {
  const PaketForm({super.key});

  @override
  State<PaketForm> createState() => _PaketFormState();
}

class _PaketFormState extends State<PaketForm> {
  List<String> cities = [];
  // hashmap to store city names and their IDs
  Map<String, String> cityId = {};
  // Controllers
  final _namaPengirimController = TextEditingController();
  final _kontakPengirimController = TextEditingController();
  final _namaPenerimaController = TextEditingController();
  final _kontakPenerimaController = TextEditingController();
  final _beratController = TextEditingController();
  final _emailController = TextEditingController();
  String get type => 'Paket';

  int? harga = 0;

  String? selectedFrom;
  String? selectedTo;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    fetchCities();
  }

  void _calculatePrice() {
    if (selectedFrom != null &&
        selectedTo != null &&
        _beratController.text.isNotEmpty) {
      try {
        double berat = double.parse(_beratController.text);
        // Base price calculation (you can adjust the formula as needed)
        // For example: base price of Rp 10,000 per kg + distance factor
        int basePrice = 10000;

        setState(() {
          harga = (basePrice * berat).toInt();
        });
      } catch (e) {
        // Handle invalid input
        setState(() {
          harga = 0;
        });
      }
    } else {
      setState(() {
        harga = 0;
      });
    }
  }

  // Fetch cities from API
  Future<void> fetchCities() async {
    try {
      final uri = Uri.https('pegi-backend.vercel.app', '/api/city');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<String> cityNames =
            data.map((city) => city['name'].toString()).toList();

        final cityMap = Map<String, String>.from(
          data.asMap().map((index, city) => MapEntry(city['name'], city['id'])),
        );

        if (!mounted) return; // Check if widget is still mounted
        setState(() {
          cities = cityNames;
          // Populate cityMap with city names and their IDs
          cityId = cityMap;
        });
      } else {
        throw Exception('Failed to load cities');
      }
    } catch (e) {
      print('Error fetching cities: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil daftar kota'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _namaPengirimController.dispose();
    _kontakPengirimController.dispose();
    _namaPenerimaController.dispose();
    _kontakPenerimaController.dispose();
    _beratController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void orderPage(type) {
    String? departureCityId = cityId[selectedFrom];
    String? arrivalCityId = cityId[selectedTo];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderTiketPage(
              departureCityId: departureCityId ?? '',
              arrivalCityId: arrivalCityId ?? '',
              selectedDate: selectedDate ?? DateTime.now(),
              type: type,
              pengirim: _namaPengirimController.text,
              kontakPengirim: _kontakPengirimController.text,
              penerima: _namaPenerimaController.text,
              kontakPenerima: _kontakPenerimaController.text,
              berat: double.tryParse(_beratController.text),
              email: _emailController.text,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildTextField("Nama Pengirim", _namaPengirimController),
              buildTextField("Kontak Pengirim", _kontakPengirimController),
              buildTextField("Nama Penerima", _namaPenerimaController),
              buildTextField("Kontak Penerima", _kontakPenerimaController),
              buildTextField("Email", _emailController),
              const SizedBox(height: 8),

              // Dropdown Berangkat
              DropdownInput(
                icon: Icons.arrow_upward,
                iconColor: Colors.green,
                label: "Berangkat Dari",
                value: selectedFrom,
                items: cities,
                onChanged: (val) {
                  setState(() => selectedFrom = val);
                  _calculatePrice(); // Recalculate price when selection changes
                },
              ),
              const SizedBox(height: 16),

              // Dropdown Tujuan
              DropdownInput(
                icon: Icons.arrow_downward,
                iconColor: Colors.red,
                label: "Tujuan",
                value: selectedTo,
                items: cities,
                onChanged: (val) {
                  setState(() => selectedTo = val);
                  _calculatePrice(); // Recalculate price when selection changes
                },
              ),
              const SizedBox(height: 16),

              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _beratController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: "Berat (kg)",
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    _calculatePrice(); // Recalculate price when weight changes
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Date Picker
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: InputItem(
                  icon: Icons.calendar_month,
                  iconColor: Colors.blue,
                  label: "Tanggal Pergi",
                  value:
                      selectedDate != null
                          ? _formatDate(selectedDate!)
                          : "Pilih tanggal",
                ),
              ),
              const SizedBox(height: 24),

              // Harga + Button
              Text(
                "Total Harga: ${harga == 0 ? 'Belum tersedia' : 'Rp ${NumberFormat("#,##0", "id_ID").format(harga)}'}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedFrom == null ||
                        selectedTo == null ||
                        selectedDate == null ||
                        _namaPengirimController.text.isEmpty ||
                        _kontakPengirimController.text.isEmpty ||
                        _namaPenerimaController.text.isEmpty ||
                        _kontakPenerimaController.text.isEmpty ||
                        _beratController.text.isEmpty ||
                        _emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Silakan lengkapi semua field'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    orderPage(type);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Cari Tiket",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${_getDayName(date.weekday)}, ${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}";
  }

  String _getDayName(int weekday) {
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[(weekday - 1) % 7];
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[(month - 1) % 12];
  }
}
