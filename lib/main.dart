import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'database_service.dart';
import 'terms_and_conditions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.database;
  runApp(const RENTahananApp());
}

// ============================================================
// COLORS - SAME BEIGE & GREEN THEME
// ============================================================

const Color deepGreen = Color(0xFF315C45);
const Color forestGreen = Color(0xFF3F7658);
const Color softGreen = Color(0xFFDCE8D8);

const Color beige = Color(0xFFF5EFE3);
const Color lightBeige = Color(0xFFFBF8F1);

const Color darkText = Color(0xFF293B31);
const Color muted = Color(0xFF7C857D);
const Color borderColor = Color(0xFFE5DED1);

const Color white = Colors.white;

// ============================================================
// APP
// ============================================================

class RENTahananApp extends StatelessWidget {
  const RENTahananApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RENtahanan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: beige,
        colorScheme: ColorScheme.fromSeed(
          seedColor: deepGreen,
          primary: deepGreen,
          secondary: forestGreen,
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

// ============================================================
// DATABASE SERVICE IS IN lib/database_service.dart
// ============================================================

// ============================================================
// WELCOME
// ============================================================

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const RENTahananLogo(size: 135),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: deepGreen.withAlpha(30),
                        blurRadius: 25,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Welcome!',
                        style: TextStyle(
                          color: deepGreen,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage your rental experience\nin one place.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        text: 'Login',
                        icon: Icons.login_rounded,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RoleSelectionPage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      SecondaryButton(
                        text: 'Browse Rooms as Guest',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const GuestDashboard(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SuperadminPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Superadmin',
                          style: TextStyle(color: muted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'RENtahanan Apartment Management System',
                  style: TextStyle(
                    color: Color(0xFF9AA29C),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ROLE SELECTION
// ============================================================

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: deepGreen),
              ),
            ),
            const SizedBox(height: 25),
            const RENTahananLogo(size: 95),
            const SizedBox(height: 10),
            const Text(
              'Welcome to RENTahanan',
              style: TextStyle(
                color: deepGreen,
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'How would you like to login?',
              style: TextStyle(
                color: muted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 30),
            RoleCard(
              icon: Icons.apartment_rounded,
              title: 'Landlord',
              description:
                  'Oversee properties, manage tenants, and payment records, \nand schedule unit viewing requests.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(role: 'Landlord'),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            RoleCard(
              icon: Icons.person_outline_rounded,
              title: 'Tenant',
              description:
                  'Manage rented unit, view rent payment history, \nand send messages for rental unit related concerns.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(role: 'Tenant'),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            RoleCard(
              icon: Icons.person_search_outlined,
              title: 'Guest Account',
              description:
                  'Log in to track viewing requests\nand rental status.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuestLoginPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// GUEST DASHBOARD
// ============================================================

class GuestDashboard extends StatefulWidget {
  /// Pass the logged-in tenant's user map when available.
  /// Leave null when browsing as a true guest (no account).
  final Map<String, dynamic>? user;

  const GuestDashboard({super.key, this.user});

  @override
  State<GuestDashboard> createState() => _GuestDashboardState();
}

class _GuestDashboardState extends State<GuestDashboard> {
  List<Map<String, dynamic>> _allRooms = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;

  String _selectedLocation = 'All';
  String _priceSort = 'None';

  List<String> get _locations {
    final locs = _allRooms
        .map((r) => (r['location'] ?? '').toString().trim())
        .where((l) => l.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...locs];
  }

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    final data = await DatabaseService.instance.getAvailableRooms();
    if (!mounted) return;
    setState(() {
      _allRooms = data;
      _applyFilters();
      _loading = false;
    });
  }

  void _applyFilters() {
    var result = List<Map<String, dynamic>>.from(_allRooms);

    if (_selectedLocation != 'All') {
      result = result
          .where((r) =>
              (r['location'] ?? '').toString().trim() == _selectedLocation)
          .toList();
    }

    if (_priceSort == 'Low to High') {
      result.sort((a, b) {
        final pa = (a['price'] as num?)?.toDouble() ?? 0;
        final pb = (b['price'] as num?)?.toDouble() ?? 0;
        return pa.compareTo(pb);
      });
    } else if (_priceSort == 'High to Low') {
      result.sort((a, b) {
        final pa = (a['price'] as num?)?.toDouble() ?? 0;
        final pb = (b['price'] as num?)?.toDouble() ?? 0;
        return pb.compareTo(pa);
      });
    }

    _filtered = result;
  }

  String _money(dynamic value) {
    final n = (value is num)
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    return '₱${n.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        elevation: 0,
        title: const Text(
          'Browse Rooms',
          style: TextStyle(
            color: deepGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: deepGreen),
        actions: widget.user == null
            ? [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GuestLoginPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Guest Login',
                    style: TextStyle(
                      color: deepGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RoleSelectionPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ]
            : const [],
      ),
      body: Column(
        children: [
          // ── Filter bar ──────────────────────────────────────
          Container(
            color: white,
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(
              children: [
                // Location filter
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: lightBeige,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedLocation,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          style: const TextStyle(color: darkText, fontSize: 12),
                          items: _locations
                              .map((loc) => DropdownMenuItem(
                                    value: loc,
                                    child: Text(loc,
                                        overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() {
                              _selectedLocation = val;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Price sort
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price',
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: lightBeige,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                        ),
                        child: DropdownButton<String>(
                          value: _priceSort,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          style: const TextStyle(color: darkText, fontSize: 12),
                          items: const [
                            DropdownMenuItem(
                                value: 'None', child: Text('Default')),
                            DropdownMenuItem(
                                value: 'Low to High',
                                child: Text('Low → High')),
                            DropdownMenuItem(
                                value: 'High to Low',
                                child: Text('High → Low')),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() {
                              _priceSort = val;
                              _applyFilters();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Room list ────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: deepGreen))
                : RefreshIndicator(
                    color: deepGreen,
                    onRefresh: _loadRooms,
                    child: _filtered.isEmpty
                        ? const EmptyState(
                            icon: Icons.home_work_outlined,
                            text: 'No rooms match your filters.',
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.76,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (context, index) {
                              final room = _filtered[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RoomDetailsPage(
                                      room: room,
                                      user: widget.user,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: deepGreen.withAlpha(20),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            StoredImageGallery(
                                              data: room['image'],
                                              width: double.infinity,
                                              height: double.infinity,
                                              radius: 0,
                                              fallbackIcon:
                                                  Icons.meeting_room_outlined,
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withAlpha(235),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  '${_money(room['price'])}/mo',
                                                  style: const TextStyle(
                                                    color: deepGreen,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            10, 9, 8, 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    room['name']?.toString() ??
                                                        'Room',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: darkText,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.apartment_rounded,
                                                  color: forestGreen,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              room['location']?.toString() ??
                                                  '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: muted,
                                                fontSize: 10,
                                              ),
                                            ),
                                            const SizedBox(height: 7),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 30,
                                              child: OutlinedButton(
                                                onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        RoomDetailsPage(
                                                      room: room,
                                                      user: widget.user,
                                                    ),
                                                  ),
                                                ),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: deepGreen,
                                                  side: const BorderSide(
                                                    color: borderColor,
                                                  ),
                                                  padding: EdgeInsets.zero,
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'View room',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class SuperadminPage extends StatefulWidget {
  const SuperadminPage({super.key});

  @override
  State<SuperadminPage> createState() => _SuperadminPageState();
}

class _SuperadminPageState extends State<SuperadminPage> {
  final adminPassword = TextEditingController();
  final name = TextEditingController();
  final email = TextEditingController();
  final contactNumber = TextEditingController();
  final landlordPassword = TextEditingController();
  final apartment = TextEditingController();
  final location = TextEditingController();
  final floors = TextEditingController(text: '1');
  final rooms = TextEditingController(text: '1');
  final monthlyRent = TextEditingController();
  late Future<bool> _hasAdmin;
  bool _authenticated = false;
  bool _working = false;
  bool _hideAdminPassword = true;
  bool _hideLandlordPassword = true;

  @override
  void initState() {
    super.initState();
    _hasAdmin = DatabaseService.instance.hasSuperadmin();
  }

  Future<void> _saveAdmin(bool isFirstSetup) async {
    if (adminPassword.text.trim().length < 8) {
      _message('Use a superadmin password with at least 8 characters.');
      return;
    }
    setState(() => _working = true);
    try {
      if (isFirstSetup) {
        await DatabaseService.instance.createSuperadmin(adminPassword.text);
      } else if (!await DatabaseService.instance
          .loginSuperadmin(adminPassword.text)) {
        _message('Incorrect superadmin password.');
        return;
      }
      if (mounted) setState(() => _authenticated = true);
    } catch (error) {
      debugPrint('SUPERADMIN AUTH ERROR: $error');
      _message('Could not set up superadmin access.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _provisionLandlord() async {
    final floorCount = int.tryParse(floors.text.trim());
    final roomCount = int.tryParse(rooms.text.trim());
    final rentAmount = double.tryParse(
        monthlyRent.text.trim().replaceAll(RegExp(r'[₱,\s]'), ''));
    if (name.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        contactNumber.text.trim().isEmpty ||
        landlordPassword.text.isEmpty ||
        apartment.text.trim().isEmpty ||
        location.text.trim().isEmpty ||
        floorCount == null ||
        floorCount < 1 ||
        roomCount == null ||
        roomCount < 1 ||
        rentAmount == null ||
        !rentAmount.isFinite ||
        rentAmount <= 0) {
      _message(
          'Complete landlord and apartment details with valid floors, units, and monthly rent.');
      return;
    }
    setState(() => _working = true);
    try {
      final account = await DatabaseService.instance.provisionLandlord(
        name: name.text,
        email: email.text,
        contactNumber: contactNumber.text,
        password: landlordPassword.text,
        apartmentName: apartment.text,
        location: location.text,
        totalFloors: floorCount,
        totalRooms: roomCount,
        monthlyRent: rentAmount,
        petFriendly: false,
        priceTier: 'Standard',
      );
      if (!mounted) return;
      _message(
          'Landlord account created successfully. Landlord ID: ${account['landlord_code']}');
      name.clear();
      email.clear();
      contactNumber.clear();
      landlordPassword.clear();
      apartment.clear();
      location.clear();
      monthlyRent.clear();
      setState(() {});
    } on StateError catch (error) {
      _message(error.message == 'LANDLORD_LIMIT_REACHED'
          ? 'The two landlord accounts have already been created.'
          : 'That email address is already in use.');
    } catch (error) {
      debugPrint('LANDLORD PROVISION ERROR: $error');
      _message('Unable to create the landlord account.');
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void dispose() {
    adminPassword.dispose();
    name.dispose();
    email.dispose();
    contactNumber.dispose();
    landlordPassword.dispose();
    apartment.dispose();
    location.dispose();
    floors.dispose();
    rooms.dispose();
    monthlyRent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text('Superadmin'),
      ),
      body: FutureBuilder<bool>(
        future: _hasAdmin,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final firstSetup = !snapshot.data!;
          if (!_authenticated) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstSetup ? 'Set up superadmin' : 'Superadmin login',
                        style: const TextStyle(
                          color: deepGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This local prototype stores accounts on this device only. '
                        'Initial setup is not a secure production authorization system.',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: adminPassword,
                        obscureText: _hideAdminPassword,
                        decoration: InputDecoration(
                          labelText: firstSetup
                              ? 'Create superadmin password'
                              : 'Superadmin password',
                          suffixIcon: IconButton(
                            tooltip: _hideAdminPassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () => setState(
                                () => _hideAdminPassword = !_hideAdminPassword),
                            icon: Icon(_hideAdminPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      PrimaryButton(
                        text: _working
                            ? 'Please wait...'
                            : firstSetup
                                ? 'Set up'
                                : 'Log in',
                        icon: Icons.admin_panel_settings_outlined,
                        onPressed:
                            _working ? () {} : () => _saveAdmin(firstSetup),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return FutureBuilder<int>(
            future: DatabaseService.instance.getProvisionedLandlordCount(),
            builder: (context, countSnapshot) {
              final count = countSnapshot.data ?? 0;
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Landlord accounts: $count of 2',
                          style: const TextStyle(
                            color: deepGreen,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        if (count < 2) ...[
                          const SizedBox(height: 16),
                          TextField(
                              controller: name,
                              decoration: const InputDecoration(
                                  labelText: 'Landlord full name')),
                          TextField(
                              controller: email,
                              keyboardType: TextInputType.emailAddress,
                              decoration:
                                  const InputDecoration(labelText: 'Email')),
                          TextField(
                              controller: contactNumber,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                  labelText: 'Contact number')),
                          TextField(
                              controller: landlordPassword,
                              obscureText: _hideLandlordPassword,
                              decoration: InputDecoration(
                                labelText: 'Set landlord password',
                                suffixIcon: IconButton(
                                  tooltip: _hideLandlordPassword
                                      ? 'Show password'
                                      : 'Hide password',
                                  onPressed: () => setState(() =>
                                      _hideLandlordPassword =
                                          !_hideLandlordPassword),
                                  icon: Icon(_hideLandlordPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined),
                                ),
                              )),
                          TextField(
                              controller: apartment,
                              decoration: const InputDecoration(
                                  labelText: 'Apartment / property name')),
                          TextField(
                              controller: location,
                              decoration: const InputDecoration(
                                  labelText: 'Property address')),
                          Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                      controller: floors,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          labelText: 'Floors'))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: TextField(
                                      controller: rooms,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          labelText: 'Units / rooms'))),
                            ],
                          ),
                          TextField(
                            controller: monthlyRent,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Default monthly rent per unit (₱)',
                            ),
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            text: _working
                                ? 'Creating...'
                                : 'Create landlord account',
                            icon: Icons.person_add_alt_1,
                            onPressed: _working ? () {} : _provisionLandlord,
                          ),
                        ] else
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child:
                                Text('Both landlord accounts are provisioned.'),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class GuestLoginPage extends StatefulWidget {
  const GuestLoginPage({super.key});

  @override
  State<GuestLoginPage> createState() => _GuestLoginPageState();
}

class _GuestLoginPageState extends State<GuestLoginPage> {
  final guestId = TextEditingController();
  final password = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      final guest = await DatabaseService.instance.loginGuest(
        guestCode: guestId.text,
        password: password.text,
      );
      if (!mounted) return;
      if (guest == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Guest ID or password is incorrect.')),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GuestStatusDashboard(guest: guest)),
      );
    } catch (error) {
      debugPrint('GUEST LOGIN ERROR: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to log in right now.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    guestId.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: beige,
        appBar:
            AppBar(backgroundColor: beige, title: const Text('Guest Login')),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                children: [
                  TextField(
                      controller: guestId,
                      decoration: const InputDecoration(labelText: 'Guest ID')),
                  TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 18),
                  PrimaryButton(
                    text: _loading ? 'Logging in...' : 'Log in',
                    icon: Icons.login,
                    onPressed: _loading ? () {} : _login,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class GuestViewingRequestPage extends StatefulWidget {
  final Map<String, dynamic> room;

  const GuestViewingRequestPage({super.key, required this.room});

  @override
  State<GuestViewingRequestPage> createState() =>
      _GuestViewingRequestPageState();
}

String _viewingDateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String _viewingMonthKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

bool _isViewingDateBlocked(
  DateTime date,
  List<Map<String, dynamic>> rules,
) {
  for (final rule in rules) {
    final type = rule['rule_type'].toString();
    final value = rule['rule_value'].toString();
    if ((type == 'date' && value == _viewingDateKey(date)) ||
        (type == 'month' && value == _viewingMonthKey(date)) ||
        (type == 'weekday' && int.tryParse(value) == date.weekday)) {
      return true;
    }
  }
  return false;
}

DateTime? _firstAvailableViewingDate(
  DateTime firstDate,
  DateTime lastDate,
  List<Map<String, dynamic>> rules,
) {
  var candidate = DateTime(firstDate.year, firstDate.month, firstDate.day);
  while (!candidate.isAfter(lastDate)) {
    if (!_isViewingDateBlocked(candidate, rules)) return candidate;
    candidate = candidate.add(const Duration(days: 1));
  }
  return null;
}

bool _isViewingTimeAllowed(TimeOfDay time) {
  final minutes = time.hour * 60 + time.minute;
  return minutes >= 8 * 60 && minutes <= 18 * 60;
}

String _viewingTimeKey(TimeOfDay time) =>
    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

bool _isViewingTimeBlocked(
  TimeOfDay time,
  List<Map<String, dynamic>> rules,
) {
  final timeKey = _viewingTimeKey(time);
  return rules.any((rule) =>
      rule['rule_type'] == 'time' && rule['rule_value'].toString() == timeKey);
}

Future<TimeOfDay?> _pickViewingTime(
  BuildContext context,
  TimeOfDay initialTime,
) async {
  final picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );
  if (picked == null || _isViewingTimeAllowed(picked)) return picked;

  if (!context.mounted) return null;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Outside viewing hours'),
      content: const Text(
        'Unit viewings are only available from 8:00 AM to 6:00 PM. Please choose another time.',
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Choose another time'),
        ),
      ],
    ),
  );
  return null;
}

class _GuestViewingRequestPageState extends State<GuestViewingRequestPage> {
  final name = TextEditingController();
  final password = TextEditingController();
  DateTime? date;
  TimeOfDay? time;
  bool _saving = false;
  bool _loadingAvailability = true;
  List<Map<String, dynamic>> _blockedDates = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final rules = await DatabaseService.instance.getViewingBlackouts(
        widget.room['landlord_id'] as int,
      );
      if (!mounted) return;
      setState(() {
        _blockedDates = rules;
        _loadingAvailability = false;
      });
    } catch (error) {
      debugPrint('LOAD GUEST VIEWING AVAILABILITY ERROR: $error');
      if (!mounted) return;
      setState(() => _loadingAvailability = false);
      _message('Unable to load the landlord’s viewing availability.');
    }
  }

  Future<void> _chooseDate() async {
    if (_loadingAvailability) return;
    final today = DateTime.now();
    final lastDate = DateTime(today.year + 2, today.month, today.day);
    final firstAvailable = _firstAvailableViewingDate(
      date ?? today,
      lastDate,
      _blockedDates,
    );
    if (firstAvailable == null) {
      _message('The landlord has no available viewing dates in this period.');
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: firstAvailable,
      firstDate: today,
      lastDate: lastDate,
      selectableDayPredicate: (day) =>
          !_isViewingDateBlocked(day, _blockedDates),
      helpText: 'Unavailable dates are disabled',
    );
    if (picked != null) setState(() => date = picked);
  }

  Future<void> _chooseTime() async {
    final picked = await _pickViewingTime(
      context,
      time ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked == null) return;
    if (_isViewingTimeBlocked(picked, _blockedDates)) {
      _message(
          'The landlord is unavailable at that time. Choose another time.');
      return;
    }
    setState(() => time = picked);
  }

  Future<void> _submit() async {
    if (name.text.trim().isEmpty || password.text.length < 6) {
      _message('Enter your name and a password with at least 6 characters.');
      return;
    }
    if (date == null || time == null) {
      _message('Select a viewing date and time.');
      return;
    }
    if (_isViewingDateBlocked(date!, _blockedDates)) {
      _message('The landlord is unavailable on that date. Choose another day.');
      return;
    }
    if (!_isViewingTimeAllowed(time!)) {
      await _pickViewingTime(context, time!);
      return;
    }
    if (_isViewingTimeBlocked(time!, _blockedDates)) {
      _message(
          'The landlord is unavailable at that time. Choose another time.');
      return;
    }
    setState(() => _saving = true);
    try {
      final account = await DatabaseService.instance.createGuestViewingRequest(
        name: name.text,
        password: password.text,
        roomId: widget.room['id'] as int,
        date:
            '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
        time: time!.format(context),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Viewing submitted'),
          content: Text(
            'Your Guest ID is ${account['guest_code']}. Save it with your password to log in and track the request.',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Open guest dashboard'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GuestStatusDashboard(
              guest: account..addAll({'name': name.text.trim()})),
        ),
      );
    } on StateError catch (error) {
      _message(switch (error.message) {
        'ROOM_NOT_AVAILABLE' => 'This unit is no longer available.',
        'VIEWING_DAY_BLOCKED' =>
          'The landlord is unavailable on that date. Choose another day.',
        'VIEWING_TIME_BLOCKED' =>
          'The landlord is unavailable at that time. Choose another time.',
        'VIEWING_TIME_OUT_OF_RANGE' =>
          'Unit viewings are only available from 8:00 AM to 6:00 PM.',
        'INVALID_VIEWING_DATE' => 'Choose a valid viewing date.',
        _ => 'Could not submit the viewing request.',
      });
    } catch (error) {
      debugPrint('GUEST REQUEST ERROR: $error');
      _message('Could not submit the viewing request.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    name.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: beige,
        appBar: AppBar(
            backgroundColor: beige, title: const Text('Request a Viewing')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.room['name'].toString(),
                      style: const TextStyle(
                          color: deepGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  Text(
                      '₱${widget.room['price']}/month • ${widget.room['location']}',
                      style: const TextStyle(color: muted)),
                  const SizedBox(height: 16),
                  TextField(
                      controller: name,
                      textCapitalization: TextCapitalization.words,
                      decoration:
                          const InputDecoration(labelText: 'Your name')),
                  TextField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Create a password')),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Viewing date'),
                    subtitle: Text(_loadingAvailability
                        ? 'Loading landlord availability...'
                        : date == null
                            ? 'Choose a date'
                            : '${date!.month}/${date!.day}/${date!.year}'),
                    trailing:
                        const Icon(Icons.calendar_month, color: deepGreen),
                    onTap: _loadingAvailability ? null : _chooseDate,
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Viewing time'),
                    subtitle: Text(time?.format(context) ?? 'Choose a time'),
                    trailing: const Icon(Icons.schedule, color: deepGreen),
                    onTap: _chooseTime,
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    text: _saving ? 'Submitting...' : 'Submit viewing',
                    icon: Icons.send,
                    onPressed: _saving ? () {} : _submit,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class GuestStatusDashboard extends StatefulWidget {
  final Map<String, dynamic> guest;

  const GuestStatusDashboard({super.key, required this.guest});

  @override
  State<GuestStatusDashboard> createState() => _GuestStatusDashboardState();
}

class _GuestStatusDashboardState extends State<GuestStatusDashboard> {
  bool _promptShown = false;

  Future<void> _handleTenantOffer(String tenantCode) async {
    if (_promptShown || !mounted) return;
    _promptShown = true;
    var agrees = false;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('You are now a tenant of this unit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Please take note of your Tenant ID: $tenantCode. You may now activate and log in as a tenant.'),
              const SizedBox(height: 10),
              const Text(
                  'Your guest account will be deleted when you continue.'),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: agrees,
                title: const Text(
                  'I agree to delete this guest account',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                onChanged: (value) =>
                    setDialogState(() => agrees = value ?? false),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed:
                  agrees ? () => Navigator.pop(dialogContext, true) : null,
              child: const Text('Continue to tenant activation'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || !mounted) return;
    await DatabaseService.instance
        .deleteGuestAccount(widget.guest['id'] as int);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => TenantActivationPage(tenantCode: tenantCode)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guestId = widget.guest['id'] as int;
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Guest Dashboard'),
            Text(
              'Guest ID: ${widget.guest['guest_code']}',
              style: const TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh request status',
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh, color: deepGreen),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.getGuestViewingRequests(guestId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const EmptyState(
                icon: Icons.error_outline,
                text: 'Unable to load guest requests.');
          }
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: deepGreen));
          }
          final requests = snapshot.data!;
          final offer = requests
              .where((item) => item['status'] == 'Accepted as Tenant')
              .firstOrNull;
          if (offer != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleTenantOffer(offer['tenant_code'].toString());
            });
          }
          if (requests.isEmpty) {
            return const EmptyState(
                icon: Icons.calendar_month, text: 'No viewing requests yet.');
          }
          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              AppCard(
                child: Text(
                  'Welcome, ${widget.guest['name'] ?? 'Guest'}. Your dashboard only shows your viewing and unit status.',
                  style: const TextStyle(color: darkText),
                ),
              ),
              ...requests.map((request) => AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request['room_name'].toString(),
                            style: const TextStyle(
                                color: deepGreen,
                                fontSize: 17,
                                fontWeight: FontWeight.w800)),
                        Text(
                            '${request['requested_date']} • ${request['requested_time']}'),
                        if ((request['room_location'] ?? '')
                            .toString()
                            .isNotEmpty)
                          Text(request['room_location'].toString(),
                              style: const TextStyle(color: muted)),
                        const SizedBox(height: 8),
                        StatusBadge(text: request['status'].toString()),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                user: {
                                  'id': guestId,
                                  'name': widget.guest['name'] ?? 'Guest',
                                },
                                otherUser: {
                                  'id': request['landlord_id'],
                                  'name': 'Room Owner',
                                },
                                guestId: guestId,
                                landlordId: request['landlord_id'] as int,
                                roomId: request['room_id'] as int,
                                guestViewerIsLandlord: false,
                                conversationTitle:
                                    '${widget.guest['name'] ?? 'Guest'} | ${request['room_name']}',
                              ),
                            ),
                          ),
                          icon: const Icon(Icons.chat_outlined),
                          label: const Text('Message landlord'),
                        ),
                      ],
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class TenantActivationPage extends StatefulWidget {
  final String tenantCode;

  const TenantActivationPage({super.key, required this.tenantCode});

  @override
  State<TenantActivationPage> createState() => _TenantActivationPageState();
}

class _TenantActivationPageState extends State<TenantActivationPage> {
  late final TextEditingController tenantCode;
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool termsAccepted = false;
  bool saving = false;
  bool confirmedTenantId = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    tenantCode = TextEditingController(text: widget.tenantCode);
    confirmedTenantId = widget.tenantCode.trim().isNotEmpty;
  }

  Future<void> _activate() async {
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (name.text.trim().isEmpty) {
      _showActivationError('Enter your full name.');
      return;
    }
    if (!emailPattern.hasMatch(email.text.trim())) {
      _showActivationError('Enter a valid email address in the email field.');
      return;
    }
    if (!RegExp(r'^09\d{9}$').hasMatch(phone.text.trim())) {
      _showActivationError(
          'Contact number must start with 09 and contain exactly 11 digits.');
      return;
    }
    if (password.text.length < 6) {
      _showActivationError('Password must be at least 6 characters.');
      return;
    }
    if (password.text != confirmPassword.text) {
      _showActivationError('Password and confirm password do not match.');
      return;
    }
    if (!termsAccepted) {
      _showActivationError('Accept the Terms & Conditions to continue.');
      return;
    }
    setState(() => saving = true);
    try {
      final activated = await DatabaseService.instance.activateTenant(
        tenantCode: tenantCode.text,
        name: name.text,
        email: email.text,
        contactNumber: phone.text,
        password: password.text,
      );
      if (!mounted) return;
      if (!activated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Tenant ID is invalid or already activated.')),
        );
        return;
      }
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage(role: 'Tenant')),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Tenant account activated. Log in using your email and password.')),
      );
    } on StateError catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(switch (error.message) {
            'EMAIL_ALREADY_EXISTS' =>
              'Email error: that email address is already in use.',
            'INVALID_EMAIL' => 'Email error: enter a valid email address.',
            'INVALID_PHONE_NUMBER' =>
              'Contact number must start with 09 and contain exactly 11 digits.',
            _ => 'Unable to activate tenant account.',
          }),
        ),
      );
    } catch (error) {
      debugPrint('TENANT ACTIVATION ERROR: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to activate tenant account.')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showActivationError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    tenantCode.dispose();
    name.dispose();
    email.dispose();
    phone.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: beige,
        appBar: AppBar(
            backgroundColor: beige, title: const Text('Tenant Activation')),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!confirmedTenantId) ...[
                    TextField(
                      controller: tenantCode,
                      readOnly: widget.tenantCode.trim().isNotEmpty,
                      decoration: const InputDecoration(labelText: 'Tenant ID'),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                        'Enter and confirm the Tenant ID provided by the landlord.'),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      text: 'Confirm Tenant ID',
                      icon: Icons.verified_outlined,
                      onPressed: () {
                        if (tenantCode.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Enter your Tenant ID.')),
                          );
                          return;
                        }
                        setState(() => confirmedTenantId = true);
                      },
                    ),
                  ] else ...[
                    Text(
                      'Tenant ID: ${tenantCode.text.trim().toUpperCase()}',
                      style: const TextStyle(
                        color: deepGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                        controller: name,
                        decoration:
                            const InputDecoration(labelText: 'Full name')),
                    TextField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Contact number',
                          hintText: '09xxxxxxxxx',
                          helperText:
                              'Enter exactly 11 digits, starting with 09.',
                        )),
                    TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email')),
                    TextField(
                        controller: password,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: 'Create password',
                          suffixIcon: IconButton(
                            tooltip: hidePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: () =>
                                setState(() => hidePassword = !hidePassword),
                            icon: Icon(hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                          ),
                        )),
                    TextField(
                      controller: confirmPassword,
                      obscureText: hideConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        suffixIcon: IconButton(
                          tooltip: hideConfirmPassword
                              ? 'Show password'
                              : 'Hide password',
                          onPressed: () => setState(
                              () => hideConfirmPassword = !hideConfirmPassword),
                          icon: Icon(hideConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: termsAccepted,
                      onChanged: (value) =>
                          setState(() => termsAccepted = value ?? false),
                      title: Wrap(
                        children: [
                          const Text('I agree to the '),
                          GestureDetector(
                            onTap: () => showRentahananTerms(context),
                            child: const Text('Terms & Conditions',
                                style: TextStyle(
                                    color: deepGreen,
                                    decoration: TextDecoration.underline)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrimaryButton(
                      text: saving ? 'Activating...' : 'Log in',
                      icon: Icons.login,
                      onPressed: saving ? () {} : _activate,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
}

class LoginPage extends StatefulWidget {
  final String role;

  const LoginPage({
    super.key,
    required this.role,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;
  bool loading = false;

  Future<void> login() async {
    final identifier = userController.text.trim();
    if (identifier.isEmpty || passwordController.text.isEmpty) {
      showMessage('Please enter your login details.');
      return;
    }
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    final isLandlord = widget.role == 'Landlord';
    if (isLandlord &&
        !RegExp(r'^L-\d{3}$', caseSensitive: false).hasMatch(identifier)) {
      showMessage('Enter the landlord ID provided by the superadmin.');
      return;
    }
    if (!isLandlord && !emailPattern.hasMatch(identifier)) {
      showMessage('Invalid email address. Please enter a valid email.');
      return;
    }

    setState(() => loading = true);
    Map<String, dynamic>? user;
    try {
      user = await DatabaseService.instance.login(
        identifier: identifier,
        password: passwordController.text,
        role: widget.role,
      );
    } catch (_) {
      if (mounted) showMessage('Unable to log in right now. Please try again.');
      return;
    } finally {
      if (mounted) setState(() => loading = false);
    }

    if (!mounted) return;
    if (user == null) {
      showMessage('Invalid email, password, or account role.');
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => DashboardPage(user: user!)),
      (route) => false,
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: deepGreen,
      ),
    );
  }

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: deepGreen),
                ),
              ),
              const SizedBox(height: 15),
              const RENTahananLogo(size: 90),
              const SizedBox(height: 5),
              Text(
                '${widget.role} Login',
                style: const TextStyle(
                  color: deepGreen,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Login using your ${widget.role.toLowerCase()} account',
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 25),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back!',
                      style: TextStyle(
                        color: deepGreen,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FieldLabel(
                      text: widget.role == 'Landlord'
                          ? 'Landlord ID'
                          : 'Email Address',
                    ),
                    const SizedBox(height: 7),
                    AppTextField(
                      controller: userController,
                      hintText: widget.role == 'Landlord'
                          ? 'Enter your landlord ID'
                          : 'Enter your email address',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 17),
                    const FieldLabel(
                      text: 'Password',
                    ),
                    const SizedBox(height: 7),
                    AppTextField(
                      controller: passwordController,
                      hintText: 'Enter your password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: hidePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(
                      text: loading ? 'Logging in...' : 'Login',
                      icon: Icons.login_rounded,
                      onPressed: loading ? () {} : login,
                    ),
                    if (widget.role == 'Tenant') ...[
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TenantActivationPage(tenantCode: ''),
                              ),
                            );
                          },
                          child: const Text(
                              'First time here? Activate with Tenant ID'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SIGN UP
// ============================================================

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // ── Account fields ─────────────────────────────────────
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  // ── Apartment fields (landlord only) ────────────────────
  final apartmentNameController = TextEditingController();
  final apartmentLocationController = TextEditingController();
  final floorsController = TextEditingController(text: '1');
  final roomsController = TextEditingController(text: '1');
  bool petFriendly = false;
  String priceTier = 'Standard';

  String role = 'Tenant';
  bool hidePassword = true;
  bool hideConfirm = true;
  bool terms = false;

  Future<void> signUp() async {
    // ── Basic field validation ─────────────────────────
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {
      showMessage('Please complete all fields.');
      return;
    }

    if (passwordController.text != confirmController.text) {
      showMessage('Passwords do not match.');
      return;
    }

    // ── Landlord apartment validation ──────────────────
    if (role == 'Landlord') {
      if (apartmentNameController.text.trim().isEmpty) {
        showMessage('Please enter your apartment name.');
        return;
      }
      if (apartmentLocationController.text.trim().isEmpty) {
        showMessage('Please enter your apartment location.');
        return;
      }
      final floors = int.tryParse(floorsController.text.trim()) ?? 0;
      final rooms = int.tryParse(roomsController.text.trim()) ?? 0;
      if (floors <= 0) {
        showMessage('Please enter a valid number of floors.');
        return;
      }
      if (rooms <= 0) {
        showMessage('Please enter a valid number of rooms.');
        return;
      }
    }

    if (!terms) {
      showMessage('Please agree to the Terms & Conditions.');
      return;
    }

    try {
      final newId = await DatabaseService.instance.createUser(
        name: nameController.text,
        email: emailController.text,
        password: passwordController.text,
        role: role,
      );

      // Save apartment details for landlords
      if (role == 'Landlord') {
        await DatabaseService.instance.createLandlordApartment(
          landlordId: newId,
          apartmentName: apartmentNameController.text.trim(),
          location: apartmentLocationController.text.trim(),
          totalFloors: int.tryParse(floorsController.text.trim()) ?? 1,
          totalRooms: int.tryParse(roomsController.text.trim()) ?? 1,
          petFriendly: petFriendly,
          priceTier: priceTier,
        );
      }

      if (!mounted) return;

      showMessage('Account created successfully.');

      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => LoginPage(role: role),
          ),
        );
      });
    } catch (e) {
      debugPrint('SIGN UP ERROR: $e');
      if (!mounted) return;
      if (e.toString().contains('EMAIL_ALREADY_EXISTS')) {
        showMessage('Email already exists.');
      } else {
        showMessage('Unable to create account. Please try again.');
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: deepGreen,
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    apartmentNameController.dispose();
    apartmentLocationController.dispose();
    floorsController.dispose();
    roomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 10),

              const RENTahananLogo(size: 80),

              const SizedBox(height: 5),

              const Text(
                'Create Account',
                style: TextStyle(
                  color: deepGreen,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 20),

              // ── Account info card ────────────────────────
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FieldLabel(text: 'Full Name'),
                    const SizedBox(height: 7),
                    AppTextField(
                      controller: nameController,
                      hintText: 'Enter your full name',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 15),
                    const FieldLabel(text: 'Email Address'),
                    const SizedBox(height: 7),
                    AppTextField(
                      controller: emailController,
                      hintText: 'Enter your email address',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 15),
                    const FieldLabel(text: 'Account Type'),
                    const SizedBox(height: 7),
                    const Text('Tenant account'),
                    const SizedBox(height: 15),
                    const FieldLabel(text: 'Password'),
                    const SizedBox(height: 7),
                    AppTextField(
                      controller: passwordController,
                      hintText: 'Create a password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: hidePassword,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => hidePassword = !hidePassword),
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const FieldLabel(text: 'Confirm Password'),
                    const SizedBox(height: 7),
                    AppTextField(
                      controller: confirmController,
                      hintText: 'Confirm your password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: hideConfirm,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => hideConfirm = !hideConfirm),
                        icon: Icon(
                          hideConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      value: terms,
                      onChanged: (v) => setState(() => terms = v ?? false),
                      activeColor: deepGreen,
                      contentPadding: EdgeInsets.zero,
                      title: Wrap(
                        children: [
                          const Text(
                            'I agree to the ',
                            style: TextStyle(color: muted, fontSize: 10),
                          ),
                          GestureDetector(
                            onTap: () => showRentahananTerms(context),
                            child: const Text(
                              'Terms & Conditions',
                              style: TextStyle(
                                color: deepGreen,
                                fontSize: 10,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const Text(
                            ' and Privacy Policy.',
                            style: TextStyle(color: muted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Apartment setup card (landlord only) ─────
              if (role == 'Landlord') ...[
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: softGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.apartment_rounded,
                              color: forestGreen,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Apartment Details',
                                  style: TextStyle(
                                    color: deepGreen,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Tell tenants about your property.',
                                  style: TextStyle(color: muted, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const FieldLabel(text: 'Apartment / Building Name'),
                      const SizedBox(height: 7),
                      AppTextField(
                        controller: apartmentNameController,
                        hintText: 'e.g. Santos Apartments',
                        icon: Icons.home_work_outlined,
                      ),
                      const SizedBox(height: 15),
                      const FieldLabel(text: 'Location / Address'),
                      const SizedBox(height: 7),
                      AppTextField(
                        controller: apartmentLocationController,
                        hintText: 'e.g. Hagonoy, Taguig City',
                        icon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FieldLabel(text: 'Number of Floors'),
                                const SizedBox(height: 7),
                                AppTextField(
                                  controller: floorsController,
                                  hintText: '1',
                                  icon: Icons.stairs_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FieldLabel(text: 'Total Rooms'),
                                const SizedBox(height: 7),
                                AppTextField(
                                  controller: roomsController,
                                  hintText: '1',
                                  icon: Icons.meeting_room_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const FieldLabel(text: 'Price Tier'),
                      const SizedBox(height: 7),
                      DropdownButtonFormField<String>(
                        initialValue: priceTier,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: lightBeige,
                          prefixIcon: const Icon(
                            Icons.attach_money_rounded,
                            color: forestGreen,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(color: borderColor),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Budget',
                            child: Text('Budget  (₱3,000 – ₱6,000/mo)'),
                          ),
                          DropdownMenuItem(
                            value: 'Standard',
                            child: Text('Standard  (₱6,000 – ₱10,000/mo)'),
                          ),
                          DropdownMenuItem(
                            value: 'Premium',
                            child: Text('Premium  (₱10,000+/mo)'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => priceTier = v);
                        },
                      ),
                      const SizedBox(height: 15),
                      Container(
                        decoration: BoxDecoration(
                          color: lightBeige,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: SwitchListTile(
                          value: petFriendly,
                          onChanged: (v) => setState(() => petFriendly = v),
                          activeThumbColor: forestGreen,
                          title: const Text(
                            'Pet Friendly',
                            style: TextStyle(
                              color: deepGreen,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: const Text(
                            'Allow tenants with pets to rent rooms.',
                            style: TextStyle(color: muted, fontSize: 10),
                          ),
                          secondary: const Icon(
                            Icons.pets_rounded,
                            color: forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              PrimaryButton(
                text: 'Create Account',
                icon: Icons.person_add_alt_1_rounded,
                onPressed: signUp,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardPage({
    super.key,
    required this.user,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  int get userId => widget.user['id'] as int;

  bool get isTenant =>
      (widget.user['role'] ?? '').toString().trim().toLowerCase() == 'tenant';

  @override
  Widget build(BuildContext context) {
    final pages = isTenant
        ? [
            TenantHomePage(user: widget.user),
            ExplorePage(user: widget.user),
            ActivityPage(user: widget.user),
            ProfilePage(user: widget.user),
          ]
        : [
            LandlordHomePage(user: widget.user),
            LandlordExplorePage(user: widget.user),
            LandlordActivityPage(user: widget.user),
            ProfilePage(user: widget.user),
          ];

    return Scaffold(
      backgroundColor: beige,
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: white,
        indicatorColor: softGreen,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class AnnouncementsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const AnnouncementsPage({super.key, required this.user});

  @override
  State<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  late Future<List<Map<String, dynamic>>> _announcements;

  bool get _isLandlord =>
      (widget.user['role'] ?? '').toString().toLowerCase() == 'landlord';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    final userId = widget.user['id'] as int;
    _announcements = _isLandlord
        ? DatabaseService.instance.getLandlordAnnouncements(userId)
        : DatabaseService.instance.getTenantAnnouncements(userId);
  }

  Future<void> _createAnnouncement() async {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final announcement = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Announcement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                maxLength: 80,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: messageController,
                maxLines: 5,
                maxLength: 1000,
                decoration: const InputDecoration(labelText: 'Message'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final message = messageController.text.trim();
              if (title.isEmpty || message.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enter both a title and an announcement.'),
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext, {
                'title': title,
                'message': message,
              });
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
    if (announcement == null) return;

    try {
      await DatabaseService.instance.createAnnouncement(
        landlordId: widget.user['id'] as int,
        title: announcement['title']!,
        message: announcement['message']!,
      );
      if (!mounted) return;
      setState(_loadAnnouncements);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Announcement published.')),
      );
    } catch (error) {
      debugPrint('CREATE ANNOUNCEMENT ERROR: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to publish the announcement.')),
      );
    }
  }

  Future<void> _deleteAnnouncement(int announcementId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete announcement?'),
        content: const Text('This announcement will no longer be visible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await DatabaseService.instance.deleteAnnouncement(
        announcementId: announcementId,
        landlordId: widget.user['id'] as int,
      );
      if (mounted) setState(_loadAnnouncements);
    } catch (error) {
      debugPrint('DELETE ANNOUNCEMENT ERROR: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete the announcement.')),
      );
    }
  }

  String _dateLabel(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text('Announcements'),
        actions: [
          if (_isLandlord)
            IconButton(
              tooltip: 'Post announcement',
              onPressed: _createAnnouncement,
              icon: const Icon(Icons.add_circle_outline, color: deepGreen),
            ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _announcements,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline,
              text: 'Unable to load announcements.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: deepGreen),
            );
          }
          final announcements = snapshot.data!;
          if (announcements.isEmpty) {
            return EmptyState(
              icon: Icons.campaign_outlined,
              text: _isLandlord
                  ? 'No announcements yet. Use + to post an update for your tenants.'
                  : 'There are no announcements from your landlord yet.',
            );
          }
          return RefreshIndicator(
            color: deepGreen,
            onRefresh: () async {
              setState(_loadAnnouncements);
              await _announcements;
            },
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: announcements
                  .map(
                    (announcement) => AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.campaign_rounded,
                                  color: forestGreen),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  announcement['title'].toString(),
                                  style: const TextStyle(
                                    color: deepGreen,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (_isLandlord)
                                IconButton(
                                  tooltip: 'Delete announcement',
                                  onPressed: () => _deleteAnnouncement(
                                    announcement['id'] as int,
                                  ),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: muted,
                                  ),
                                ),
                            ],
                          ),
                          if (!_isLandlord) ...[
                            const SizedBox(height: 3),
                            Text(
                              'From ${announcement['landlord_name'] ?? 'your landlord'}',
                              style: const TextStyle(
                                  color: forestGreen, fontSize: 11),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            announcement['message'].toString(),
                            style:
                                const TextStyle(color: darkText, height: 1.45),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _dateLabel(announcement['created_at']),
                            style: const TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

class DashboardAnnouncements extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardAnnouncements({super.key, required this.user});

  @override
  State<DashboardAnnouncements> createState() => _DashboardAnnouncementsState();
}

class _DashboardAnnouncementsState extends State<DashboardAnnouncements> {
  late Future<List<Map<String, dynamic>>> _announcements;

  bool get _isLandlord =>
      (widget.user['role'] ?? '').toString().toLowerCase() == 'landlord';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  void _loadAnnouncements() {
    final userId = widget.user['id'] as int;
    _announcements = _isLandlord
        ? DatabaseService.instance.getLandlordAnnouncements(userId)
        : DatabaseService.instance.getTenantAnnouncements(userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _announcements,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const AppCard(
            child: Text(
              'Unable to load announcements.',
              style: TextStyle(color: muted),
            ),
          );
        }

        final announcements = snapshot.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: 'Announcements',
              subtitle: _isLandlord
                  ? 'Updates for your tenants.'
                  : 'Updates from your landlord.',
            ),
            const SizedBox(height: 10),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(color: deepGreen),
                ),
              )
            else if (announcements.isEmpty)
              AppCard(
                child: Text(
                  _isLandlord
                      ? 'No announcements yet. Post an update for your tenants.'
                      : 'There are no announcements from your landlord yet.',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              )
            else if (announcements.isNotEmpty) ...[
              ...announcements.take(2).map(
                    (announcement) => AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            announcement['title'].toString(),
                            style: const TextStyle(
                              color: deepGreen,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            announcement['message'].toString(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: darkText,
                              height: 1.4,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
            if (_isLandlord || announcements.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnnouncementsPage(user: widget.user),
                      ),
                    );
                    if (mounted) setState(_loadAnnouncements);
                  },
                  icon: const Icon(Icons.campaign_outlined),
                  label: Text(
                    _isLandlord
                        ? 'Manage announcements'
                        : 'View all announcements',
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class ContractFeedbackPrompt extends StatefulWidget {
  final Map<String, dynamic> user;

  const ContractFeedbackPrompt({super.key, required this.user});

  @override
  State<ContractFeedbackPrompt> createState() => _ContractFeedbackPromptState();
}

class _ContractFeedbackPromptState extends State<ContractFeedbackPrompt> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    _checkForEndedContract();
  }

  Future<void> _checkForEndedContract() async {
    try {
      final tenantId = widget.user['id'] as int;
      final active =
          await DatabaseService.instance.getActiveContractDetails(tenantId);
      if (active != null || !mounted) return;

      final contract =
          await DatabaseService.instance.getLatestTerminatedContract(tenantId);
      if (contract == null || !mounted) return;
      final alreadyReviewed =
          await DatabaseService.instance.hasReviewForContractRoom(
        tenantId: tenantId,
        roomId: contract['room_id'] as int,
      );
      if (alreadyReviewed || !mounted || _checked) return;
      _checked = true;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final leaveFeedback = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Your contract has ended'),
            content: const Text(
              'Please leave a rating, feedback, and any suggestions about your stay.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Leave feedback'),
              ),
            ],
          ),
        );
        if (leaveFeedback == true && mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReviewPage(user: widget.user, contract: contract),
            ),
          );
        }
      });
    } catch (error) {
      debugPrint('CONTRACT END CHECK ERROR: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to check your contract status.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ============================================================
// TENANT HOME
// ============================================================

class TenantHomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const TenantHomePage({
    super.key,
    required this.user,
  });

  @override
  State<TenantHomePage> createState() => _TenantHomePageState();
}

class _TenantHomePageState extends State<TenantHomePage> {
  Future<void> _deleteEndedAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'Your account will be deactivated and your personal contact details removed. Historical contracts, payments, and feedback will remain in the landlord records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep account'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await DatabaseService.instance
          .deleteTenantAccount(widget.user['id'] as int);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (_) => false,
      );
    } on StateError catch (error) {
      if (!mounted) return;
      final message = error.message == 'ACTIVE_CONTRACT_MUST_END_FIRST'
          ? 'You can delete your account after your active rental ends.'
          : 'Unable to delete your account.';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      debugPrint('DELETE TENANT ACCOUNT ERROR: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to delete your account.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantId = widget.user['id'] as int;

    return AppScaffold(
      title: 'Good day, ${widget.user['name']}!',
      subtitle: 'Here is a summary of your current rental.',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: deepGreen,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationsPage(
                  userId: tenantId,
                ),
              ),
            );
          },
        ),
      ],
      child: RefreshIndicator(
        color: deepGreen,
        onRefresh: () async {
          if (mounted) setState(() {});
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 25),
          children: [
            DashboardAnnouncements(user: widget.user),
            ContractFeedbackPrompt(user: widget.user),
            const SizedBox(height: 8),
            // ── Active contract / room card ──────────────────
            FutureBuilder<Map<String, dynamic>?>(
              future:
                  DatabaseService.instance.getActiveContractDetails(tenantId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: CircularProgressIndicator(color: deepGreen),
                    ),
                  );
                }

                final contract = snapshot.data;

                if (contract == null) {
                  return AppCard(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.home_work_outlined,
                          color: forestGreen,
                          size: 42,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No Active Rental',
                          style: TextStyle(
                            color: deepGreen,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Your contract has ended. You can keep this account to browse other rooms and message landlords, or choose to delete it.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: muted, fontSize: 11, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        SecondaryButton(
                          text: 'Keep my account & browse rooms',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    GuestDashboard(user: widget.user),
                              ),
                            );
                          },
                        ),
                        TextButton.icon(
                          onPressed: _deleteEndedAccount,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.red,
                          ),
                          label: const Text(
                            'Delete my account',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final monthlyRent =
                    (contract['monthly_rent'] as num?)?.toDouble() ?? 0.0;
                final startDate = DateTime.tryParse(
                        contract['start_date']?.toString() ?? '') ??
                    DateTime.now();
                final endDateRaw = contract['contract_end_date']?.toString();
                final endDate =
                    endDateRaw != null ? DateTime.tryParse(endDateRaw) : null;
                final daysRented = DateTime.now().difference(startDate).inDays;

                String fmtDate(DateTime? d) {
                  if (d == null) return 'Ongoing';
                  return '${d.month}/${d.day}/${d.year}';
                }

                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [deepGreen, forestGreen],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contract['room_name'] ?? 'Your Room',
                                  style: const TextStyle(
                                    color: deepGreen,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      color: muted,
                                      size: 13,
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        contract['room_location'] ?? '',
                                        style: const TextStyle(
                                            color: muted, fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: softGreen,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: forestGreen,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: borderColor),
                      const SizedBox(height: 12),
                      // Details
                      _tenantInfoRow(
                        Icons.payments_outlined,
                        'Monthly Rent',
                        '₱${monthlyRent.toStringAsFixed(2)}',
                      ),
                      _tenantInfoRow(
                        Icons.calendar_today_outlined,
                        'Start Date',
                        fmtDate(startDate),
                      ),
                      _tenantInfoRow(
                        Icons.event_outlined,
                        'End Date',
                        fmtDate(endDate),
                      ),
                      _tenantInfoRow(
                        Icons.timelapse_rounded,
                        'Days Rented',
                        '$daysRented day${daysRented == 1 ? '' : 's'}',
                      ),
                      _tenantInfoRow(
                        Icons.person_outline_rounded,
                        'Landlord',
                        contract['landlord_name'] ?? '—',
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // ── Upcoming payment ─────────────────────────────
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseService.instance.getTenantPayments(tenantId),
              builder: (context, snapshot) {
                final payments = snapshot.data ?? [];
                final pending = payments.where((p) {
                  final s = (p['status'] ?? '').toString().toLowerCase();
                  return s == 'pending' || s == 'overdue';
                }).toList();
                pending.sort((a, b) {
                  final dateA =
                      DateTime.tryParse((a['due_date'] ?? '').toString());
                  final dateB =
                      DateTime.tryParse((b['due_date'] ?? '').toString());
                  if (dateA == null) return dateB == null ? 0 : 1;
                  if (dateB == null) return -1;
                  return dateA.compareTo(dateB);
                });

                if (pending.isEmpty) return const SizedBox.shrink();

                final next = pending.first;
                final amount = (next['amount'] as num?)?.toDouble() ?? 0.0;
                final dueRaw = next['due_date']?.toString() ?? '';
                final due = DateTime.tryParse(dueRaw);
                final overdue = due != null && due.isBefore(DateTime.now());
                final daysUntil =
                    due != null ? due.difference(DateTime.now()).inDays : 0;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: overdue ? const Color(0xFFFFEEEE) : softGreen,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: overdue ? Colors.red.shade200 : borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        overdue
                            ? Icons.warning_amber_rounded
                            : Icons.payments_outlined,
                        color: overdue ? Colors.red : forestGreen,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              overdue ? 'Payment Overdue!' : 'Upcoming Payment',
                              style: TextStyle(
                                color: overdue ? Colors.red : deepGreen,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              (next['payment_type'] ?? 'Rent').toString(),
                              style: const TextStyle(
                                color: muted,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '₱${amount.toStringAsFixed(2)} • Due ${due != null ? '${due.month}/${due.day}/${due.year}' : dueRaw}',
                              style: TextStyle(
                                color: overdue ? Colors.red.shade700 : muted,
                                fontSize: 11,
                              ),
                            ),
                            if (!overdue && daysUntil >= 0)
                              Text(
                                '$daysUntil day${daysUntil == 1 ? '' : 's'} remaining',
                                style:
                                    const TextStyle(color: muted, fontSize: 10),
                              ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TenantPaymentsPage(user: widget.user),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          color: deepGreen,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            // ── Quick Actions (4 full-width landscape tiles) ─
            const SectionTitle(
              title: 'Quick Actions',
              subtitle: 'Manage your rental from here.',
            ),
            const SizedBox(height: 12),

            FeatureTile(
              icon: Icons.campaign_outlined,
              title: 'Announcements',
              description: 'Read updates from your landlord',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnnouncementsPage(user: widget.user),
                ),
              ),
            ),

            FeatureTile(
              icon: Icons.payments_outlined,
              title: 'Payments',
              description: 'View rent history and due dates',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TenantPaymentsPage(user: widget.user),
                ),
              ),
            ),

            FeatureTile(
              icon: Icons.description_outlined,
              title: 'Contract',
              description: 'View your active rental contract',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TenantContractPage(user: widget.user),
                ),
              ),
            ),

            FeatureTile(
              icon: Icons.report_problem_outlined,
              title: 'Report a Concern',
              description: 'Send water, electricity or maintenance issues',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TenantReportPage(user: widget.user),
                ),
              ),
            ),

            FeatureTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Message Landlord',
              description: 'Contact your landlord directly',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TenantLandlordChatPage(user: widget.user),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tenantInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: forestGreen),
          const SizedBox(width: 8),
          Expanded(
            child:
                Text(label, style: const TextStyle(color: muted, fontSize: 11)),
          ),
          Text(value,
              style: const TextStyle(
                  color: darkText, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ============================================================
// TENANT EXPLORE  (Rental Tools — no room browsing)
// ============================================================

class ExplorePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const ExplorePage({
    super.key,
    required this.user,
  });

  void _go(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Rental Management',
      subtitle: 'Your contract, payments, messages and rental concerns.',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
        children: [
          FeatureTile(
            icon: Icons.description_outlined,
            title: 'My Contract',
            description:
                'View your active rental contract, start date, rent amount and status.',
            onTap: () => _go(context, TenantContractPage(user: user)),
          ),
          FeatureTile(
            icon: Icons.payments_outlined,
            title: 'My Payments',
            description:
                'View rent payment history, due dates and send reminders.',
            onTap: () => _go(context, TenantPaymentsPage(user: user)),
          ),
          FeatureTile(
            icon: Icons.report_problem_outlined,
            title: 'Rental Concerns',
            description:
                'Submit and track water, electricity, noise or maintenance concerns.',
            onTap: () => _go(context, TenantReportPage(user: user)),
          ),
          FeatureTile(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Message Landlord',
            description: 'Send a message directly to your landlord.',
            onTap: () => _go(context, TenantLandlordChatPage(user: user)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ROOM DETAILS
// ============================================================

class RoomDetailsPage extends StatelessWidget {
  final Map<String, dynamic> room;
  final Map<String, dynamic>? user;

  const RoomDetailsPage({
    super.key,
    required this.room,
    required this.user,
  });

  void _requestViewing(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => user == null
            ? GuestViewingRequestPage(room: room)
            : ViewingRequestPage(room: room, user: user!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text(
          'Room Details',
          style: TextStyle(
            color: deepGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: deepGreen,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StoredImageGallery(
              data: room['image'],
              width: double.infinity,
              height: 250,
              radius: 20,
              fallbackIcon: Icons.home_work_rounded,
              showThumbnails: true,
            ),
            const SizedBox(height: 18),
            Text(
              room['name']?.toString() ?? 'Room',
              style: const TextStyle(
                color: deepGreen,
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: forestGreen,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    room['location']?.toString() ?? '',
                    style: const TextStyle(color: muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              '₱${(room['price'] as num).toStringAsFixed(0)} / month',
              style: const TextStyle(
                color: deepGreen,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                InfoChip(
                  icon: Icons.bed_outlined,
                  text:
                      '${room['bedrooms'] ?? 1} Bedroom${room['bedrooms'] == 1 ? '' : 's'}',
                ),
                InfoChip(
                  icon: Icons.bathtub_outlined,
                  text:
                      '${room['bathrooms'] ?? 1} Bathroom${room['bathrooms'] == 1 ? '' : 's'}',
                ),
                InfoChip(
                  icon: Icons.stairs_outlined,
                  text: 'Floor ${room['floor'] ?? 1}',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About this room',
                    style: TextStyle(
                      color: deepGreen,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    (room['description'] ?? '').toString().trim().isEmpty
                        ? 'No description provided.'
                        : room['description'].toString(),
                    style: const TextStyle(
                      color: muted,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (user == null) ...[
              const SizedBox(height: 18),
              RoomGuestReviews(roomId: room['id'] as int),
            ],
            const SizedBox(height: 16),
            if (user != null)
              SecondaryButton(
                text: 'Message Owner',
                onPressed: () async {
                  final landlord = await DatabaseService.instance
                      .getUser(room['landlord_id']);

                  if (!context.mounted || landlord == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        user: user!,
                        otherUser: landlord,
                        roomId: room['id'] as int,
                        conversationTitle:
                            '${landlord['name']} | ${room['name']}',
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(18, 8, 18, 14),
        child: PrimaryButton(
          text: 'Request Viewing',
          icon: Icons.calendar_month_rounded,
          onPressed: () => _requestViewing(context),
        ),
      ),
    );
  }
}

// ============================================================
// VIEWING REQUEST
// ============================================================

class ViewingRequestPage extends StatefulWidget {
  final Map<String, dynamic> room;
  final Map<String, dynamic> user;

  const ViewingRequestPage({
    super.key,
    required this.room,
    required this.user,
  });

  @override
  State<ViewingRequestPage> createState() => _ViewingRequestPageState();
}

class _ViewingRequestPageState extends State<ViewingRequestPage> {
  final messageController = TextEditingController();

  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

  TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
  List<Map<String, dynamic>> _blockedDates = [];
  bool _loadingAvailability = true;

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    try {
      final rules = await DatabaseService.instance.getViewingBlackouts(
        widget.room['landlord_id'] as int,
      );
      if (!mounted) return;
      final firstAvailable = _firstAvailableViewingDate(
        DateTime.now().add(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 60)),
        rules,
      );
      setState(() {
        _blockedDates = rules;
        if (firstAvailable != null) selectedDate = firstAvailable;
        _loadingAvailability = false;
      });
    } catch (error) {
      debugPrint('LOAD TENANT VIEWING AVAILABILITY ERROR: $error');
      if (!mounted) return;
      setState(() => _loadingAvailability = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to load the landlord’s viewing availability.'),
        ),
      );
    }
  }

  Future<void> _chooseDate() async {
    if (_loadingAvailability) return;
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    final lastDate = today.add(const Duration(days: 60));
    final firstAvailable = _firstAvailableViewingDate(
      selectedDate.isBefore(firstDate) ? firstDate : selectedDate,
      lastDate,
      _blockedDates,
    );
    if (firstAvailable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('The landlord has no available dates in the next 60 days.'),
        ),
      );
      return;
    }
    final date = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: firstAvailable,
      selectableDayPredicate: (day) =>
          !_isViewingDateBlocked(day, _blockedDates),
      helpText: 'Unavailable dates are disabled',
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> _chooseTime() async {
    final time = await _pickViewingTime(context, selectedTime);
    if (!mounted) return;
    if (time == null) return;
    if (_isViewingTimeBlocked(time, _blockedDates)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'The landlord is unavailable at that time. Choose another time.'),
        ),
      );
      return;
    }
    setState(() => selectedTime = time);
  }

  Future<void> submit() async {
    if (_isViewingDateBlocked(selectedDate, _blockedDates)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'The landlord is unavailable on that date. Choose another day.'),
        ),
      );
      return;
    }
    if (!_isViewingTimeAllowed(selectedTime)) {
      await _pickViewingTime(context, selectedTime);
      return;
    }
    if (_isViewingTimeBlocked(selectedTime, _blockedDates)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'The landlord is unavailable at that time. Choose another time.'),
        ),
      );
      return;
    }

    try {
      await DatabaseService.instance.requestViewing(
        tenantId: widget.user['id'],
        landlordId: widget.room['landlord_id'],
        roomId: widget.room['id'],
        date: _viewingDateKey(selectedDate),
        time: selectedTime.format(context),
        message: messageController.text,
      );
    } on StateError catch (error) {
      if (!mounted) return;
      final message = switch (error.message) {
        'VIEWING_DAY_BLOCKED' =>
          'The landlord is unavailable on that date. Choose another day.',
        'VIEWING_TIME_BLOCKED' =>
          'The landlord is unavailable at that time. Choose another time.',
        'VIEWING_TIME_OUT_OF_RANGE' =>
          'Unit viewings are only available from 8:00 AM to 6:00 PM.',
        'ROOM_NOT_AVAILABLE' => 'This unit is no longer available.',
        'INVALID_VIEWING_DATE' => 'Choose a valid viewing date.',
        _ => 'Unable to send the viewing request. Please try again.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    } catch (error) {
      debugPrint('TENANT VIEWING REQUEST ERROR: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Unable to send the viewing request. Please try again.'),
        ),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request Sent'),
        content: const Text(
          'Your viewing request has been sent to the owner. You will receive a notification once it is approved or rejected.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Done',
              style: TextStyle(color: deepGreen),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text(
          'Request Viewing',
          style: TextStyle(
            color: deepGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: deepGreen,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.room['name'],
                style: const TextStyle(
                  color: deepGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              const FieldLabel(text: 'Viewing Date'),
              const SizedBox(height: 7),
              ListTile(
                tileColor: lightBeige,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                leading: const Icon(
                  Icons.calendar_month_rounded,
                  color: forestGreen,
                ),
                title: Text(
                  '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
                ),
                subtitle: _loadingAvailability
                    ? const Text('Loading landlord availability...')
                    : null,
                onTap: _loadingAvailability ? null : _chooseDate,
              ),
              const SizedBox(height: 15),
              const FieldLabel(text: 'Viewing Time'),
              const SizedBox(height: 7),
              ListTile(
                tileColor: lightBeige,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                leading: const Icon(
                  Icons.access_time_rounded,
                  color: forestGreen,
                ),
                title: Text(
                  selectedTime.format(context),
                ),
                subtitle: const Text('Available between 8:00 AM and 6:00 PM'),
                onTap: _chooseTime,
              ),
              const SizedBox(height: 15),
              const FieldLabel(
                text: 'Message to Owner',
              ),
              const SizedBox(height: 7),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Optional message...',
                  filled: true,
                  fillColor: lightBeige,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: borderColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                text: 'Send Request',
                icon: Icons.send_rounded,
                onPressed: submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CHAT
// ============================================================

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> otherUser;
  final int? roomId;
  final int? guestId;
  final int? landlordId;
  final bool guestViewerIsLandlord;
  final String? conversationTitle;
  final String? conversationSubtitle;

  const ChatPage({
    super.key,
    required this.user,
    required this.otherUser,
    this.roomId,
    this.guestId,
    this.landlordId,
    this.guestViewerIsLandlord = false,
    this.conversationTitle,
    this.conversationSubtitle,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = TextEditingController();

  Future<void> send() async {
    final messageText = controller.text.trim();
    if (messageText.isEmpty) return;
    try {
      if (widget.guestId != null) {
        await DatabaseService.instance.sendGuestMessage(
          guestId: widget.guestId!,
          landlordId: widget.landlordId!,
          roomId: widget.roomId!,
          fromLandlord: widget.guestViewerIsLandlord,
          message: messageText,
        );
      } else {
        await DatabaseService.instance.sendMessage(
          senderId: widget.user['id'],
          receiverId: widget.otherUser['id'],
          message: messageText,
          roomId: widget.roomId,
        );
      }
      if (!mounted) return;
      controller.clear();
      setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Message could not be sent. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.conversationTitle ?? widget.otherUser['name'].toString(),
              style: const TextStyle(
                color: deepGreen,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            if (widget.conversationSubtitle != null)
              Text(
                widget.conversationSubtitle!,
                style: const TextStyle(color: muted, fontSize: 12),
              ),
          ],
        ),
        iconTheme: const IconThemeData(
          color: deepGreen,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: widget.guestId != null
                  ? DatabaseService.instance.getGuestConversation(
                      guestId: widget.guestId!,
                      landlordId: widget.landlordId!,
                      roomId: widget.roomId!,
                      viewerIsLandlord: widget.guestViewerIsLandlord,
                    )
                  : DatabaseService.instance.getConversation(
                      widget.user['id'],
                      widget.otherUser['id'],
                    ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Could not load messages.'),
                        TextButton(
                            onPressed: () => setState(() {}),
                            child: const Text('Retry')),
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: deepGreen));
                }
                final messages = snapshot.data ?? <Map<String, dynamic>>[];
                if (messages.isEmpty) {
                  return const Center(
                      child: Text(
                          'No messages yet. Start the conversation below.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message = messages[index];

                    final mine = widget.guestId != null
                        ? message['sender_role'] ==
                            (widget.guestViewerIsLandlord
                                ? 'landlord'
                                : 'guest')
                        : message['sender_id'] == widget.user['id'];

                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: mine ? deepGreen : white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message['message'].toString(),
                              style: TextStyle(
                                  color: mine ? Colors.white : darkText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeAgo(message['created_at']),
                              style: TextStyle(
                                color: mine ? Colors.white70 : muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      filled: true,
                      fillColor: lightBeige,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: deepGreen,
                  onPressed: send,
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
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

// ============================================================
// TENANT ACTIVITY
// ============================================================

class ActivityPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ActivityPage({super.key, required this.user});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  Future<void> openPage(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (mounted) setState(() {});
  }

  String money(dynamic value) {
    if (value is num) return '₱${value.toStringAsFixed(2)}';
    return '₱0.00';
  }

  String shortDate(dynamic value) {
    final d = DateTime.tryParse(value?.toString() ?? '');
    if (d == null) return value?.toString() ?? '';
    return '${d.month}/${d.day}/${d.year}';
  }

  Widget sectionHeader(String title, String subtitle) {
    return SectionTitle(title: title, subtitle: subtitle);
  }

  @override
  Widget build(BuildContext context) {
    final tenantId = widget.user['id'] as int;

    return AppScaffold(
      title: 'Activity',
      subtitle: 'Manage your rental, requests, payments and concerns.',
      child: RefreshIndicator(
        color: deepGreen,
        onRefresh: () async {
          if (mounted) setState(() {});
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
          children: [
            // ══════════════════════════════════════════════
            // RECENT RENTAL ACTIVITY  ← moved to top
            // ══════════════════════════════════════════════
            sectionHeader(
              'Recent Rental Activity',
              'Updates from your rental records appear here.',
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseService.instance.getNotifications(tenantId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const AppCard(
                    child: Center(
                      child: CircularProgressIndicator(color: deepGreen),
                    ),
                  );
                }

                final notifications = snapshot.data!;
                if (notifications.isEmpty) {
                  return const AppCard(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_rounded,
                          color: forestGreen,
                          size: 38,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No recent activity yet.',
                          style: TextStyle(
                            color: deepGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Viewing approvals, payment updates, landlord messages, report updates and contract changes will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: muted, fontSize: 10, height: 1.5),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: notifications.take(8).map((item) {
                    var icon = Icons.notifications_none_rounded;
                    final title = item['title'].toString().toLowerCase();
                    if (title.contains('payment') || title.contains('rent')) {
                      icon = Icons.payments_outlined;
                    } else if (title.contains('view')) {
                      icon = Icons.calendar_month_rounded;
                    } else if (title.contains('report') ||
                        title.contains('concern')) {
                      icon = Icons.report_problem_outlined;
                    } else if (title.contains('message')) {
                      icon = Icons.chat_bubble_outline_rounded;
                    } else if (title.contains('contract')) {
                      icon = Icons.description_outlined;
                    } else if (title.contains('review')) {
                      icon = Icons.star_outline_rounded;
                    }

                    return ActivityCard(
                      icon: icon,
                      title: item['title'],
                      subtitle: item['message'],
                      timestamp: timeAgo(item['created_at']),
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 22),

            // ══════════════════════════════════════════════
            // RENTAL MANAGEMENT — removed (present in Home & Explore)
            // ══════════════════════════════════════════════
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TENANT PAYMENTS
// ============================================================

class TenantPaymentsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const TenantPaymentsPage({super.key, required this.user});

  String money(dynamic value) {
    final number = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0;
    return '₱${number.toStringAsFixed(2)}';
  }

  DateTime? parseDate(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '');

  String formatDate(dynamic value) {
    final date = parseDate(value);
    if (date == null) return value?.toString() ?? 'No date';
    return '${date.month}/${date.day}/${date.year}';
  }

  String displayStatus(Map<String, dynamic> payment) {
    final savedStatus = (payment['status'] ?? 'Pending').toString();
    final lower = savedStatus.toLowerCase();
    if (lower == 'paid') return 'PAID';

    final due = parseDate(payment['due_date']);
    if (due != null && due.isBefore(DateTime.now())) {
      return 'OVERDUE';
    }
    return savedStatus.toUpperCase();
  }

  bool isOutstanding(Map<String, dynamic> payment) {
    final status = displayStatus(payment).toLowerCase();
    return status == 'pending' || status == 'overdue';
  }

  Future<void> sendReminder(
    BuildContext context,
    Map<String, dynamic> payment,
  ) async {
    final contract =
        await DatabaseService.instance.getActiveContract(user['id'] as int);

    if (contract == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active rental contract found.')),
        );
      }
      return;
    }

    final landlord =
        await DatabaseService.instance.getUser(contract['landlord_id'] as int);
    final email = landlord?['email']?.toString();

    if (email == null || email.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Landlord email is not available.')),
        );
      }
      return;
    }

    final amount = money(payment['amount']);
    final dueDate = formatDate(payment['due_date']);
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'RENTahanan Payment Reminder',
        'body':
            'Hello, I would like to remind you about my rent payment of $amount due on $dueDate.',
      },
    );

    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to open the email application.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantId = user['id'] as int;

    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        elevation: 0,
        title: const Text(
          'My Payments',
          style: TextStyle(color: deepGreen, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: deepGreen),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.getTenantPayments(tenantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: deepGreen),
            );
          }

          final payments = snapshot.data ?? [];
          final outstanding = payments.where(isOutstanding).toList();
          final totalOutstanding = outstanding.fold<double>(
            0,
            (sum, payment) =>
                sum + ((payment['amount'] as num?)?.toDouble() ?? 0),
          );

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Outstanding Balance',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      money(totalOutstanding),
                      style: const TextStyle(
                        color: deepGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      outstanding.isEmpty
                          ? 'You have no pending payments.'
                          : '${outstanding.length} payment${outstanding.length == 1 ? '' : 's'} need your attention.',
                      style: const TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SectionTitle(
                title: 'Payment History',
                subtitle: 'Your rent payments and due dates.',
              ),
              const SizedBox(height: 12),
              if (payments.isEmpty)
                const EmptyState(
                  icon: Icons.payments_outlined,
                  text: 'No payment records yet.',
                )
              else
                ...payments.map(
                  (payment) {
                    final status = displayStatus(payment);
                    final paid = status == 'PAID';
                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: softGreen,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.payments_outlined,
                                  color: forestGreen,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      money(payment['amount']),
                                      style: const TextStyle(
                                        color: deepGreen,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      (payment['payment_type'] ?? 'Rent')
                                          .toString(),
                                      style: const TextStyle(
                                        color: muted,
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      'Due ${formatDate(payment['due_date'])}',
                                      style: const TextStyle(
                                        color: muted,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: paid ? softGreen : beige,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: paid ? forestGreen : deepGreen,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// TENANT VIEWING REQUESTS
// ============================================================

class TenantViewingRequestsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const TenantViewingRequestsPage({super.key, required this.user});

  String formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return value?.toString() ?? '';
    return '${date.month}/${date.day}/${date.year}';
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return forestGreen;
      case 'declined':
        return Colors.red.shade700;
      default:
        return deepGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tenantId = user['id'] as int;

    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        elevation: 0,
        title: const Text(
          'Viewing Requests',
          style: TextStyle(color: deepGreen, fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: deepGreen),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.getTenantViewingRequests(tenantId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: deepGreen),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const EmptyState(
              icon: Icons.calendar_month_outlined,
              text: 'No viewing requests yet.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
            children: [
              const SectionTitle(
                title: 'My Viewing Requests',
                subtitle: 'Track the schedules you requested for rooms.',
              ),
              const SizedBox(height: 12),
              ...requests.map(
                (request) {
                  final status = (request['status'] ?? 'Pending').toString();
                  final room = (request['room_name'] ?? 'Room').toString();
                  final date = formatDate(request['requested_date']);
                  final time = (request['requested_time'] ?? '').toString();
                  final message = (request['message'] ?? '').toString();

                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: softGreen,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: forestGreen,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    room,
                                    style: const TextStyle(
                                      color: deepGreen,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '$date • $time',
                                    style: const TextStyle(
                                      color: muted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: softGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor(status),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (message.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            message,
                            style: const TextStyle(
                              color: darkText,
                              fontSize: 10,
                              height: 1.45,
                            ),
                          ),
                        ],
                        if (status.toLowerCase() == 'approved') ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: softGreen,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: forestGreen,
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Your landlord approved this viewing schedule.',
                                    style: TextStyle(
                                      color: deepGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// TENANT REPORT / CONCERN
// ============================================================

class TenantReportPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const TenantReportPage({super.key, required this.user});

  @override
  State<TenantReportPage> createState() => _TenantReportPageState();
}

class _TenantReportPageState extends State<TenantReportPage> {
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  String category = 'Maintenance';
  bool sending = false;

  Future<void> submit() async {
    if (subjectController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please complete the subject and description.')));
      return;
    }

    setState(() => sending = true);
    try {
      final contract =
          await DatabaseService.instance.getActiveContract(widget.user['id']);
      if (contract == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Your landlord must confirm your rental before you can report a room-related concern.')),
          );
        }
        return;
      }
      await DatabaseService.instance.createReport(
        tenantId: widget.user['id'],
        landlordId: contract['landlord_id'],
        roomId: contract['room_id'],
        category: category,
        subject: subjectController.text.trim(),
        description: descriptionController.text.trim(),
      );
      if (!mounted) return;
      subjectController.clear();
      descriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report sent to your landlord.')));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to send the report. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  void dispose() {
    subjectController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text('Report a Concern',
            style: TextStyle(color: deepGreen, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: deepGreen),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Send a report to your landlord',
                    style: TextStyle(
                        color: deepGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                    'Use this for rental concerns such as water, electricity, maintenance, noise or other problems.',
                    style: TextStyle(color: muted, fontSize: 10, height: 1.5)),
                const SizedBox(height: 20),
                const FieldLabel(text: 'Concern Category'),
                const SizedBox(height: 7),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: lightBeige,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: borderColor))),
                  items: const [
                    DropdownMenuItem(
                        value: 'Water', child: Text('Water Problem')),
                    DropdownMenuItem(
                        value: 'Electricity',
                        child: Text('Electricity Problem')),
                    DropdownMenuItem(
                        value: 'Maintenance', child: Text('Maintenance')),
                    DropdownMenuItem(
                        value: 'Noise', child: Text('Noise / Surroundings')),
                    DropdownMenuItem(
                        value: 'Other', child: Text('Other Concern')),
                  ],
                  onChanged: (value) =>
                      setState(() => category = value ?? category),
                ),
                const SizedBox(height: 15),
                const FieldLabel(text: 'Subject'),
                const SizedBox(height: 7),
                AppTextField(
                    controller: subjectController,
                    hintText: 'Example: No water since this morning',
                    icon: Icons.subject_rounded),
                const SizedBox(height: 15),
                const FieldLabel(text: 'Description'),
                const SizedBox(height: 7),
                TextField(
                  controller: descriptionController,
                  maxLines: 5,
                  style: const TextStyle(color: darkText, fontSize: 11),
                  decoration: InputDecoration(
                      hintText: 'Explain the concern...',
                      filled: true,
                      fillColor: lightBeige,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: borderColor))),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                    text: sending ? 'Sending...' : 'Send Report',
                    icon: Icons.send_rounded,
                    onPressed: sending ? () {} : submit),
              ],
            ),
          ),
          const SectionTitle(
              title: 'My Reports',
              subtitle: 'Track the status of concerns you submitted.'),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future:
                DatabaseService.instance.getTenantReports(widget.user['id']),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const EmptyState(
                    icon: Icons.assignment_outlined,
                    text: 'No submitted reports yet.');
              }
              return Column(
                  children: snapshot.data!
                      .map((report) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ActivityCard(
                                    icon: Icons.report_problem_outlined,
                                    title: report['subject'],
                                    subtitle:
                                        '${report['category']} • ${report['description']}',
                                    status: report['status']),
                                if ((report['landlord_reply'] ?? '')
                                    .toString()
                                    .trim()
                                    .isNotEmpty)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(
                                        left: 14, right: 14, top: 4),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: softGreen,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                        'Landlord reply: ${report['landlord_reply']}',
                                        style: const TextStyle(
                                            color: darkText,
                                            fontSize: 11,
                                            height: 1.4)),
                                  ),
                              ],
                            ),
                          ))
                      .toList());
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TENANT LANDLORD CHAT
// ============================================================

class TenantLandlordChatPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const TenantLandlordChatPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text('Message Landlord',
            style: TextStyle(color: deepGreen, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: deepGreen),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: DatabaseService.instance
            .getLatestLandlordContractForTenant(user['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: deepGreen));
          }
          final contract = snapshot.data;
          if (contract == null) {
            return const EmptyState(
                icon: Icons.chat_bubble_outline_rounded,
                text:
                    'No previous landlord conversation is available yet. Browse rooms to message a new landlord.');
          }

          return FutureBuilder<Map<String, dynamic>?>(
            future: DatabaseService.instance.getUser(contract['landlord_id']),
            builder: (context, landlordSnapshot) {
              if (!landlordSnapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: deepGreen));
              }
              final landlord = landlordSnapshot.data;
              if (landlord == null) {
                return const EmptyState(
                    icon: Icons.person_off_outlined,
                    text: 'Landlord account not found.');
              }
              return ChatPage(
                user: user,
                otherUser: landlord,
                conversationTitle: 'Name of the landlord',
                conversationSubtitle:
                    landlord['contact_number']?.toString().isNotEmpty == true
                        ? landlord['contact_number'].toString()
                        : 'Phone number unavailable',
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// TENANT CONTRACT
// ============================================================

class TenantContractPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const TenantContractPage({super.key, required this.user});

  String dateText(dynamic value) {
    if (value == null) return 'Ongoing';
    final d = DateTime.tryParse(value.toString());
    if (d == null) return value.toString();
    return '${d.month}/${d.day}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text('My Contract',
            style: TextStyle(color: deepGreen, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: deepGreen),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: DatabaseService.instance
            .getActiveContractDetails(user['id'] as int),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: deepGreen));
          }
          final contract = snapshot.data;
          if (contract != null) {
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Active Rental Contract',
                          style: TextStyle(
                              color: deepGreen,
                              fontSize: 19,
                              fontWeight: FontWeight.w800)),
                      if ((contract['contract_image'] ?? '')
                          .toString()
                          .isNotEmpty) ...[
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _showStoredImageZoom(
                            context,
                            contract['contract_image'],
                            Icons.description_outlined,
                          ),
                          child: StoredImage(
                            data: contract['contract_image'],
                            width: double.infinity,
                            height: 220,
                            radius: 14,
                            fallbackIcon: Icons.description_outlined,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            'Tap the contract image to zoom.',
                            style: TextStyle(color: muted, fontSize: 10),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      InfoRow(
                        label: 'Property',
                        value: contract['room_name']?.toString() ?? 'Unit',
                      ),
                      InfoRow(
                        label: 'Location',
                        value: contract['room_location']?.toString() ?? '',
                      ),
                      InfoRow(
                        label: 'Floor',
                        value: contract['room_floor']?.toString() ?? '—',
                      ),
                      InfoRow(
                        label: 'Bedrooms / Bathrooms',
                        value:
                            '${contract['room_bedrooms'] ?? '—'} / ${contract['room_bathrooms'] ?? '—'}',
                      ),
                      InfoRow(
                          label: 'Monthly Rent',
                          value:
                              '₱${(contract['monthly_rent'] as num).toStringAsFixed(2)}'),
                      InfoRow(
                          label: 'Start Date',
                          value: dateText(contract['start_date'])),
                      InfoRow(
                          label: 'End Date',
                          value: contract['contract_end_date'] == null
                              ? 'Ongoing / Not set'
                              : dateText(contract['contract_end_date'])),
                      if (((contract['duration_months'] as num?)?.toInt() ??
                              0) >
                          0) ...[
                        InfoRow(
                          label: 'Rent Duration',
                          value:
                              '${(contract['duration_months'] as num).toInt()} months',
                        ),
                        InfoRow(
                          label: 'Payment Terms',
                          value: contract['payment_terms']?.toString() ??
                              'Monthly',
                        ),
                        InfoRow(
                          label: 'Security Deposit',
                          value:
                              '₱${(contract['security_deposit'] as num).toStringAsFixed(2)}',
                        ),
                        InfoRow(
                          label: 'Advance Rent',
                          value:
                              '₱${(contract['advance_amount'] as num).toStringAsFixed(2)}',
                        ),
                        InfoRow(
                          label: 'Total Contract Rent',
                          value:
                              '₱${(contract['total_contract_amount'] as num).toStringAsFixed(2)}',
                        ),
                      ],
                      InfoRow(label: 'Status', value: contract['status']),
                    ],
                  ),
                ),
                const AppCard(
                    child: Text(
                        'Your landlord manages contract termination. After your contract ends, you can leave a review for your rental experience.',
                        style: TextStyle(
                            color: muted, fontSize: 10, height: 1.5))),
              ],
            );
          }

          return FutureBuilder<Map<String, dynamic>?>(
            future: DatabaseService.instance
                .getLatestTerminatedContract(user['id']),
            builder: (context, terminatedSnapshot) {
              final terminated = terminatedSnapshot.data;
              if (terminated == null) {
                return const EmptyState(
                    icon: Icons.description_outlined,
                    text: 'You do not have an active contract.');
              }
              return ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Previous Contract',
                            style: TextStyle(
                                color: deepGreen,
                                fontSize: 19,
                                fontWeight: FontWeight.w800)),
                        if ((terminated['contract_image'] ?? '')
                            .toString()
                            .isNotEmpty) ...[
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => _showStoredImageZoom(
                              context,
                              terminated['contract_image'],
                              Icons.description_outlined,
                            ),
                            child: StoredImage(
                              data: terminated['contract_image'],
                              width: double.infinity,
                              height: 220,
                              radius: 14,
                              fallbackIcon: Icons.description_outlined,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              'Tap the contract image to zoom.',
                              style: TextStyle(color: muted, fontSize: 10),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        InfoRow(
                            label: 'Monthly Rent',
                            value:
                                '₱${(terminated['monthly_rent'] as num).toStringAsFixed(2)}'),
                        InfoRow(
                            label: 'Start Date',
                            value: dateText(terminated['start_date'])),
                        InfoRow(
                            label: 'End Date',
                            value: dateText(terminated['end_date'])),
                        InfoRow(label: 'Status', value: terminated['status']),
                        const SizedBox(height: 18),
                        PrimaryButton(
                          text: 'Leave a Review',
                          icon: Icons.star_outline_rounded,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ReviewPage(
                                        user: user, contract: terminated)));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: muted, fontSize: 11))),
          Text(value,
              style: const TextStyle(
                  color: darkText, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ============================================================
// REVIEW
// ============================================================

class ReviewPage extends StatefulWidget {
  final Map<String, dynamic> user;
  final Map<String, dynamic> contract;

  const ReviewPage({super.key, required this.user, required this.contract});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int rating = 5;
  final commentController = TextEditingController();
  final suggestionsController = TextEditingController();
  bool saving = false;

  Future<void> submit() async {
    if (commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please write a review.')));
      return;
    }
    setState(() => saving = true);
    final exists = await DatabaseService.instance.hasReviewForContractRoom(
        tenantId: widget.user['id'], roomId: widget.contract['room_id']);
    if (exists) {
      if (mounted) {
        setState(() => saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You already reviewed this rental.')));
      }
      return;
    }
    await DatabaseService.instance.addReview(
      tenantId: widget.user['id'],
      landlordId: widget.contract['landlord_id'],
      roomId: widget.contract['room_id'],
      rating: rating,
      comment: commentController.text.trim(),
      suggestions: suggestionsController.text.trim(),
    );
    if (!mounted) return;
    setState(() => saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your review!')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    commentController.dispose();
    suggestionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text('Leave a Review',
            style: TextStyle(color: deepGreen, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: deepGreen),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('How was your rental experience?',
                    style: TextStyle(
                        color: deepGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 18),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        5,
                        (index) => IconButton(
                              onPressed: () =>
                                  setState(() => rating = index + 1),
                              icon: Icon(
                                  index < rating
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: forestGreen,
                                  size: 34),
                            )),
                  ),
                ),
                Center(
                    child: Text('$rating out of 5',
                        style: const TextStyle(color: muted, fontSize: 11))),
                const SizedBox(height: 18),
                const FieldLabel(text: 'Your Review'),
                const SizedBox(height: 7),
                TextField(
                  controller: commentController,
                  maxLines: 6,
                  style: const TextStyle(color: darkText, fontSize: 11),
                  decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      filled: true,
                      fillColor: lightBeige,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: borderColor))),
                ),
                const SizedBox(height: 16),
                const FieldLabel(text: 'Suggestions (optional)'),
                const SizedBox(height: 7),
                TextField(
                  controller: suggestionsController,
                  maxLines: 4,
                  style: const TextStyle(color: darkText, fontSize: 11),
                  decoration: InputDecoration(
                    hintText: 'How could the apartment or service improve?',
                    filled: true,
                    fillColor: lightBeige,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: borderColor),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                    text: saving ? 'Submitting...' : 'Submit Review',
                    icon: Icons.star_rounded,
                    onPressed: saving ? () {} : submit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LANDLORD HOME
// ============================================================

class LandlordHomePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const LandlordHomePage({
    super.key,
    required this.user,
  });

  @override
  State<LandlordHomePage> createState() => _LandlordHomePageState();
}

class _LandlordHomePageState extends State<LandlordHomePage> {
  Future<void> addRoom() => _showRoomForm();

  Future<void> editRoom(Map<String, dynamic> room) => _showRoomForm(room: room);

  Future<void> _openRoomDetails(Map<String, dynamic> room) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => LandlordPropertyDetailsPage(
          roomId: room['id'] as int,
          landlordId: widget.user['id'] as int,
          onEdit: editRoom,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _showRoomForm({Map<String, dynamic>? room}) async {
    // Load this landlord's saved apartment details for smart defaults
    final apt = await DatabaseService.instance
        .getLandlordApartment(widget.user['id'] as int);
    final defaultLocation =
        (apt?['location'] as String?)?.trim().isNotEmpty == true
            ? apt!['location'] as String
            : 'Hagonoy, Taguig City';
    final totalFloors = (apt?['total_floors'] as int?) ?? 5;
    final baseRent = (apt?['monthly_rent'] as num?)?.toDouble() ?? 0;

    final nameController =
        TextEditingController(text: room?['name']?.toString() ?? '');
    final locationController = TextEditingController(
      text: room?['location']?.toString() ?? defaultLocation,
    );
    final floorController =
        TextEditingController(text: room?['floor']?.toString() ?? '1');
    final bedroomsController =
        TextEditingController(text: room?['bedrooms']?.toString() ?? '1');
    final bathroomsController =
        TextEditingController(text: room?['bathrooms']?.toString() ?? '1');
    final descriptionController = TextEditingController(
      text: room?['description']?.toString() ?? '',
    );
    final priceController = TextEditingController(
      text: room?['price'] != null
          ? (room!['price'] as num).toStringAsFixed(2)
          : baseRent > 0
              ? baseRent.toStringAsFixed(2)
              : '',
    );
    final roomImages = storedImageData(room?['image']);

    Future<void> pickRoomImages(
      BuildContext dialogContext,
      StateSetter updateDialog,
    ) async {
      if (roomImages.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can add up to 5 room photos.')),
        );
        return;
      }

      try {
        final pickedImages = await ImagePicker().pickMultiImage(
          imageQuality: 75,
          maxWidth: 1280,
          maxHeight: 1280,
          limit: 5 - roomImages.length,
        );
        if (pickedImages.isEmpty) return;

        final savedImages = <String>[];
        for (final image in pickedImages) {
          savedImages.add(await DatabaseService.instance.storeRoomImage(
            landlordId: widget.user['id'] as int,
            sourcePath: image.path,
          ));
        }

        if (!dialogContext.mounted) return;
        updateDialog(() => roomImages.addAll(savedImages));
      } on PlatformException catch (error) {
        debugPrint('ROOM IMAGE PICKER ERROR (${error.code}): ${error.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Photo picker error (${error.code}): ${error.message}'),
            ),
          );
        }
      } catch (error) {
        debugPrint('ROOM IMAGE PICKER ERROR: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Unable to read the selected photos: $error')),
          );
        }
      }
    }

    final saved = await showDialog<bool>(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text(
            'Add or Edit Room',
            style: TextStyle(color: deepGreen),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Room Name'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: floorController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Floor (1–$totalFloors)',
                  ),
                ),
                TextField(
                  controller: priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Monthly Rent (₱)'),
                ),
                TextField(
                  controller: bedroomsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Bedrooms'),
                ),
                TextField(
                  controller: bathroomsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Bathrooms'),
                ),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText:
                        'Description and accommodations (e.g. Wi-Fi, own bathroom, water, electricity)',
                  ),
                ),
                const SizedBox(height: 12),
                if (roomImages.isNotEmpty) ...[
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: roomImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) => Stack(
                        children: [
                          StoredImage(
                            data: roomImages[index],
                            width: 112,
                            height: 88,
                            radius: 10,
                            fallbackIcon: Icons.meeting_room_outlined,
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: IconButton(
                              onPressed: () => setDialogState(
                                  () => roomImages.removeAt(index)),
                              tooltip: 'Remove photo',
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              iconSize: 22,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton.icon(
                  onPressed: () =>
                      pickRoomImages(dialogContext, setDialogState),
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(
                    'Add photos (${roomImages.length}/5)',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final cleanedPrice =
                    priceController.text.replaceAll(RegExp(r'[₱,\s]'), '');
                final parsedPrice = double.tryParse(cleanedPrice);

                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a property name.')),
                  );
                  return;
                }

                if (parsedPrice == null || parsedPrice <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Enter a valid monthly rent greater than ₱0.'),
                    ),
                  );
                  return;
                }

                try {
                  final name = nameController.text.trim();
                  final floor = int.tryParse(floorController.text) ?? 1;
                  final location = locationController.text.trim().isEmpty
                      ? defaultLocation
                      : locationController.text.trim();
                  final description = descriptionController.text.trim();
                  final bedrooms = int.tryParse(bedroomsController.text) ?? 1;
                  final bathrooms = int.tryParse(bathroomsController.text) ?? 1;
                  final image = jsonEncode(roomImages);
                  if (room == null) {
                    await DatabaseService.instance.addRoom(
                      landlordId: widget.user['id'] as int,
                      name: name,
                      floor: floor,
                      location: location,
                      description: description,
                      price: parsedPrice,
                      bedrooms: bedrooms,
                      bathrooms: bathrooms,
                      image: image,
                    );
                  } else {
                    await DatabaseService.instance.updateRoom(
                      roomId: room['id'] as int,
                      landlordId: widget.user['id'] as int,
                      name: name,
                      floor: floor,
                      location: location,
                      description: description,
                      price: parsedPrice,
                      bedrooms: bedrooms,
                      bathrooms: bathrooms,
                      image: image,
                    );
                  }
                } catch (error) {
                  debugPrint('ADD ROOM ERROR: $error');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unable to save the room.')),
                    );
                  }
                  return;
                }

                if (!mounted || !dialogContext.mounted) return;
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: deepGreen),
              child: Text(
                room == null ? 'Add' : 'Save changes',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) setState(() {});
  }

  Future<void> _confirmDeleteRoom(Map<String, dynamic> room) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove property?'),
        content: Text(
            'Are you sure you want to remove "${room['name']}"? Tenants will no longer see this property in Explore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    await DatabaseService.instance.deleteRoom(
      roomId: room['id'] as int,
      landlordId: widget.user['id'] as int,
    );
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Property removed successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Landlord Dashboard',
      subtitle: 'Manage your rental property with ease.',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.add_home_work_rounded,
            color: deepGreen,
          ),
          onPressed: addRoom,
        ),
      ],
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.getLandlordRooms(widget.user['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: deepGreen,
              ),
            );
          }

          final rooms = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              DashboardAnnouncements(user: widget.user),
              const SizedBox(height: 12),
              const SectionTitle(
                title: 'My Properties',
                subtitle: 'Tap a listing to edit room details and photos.',
              ),
              const SizedBox(height: 12),
              ...rooms.map(
                (room) => LandlordRoomCard(
                  room: room,
                  onTap: () => _openRoomDetails(room),
                  onDelete: () => _confirmDeleteRoom(room),
                ),
              ),
              const SizedBox(height: 20),
              LandlordSalesDashboard(user: widget.user),
              const SizedBox(height: 12),
              LandlordFeedbackSection(
                landlordId: widget.user['id'] as int,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// LANDLORD EXPLORE
// ============================================================

class ViewingAvailabilityPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ViewingAvailabilityPage({super.key, required this.user});

  @override
  State<ViewingAvailabilityPage> createState() =>
      _ViewingAvailabilityPageState();
}

class _ViewingAvailabilityPageState extends State<ViewingAvailabilityPage> {
  static const _weekdays = <int, String>{
    DateTime.monday: 'Every Monday',
    DateTime.tuesday: 'Every Tuesday',
    DateTime.wednesday: 'Every Wednesday',
    DateTime.thursday: 'Every Thursday',
    DateTime.friday: 'Every Friday',
    DateTime.saturday: 'Every Saturday',
    DateTime.sunday: 'Every Sunday',
  };

  late Future<List<Map<String, dynamic>>> _rules;
  int _weekday = DateTime.sunday;
  bool _saving = false;

  int get _landlordId => widget.user['id'] as int;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  void _loadRules() {
    _rules = DatabaseService.instance.getViewingBlackouts(_landlordId);
  }

  String _monthLabel(String value) {
    final parts = value.split('-');
    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    return '${_monthNames[date.month - 1]} ${date.year}';
  }

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _ruleLabel(Map<String, dynamic> rule) {
    final type = rule['rule_type'].toString();
    final value = rule['rule_value'].toString();
    if (type == 'weekday') {
      return _weekdays[int.parse(value)] ?? 'Weekday';
    }
    if (type == 'month') return 'All of ${_monthLabel(value)}';
    if (type == 'time') {
      return 'Every day at $value';
    }
    final date = DateTime.parse(value);
    return 'Date unavailable: ${date.month}/${date.day}/${date.year}';
  }

  Future<void> _addRule(String type, String value) async {
    setState(() => _saving = true);
    try {
      await DatabaseService.instance.addViewingBlackout(
        landlordId: _landlordId,
        ruleType: type,
        ruleValue: value,
      );
      if (mounted) setState(_loadRules);
    } catch (error) {
      debugPrint('ADD VIEWING BLACKOUT ERROR: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to save that unavailable time.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10, 12, 31),
      helpText: 'Choose a month to block',
    );
    if (picked == null) return;
    await _addRule(
      'month',
      '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}',
    );
  }

  Future<void> _addDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 10, 12, 31),
      helpText: 'Choose an unavailable date',
    );
    if (picked == null) return;
    await _addRule(
      'date',
      '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}',
    );
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked == null) return;
    await _addRule('time', _viewingTimeKey(picked));
  }

  Future<void> _removeRule(Map<String, dynamic> rule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove unavailable time?'),
        content: Text('Allow guests to book ${_ruleLabel(rule)} again?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await DatabaseService.instance.removeViewingBlackout(
        landlordId: _landlordId,
        blackoutId: rule['id'] as int,
      );
      if (mounted) setState(_loadRules);
    } catch (error) {
      debugPrint('REMOVE VIEWING BLACKOUT ERROR: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to remove the unavailable time.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text('Viewing Availability'),
        iconTheme: const IconThemeData(color: deepGreen),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const AppCard(
            child: Text(
              'Choose the weekdays, dates, times, or entire months when you cannot host viewings. A blocked time applies every day. Viewing hours are 8:00 AM to 6:00 PM.',
              style: TextStyle(color: darkText, height: 1.5),
            ),
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Block a recurring weekday',
                  style: TextStyle(
                    color: deepGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _weekday,
                  decoration: const InputDecoration(labelText: 'Weekday'),
                  items: _weekdays.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: _saving
                      ? null
                      : (value) {
                          if (value != null) setState(() => _weekday = value);
                        },
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  text: 'Confirm',
                  icon: Icons.event_busy_outlined,
                  onPressed: _saving
                      ? () {}
                      : () => _addRule('weekday', _weekday.toString()),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _addDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: const Text('Block a specific date'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _addMonth,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text('Block an entire month'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _addTime,
                  icon: const Icon(Icons.schedule_outlined),
                  label: const Text('Block a viewing time'),
                ),
              ],
            ),
          ),
          const SectionTitle(
            title: 'Unavailable dates',
            subtitle: 'Remove a rule to allow viewings on that schedule.',
          ),
          const SizedBox(height: 10),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _rules,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const AppCard(
                  child: Text(
                    'Unable to load viewing availability.',
                    style: TextStyle(color: muted),
                  ),
                );
              }
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: deepGreen),
                );
              }
              final rules = snapshot.data!;
              if (rules.isEmpty) {
                return const AppCard(
                  child: Text(
                    'No dates are blocked. Guests can request any date during viewing hours.',
                    style: TextStyle(color: muted),
                  ),
                );
              }
              return Column(
                children: rules
                    .map(
                      (rule) => AppCard(
                        padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.event_busy_outlined,
                            color: forestGreen,
                          ),
                          title: Text(
                            _ruleLabel(rule),
                            style: const TextStyle(
                              color: darkText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove unavailable time',
                            onPressed: () => _removeRule(rule),
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LandlordExplorePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const LandlordExplorePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Explore',
      subtitle: 'Manage your rooms and rental records.',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          FeatureTile(
            icon: Icons.groups_2_outlined,
            title: 'Active Tenants',
            description:
                'View tenant profiles, assigned units, rent, contracts and payment history.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LandlordTenantsPage(user: user),
              ),
            ),
          ),
          FeatureTile(
            icon: Icons.calendar_month_rounded,
            title: 'Viewing Requests',
            description:
                'Review tenant viewings and manage guest viewing approvals.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LandlordViewingRequestsPage(
                    user: user,
                  ),
                ),
              );
            },
          ),
          FeatureTile(
            icon: Icons.event_busy_outlined,
            title: 'Viewing Availability',
            description:
                'Block weekdays, dates, months, or daily viewing times for guest and tenant requests.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewingAvailabilityPage(user: user),
              ),
            ),
          ),
          FeatureTile(
            icon: Icons.payments_outlined,
            title: 'Payments',
            description: 'View rent payments and send reminders.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LandlordPaymentsPage(
                    user: user,
                  ),
                ),
              );
            },
          ),
          FeatureTile(
            icon: Icons.insert_chart_outlined_rounded,
            title: 'Sales Report',
            description: 'View monthly sales and annual net collections.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SalesReportPage(user: user),
              ),
            ),
          ),
          FeatureTile(
            icon: Icons.campaign_outlined,
            title: 'Announcements',
            description: 'Post updates for your active tenants.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AnnouncementsPage(user: user),
              ),
            ),
          ),
          FeatureTile(
            icon: Icons.message_outlined,
            title: 'Messages',
            description:
                'Reply to tenants and guests, review viewing requests, and find unread conversations.',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LandlordMessagesPage(user: user),
              ),
            ),
          ),
          FeatureTile(
            icon: Icons.report_problem_outlined,
            title: 'Tenant Reports',
            description: 'Review tenant concerns and update their status.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LandlordReportsPage(user: user),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class LandlordMessagesPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const LandlordMessagesPage({super.key, required this.user});

  @override
  State<LandlordMessagesPage> createState() => _LandlordMessagesPageState();
}

class _LandlordMessagesPageState extends State<LandlordMessagesPage> {
  static const _filters = [
    'All',
    'Unread',
    'Current tenants',
    'Viewing guests'
  ];
  String _filter = 'All';

  Future<void> _openThread(Map<String, dynamic> thread) async {
    final isGuest = thread['participant_type'] == 'guest';
    if (isGuest) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            user: widget.user,
            otherUser: {
              'id': thread['participant_id'],
              'name': thread['participant_name'],
            },
            guestId: (thread['participant_id'] as num).toInt(),
            landlordId: widget.user['id'] as int,
            roomId: (thread['room_id'] as num).toInt(),
            guestViewerIsLandlord: true,
            conversationTitle:
                '${thread['participant_name']} | ${thread['room_name']} Guest',
          ),
        ),
      );
    } else {
      final tenant = await DatabaseService.instance
          .getUser((thread['participant_id'] as num).toInt());
      if (!mounted) return;
      if (tenant == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tenant account could not be found.')),
        );
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            user: widget.user,
            otherUser: tenant,
            roomId: thread['room_id'] == null
                ? null
                : (thread['room_id'] as num).toInt(),
            conversationTitle:
                '${thread['participant_name']} | ${thread['room_name'] ?? 'Tenant'} Tenant',
          ),
        ),
      );
    }
    if (mounted) setState(() {});
  }

  List<Map<String, dynamic>> _filteredThreads(
    List<Map<String, dynamic>> threads,
  ) {
    switch (_filter) {
      case 'Unread':
        return threads
            .where((thread) => (thread['unread_count'] as num? ?? 0) > 0)
            .toList();
      case 'Current tenants':
        return threads
            .where((thread) =>
                thread['participant_type'] == 'tenant' &&
                (thread['is_current'] as num? ?? 0) == 1)
            .toList();
      case 'Viewing guests':
        return threads
            .where((thread) => thread['participant_type'] == 'guest')
            .toList();
      default:
        return threads;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: beige,
        appBar: AppBar(
          backgroundColor: beige,
          title: const Text(
            'Messages',
            style: TextStyle(color: deepGreen, fontWeight: FontWeight.w800),
          ),
          iconTheme: const IconThemeData(color: deepGreen),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseService.instance.getLandlordMessageThreads(
            widget.user['id'] as int,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const EmptyState(
                icon: Icons.error_outline,
                text: 'Unable to load messages. Please try again later.',
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: deepGreen),
              );
            }
            final threads = _filteredThreads(snapshot.data!);
            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                  child: Row(
                    children: _filters
                        .map(
                          (filter) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: _filter == filter,
                              onSelected: (_) =>
                                  setState(() => _filter = filter),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Expanded(
                  child: threads.isEmpty
                      ? const EmptyState(
                          icon: Icons.chat_bubble_outline,
                          text: 'No conversations match this filter.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          itemCount: threads.length,
                          itemBuilder: (context, index) {
                            final thread = threads[index];
                            final isGuest =
                                thread['participant_type'] == 'guest';
                            final unread =
                                (thread['unread_count'] as num? ?? 0).toInt();
                            final room = thread['room_name']?.toString();
                            return AppCard(
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: softGreen,
                                  child: Icon(
                                    isGuest
                                        ? Icons.event_available_outlined
                                        : Icons.person_outline,
                                    color: deepGreen,
                                  ),
                                ),
                                title: Text(
                                  '${thread['participant_name']} | ${room ?? (isGuest ? 'Viewing' : 'Tenant')} ${isGuest ? 'Guest' : 'Tenant'}',
                                  style: const TextStyle(
                                    color: deepGreen,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      thread['last_message']?.toString() ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (isGuest)
                                      Text(
                                        'Viewing: ${thread['viewing_date']} • ${thread['viewing_time']} (${thread['viewing_status']})',
                                        style: const TextStyle(
                                            color: muted, fontSize: 12),
                                      ),
                                    Text(
                                      timeAgo(thread['last_at']),
                                      style: const TextStyle(
                                          color: muted, fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: unread > 0
                                    ? CircleAvatar(
                                        radius: 13,
                                        backgroundColor: deepGreen,
                                        child: Text(
                                          '$unread',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11),
                                        ),
                                      )
                                    : const Icon(Icons.chevron_right),
                                onTap: () => _openThread(thread),
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

class LandlordTenantsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const LandlordTenantsPage({super.key, required this.user});

  @override
  State<LandlordTenantsPage> createState() => _LandlordTenantsPageState();
}

class _LandlordTenantsPageState extends State<LandlordTenantsPage> {
  Future<void> _terminateContract(Map<String, dynamic> tenant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Terminate Contract?'),
        content: Text(
          'Terminate ${tenant['name']}\'s contract for ${tenant['room_name']}? The room will become available again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: deepGreen),
            child: const Text(
              'Terminate',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final changed = await DatabaseService.instance.terminateContract(
      contractId: tenant['contract_id'] as int,
      landlordId: widget.user['id'] as int,
    );
    if (!mounted) return;
    if (changed == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('This contract is no longer active. Refresh and try again.'),
        ),
      );
      setState(() {});
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contract terminated successfully.')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: beige,
        appBar: AppBar(
          backgroundColor: beige,
          title: const Text('Active Tenants'),
          iconTheme: const IconThemeData(color: deepGreen),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseService.instance
              .getLandlordActiveTenants(widget.user['id'] as int),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const EmptyState(
                icon: Icons.error_outline,
                text: 'Unable to load active tenants.',
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: deepGreen),
              );
            }
            final tenants = snapshot.data!;
            if (tenants.isEmpty) {
              return const EmptyState(
                icon: Icons.groups_2_outlined,
                text: 'No active tenants yet.',
              );
            }
            return ListView(
              padding: const EdgeInsets.all(18),
              children: tenants
                  .map(
                    (tenant) => AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: softGreen,
                          child: Icon(Icons.person, color: deepGreen),
                        ),
                        title: Text(
                          tenant['name'].toString(),
                          style: const TextStyle(
                            color: deepGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        subtitle: Text(
                          '${tenant['room_name']} • ₱${tenant['monthly_rent']}/month\n${tenant['email']}',
                        ),
                        isThreeLine: true,
                        trailing: Wrap(
                          spacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            IconButton(
                              tooltip: 'Terminate contract',
                              icon: const Icon(
                                Icons.cancel_outlined,
                                color: Colors.red,
                              ),
                              onPressed: () => _terminateContract(tenant),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LandlordTenantProfilePage(
                              tenant: tenant,
                              landlordId: widget.user['id'] as int,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      );
}

class LandlordTenantProfilePage extends StatelessWidget {
  final Map<String, dynamic> tenant;
  final int landlordId;

  const LandlordTenantProfilePage({
    super.key,
    required this.tenant,
    required this.landlordId,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: beige,
        appBar: AppBar(
          backgroundColor: beige,
          title: const Text('Tenant Profile'),
          iconTheme: const IconThemeData(color: deepGreen),
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tenant['name'].toString(),
                      style: const TextStyle(
                          color: deepGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(
                      'Tenant ID: ${tenant['tenant_code'] ?? tenant['tenant_id']}'),
                  Text('Email: ${tenant['email']}'),
                  Text(
                      'Contact: ${tenant['contact_number'] ?? 'Not provided'}'),
                  Text(
                      'Unit: ${tenant['room_name']} • Floor ${tenant['floor']}'),
                  if ((tenant['location'] ?? '').toString().isNotEmpty)
                    Text('Location: ${tenant['location']}'),
                  Text(
                      'Property: ${tenant['bedrooms']} bedroom(s) • ${tenant['bathrooms']} bathroom(s)'),
                  Text('Monthly rent: ₱${tenant['monthly_rent']}'),
                  Text('Contract start: ${tenant['start_date']}'),
                  Text(
                      'Contract end: ${tenant['contract_end_date'] ?? 'Ongoing'}'),
                  if ((tenant['duration_months'] as num?)?.toInt() != null &&
                      (tenant['duration_months'] as num).toInt() > 0) ...[
                    Text(
                        'Rent duration: ${(tenant['duration_months'] as num).toInt()} months'),
                    Text(
                        'Payment terms: ${tenant['payment_terms'] ?? 'Monthly'}'),
                    Text(
                        'Security deposit: ₱${(tenant['security_deposit'] as num).toStringAsFixed(2)}'),
                    Text(
                        'One-month advance: ₱${(tenant['advance_amount'] as num).toStringAsFixed(2)}'),
                    Text(
                        'Total contract rent: ₱${(tenant['total_contract_amount'] as num).toStringAsFixed(2)}'),
                  ],
                ],
              ),
            ),
            const SectionTitle(
              title: 'Bills & Payments',
              subtitle: 'Rent bills recorded for this tenant.',
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseService.instance.getLandlordPayments(landlordId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: deepGreen),
                  );
                }
                final payments = snapshot.data!
                    .where((payment) =>
                        payment['tenant_id'] == tenant['tenant_id'])
                    .toList();
                if (payments.isEmpty) {
                  return const EmptyState(
                    icon: Icons.payments_outlined,
                    text: 'No bill or payment records yet.',
                  );
                }
                return Column(
                  children: payments
                      .map(
                        (payment) => AppCard(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                                '${payment['payment_type'] ?? 'Rent'} • ₱${payment['amount']}'),
                            subtitle: Text(
                                '${payment['status']} • Due ${payment['due_date']}'),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      );
}

class LandlordGuestRequestsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const LandlordGuestRequestsPage({super.key, required this.user});

  @override
  State<LandlordGuestRequestsPage> createState() =>
      _LandlordGuestRequestsPageState();
}

class _LandlordGuestRequestsPageState extends State<LandlordGuestRequestsPage> {
  bool _acceptingTenant = false;

  Future<void> _update(int requestId, String status) async {
    try {
      await DatabaseService.instance
          .updateGuestViewingStatus(requestId, status);
      if (mounted) setState(() {});
    } catch (error) {
      debugPrint('GUEST VIEWING STATUS ERROR: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update viewing request.')),
        );
      }
    }
  }

  Future<void> _acceptTenant(Map<String, dynamic> request) async {
    final durationController = TextEditingController(text: '6');
    final rentController = TextEditingController(
      text:
          ((request['room_price'] as num?)?.toDouble() ?? 0).toStringAsFixed(2),
    );
    final depositController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var dueDate = DateTime.now();
    String? contractImage;
    String dateText(DateTime date) => '${date.month}/${date.day}/${date.year}';
    double parseAmount(String text) =>
        double.tryParse(text.trim().replaceAll(',', '')) ?? 0;

    Future<void> pickContractImage(StateSetter updateDialog) async {
      try {
        final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 75,
          maxWidth: 1600,
          maxHeight: 1600,
        );
        if (picked == null) return;
        final encoded = base64Encode(await picked.readAsBytes());
        updateDialog(() => contractImage = encoded);
      } catch (error) {
        debugPrint('CONTRACT IMAGE PICKER ERROR: $error');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Unable to select the contract image.')),
          );
        }
      }
    }

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final duration = int.tryParse(durationController.text.trim()) ?? 0;
            final rent = parseAmount(rentController.text);
            final deposit = parseAmount(depositController.text);
            return AlertDialog(
              title: const Text('Set Contract and Payment Terms'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${request['room_name']} • ${request['guest_name']}',
                        style: const TextStyle(
                          color: deepGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (contractImage != null) ...[
                        StoredImage(
                          data: contractImage,
                          width: 180,
                          height: 120,
                          radius: 12,
                          fallbackIcon: Icons.description_outlined,
                        ),
                        const SizedBox(height: 8),
                      ],
                      OutlinedButton.icon(
                        onPressed: () => pickContractImage(setDialogState),
                        icon: const Icon(Icons.upload_file_outlined),
                        label: Text(contractImage == null
                            ? 'Attach contract image'
                            : 'Change contract image'),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Rent duration (months)',
                        ),
                        validator: (value) {
                          final months = int.tryParse(value?.trim() ?? '');
                          return months == null || months < 1
                              ? 'Enter at least 1 month.'
                              : null;
                        },
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      TextFormField(
                        controller: rentController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Monthly rent (₱)',
                        ),
                        validator: (value) {
                          final amount = parseAmount(value ?? '');
                          return !amount.isFinite || amount <= 0
                              ? 'Enter an amount greater than zero.'
                              : null;
                        },
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      TextFormField(
                        controller: depositController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Security deposit / downpayment (₱)',
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          return amount == null ||
                                  !amount.isFinite ||
                                  amount < 0
                              ? 'Enter zero or a positive amount.'
                              : null;
                        },
                        onChanged: (_) => setDialogState(() {}),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('First payment due date'),
                        subtitle: Text(dateText(dueDate)),
                        trailing: const Icon(
                          Icons.calendar_month,
                          color: deepGreen,
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: dueDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setDialogState(() => dueDate = picked);
                          }
                        },
                      ),
                      const Divider(),
                      const Text(
                        'Payment terms: Monthly',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text('Security deposit: ₱${deposit.toStringAsFixed(2)}'),
                      Text('One-month advance: ₱${rent.toStringAsFixed(2)}'),
                      Text(
                        'Remaining rent: ₱${((duration > 0 ? duration - 1 : 0) * rent).toStringAsFixed(2)}',
                      ),
                      Text(
                        'Total contract rent: ₱${(duration * rent).toStringAsFixed(2)} (deposit excluded)',
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Confirm as Tenant'),
                ),
              ],
            );
          },
        ),
      );
      if (confirmed != true || !mounted) return;

      setState(() => _acceptingTenant = true);
      final tenant = await DatabaseService.instance.acceptGuestAsTenant(
        requestId: request['id'] as int,
        landlordId: widget.user['id'] as int,
        durationMonths: int.parse(durationController.text.trim()),
        monthlyRent: parseAmount(rentController.text),
        securityDeposit: parseAmount(depositController.text),
        firstDueDate: dueDate,
        contractImage: contractImage,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Tenant accepted'),
          content: Text(
            '${tenant['tenant_name']} is now assigned to ${tenant['room_name']}.\n\n'
            'Location: ${tenant['room_location']}\n'
            'Floor: ${tenant['room_floor']} • ${tenant['room_bedrooms']} bedroom(s) • ${tenant['room_bathrooms']} bathroom(s)\n\n'
            'Tenant ID: ${tenant['tenant_code']}\n'
            'Monthly rent: ₱${(tenant['monthly_rent'] as num).toStringAsFixed(2)}\n'
            'Security deposit due: ₱${(tenant['security_deposit'] as num).toStringAsFixed(2)}\n'
            'One-month advance due: ₱${(tenant['advance_amount'] as num).toStringAsFixed(2)}\n'
            'Total contract rent: ₱${(tenant['total_contract_amount'] as num).toStringAsFixed(2)}\n\n'
            'These amounts are recorded as unpaid. The guest can finish tenant activation from their guest dashboard.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) setState(() {});
    } on StateError catch (error) {
      final message = error.message == 'ROOM_ALREADY_OCCUPIED'
          ? 'This room has already been assigned.'
          : 'Approve the viewing and verify the room is available first.';
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (error) {
      debugPrint('ACCEPT GUEST TENANT ERROR: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Unable to accept this guest as a tenant.')),
        );
      }
    } finally {
      durationController.dispose();
      rentController.dispose();
      depositController.dispose();
      if (mounted) setState(() => _acceptingTenant = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: beige,
        appBar: AppBar(
          backgroundColor: beige,
          title: const Text('Guest Requests'),
          iconTheme: const IconThemeData(color: deepGreen),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: DatabaseService.instance
              .getLandlordGuestViewingRequests(widget.user['id'] as int),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const EmptyState(
                icon: Icons.error_outline,
                text: 'Unable to load guest requests.',
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: deepGreen),
              );
            }
            final requests = snapshot.data!;
            if (requests.isEmpty) {
              return const EmptyState(
                icon: Icons.calendar_month_outlined,
                text: 'No guest requests yet.',
              );
            }
            return ListView(
              padding: const EdgeInsets.all(18),
              children: requests.map((request) {
                final status = request['status'].toString();
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request['guest_name'].toString(),
                          style: const TextStyle(
                              color: deepGreen,
                              fontWeight: FontWeight.w800,
                              fontSize: 17)),
                      Text(
                          'Guest ID ${request['guest_code']} • ${request['room_name']}'),
                      Text(
                          '${request['requested_date']} • ${request['requested_time']}'),
                      const SizedBox(height: 8),
                      StatusBadge(text: status),
                      if (status == 'Pending') ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () =>
                                    _update(request['id'] as int, 'Approved'),
                                child: const Text('Approve viewing'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () =>
                                    _update(request['id'] as int, 'Rejected'),
                                child: const Text('Reject'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (status == 'Approved') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _acceptingTenant
                                ? null
                                : () => _acceptTenant(request),
                            child: Text(_acceptingTenant
                                ? 'Processing...'
                                : 'Accept as Tenant'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      );
}

// ============================================================
// LANDLORD VIEWING REQUESTS
// ============================================================

class LandlordViewingRequestsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const LandlordViewingRequestsPage({
    super.key,
    required this.user,
  });

  @override
  State<LandlordViewingRequestsPage> createState() =>
      _LandlordViewingRequestsPageState();
}

class _LandlordViewingRequestsPageState
    extends State<LandlordViewingRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text(
          'Viewing Requests',
          style: TextStyle(
            color: deepGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LandlordGuestRequestsPage(user: widget.user),
              ),
            ),
            icon: const Icon(Icons.person_search_outlined),
            label: const Text('Guest approvals'),
          ),
        ],
        iconTheme: const IconThemeData(
          color: deepGreen,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.getLandlordViewingRequests(
          widget.user['id'],
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: deepGreen,
              ),
            );
          }

          final requests = snapshot.data!;

          if (requests.isEmpty) {
            return const EmptyState(
              icon: Icons.calendar_month_outlined,
              text: 'No viewing requests yet.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: requests.map((request) {
              final pending = request['status'] == 'Pending';

              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request['room_name'],
                      style: const TextStyle(
                        color: deepGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Requested by ${request['tenant_name']}',
                      style: const TextStyle(
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${request['requested_date']} • ${request['requested_time']}',
                      style: const TextStyle(
                        color: muted,
                      ),
                    ),
                    if ((request['message'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        request['message'],
                        style: const TextStyle(
                          color: darkText,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    StatusBadge(
                      text: request['status'],
                    ),
                    if (pending) ...[
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await DatabaseService.instance
                                    .updateViewingRequest(
                                  request['id'],
                                  'Approved',
                                );

                                setState(() {});
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: deepGreen,
                              ),
                              child: const Text(
                                'Approve',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                await DatabaseService.instance
                                    .updateViewingRequest(
                                  request['id'],
                                  'Rejected',
                                );

                                setState(() {});
                              },
                              child: const Text('Reject'),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (request['status'] == 'Approved') ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.verified_user_rounded),
                          label: const Text('Confirm as Tenant'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: deepGreen,
                              foregroundColor: Colors.white),
                          onPressed: () async {
                            // ── 1. Fetch full details for the preview ──
                            final details = await DatabaseService.instance
                                .getViewingRequestDetails(request['id'] as int);

                            if (!mounted) return;
                            if (details == null) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Could not load request details.')),
                              );
                              return;
                            }

                            // ── 2. Compute contract figures ────────────
                            final monthlyRent =
                                (details['room_price'] as num).toDouble();
                            final deposit = monthlyRent; // 1-month deposit
                            final advance = monthlyRent; // 1-month advance
                            final remainingMonthly =
                                monthlyRent - 0; // full amount each month
                            final totalContract =
                                deposit + advance + monthlyRent;
                            // (deposit + advance + first full month)
                            final startDate = DateTime.now();
                            final dueDate = DateTime(
                              startDate.year,
                              startDate.month + 1,
                              startDate.day,
                            );

                            String fmt(double v) => '₱${v.toStringAsFixed(2)}';
                            String fmtDate(DateTime d) =>
                                '${d.month}/${d.day}/${d.year}';

                            // ── 3. Show contract details dialog ────────
                            // Capture helpers as local functions so they
                            // are reachable inside the dialog builder.
                            Widget cSection(String t) =>
                                _LandlordViewingRequestsPageState
                                    ._contractSection(t);
                            Widget cRow(String l, String v,
                                    {bool highlight = false,
                                    bool bold = false}) =>
                                _LandlordViewingRequestsPageState._contractRow(
                                    l, v,
                                    highlight: highlight, bold: bold);
                            String? contractImage;

                            final confirmed = await showDialog<bool>(
                              // ignore: use_build_context_synchronously
                              context: context,
                              barrierDismissible: false,
                              builder: (dialogContext) => StatefulBuilder(
                                builder: (dialogContext, setDialogState) =>
                                    AlertDialog(
                                  backgroundColor: beige,
                                  titlePadding:
                                      const EdgeInsets.fromLTRB(20, 20, 20, 8),
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  title: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: softGreen,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.description_outlined,
                                          color: forestGreen,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Text(
                                          'Contract Summary',
                                          style: TextStyle(
                                            color: deepGreen,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Divider(color: borderColor),
                                        // ROOM INFO
                                        cSection('Room Details'),
                                        cRow('Room',
                                            details['room_name'].toString()),
                                        cRow(
                                            'Location',
                                            details['room_location']
                                                .toString()),
                                        cRow('Floor',
                                            'Floor ${details['room_floor']}'),
                                        cRow('Bedrooms',
                                            '${details['room_bedrooms']}'),
                                        cRow('Bathrooms',
                                            '${details['room_bathrooms']}'),
                                        const SizedBox(height: 8),
                                        // TENANT INFO
                                        cSection('Tenant'),
                                        cRow('Name',
                                            details['tenant_name'].toString()),
                                        cRow('Email',
                                            details['tenant_email'].toString()),
                                        const SizedBox(height: 8),
                                        // CONTRACT TERMS
                                        cSection('Contract Terms'),
                                        cRow('Rent Duration', 'Month-to-month'),
                                        cRow('Monthly Rent', fmt(monthlyRent)),
                                        cRow('Payment Terms',
                                            'Monthly, in advance'),
                                        cRow('Start Date', fmtDate(startDate)),
                                        cRow(
                                            'First Due Date', fmtDate(dueDate)),
                                        const SizedBox(height: 8),
                                        // FINANCIAL BREAKDOWN
                                        cSection('Financial Breakdown'),
                                        cRow('Security Deposit', fmt(deposit),
                                            highlight: true),
                                        cRow('1-Month Advance', fmt(advance),
                                            highlight: true),
                                        cRow('Remaining Monthly Fee',
                                            fmt(remainingMonthly)),
                                        const Divider(color: borderColor),
                                        cRow('Total Move-in Amount',
                                            fmt(totalContract),
                                            bold: true),
                                        const SizedBox(height: 4),
                                        const Text(
                                          '* Total = Deposit + Advance + 1st month rent',
                                          style: TextStyle(
                                              color: muted,
                                              fontSize: 9,
                                              height: 1.4),
                                        ),
                                        if (contractImage != null) ...[
                                          const SizedBox(height: 8),
                                          StoredImage(
                                            data: contractImage,
                                            width: 180,
                                            height: 120,
                                            radius: 12,
                                            fallbackIcon:
                                                Icons.description_outlined,
                                          ),
                                        ],
                                        OutlinedButton.icon(
                                          onPressed: () async {
                                            final messenger =
                                                ScaffoldMessenger.of(context);
                                            try {
                                              final picked =
                                                  await ImagePicker().pickImage(
                                                source: ImageSource.gallery,
                                                imageQuality: 75,
                                                maxWidth: 1600,
                                                maxHeight: 1600,
                                              );
                                              if (picked == null) return;
                                              final encoded = base64Encode(
                                                  await picked.readAsBytes());
                                              setDialogState(() =>
                                                  contractImage = encoded);
                                            } catch (error) {
                                              debugPrint(
                                                  'CONTRACT IMAGE PICKER ERROR: $error');
                                              if (!mounted) return;
                                              messenger.showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Unable to select the contract image.'),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.upload_file_outlined),
                                          label: Text(contractImage == null
                                              ? 'Attach contract image'
                                              : 'Change contract image'),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  ),
                                  actionsPadding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 14),
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, false),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: borderColor),
                                      ),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(color: muted),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      icon: const Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 16),
                                      label: const Text('Confirm Tenancy'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: deepGreen,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () =>
                                          Navigator.pop(dialogContext, true),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            if (confirmed != true) return;
                            if (!mounted) return;

                            // ── 4. Activate the tenant ─────────────────
                            try {
                              await DatabaseService.instance
                                  .activateTenantFromViewingRequest(
                                request['id'] as int,
                                contractImage: contractImage,
                              );
                              if (!mounted) return;
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Tenant confirmed. Room is now occupied.'),
                              ));
                              setState(() {});
                            } catch (e) {
                              if (!mounted) return;
                              final msg = e
                                          .toString()
                                          .contains('ROOM_NOT_AVAILABLE') ||
                                      e
                                          .toString()
                                          .contains('ROOM_ALREADY_OCCUPIED')
                                  ? 'This room is no longer available.'
                                  : 'Could not confirm this tenant. Please try again.';
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text(msg)));
                            }
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ── Helper widgets for contract preview dialog ──────────
  static Widget _contractSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: forestGreen,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  static Widget _contractRow(String label, String value,
      {bool highlight = false, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(color: muted, fontSize: 11),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: highlight ? forestGreen : darkText,
                fontSize: 11,
                fontWeight:
                    bold || highlight ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LANDLORD PAYMENTS
// ============================================================

class LandlordPaymentsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const LandlordPaymentsPage({super.key, required this.user});

  Future<void> sendReminder(
    BuildContext context,
    Map<String, dynamic> payment,
  ) async {
    final tenant =
        await DatabaseService.instance.getUser(payment['tenant_id'] as int);
    if (tenant == null) return;

    final uri = Uri(
      scheme: 'mailto',
      path: tenant['email'].toString(),
      queryParameters: {
        'subject': 'RENTahanan Payment Reminder',
        'body':
            'Hello ${tenant['name']},\n\nThis is a reminder that your rental payment of ₱${payment['amount']} is due on ${payment['due_date']}.\n\nThank you.',
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No email application is available.')),
      );
    }
  }

  Future<void> recordPayment(BuildContext context) async {
    final contracts = await DatabaseService.instance
        .getLandlordActiveContracts(user['id'] as int);
    if (!context.mounted) return;
    if (contracts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('There are no active rental contracts to bill yet.')),
      );
      return;
    }
    final amountController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 7));
    int selectedContract = contracts.first['id'] as int;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Record Rental Due'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedContract,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Tenant / Unit'),
                  items: contracts
                      .map((c) => DropdownMenuItem<int>(
                            value: c['id'] as int,
                            child: Text(
                                '${c['tenant_name']} • ${c['room_name']}',
                                overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => selectedContract = v);
                  },
                ),
                TextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Amount (₱)'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due date'),
                  subtitle:
                      Text('${dueDate.month}/${dueDate.day}/${dueDate.year}'),
                  trailing: const Icon(Icons.calendar_month, color: deepGreen),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: dueDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setDialogState(() => dueDate = picked);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save due'),
            ),
          ],
        ),
      ),
    );
    if (saved != true) {
      amountController.dispose();
      return;
    }
    final amount = double.tryParse(amountController.text.trim());
    amountController.dispose();
    if (amount == null || amount <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Enter a valid amount greater than zero.')),
        );
      }
      return;
    }
    final contract = contracts.firstWhere((c) => c['id'] == selectedContract);
    final due =
        '${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}';
    try {
      await DatabaseService.instance.createPayment(
        tenantId: contract['tenant_id'] as int,
        landlordId: user['id'] as int,
        contractId: selectedContract,
        amount: amount,
        dueDate: due,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Rental due saved and tenant notified.')));
        (context as Element).markNeedsBuild();
      }
    } on StateError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message == 'PAYMENT_DUE_ALREADY_EXISTS'
                  ? 'A payment already exists for that contract and due date.'
                  : 'Unable to record this rental due.',
            ),
          ),
        );
      }
    } catch (error) {
      debugPrint('RENTAL DUE ERROR: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to record this rental due.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text(
          'Payments',
          style: TextStyle(
            color: deepGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Record rental due',
            onPressed: () => recordPayment(context),
            icon: const Icon(Icons.add_circle_outline, color: deepGreen),
          ),
        ],
        iconTheme: const IconThemeData(
          color: deepGreen,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.getLandlordPayments(user['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: deepGreen,
              ),
            );
          }

          final payments = snapshot.data!;

          if (payments.isEmpty) {
            return const EmptyState(
              icon: Icons.payments_outlined,
              text: 'No payment records yet.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: payments.map((payment) {
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment['tenant_name'],
                      style: const TextStyle(
                        color: deepGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if ((payment['room_name'] ?? '').toString().isNotEmpty)
                      Text('Unit: ${payment['room_name']}'),
                    Text(
                      (payment['payment_type'] ?? 'Rent').toString(),
                      style: const TextStyle(color: muted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₱${payment['amount']}',
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Due: ${payment['due_date']}',
                      style: const TextStyle(
                        color: muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StatusBadge(
                      text: payment['status'] == 'Paid'
                          ? 'Paid'
                          : (DateTime.tryParse(
                                    payment['due_date'].toString(),
                                  )?.isBefore(DateTime.now()) ??
                                  false)
                              ? 'Overdue'
                              : 'Due',
                    ),
                    const SizedBox(height: 12),
                    if (payment['status'] != 'Paid')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await DatabaseService.instance
                                  .updatePaymentStatus(
                                payment['id'] as int,
                                'Paid',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Payment marked as paid.'),
                                  ),
                                );
                                (context as Element).markNeedsBuild();
                              }
                            } catch (error) {
                              debugPrint('MARK PAYMENT PAID ERROR: $error');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Unable to update payment status.'),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Mark as paid'),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class LandlordSalesDashboard extends StatefulWidget {
  final Map<String, dynamic> user;

  const LandlordSalesDashboard({super.key, required this.user});

  @override
  State<LandlordSalesDashboard> createState() => _LandlordSalesDashboardState();
}

class _LandlordSalesDashboardState extends State<LandlordSalesDashboard> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late Future<List<Map<String, dynamic>>> _sales;

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _loadSales() {
    _sales = DatabaseService.instance.getLandlordSalesByMonth(
      landlordId: widget.user['id'] as int,
      year: DateTime.now().year,
    );
  }

  String _money(double amount) => '₱${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _sales,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const AppCard(
            child: Text(
              'Unable to load sales and financial information.',
              style: TextStyle(color: muted),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: deepGreen),
          );
        }

        final totals = List<double>.filled(12, 0);
        for (final row in snapshot.data!) {
          final month = (row['month'] as num).toInt();
          if (month >= 1 && month <= 12) {
            totals[month - 1] = (row['total'] as num).toDouble();
          }
        }
        final annualTotal = totals.fold<double>(0, (sum, value) => sum + value);
        final bestMonth = totals.reduce((a, b) => a >= b ? a : b);
        final bestMonthName = _months[totals.indexOf(bestMonth)];
        final average = annualTotal / currentMonth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Sales Report',
              subtitle: 'A monthly view of rental payments collected.',
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net collected • ${DateTime.now().year}',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _money(annualTotal),
                    style: const TextStyle(
                      color: deepGreen,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _FinancialStat(
                          label: '${_months[currentMonth - 1]} collected',
                          value: _money(totals[currentMonth - 1]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FinancialStat(
                          label: 'Best month · $bestMonthName',
                          value: _money(bestMonth),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FinancialStat(
                          label: 'Monthly average',
                          value: _money(average),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 190,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _MonthlyCollectionPainter(totals),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Paid rent and payment records only. Expenses are not tracked.',
                    style: TextStyle(color: muted, fontSize: 10),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SalesReportPage(user: widget.user),
                        ),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Full financial report'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class LandlordFeedbackSection extends StatelessWidget {
  final int landlordId;

  const LandlordFeedbackSection({super.key, required this.landlordId});

  String _dateLabel(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '';
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseService.instance.getLandlordReviews(landlordId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const AppCard(
            child: Text(
              'Unable to load tenant feedback.',
              style: TextStyle(color: muted),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: deepGreen),
          );
        }
        final reviews = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Tenant Feedback',
              subtitle:
                  'Ratings, reviews, and suggestions after completed stays.',
            ),
            const SizedBox(height: 10),
            if (reviews.isEmpty)
              const AppCard(
                child: Text(
                  'No tenant feedback has been submitted yet.',
                  style: TextStyle(color: muted),
                ),
              )
            else
              ...reviews.map(
                (review) => AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: forestGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${review['rating']}/5',
                            style: const TextStyle(
                              color: deepGreen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              review['room_name']?.toString() ?? 'Former unit',
                              style: const TextStyle(
                                color: muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            _dateLabel(review['created_at']),
                            style: const TextStyle(color: muted, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        review['comment']?.toString() ?? '',
                        style: const TextStyle(
                          color: darkText,
                          height: 1.4,
                        ),
                      ),
                      if ((review['suggestions'] ?? '')
                          .toString()
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Text(
                          'Suggestion',
                          style: TextStyle(
                            color: deepGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          review['suggestions'].toString(),
                          style: const TextStyle(
                            color: muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class RoomGuestReviews extends StatelessWidget {
  final int roomId;

  const RoomGuestReviews({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseService.instance.getRoomReviews(roomId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const AppCard(
            child: Text(
              'Unable to load room feedback.',
              style: TextStyle(color: muted),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: deepGreen),
          );
        }
        final reviews = snapshot.data!;
        final average = reviews.isEmpty
            ? 0.0
            : reviews.fold<double>(
                  0,
                  (total, review) =>
                      total + (review['rating'] as num).toDouble(),
                ) /
                reviews.length;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(
              title: 'Guest Ratings & Feedback',
              subtitle: 'Reviews from renters who have completed their stay.',
            ),
            const SizedBox(height: 8),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: forestGreen,
                        size: 24,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        reviews.isEmpty
                            ? 'No ratings yet'
                            : average.toStringAsFixed(1),
                        style: const TextStyle(
                          color: deepGreen,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (reviews.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '(${reviews.length} review${reviews.length == 1 ? '' : 's'})',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'There is no guest feedback for this room yet.',
                        style: TextStyle(color: muted),
                      ),
                    )
                  else ...[
                    const Divider(height: 22),
                    ...reviews.map(
                      (review) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ...List.generate(
                                  5,
                                  (index) => Icon(
                                    index < (review['rating'] as num).toInt()
                                        ? Icons.star_rounded
                                        : Icons.star_border_rounded,
                                    size: 17,
                                    color: forestGreen,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'Former renter',
                                  style: TextStyle(color: muted, fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              review['comment']?.toString() ?? '',
                              style: const TextStyle(
                                color: darkText,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FinancialStat extends StatelessWidget {
  final String label;
  final String value;

  const _FinancialStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: muted, fontSize: 10),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              color: darkText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlyCollectionPainter extends CustomPainter {
  final List<double> totals;

  const _MonthlyCollectionPainter(this.totals);

  @override
  void paint(Canvas canvas, Size size) {
    const left = 34.0;
    const right = 8.0;
    const top = 12.0;
    const bottom = 25.0;
    final chart = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );
    final maxAmount =
        totals.fold<double>(0, (max, value) => value > max ? value : max);
    final scale = maxAmount == 0 ? 1.0 : maxAmount;
    final gridPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = forestGreen
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pointPaint = Paint()
      ..color = forestGreen
      ..style = PaintingStyle.fill;

    for (var index = 0; index < 3; index++) {
      final fraction = index / 2;
      final y = chart.bottom - chart.height * fraction;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), gridPaint);
      final label = TextPainter(
        text: TextSpan(
          text: _axisLabel(maxAmount * fraction),
          style: const TextStyle(color: muted, fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: left - 3);
      label.paint(canvas, Offset(0, y - label.height / 2));
    }

    final path = Path();
    for (var index = 0; index < totals.length; index++) {
      final x = chart.left + chart.width * index / (totals.length - 1);
      final y = chart.bottom - chart.height * totals[index] / scale;
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, pointPaint);

      final monthLabel = TextPainter(
        text: TextSpan(
          text: const [
            'J',
            'F',
            'M',
            'A',
            'M',
            'J',
            'J',
            'A',
            'S',
            'O',
            'N',
            'D',
          ][index],
          style: const TextStyle(color: muted, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      monthLabel.paint(
        canvas,
        Offset(x - monthLabel.width / 2, chart.bottom + 5),
      );
    }
    canvas.drawPath(path, linePaint);
  }

  String _axisLabel(double amount) {
    if (amount >= 1000000) return '₱${(amount / 1000000).toStringAsFixed(1)}m';
    if (amount >= 1000) return '₱${(amount / 1000).toStringAsFixed(0)}k';
    return '₱${amount.toStringAsFixed(0)}';
  }

  @override
  bool shouldRepaint(covariant _MonthlyCollectionPainter oldDelegate) =>
      oldDelegate.totals != totals;
}

class SalesReportPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const SalesReportPage({super.key, required this.user});

  @override
  State<SalesReportPage> createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late int _selectedYear;
  late Future<List<Map<String, dynamic>>> _sales;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
    _loadSales();
  }

  void _loadSales() {
    _sales = DatabaseService.instance.getLandlordSalesByMonth(
      landlordId: widget.user['id'] as int,
      year: _selectedYear,
    );
  }

  String _money(double amount) => '₱${amount.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text('Sales Report'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _sales,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline,
              text: 'Unable to load the sales report.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: deepGreen),
            );
          }

          final totalsByMonth = <int, double>{
            for (final row in snapshot.data!)
              (row['month'] as num).toInt(): (row['total'] as num).toDouble(),
          };
          final annualTotal = totalsByMonth.values.fold<double>(
            0,
            (total, amount) => total + amount,
          );
          return RefreshIndicator(
            color: deepGreen,
            onRefresh: () async {
              setState(_loadSales);
              await _sales;
            },
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Report year',
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      DropdownButton<int>(
                        value: _selectedYear,
                        isExpanded: true,
                        underline: const SizedBox.shrink(),
                        items: List.generate(
                          6,
                          (index) => currentYear - index,
                        )
                            .map((year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year.toString()),
                                ))
                            .toList(),
                        onChanged: (year) {
                          if (year == null) return;
                          setState(() {
                            _selectedYear = year;
                            _loadSales();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      const Divider(color: borderColor),
                      const SizedBox(height: 8),
                      const Text(
                        'Net collected this year',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _money(annualTotal),
                        style: const TextStyle(
                          color: deepGreen,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Paid payment records only; unpaid amounts are excluded. Expenses are not tracked in this report.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const SectionTitle(
                  title: 'Monthly Sales',
                  subtitle: 'Rental payments collected by month.',
                ),
                const SizedBox(height: 8),
                ...List.generate(12, (index) {
                  final amount = totalsByMonth[index + 1] ?? 0;
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: softGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: deepGreen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _months[index],
                            style: const TextStyle(
                              color: darkText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          _money(amount),
                          style: const TextStyle(
                            color: deepGreen,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// LANDLORD REPORTS
// ============================================================

class LandlordReportsPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const LandlordReportsPage({super.key, required this.user});

  @override
  State<LandlordReportsPage> createState() => _LandlordReportsPageState();
}

class _LandlordReportsPageState extends State<LandlordReportsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text('Tenant Reports',
            style: TextStyle(color: deepGreen, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: deepGreen),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.getLandlordReports(widget.user['id']),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: deepGreen));
          }
          final reports = snapshot.data!;
          if (reports.isEmpty) {
            return const EmptyState(
                icon: Icons.report_problem_outlined,
                text: 'No tenant reports yet.');
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: reports.map((report) {
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(report['subject'],
                                style: const TextStyle(
                                    color: deepGreen,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800))),
                        StatusBadge(text: report['status']),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text('${report['category']} • ${report['tenant_name']}',
                        style: const TextStyle(color: muted, fontSize: 10)),
                    if (report['room_name'] != null) ...[
                      const SizedBox(height: 4),
                      Text('Room: ${report['room_name']}',
                          style: const TextStyle(color: muted, fontSize: 10)),
                    ],
                    const SizedBox(height: 12),
                    Text(report['description'],
                        style: const TextStyle(
                            color: darkText, fontSize: 11, height: 1.5)),
                    if ((report['landlord_reply'] ?? '')
                        .toString()
                        .trim()
                        .isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Landlord reply',
                          style: TextStyle(
                              color: deepGreen, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(report['landlord_reply'].toString(),
                          style: const TextStyle(
                              color: darkText, fontSize: 11, height: 1.5)),
                    ],
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      initialValue: report['status'].toString(),
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: lightBeige,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide:
                                  const BorderSide(color: borderColor))),
                      items: const [
                        DropdownMenuItem(
                            value: 'Submitted', child: Text('Submitted')),
                        DropdownMenuItem(
                            value: 'In Progress', child: Text('In Progress')),
                        DropdownMenuItem(
                            value: 'Resolved', child: Text('Resolved')),
                      ],
                      onChanged: (value) async {
                        if (value == null || value == report['status']) return;
                        await DatabaseService.instance
                            .updateReportStatus(report['id'], value);
                        if (mounted) setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.reply_outlined),
                      label: Text(
                          (report['landlord_reply'] ?? '').toString().isEmpty
                              ? 'Reply to concern'
                              : 'Update reply'),
                      onPressed: () async {
                        final controller = TextEditingController(
                            text: (report['landlord_reply'] ?? '').toString());
                        final reply = await showDialog<String>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Reply to tenant concern'),
                            content: TextField(
                              controller: controller,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                  hintText: 'Write your response...'),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Cancel')),
                              ElevatedButton(
                                  onPressed: () => Navigator.pop(
                                      dialogContext, controller.text.trim()),
                                  child: const Text('Send reply')),
                            ],
                          ),
                        );
                        controller.dispose();
                        if (reply == null || reply.trim().isEmpty) return;
                        await DatabaseService.instance.replyToReport(
                          reportId: report['id'] as int,
                          landlordId: widget.user['id'] as int,
                          reply: reply,
                        );
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

// ============================================================
// LANDLORD ACTIVITY
// ============================================================

class LandlordActivityPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const LandlordActivityPage({super.key, required this.user});

  void open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  String money(dynamic value) => '₱${(value as num).toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final landlordId = user['id'] as int;

    return AppScaffold(
      title: 'Activity',
      subtitle: 'See what happened and what needs your attention.',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 25),
        children: [
          // ══════════════════════════════════════════════
          // RECENT ACTIVITY  ← moved to top
          // ══════════════════════════════════════════════
          const SectionTitle(
            title: 'Recent Activity',
            subtitle: 'A timeline of recent events in your rental property.',
          ),
          const SizedBox(height: 12),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseService.instance.getNotifications(landlordId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(25),
                    child: CircularProgressIndicator(color: deepGreen),
                  ),
                );
              }

              final notifications = snapshot.data!;
              if (notifications.isEmpty) {
                return const AppCard(
                  child: Text(
                    'No recent activity yet. New viewing requests, payments, reports, messages and contract updates will appear here.',
                    style: TextStyle(color: muted, fontSize: 11, height: 1.5),
                  ),
                );
              }

              return Column(
                children: notifications.take(10).map((item) {
                  IconData icon = Icons.notifications_none_rounded;
                  final title = item['title'].toString().toLowerCase();
                  if (title.contains('payment')) icon = Icons.payments_outlined;
                  if (title.contains('view')) {
                    icon = Icons.calendar_month_rounded;
                  }
                  if (title.contains('report') || title.contains('concern')) {
                    icon = Icons.report_problem_outlined;
                  }
                  if (title.contains('message')) {
                    icon = Icons.chat_bubble_outline_rounded;
                  }
                  if (title.contains('contract')) {
                    icon = Icons.description_outlined;
                  }
                  if (title.contains('review')) {
                    icon = Icons.star_outline_rounded;
                  }

                  return ActivityCard(
                    icon: icon,
                    title: item['title'],
                    subtitle: item['message'],
                    timestamp: timeAgo(item['created_at']),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 22),

          // ══════════════════════════════════════════════
          // NEEDS ATTENTION
          // ══════════════════════════════════════════════
          const SectionTitle(
            title: 'Needs Attention',
            subtitle: 'Review pending requests, payments and tenant concerns.',
          ),
          const SizedBox(height: 12),

          FutureBuilder<List<Map<String, dynamic>>>(
            future:
                DatabaseService.instance.getLandlordViewingRequests(landlordId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final pending = snapshot.data!
                  .where(
                    (r) => r['status'].toString().toLowerCase() == 'pending',
                  )
                  .toList();
              if (pending.isEmpty) return const SizedBox.shrink();
              final request = pending.first;
              return FeatureTile(
                icon: Icons.calendar_month_rounded,
                title:
                    '${pending.length} Pending Viewing Request${pending.length == 1 ? '' : 's'}',
                description:
                    '${request['tenant_name']} requested ${request['room_name']} • ${request['requested_date']} ${request['requested_time']}',
                onTap: () =>
                    open(context, LandlordViewingRequestsPage(user: user)),
              );
            },
          ),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseService.instance.getLandlordPayments(landlordId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final attention = snapshot.data!.where((p) {
                final status = p['status'].toString().toLowerCase();
                return status == 'pending' || status == 'overdue';
              }).toList();
              if (attention.isEmpty) return const SizedBox.shrink();
              final payment = attention.first;
              return FeatureTile(
                icon: Icons.payments_outlined,
                title:
                    '${attention.length} Payment${attention.length == 1 ? '' : 's'} Need Attention',
                description:
                    '${payment['tenant_name']} • ${money(payment['amount'])} • Due ${payment['due_date']}',
                onTap: () => open(context, LandlordPaymentsPage(user: user)),
              );
            },
          ),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseService.instance.getLandlordReports(landlordId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final unresolved = snapshot.data!.where((r) {
                final status = r['status'].toString().toLowerCase();
                return status != 'resolved' && status != 'closed';
              }).toList();
              if (unresolved.isEmpty) return const SizedBox.shrink();
              final report = unresolved.first;
              return FeatureTile(
                icon: Icons.report_problem_outlined,
                title:
                    '${unresolved.length} Unresolved Tenant Report${unresolved.length == 1 ? '' : 's'}',
                description:
                    '${report['tenant_name']} • ${report['room_name']} • ${report['subject']}',
                onTap: () => open(context, LandlordReportsPage(user: user)),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> user;

  const ProfilePage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profile',
      subtitle: 'Manage your RENtahanan account.',
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: softGreen,
              child: Icon(
                Icons.person_rounded,
                color: forestGreen,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              user['name'],
              style: const TextStyle(
                color: deepGreen,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: Text(
              user['email'],
              style: const TextStyle(
                color: muted,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: StatusBadge(
              text: user['role'],
            ),
          ),
          if ((user['landlord_code'] ?? '').toString().isNotEmpty ||
              (user['contact_number'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((user['landlord_code'] ?? '').toString().isNotEmpty)
                    Text(
                      user['role'] == 'Landlord'
                          ? 'Landlord ID: ${user['landlord_code']}'
                          : 'Tenant ID: ${user['landlord_code']}',
                      style: const TextStyle(
                        color: deepGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  if ((user['contact_number'] ?? '').toString().isNotEmpty)
                    Text('Contact number: ${user['contact_number']}'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 30),
          FeatureTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            description: 'View your latest system notifications.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationsPage(
                    userId: user['id'],
                  ),
                ),
              );
            },
          ),
          FeatureTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            description: 'Sign out of your RENtahanan account.',
            onTap: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Logout?'),
                  content: const Text('Do you want to logout of your account?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              );
              if (shouldLogout != true || !context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const WelcomePage(),
                ),
                (_) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NOTIFICATIONS
// ============================================================

class NotificationsPage extends StatelessWidget {
  final int userId;

  const NotificationsPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: deepGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(
          color: deepGreen,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseService.instance.getNotifications(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: deepGreen,
              ),
            );
          }

          final notifications = snapshot.data!;

          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              text: 'No notifications.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(18),
            children: notifications
                .map(
                  (notification) => AppCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: softGreen,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.notifications_rounded,
                            color: forestGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'],
                                style: const TextStyle(
                                  color: deepGreen,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                notification['message'],
                                style: const TextStyle(
                                  color: muted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

// ============================================================
// ROOM CARD
// ============================================================

class RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final Map<String, dynamic> user;

  const RoomCard({
    super.key,
    required this.room,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomDetailsPage(
              room: room,
              user: user,
            ),
          ),
        );
      },
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 145,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: softGreen,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: const Icon(
                Icons.home_work_rounded,
                color: forestGreen,
                size: 60,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room['name'],
                    style: const TextStyle(
                      color: deepGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    room['location'],
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Floor ${room['floor'] ?? 1}',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '₱${(room['price'] as num).toStringAsFixed(0)} / month',
                    style: const TextStyle(
                      color: deepGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${room['bedrooms']} bed',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${room['bathrooms']} bath',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LANDLORD ROOM CARD
// ============================================================

class LandlordPropertyDetailsPage extends StatefulWidget {
  final int roomId;
  final int landlordId;
  final Future<void> Function(Map<String, dynamic> room) onEdit;

  const LandlordPropertyDetailsPage({
    super.key,
    required this.roomId,
    required this.landlordId,
    required this.onEdit,
  });

  @override
  State<LandlordPropertyDetailsPage> createState() =>
      _LandlordPropertyDetailsPageState();
}

class _LandlordPropertyDetailsPageState
    extends State<LandlordPropertyDetailsPage> {
  late Future<Map<String, dynamic>?> _room;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  void _loadRoom() {
    _room = DatabaseService.instance
        .getLandlordRooms(widget.landlordId)
        .then((rooms) {
      for (final room in rooms) {
        if (room['id'] == widget.roomId) return room;
      }
      return null;
    });
  }

  Future<void> _edit(Map<String, dynamic> room) async {
    await widget.onEdit(room);
    if (mounted) setState(_loadRoom);
  }

  Future<void> _setContractEndDate(Map<String, dynamic> room) async {
    final now = DateTime.now();
    final current = DateTime.tryParse(
      (room['contract_end_date'] ?? '').toString(),
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now.add(const Duration(days: 365)),
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 20),
    );
    if (picked == null) return;

    final date =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    try {
      await DatabaseService.instance.setContractEndDate(
        contractId: room['active_contract_id'] as int,
        landlordId: widget.landlordId,
        contractEndDate: date,
      );
      if (!mounted) return;
      setState(_loadRoom);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contract end date saved.')),
      );
    } catch (error) {
      debugPrint('UPDATE PROPERTY CONTRACT END DATE ERROR: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to update the contract end date.')),
      );
    }
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(
              label,
              style: const TextStyle(
                color: muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(dynamic value) {
    final text = (value ?? '').toString();
    if (text.isEmpty) return 'Not set';
    final date = DateTime.tryParse(text);
    if (date == null) return text;
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: beige,
      appBar: AppBar(
        backgroundColor: beige,
        title: const Text('Property Details'),
        iconTheme: const IconThemeData(color: deepGreen),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _room,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline,
              text: 'Unable to load this property.',
            );
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: deepGreen),
            );
          }
          final room = snapshot.data;
          if (room == null) {
            return const EmptyState(
              icon: Icons.home_work_outlined,
              text: 'This property could not be found.',
            );
          }
          final occupied = room['active_contract_id'] != null;
          final tenantName = (room['tenant_name'] ?? '').toString();

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            children: [
              StoredImageGallery(
                data: room['image'],
                width: double.infinity,
                height: 245,
                radius: 20,
                fallbackIcon: Icons.home_work_rounded,
                showThumbnails: true,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room['name']?.toString() ?? 'Unit',
                      style: const TextStyle(
                        color: deepGreen,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  StatusBadge(text: occupied ? 'Occupied' : 'Available'),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '₱${(room['price'] as num).toStringAsFixed(2)} per month',
                style: const TextStyle(
                  color: deepGreen,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unit Information',
                      style: TextStyle(
                        color: deepGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _detailRow('Location', room['location'].toString()),
                    _detailRow('Floor', '${room['floor'] ?? 1}'),
                    _detailRow('Bedrooms', '${room['bedrooms'] ?? 1}'),
                    _detailRow('Bathrooms', '${room['bathrooms'] ?? 1}'),
                    const SizedBox(height: 8),
                    const Text(
                      'Description',
                      style: TextStyle(
                        color: deepGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      (room['description'] ?? '').toString().trim().isEmpty
                          ? 'No description provided.'
                          : room['description'].toString(),
                      style: const TextStyle(
                        color: darkText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Tenant',
                      style: TextStyle(
                        color: deepGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!occupied)
                      const Text(
                        'There is no active tenant in this unit.',
                        style: TextStyle(color: muted),
                      )
                    else ...[
                      _detailRow('Name', tenantName),
                      if ((room['tenant_code'] ?? '').toString().isNotEmpty)
                        _detailRow('Tenant ID', room['tenant_code'].toString()),
                      if ((room['tenant_email'] ?? '').toString().isNotEmpty)
                        _detailRow('Email', room['tenant_email'].toString()),
                      if ((room['tenant_contact'] ?? '').toString().isNotEmpty)
                        _detailRow(
                          'Contact',
                          room['tenant_contact'].toString(),
                        ),
                      _detailRow(
                        'Contract ends',
                        _dateLabel(room['contract_end_date']),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _setContractEndDate(room),
                          icon: const Icon(Icons.edit_calendar_outlined),
                          label: const Text('Edit end date'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              PrimaryButton(
                text: 'Edit Unit Details',
                icon: Icons.edit_outlined,
                onPressed: () => _edit(room),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LandlordRoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const LandlordRoomCard({
    super.key,
    required this.room,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final occupied = room['active_contract_id'] != null;
    final tenantName = (room['tenant_name'] ?? '').toString();
    return AppCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              StoredImage(
                data: room['image'],
                width: 70,
                height: 70,
                radius: 18,
                fallbackIcon: Icons.home_work_rounded,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            room['name'],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: deepGreen,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      room['location'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      children: [
                        Text(
                          'Floor ${room['floor'] ?? 1}',
                          style: const TextStyle(color: muted, fontSize: 10),
                        ),
                        Text(
                          '₱${(room['price'] as num).toStringAsFixed(0)}/mo',
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (occupied && tenantName.isNotEmpty)
                          Text(
                            tenantName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusBadge(text: occupied ? 'Occupied' : 'Available'),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: deepGreen,
                    size: 20,
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Remove property',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: Colors.red.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// UI COMPONENTS
// ============================================================

List<String> storedImageData(dynamic data) {
  if (data is List) {
    return data.whereType<String>().where((image) => image.isNotEmpty).toList();
  }

  final encoded = data?.toString() ?? '';
  if (encoded.isEmpty) return [];

  try {
    final decoded = jsonDecode(encoded);
    if (decoded is List) {
      return decoded
          .whereType<String>()
          .where((image) => image.isNotEmpty)
          .toList();
    }
  } on FormatException {
    // Older listings store a single base64 image instead of a JSON list.
  }
  return [encoded];
}

void _showStoredImageZoom(
  BuildContext context,
  dynamic data,
  IconData fallbackIcon,
) {
  final images = storedImageData(data);
  if (images.isEmpty) return;

  ImageProvider imageProvider;
  try {
    imageProvider = MemoryImage(base64Decode(images.first));
  } on FormatException {
    imageProvider = FileImage(File(images.first));
  }

  showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      child: SizedBox(
        width: MediaQuery.sizeOf(dialogContext).width * 0.9,
        height: MediaQuery.sizeOf(dialogContext).height * 0.75,
        child: InteractiveViewer(
          minScale: 0.75,
          maxScale: 5,
          child: Image(
            image: imageProvider,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Icon(fallbackIcon, color: forestGreen, size: 42),
            ),
          ),
        ),
      ),
    ),
  );
}

class StoredImage extends StatelessWidget {
  final dynamic data;
  final double width;
  final double height;
  final double radius;
  final IconData fallbackIcon;

  const StoredImage({
    super.key,
    required this.data,
    required this.width,
    required this.height,
    required this.radius,
    required this.fallbackIcon,
  });

  Widget _placeholder() => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: softGreen,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Icon(fallbackIcon, color: forestGreen, size: 38),
      );

  @override
  Widget build(BuildContext context) {
    final images = storedImageData(data);
    if (images.isEmpty) return _placeholder();

    ImageProvider imageProvider;
    try {
      imageProvider = MemoryImage(base64Decode(images.first));
    } on FormatException {
      imageProvider = FileImage(File(images.first));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image(
        image: imageProvider,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      ),
    );
  }
}

class StoredImageGallery extends StatefulWidget {
  final dynamic data;
  final double width;
  final double height;
  final double radius;
  final IconData fallbackIcon;
  final bool showThumbnails;

  const StoredImageGallery({
    super.key,
    required this.data,
    required this.width,
    required this.height,
    required this.radius,
    required this.fallbackIcon,
    this.showThumbnails = false,
  });

  @override
  State<StoredImageGallery> createState() => _StoredImageGalleryState();
}

class _StoredImageGalleryState extends State<StoredImageGallery> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = storedImageData(widget.data);
    if (images.length < 2) {
      return StoredImage(
        data: images.isEmpty ? null : images.first,
        width: widget.width,
        height: widget.height,
        radius: widget.radius,
        fallbackIcon: widget.fallbackIcon,
      );
    }

    final gallery = SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) => StoredImage(
                data: images[index],
                width: widget.width,
                height: widget.height,
                radius: 0,
                fallbackIcon: widget.fallbackIcon,
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    width: index == _currentPage ? 18 : 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: index == _currentPage
                          ? Colors.white
                          : Colors.white.withAlpha(150),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentPage + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.showThumbnails) return gallery;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        gallery,
        const SizedBox(height: 10),
        SizedBox(
          height: 58,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                );
              },
              child: Container(
                width: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: index == _currentPage ? deepGreen : borderColor,
                    width: index == _currentPage ? 2 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: StoredImage(
                  data: images[index],
                  width: 72,
                  height: 58,
                  radius: 8,
                  fallbackIcon: widget.fallbackIcon,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              softGreen,
              beige,
              lightBeige,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final List<Widget>? actions;

  const AppScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              10,
              15,
            ),
            child: Row(
              children: [
                const RENTahananLogo(size: 50),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: deepGreen,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (actions != null) ...actions!,
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(17),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      padding: padding,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: deepGreen.withAlpha(22),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: deepGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17),
              const SizedBox(width: 7),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: lightBeige,
          foregroundColor: deepGreen,
          side: const BorderSide(
            color: deepGreen,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: darkText,
        fontSize: 11,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFFA3AAA4),
          fontSize: 10.5,
        ),
        prefixIcon: Icon(
          icon,
          color: forestGreen,
          size: 18,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: lightBeige,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(
            color: deepGreen,
          ),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: darkText,
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: GestureDetector(
        onTap: onTap,
        child: AppCard(
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: softGreen,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: forestGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 9.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: deepGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: deepGreen,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: muted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: softGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: forestGreen,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: deepGreen,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: deepGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String text;

  const StatusBadge({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: softGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: deepGreen,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoChip({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: softGreen,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: forestGreen,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: deepGreen,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

String timeAgo(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return 'Time unavailable';

  final difference = DateTime.now().difference(date);
  if (difference.isNegative || difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes min${minutes == 1 ? '' : 's'} ago';
  }
  if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours hr${hours == 1 ? '' : 's'} ago';
  }
  if (difference.inDays < 7) {
    final days = difference.inDays;
    return '$days day${days == 1 ? '' : 's'} ago';
  }
  if (difference.inDays < 30) {
    final weeks = difference.inDays ~/ 7;
    return '$weeks wk${weeks == 1 ? '' : 's'} ago';
  }
  if (difference.inDays < 365) {
    final months = difference.inDays ~/ 30;
    return '$months mo${months == 1 ? '' : 's'} ago';
  }
  final years = difference.inDays ~/ 365;
  return '$years yr${years == 1 ? '' : 's'} ago';
}

class ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? status;
  final String? timestamp;

  const ActivityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.status,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: softGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: forestGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: deepGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
                if (timestamp != null || status != null) ...[
                  const SizedBox(height: 7),
                  if (timestamp != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: softGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        timestamp!,
                        style: const TextStyle(
                          color: forestGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  else
                    StatusBadge(text: status!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;

  const EmptyState({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              icon,
              size: 55,
              color: forestGreen,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LOGO
// ============================================================

class RENTahananLogo extends StatelessWidget {
  final double size;

  const RENTahananLogo({
    super.key,
    this.size = 130,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/rentahanan_logo2.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) {
        return SizedBox(
          width: size,
          height: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_work_rounded,
                color: forestGreen,
                size: size * .48,
              ),
              Text(
                'RENtahanan',
                style: TextStyle(
                  color: forestGreen,
                  fontSize: size * .13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
