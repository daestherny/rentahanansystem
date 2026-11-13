import 'dart:convert';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;
  Future<Database>? _databaseFuture;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Prevent multiple parts of the app from opening SQLite at the same time.
    _databaseFuture ??= _openDatabase();

    try {
      _database = await _databaseFuture!;
      return _database!;
    } catch (_) {
      // Allow a later attempt if opening the database fails.
      _databaseFuture = null;
      rethrow;
    }
  }

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'rentahanan.db');

    return openDatabase(
      path,
      version: 19,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    _databaseFuture = null;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await _createAccountTables(db);

    await db.execute('''
      CREATE TABLE rooms (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        landlord_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        floor INTEGER NOT NULL DEFAULT 1,
        location TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        bedrooms INTEGER NOT NULL,
        bathrooms INTEGER NOT NULL,
        image TEXT,
        available INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE contracts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenant_id INTEGER NOT NULL,
        landlord_id INTEGER NOT NULL,
        room_id INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        contract_end_date TEXT,
        monthly_rent REAL NOT NULL,
        duration_months INTEGER NOT NULL DEFAULT 0,
        payment_terms TEXT NOT NULL DEFAULT 'Monthly',
        security_deposit REAL NOT NULL DEFAULT 0,
        advance_amount REAL NOT NULL DEFAULT 0,
        total_contract_amount REAL NOT NULL DEFAULT 0,
        contract_image TEXT,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE viewing_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenant_id INTEGER NOT NULL,
        landlord_id INTEGER NOT NULL,
        room_id INTEGER NOT NULL,
        requested_date TEXT NOT NULL,
        requested_time TEXT NOT NULL,
        message TEXT,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_id INTEGER NOT NULL,
        receiver_id INTEGER NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL,
        room_id INTEGER,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await _createGuestMessagesTable(db);

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenant_id INTEGER NOT NULL,
        landlord_id INTEGER NOT NULL,
        contract_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_type TEXT NOT NULL DEFAULT 'Rent',
        due_date TEXT NOT NULL,
        paid_at TEXT,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenant_id INTEGER NOT NULL,
        landlord_id INTEGER NOT NULL,
        room_id INTEGER NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT NOT NULL,
        suggestions TEXT NOT NULL DEFAULT '',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tenant_id INTEGER NOT NULL,
        landlord_id INTEGER NOT NULL,
        room_id INTEGER,
        category TEXT NOT NULL,
        subject TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        landlord_reply TEXT,
        replied_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE landlord_apartments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        landlord_id INTEGER NOT NULL UNIQUE,
        apartment_name TEXT NOT NULL,
        location TEXT NOT NULL,
        total_floors INTEGER NOT NULL DEFAULT 1,
        total_rooms INTEGER NOT NULL DEFAULT 1,
        monthly_rent REAL NOT NULL DEFAULT 0,
        pet_friendly INTEGER NOT NULL DEFAULT 0,
        price_tier TEXT NOT NULL DEFAULT 'Standard',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE announcements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        landlord_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await _createViewingBlackoutsTable(db);
    await _createNewAccountFeatures(db);
  }

  Future<void> _upgradeDatabase(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS reports (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          tenant_id INTEGER NOT NULL,
          landlord_id INTEGER NOT NULL,
          room_id INTEGER,
          category TEXT NOT NULL,
          subject TEXT NOT NULL,
          description TEXT NOT NULL,
          status TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 3) {
      // Add the floor field required by the current RENTahanan UI.
      // SQLite will use 1 for existing rooms.
      await db.execute(
        'ALTER TABLE rooms ADD COLUMN floor INTEGER NOT NULL DEFAULT 1',
      );
    }

    if (oldVersion < 4) {
      // Remove legacy sample listings from older app versions. These were
      // demonstration data, not properties created by the current landlord.
      await db.delete(
        'rooms',
        where: 'LOWER(name) IN (?, ?, ?, ?)',
        whereArgs: [
          'cozy studio room',
          'modern solo room',
          'family apartment',
          'room 201',
        ],
      );
    }

    if (oldVersion < 5) {
      // Remove the additional known sample rooms reported in the tenant view.
      // This migration runs once for databases upgrading from version 4 or earlier.
      await db.delete(
        'rooms',
        where: 'LOWER(TRIM(name)) IN (?, ?)',
        whereArgs: ['room 101', 'room 102'],
      );
    }

    if (oldVersion < 6) {
      // Clean up legacy demo listings that may remain in existing local databases.
      await db.delete(
        'rooms',
        where: 'LOWER(TRIM(name)) IN (?, ?, ?, ?, ?, ?)',
        whereArgs: [
          'cozy studio room',
          'modern solo room',
          'family apartment',
          'room 201',
          'room 101',
          'room 102',
        ],
      );
    }

    if (oldVersion < 7) {
      await _migrateUsersToSeparateTables(db);
    }

    if (oldVersion < 8) {
      final reportColumns = await db.rawQuery('PRAGMA table_info(reports)');
      final columnNames = reportColumns.map((c) => c['name']).toSet();
      if (!columnNames.contains('landlord_reply')) {
        await db.execute('ALTER TABLE reports ADD COLUMN landlord_reply TEXT');
      }
      if (!columnNames.contains('replied_at')) {
        await db.execute('ALTER TABLE reports ADD COLUMN replied_at TEXT');
      }
      final contractColumns = await db.rawQuery('PRAGMA table_info(contracts)');
      final contractColumnNames = contractColumns.map((c) => c['name']).toSet();
      if (!contractColumnNames.contains('contract_end_date')) {
        await db
            .execute('ALTER TABLE contracts ADD COLUMN contract_end_date TEXT');
      }
    }

    if (oldVersion < 9) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS landlord_apartments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          landlord_id INTEGER NOT NULL UNIQUE,
          apartment_name TEXT NOT NULL,
          location TEXT NOT NULL,
          total_floors INTEGER NOT NULL DEFAULT 1,
          total_rooms INTEGER NOT NULL DEFAULT 1,
          monthly_rent REAL NOT NULL DEFAULT 0,
          pet_friendly INTEGER NOT NULL DEFAULT 0,
          price_tier TEXT NOT NULL DEFAULT 'Standard',
          created_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 10) {
      await _addColumnIfMissing(db, 'landlords', 'landlord_code', 'TEXT');
      await _addColumnIfMissing(db, 'tenants', 'tenant_code', 'TEXT');
      await _addColumnIfMissing(db, 'tenants', 'contact_number', 'TEXT');
      await _addColumnIfMissing(
          db, 'tenants', 'activated', 'INTEGER NOT NULL DEFAULT 1');
      await _createNewAccountFeatures(db);
      await _createUsersCompatibilityView(db);
    }

    if (oldVersion < 11) {
      await _addColumnIfMissing(
          db, 'contracts', 'duration_months', 'INTEGER NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'contracts', 'payment_terms', "TEXT NOT NULL DEFAULT 'Monthly'");
      await _addColumnIfMissing(
          db, 'contracts', 'security_deposit', 'REAL NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'contracts', 'advance_amount', 'REAL NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'contracts', 'total_contract_amount', 'REAL NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'payments', 'payment_type', "TEXT NOT NULL DEFAULT 'Rent'");
    }

    if (oldVersion < 12) {
      await _addColumnIfMissing(
          db, 'landlord_apartments', 'monthly_rent', 'REAL NOT NULL DEFAULT 0');
    }

    if (oldVersion < 13) {
      await _addColumnIfMissing(db, 'payments', 'paid_at', 'TEXT');
      await db.execute('''
        UPDATE payments
        SET paid_at = due_date
        WHERE LOWER(status) = 'paid' AND paid_at IS NULL
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS announcements (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          landlord_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          message TEXT NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }

    if (oldVersion < 14) {
      await _addColumnIfMissing(db, 'contracts', 'contract_image', 'TEXT');
      await _addColumnIfMissing(
        db,
        'reviews',
        'suggestions',
        "TEXT NOT NULL DEFAULT ''",
      );
    }

    if (oldVersion < 15) {
      await _createViewingBlackoutsTable(db);
    }

    if (oldVersion < 16) {
      await _migrateRoomImagesToFiles(db);
    }

    if (oldVersion < 17) {
      await _shortenAccountCodes(db);
    }

    if (oldVersion < 18) {
      await _addColumnIfMissing(
        db,
        'tenants',
        'account_deleted',
        'INTEGER NOT NULL DEFAULT 0',
      );
      await _addColumnIfMissing(db, 'messages', 'room_id', 'INTEGER');
      await _createGuestMessagesTable(db);
      await _createUsersCompatibilityView(db);
    }

    if (oldVersion < 19) {
      await _addColumnIfMissing(db, 'landlords', 'contact_number', 'TEXT');
      await _createUsersCompatibilityView(db);
    }
  }

  Future<void> _createGuestMessagesTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS guest_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guest_id INTEGER NOT NULL,
        landlord_id INTEGER NOT NULL,
        room_id INTEGER NOT NULL,
        sender_role TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT NOT NULL,
        is_read INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _shortenAccountCodes(DatabaseExecutor db) async {
    final guests = await db.query('guest_accounts', columns: ['id']);
    for (final guest in guests) {
      final id = (guest['id'] as num).toInt();
      await db.update(
        'guest_accounts',
        {'guest_code': 'G-${id.toString().padLeft(3, '0')}'},
        where: 'id = ?',
        whereArgs: [id],
      );
    }

    final tenants = await db.query('tenants', columns: ['id']);
    for (final tenant in tenants) {
      final id = (tenant['id'] as num).toInt();
      await db.update(
        'tenants',
        {'tenant_code': 'T-${id.toString().padLeft(3, '0')}'},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<void> _migrateRoomImagesToFiles(DatabaseExecutor db) async {
    final rows = await db.rawQuery('''
      SELECT id, length(image) AS image_length
      FROM rooms
      WHERE image IS NOT NULL AND image != ''
    ''');
    final imagesDirectory =
        Directory(p.join(await getDatabasesPath(), 'room_images'));
    await imagesDirectory.create(recursive: true);

    for (final row in rows) {
      final roomId = (row['id'] as num).toInt();
      final imageLength = (row['image_length'] as num).toInt();
      final imageBuffer = StringBuffer();
      for (var offset = 1; offset <= imageLength; offset += 512 * 1024) {
        final chunk = await db.rawQuery(
          'SELECT substr(image, ?, ?) AS image_chunk FROM rooms WHERE id = ?',
          [offset, 512 * 1024, roomId],
        );
        imageBuffer.write(chunk.first['image_chunk'] as String? ?? '');
      }

      final encoded = imageBuffer.toString();
      dynamic decoded;
      try {
        decoded = jsonDecode(encoded);
      } on FormatException {
        decoded = encoded;
      }
      final imageValues = decoded is List ? decoded : [decoded];
      final storedPaths = <String>[];
      for (var index = 0; index < imageValues.length; index++) {
        final value = imageValues[index];
        if (value is! String || value.isEmpty) continue;
        try {
          final bytes = base64Decode(value);
          final imageFile = File(
            p.join(imagesDirectory.path, 'room_${roomId}_$index.jpg'),
          );
          await imageFile.writeAsBytes(bytes, flush: true);
          storedPaths.add(imageFile.path);
        } on FormatException {
          storedPaths.add(value);
        }
      }
      await db.update(
        'rooms',
        {'image': jsonEncode(storedPaths)},
        where: 'id = ?',
        whereArgs: [roomId],
      );
    }
  }

  Future<void> _createViewingBlackoutsTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS viewing_blackouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        landlord_id INTEGER NOT NULL,
        rule_type TEXT NOT NULL,
        rule_value TEXT NOT NULL,
        UNIQUE (landlord_id, rule_type, rule_value)
      )
    ''');
  }

  Future<void> _addColumnIfMissing(
    DatabaseExecutor db,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    if (columns.any((item) => item['name'] == column)) return;
    await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
  }

  Future<void> _createNewAccountFeatures(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS superadmins (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        password TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS guest_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guest_code TEXT UNIQUE,
        name TEXT NOT NULL,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS guest_viewing_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        guest_id INTEGER NOT NULL,
        landlord_id INTEGER NOT NULL,
        room_id INTEGER NOT NULL,
        requested_date TEXT NOT NULL,
        requested_time TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'Pending',
        tenant_code TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createAccountTables(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE landlords (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL COLLATE NOCASE UNIQUE,
        password TEXT NOT NULL,
        landlord_code TEXT UNIQUE,
        contact_number TEXT,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE tenants (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL COLLATE NOCASE UNIQUE,
        password TEXT NOT NULL,
        tenant_code TEXT UNIQUE,
        contact_number TEXT,
        activated INTEGER NOT NULL DEFAULT 1,
        account_deleted INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE account_id_sequence (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        next_id INTEGER NOT NULL
      )
    ''');
    await db.insert('account_id_sequence', {'id': 1, 'next_id': 1});
    await _createUsersCompatibilityView(db);
  }

  Future<void> _createUsersCompatibilityView(DatabaseExecutor db) async {
    await db.execute('DROP VIEW IF EXISTS users');
    await db.execute('''
      CREATE VIEW users AS
      SELECT id, name, email, password, 'Landlord' AS role, created_at,
        landlord_code, 1 AS activated, NULL AS tenant_code,
        contact_number, 0 AS account_deleted
      FROM landlords
      UNION ALL
      SELECT id, name, email, password, 'Tenant' AS role, created_at,
        tenant_code AS landlord_code, activated, tenant_code, contact_number,
        account_deleted
      FROM tenants
    ''');
  }

  Future<void> _migrateUsersToSeparateTables(Database db) async {
    final tableCheck = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'users'",
    );
    if (tableCheck.isNotEmpty) {
      await db.execute('ALTER TABLE users RENAME TO users_legacy_migration');
      await _createAccountTables(db);
      final oldUsers = await db.query('users_legacy_migration');
      var maxId = 0;
      for (final user in oldUsers) {
        final id = (user['id'] as num).toInt();
        if (id > maxId) maxId = id;
        final role = (user['role'] ?? '').toString().toLowerCase();
        final table = role == 'landlord' ? 'landlords' : 'tenants';
        await db.insert(table, {
          'id': id,
          'name': user['name'],
          'email': user['email'],
          'password': user['password'],
          if (role == 'landlord') 'landlord_code': null,
          'created_at': user['created_at'] ?? DateTime.now().toIso8601String(),
        });
      }
      await db.execute('DROP TABLE users_legacy_migration');
      await db.update('account_id_sequence', {'next_id': maxId + 1},
          where: 'id = 1');
    } else {
      final landlordsCheck = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'landlords'",
      );
      if (landlordsCheck.isEmpty) {
        await _createAccountTables(db);
      } else {
        await _createUsersCompatibilityView(db);
      }
    }
  }

  // ==========================================================
  // USERS
  // ==========================================================

  Future<int> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final db = await database;
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedRole = role.trim().toLowerCase();
    if (normalizedRole != 'tenant') {
      throw StateError('INVALID_ROLE');
    }

    final existing = await db.rawQuery(
      'SELECT id FROM users WHERE LOWER(email) = ? LIMIT 1',
      [normalizedEmail],
    );
    if (existing.isNotEmpty) throw StateError('EMAIL_ALREADY_EXISTS');

    return db.transaction((txn) async {
      final sequenceRows = await txn.query(
        'account_id_sequence',
        where: 'id = 1',
        limit: 1,
      );
      final id = (sequenceRows.first['next_id'] as num).toInt();
      await txn.update('account_id_sequence', {'next_id': id + 1},
          where: 'id = 1');
      final table = normalizedRole == 'landlord' ? 'landlords' : 'tenants';
      await txn.insert(table, {
        'id': id,
        'name': name.trim(),
        'email': normalizedEmail,
        'password': password,
        'created_at': DateTime.now().toIso8601String(),
      });
      return id;
    });
  }

  Future<Map<String, dynamic>?> login({
    required String identifier,
    required String password,
    required String role,
  }) async {
    final db = await database;

    final normalizedEmail = identifier.trim().toLowerCase();
    final normalizedRole = role.trim().toLowerCase();

    final result = await db.rawQuery('''
      SELECT *
      FROM users
      WHERE (LOWER(email) = ? OR UPPER(landlord_code) = ?)
        AND password = ?
        AND LOWER(role) = ?
        AND (LOWER(role) != 'landlord' OR landlord_code IS NOT NULL)
        AND (LOWER(role) != 'tenant' OR activated = 1)
        AND (LOWER(role) != 'tenant' OR account_deleted = 0)
      LIMIT 1
    ''', [
      normalizedEmail,
      normalizedRole == 'tenant'
          ? _shortAccountCode(identifier, 'T')
          : identifier.trim().toUpperCase(),
      password,
      normalizedRole
    ]);

    if (result.isEmpty) return null;

    return result.first;
  }

  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<bool> hasSuperadmin() async {
    final db = await database;
    final result = await db.query('superadmins', limit: 1);
    return result.isNotEmpty;
  }

  Future<void> createSuperadmin(String password) async {
    final db = await database;
    if (await hasSuperadmin()) throw StateError('SUPERADMIN_ALREADY_EXISTS');
    await db.insert('superadmins', {'id': 1, 'password': password});
  }

  Future<bool> loginSuperadmin(String password) async {
    final db = await database;
    final result = await db.query(
      'superadmins',
      where: 'id = 1 AND password = ?',
      whereArgs: [password],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> getProvisionedLandlordCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM landlords WHERE landlord_code IS NOT NULL',
    );
    return (result.first['total'] as int?) ?? 0;
  }

  Future<Map<String, dynamic>> provisionLandlord({
    required String name,
    required String email,
    required String contactNumber,
    required String password,
    required String apartmentName,
    required String location,
    required int totalFloors,
    required int totalRooms,
    required double monthlyRent,
    required bool petFriendly,
    required String priceTier,
  }) async {
    if (totalFloors < 1 ||
        totalRooms < 1 ||
        !monthlyRent.isFinite ||
        monthlyRent <= 0) {
      throw ArgumentError('Invalid apartment details.');
    }
    final db = await database;
    return db.transaction((txn) async {
      final countRows = await txn.rawQuery(
        'SELECT COUNT(*) AS total FROM landlords WHERE landlord_code IS NOT NULL',
      );
      final count = (countRows.first['total'] as int?) ?? 0;
      if (count >= 2) throw StateError('LANDLORD_LIMIT_REACHED');
      final emailRows = await txn.query(
        'users',
        columns: ['id'],
        where: 'LOWER(email) = ?',
        whereArgs: [email.trim().toLowerCase()],
        limit: 1,
      );
      if (emailRows.isNotEmpty) throw StateError('EMAIL_ALREADY_EXISTS');
      final sequence = await txn.query('account_id_sequence', where: 'id = 1');
      final id = (sequence.first['next_id'] as num).toInt();
      final landlordCode = 'L-${(count + 1).toString().padLeft(3, '0')}';
      await txn.update(
        'account_id_sequence',
        {'next_id': id + 1},
        where: 'id = 1',
      );
      await txn.insert('landlords', {
        'id': id,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'landlord_code': landlordCode,
        'contact_number': contactNumber.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
      await txn.insert('landlord_apartments', {
        'landlord_id': id,
        'apartment_name': apartmentName.trim(),
        'location': location.trim(),
        'total_floors': totalFloors,
        'total_rooms': totalRooms,
        'monthly_rent': monthlyRent,
        'pet_friendly': petFriendly ? 1 : 0,
        'price_tier': priceTier,
        'created_at': DateTime.now().toIso8601String(),
      });
      return {'id': id, 'landlord_code': landlordCode};
    });
  }

  Future<Map<String, dynamic>?> loginGuest({
    required String guestCode,
    required String password,
  }) async {
    final db = await database;
    final rows = await db.query(
      'guest_accounts',
      where: 'guest_code = ? AND password = ?',
      whereArgs: [_shortAccountCode(guestCode, 'G'), password],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  String _shortAccountCode(String value, String prefix) {
    final normalized = value.trim().toUpperCase();
    final codePrefix = '$prefix-';
    if (!normalized.startsWith(codePrefix)) return normalized;
    final id = int.tryParse(normalized.substring(codePrefix.length));
    if (id == null) return normalized;
    return '$prefix-${id.toString().padLeft(3, '0')}';
  }

  Future<Map<String, dynamic>> createGuestViewingRequest({
    required String name,
    required String password,
    required int roomId,
    required String date,
    required String time,
  }) async {
    final db = await database;
    final request = await db.transaction((txn) async {
      final roomRows = await txn.query(
        'rooms',
        columns: ['landlord_id', 'name'],
        where: 'id = ? AND available = 1',
        whereArgs: [roomId],
        limit: 1,
      );
      if (roomRows.isEmpty) throw StateError('ROOM_NOT_AVAILABLE');
      final landlordId = roomRows.first['landlord_id'] as int;
      await _validateViewingSlot(
        executor: txn,
        landlordId: landlordId,
        date: date,
        time: time,
      );
      final guestId = await txn.insert('guest_accounts', {
        'name': name.trim(),
        'password': password,
        'created_at': DateTime.now().toIso8601String(),
      });
      final guestCode = 'G-${guestId.toString().padLeft(3, '0')}';
      await txn.update(
        'guest_accounts',
        {'guest_code': guestCode},
        where: 'id = ?',
        whereArgs: [guestId],
      );
      await txn.insert('guest_viewing_requests', {
        'guest_id': guestId,
        'landlord_id': landlordId,
        'room_id': roomId,
        'requested_date': date,
        'requested_time': time,
        'status': 'Pending',
        'created_at': DateTime.now().toIso8601String(),
      });
      return {
        'id': guestId,
        'guest_code': guestCode,
        'landlord_id': landlordId,
      };
    });
    await addNotification(
      userId: request['landlord_id'] as int,
      title: 'New Guest Viewing Request',
      message: '${name.trim()} requested to view a unit on $date at $time.',
    );
    return request;
  }

  Future<List<Map<String, dynamic>>> getGuestViewingRequests(
      int guestId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT guest_viewing_requests.*, rooms.name AS room_name,
             rooms.location AS room_location, rooms.price AS room_price,
             rooms.floor AS room_floor
      FROM guest_viewing_requests
      INNER JOIN rooms ON rooms.id = guest_viewing_requests.room_id
      WHERE guest_viewing_requests.guest_id = ?
      ORDER BY guest_viewing_requests.id DESC
    ''', [guestId]);
  }

  Future<List<Map<String, dynamic>>> getLandlordGuestViewingRequests(
      int landlordId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT guest_viewing_requests.*, guest_accounts.name AS guest_name,
             guest_accounts.guest_code, rooms.name AS room_name,
             rooms.price AS room_price, rooms.location AS room_location,
             rooms.floor AS room_floor, rooms.bedrooms AS room_bedrooms,
             rooms.bathrooms AS room_bathrooms
      FROM guest_viewing_requests
      INNER JOIN guest_accounts ON guest_accounts.id = guest_viewing_requests.guest_id
      INNER JOIN rooms ON rooms.id = guest_viewing_requests.room_id
      WHERE guest_viewing_requests.landlord_id = ?
      ORDER BY guest_viewing_requests.id DESC
    ''', [landlordId]);
  }

  Future<int> updateGuestViewingStatus(int requestId, String status) async {
    final db = await database;
    final changed = await db.update(
      'guest_viewing_requests',
      {'status': status},
      where: 'id = ?',
      whereArgs: [requestId],
    );
    return changed;
  }

  DateTime _addMonths(DateTime date, int months) {
    final monthIndex = date.year * 12 + date.month - 1 + months;
    final year = monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, date.day > lastDay ? lastDay : date.day);
  }

  String _dateOnly(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>> acceptGuestAsTenant({
    required int requestId,
    required int landlordId,
    required int durationMonths,
    required double monthlyRent,
    required double securityDeposit,
    required DateTime firstDueDate,
    String? contractImage,
  }) async {
    if (durationMonths < 1 ||
        !monthlyRent.isFinite ||
        monthlyRent <= 0 ||
        !securityDeposit.isFinite ||
        securityDeposit < 0) {
      throw ArgumentError('Invalid rental financial terms.');
    }
    if (!(monthlyRent * durationMonths).isFinite) {
      throw ArgumentError('Contract total is too large.');
    }
    final db = await database;
    final tenant = await db.transaction((txn) async {
      final rows = await txn.rawQuery('''
        SELECT guest_viewing_requests.*, guest_accounts.name AS guest_name,
               rooms.name AS room_name, rooms.price AS room_price,
               rooms.available AS room_available, rooms.location AS room_location,
               rooms.floor AS room_floor, rooms.bedrooms AS room_bedrooms,
               rooms.bathrooms AS room_bathrooms
        FROM guest_viewing_requests
        INNER JOIN guest_accounts ON guest_accounts.id = guest_viewing_requests.guest_id
        INNER JOIN rooms ON rooms.id = guest_viewing_requests.room_id
        WHERE guest_viewing_requests.id = ?
          AND guest_viewing_requests.landlord_id = ?
        LIMIT 1
      ''', [requestId, landlordId]);
      if (rows.isEmpty) throw StateError('GUEST_REQUEST_NOT_FOUND');
      final request = rows.first;
      if (request['status'] != 'Approved') {
        throw StateError('VIEWING_REQUEST_NOT_APPROVED');
      }
      if ((request['room_available'] as int? ?? 0) != 1) {
        throw StateError('ROOM_NOT_AVAILABLE');
      }
      final active = await txn.query(
        'contracts',
        where: 'room_id = ? AND status = ?',
        whereArgs: [request['room_id'], 'Active'],
        limit: 1,
      );
      if (active.isNotEmpty) throw StateError('ROOM_ALREADY_OCCUPIED');
      final sequence = await txn.query('account_id_sequence', where: 'id = 1');
      final tenantId = (sequence.first['next_id'] as num).toInt();
      final tenantCode = 'T-${tenantId.toString().padLeft(3, '0')}';
      await txn.update(
        'account_id_sequence',
        {'next_id': tenantId + 1},
        where: 'id = 1',
      );
      await txn.insert('tenants', {
        'id': tenantId,
        'name': request['guest_name'],
        'email': 'pending-$tenantCode@rentahanan.local',
        'password': 'activation-required',
        'tenant_code': tenantCode,
        'activated': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
      final startDate = DateTime.now();
      final contractEndDate = _addMonths(startDate, durationMonths);
      final contractId = await txn.insert('contracts', {
        'tenant_id': tenantId,
        'landlord_id': request['landlord_id'],
        'room_id': request['room_id'],
        'start_date': startDate.toIso8601String(),
        'end_date': null,
        'contract_end_date': contractEndDate.toIso8601String(),
        'monthly_rent': monthlyRent,
        'duration_months': durationMonths,
        'payment_terms': 'Monthly',
        'security_deposit': securityDeposit,
        'advance_amount': monthlyRent,
        'total_contract_amount': monthlyRent * durationMonths,
        'contract_image': contractImage,
        'status': 'Active',
      });
      final dueDate = DateTime(
        firstDueDate.year,
        firstDueDate.month,
        firstDueDate.day,
      );
      Future<void> insertPayment({
        required double amount,
        required String type,
        required DateTime due,
      }) async {
        await txn.insert('payments', {
          'tenant_id': tenantId,
          'landlord_id': landlordId,
          'contract_id': contractId,
          'amount': amount,
          'payment_type': type,
          'due_date': _dateOnly(due),
          'status': 'Pending',
        });
      }

      if (securityDeposit > 0) {
        await insertPayment(
          amount: securityDeposit,
          type: 'Security Deposit',
          due: dueDate,
        );
      }
      await insertPayment(
        amount: monthlyRent,
        type: 'Advance Rent',
        due: dueDate,
      );
      for (var month = 1; month < durationMonths; month++) {
        await insertPayment(
          amount: monthlyRent,
          type: 'Monthly Rent',
          due: _addMonths(dueDate, month),
        );
      }
      await txn.update(
        'rooms',
        {'available': 0},
        where: 'id = ?',
        whereArgs: [request['room_id']],
      );
      await txn.update(
        'guest_viewing_requests',
        {'status': 'Accepted as Tenant', 'tenant_code': tenantCode},
        where: 'id = ?',
        whereArgs: [requestId],
      );
      return {
        'tenant_id': tenantId,
        'tenant_code': tenantCode,
        'guest_id': request['guest_id'],
        'tenant_name': request['guest_name'],
        'room_name': request['room_name'],
        'room_location': request['room_location'],
        'room_floor': request['room_floor'],
        'room_bedrooms': request['room_bedrooms'],
        'room_bathrooms': request['room_bathrooms'],
        'monthly_rent': monthlyRent,
        'duration_months': durationMonths,
        'security_deposit': securityDeposit,
        'advance_amount': monthlyRent,
        'total_contract_amount': monthlyRent * durationMonths,
        'first_due_date': _dateOnly(dueDate),
      };
    });
    await addNotification(
      userId: tenant['tenant_id'] as int,
      title: 'Rental Contract Confirmed',
      message:
          'Your contract for ${tenant['room_name']} is active. Your security deposit and advance rent are recorded as due.',
    );
    return tenant;
  }

  Future<void> deleteGuestAccount(int guestId) async {
    final db = await database;
    await db.delete('guest_accounts', where: 'id = ?', whereArgs: [guestId]);
  }

  Future<bool> activateTenant({
    required String tenantCode,
    required String name,
    required String email,
    required String contactNumber,
    required String password,
  }) async {
    final db = await database;
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email.trim())) {
      throw StateError('INVALID_EMAIL');
    }
    if (!RegExp(r'^09\d{9}$').hasMatch(contactNumber.trim())) {
      throw StateError('INVALID_PHONE_NUMBER');
    }
    final existingEmail = await db.query(
      'users',
      columns: ['id'],
      where: 'LOWER(email) = ?',
      whereArgs: [email.trim().toLowerCase()],
      limit: 1,
    );
    if (existingEmail.isNotEmpty) throw StateError('EMAIL_ALREADY_EXISTS');
    final changed = await db.update(
      'tenants',
      {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'contact_number': contactNumber.trim(),
        'password': password,
        'activated': 1,
      },
      where: 'tenant_code = ? AND activated = 0',
      whereArgs: [_shortAccountCode(tenantCode, 'T')],
    );
    return changed > 0;
  }

  Future<int> deleteTenantAccount(int tenantId) async {
    await _expireContracts();
    final db = await database;
    final activeContracts = await db.query(
      'contracts',
      columns: ['id'],
      where: 'tenant_id = ? AND status = ?',
      whereArgs: [tenantId, 'Active'],
      limit: 1,
    );
    if (activeContracts.isNotEmpty) {
      throw StateError('ACTIVE_CONTRACT_MUST_END_FIRST');
    }

    return db.update(
      'tenants',
      {
        'name': 'Deleted Tenant',
        'email': 'deleted-$tenantId@rentahanan.local',
        'password': 'ACCOUNT_DELETED',
        'contact_number': null,
        'account_deleted': 1,
      },
      where: 'id = ? AND account_deleted = 0',
      whereArgs: [tenantId],
    );
  }

  Future<List<Map<String, dynamic>>> getLandlordActiveTenants(
      int landlordId) async {
    await _expireContracts();
    final db = await database;
    return db.rawQuery('''
      SELECT contracts.id AS contract_id,
             tenants.id AS tenant_id, tenants.tenant_code, tenants.name,
             tenants.email, tenants.contact_number, rooms.id AS room_id,
             rooms.name AS room_name, rooms.floor, rooms.location,
             rooms.bedrooms, rooms.bathrooms, contracts.monthly_rent,
             contracts.start_date, contracts.contract_end_date,
             contracts.duration_months, contracts.payment_terms,
             contracts.security_deposit, contracts.advance_amount,
             contracts.total_contract_amount
      FROM contracts
      INNER JOIN tenants ON tenants.id = contracts.tenant_id
      INNER JOIN rooms ON rooms.id = contracts.room_id
      WHERE contracts.landlord_id = ? AND contracts.status = 'Active'
      ORDER BY tenants.name COLLATE NOCASE
    ''', [landlordId]);
  }

  // ==========================================================
  // LANDLORD APARTMENT DETAILS
  // ==========================================================

  Future<void> createLandlordApartment({
    required int landlordId,
    required String apartmentName,
    required String location,
    required int totalFloors,
    required int totalRooms,
    double monthlyRent = 0,
    required bool petFriendly,
    required String priceTier,
  }) async {
    final db = await database;
    await db.insert(
      'landlord_apartments',
      {
        'landlord_id': landlordId,
        'apartment_name': apartmentName.trim(),
        'location': location.trim(),
        'total_floors': totalFloors,
        'total_rooms': totalRooms,
        'monthly_rent': monthlyRent,
        'pet_friendly': petFriendly ? 1 : 0,
        'price_tier': priceTier,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getLandlordApartment(int landlordId) async {
    final db = await database;
    final result = await db.query(
      'landlord_apartments',
      where: 'landlord_id = ?',
      whereArgs: [landlordId],
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  // ==========================================================
  // ROOMS
  // ==========================================================

  Future<List<Map<String, dynamic>>> getAvailableRooms() async {
    final db = await database;

    // Only show available properties linked to a real landlord account.
    // This also hides orphaned or legacy demo rows from the tenant dashboard.
    return await db.rawQuery('''
      SELECT rooms.*
      FROM rooms
      INNER JOIN users ON users.id = rooms.landlord_id
      WHERE rooms.available = 1
        AND LOWER(users.role) = 'landlord'
        AND LOWER(TRIM(rooms.name)) NOT IN (
          'cozy studio room', 'modern solo room', 'family apartment',
          'room 201', 'room 101', 'room 102'
        )
      ORDER BY rooms.id DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getLandlordRooms(int landlordId) async {
    await _expireContracts();
    final db = await database;

    return await db.rawQuery('''
      SELECT rooms.*,
        (SELECT contracts.id FROM contracts
          WHERE contracts.room_id = rooms.id AND contracts.status = 'Active'
          ORDER BY contracts.id DESC LIMIT 1) AS active_contract_id,
        (SELECT contracts.contract_end_date FROM contracts
          WHERE contracts.room_id = rooms.id AND contracts.status = 'Active'
          ORDER BY contracts.id DESC LIMIT 1) AS contract_end_date,
        (SELECT tenants.name FROM contracts
          INNER JOIN tenants ON tenants.id = contracts.tenant_id
          WHERE contracts.room_id = rooms.id AND contracts.status = 'Active'
          ORDER BY contracts.id DESC LIMIT 1) AS tenant_name,
        (SELECT tenants.tenant_code FROM contracts
          INNER JOIN tenants ON tenants.id = contracts.tenant_id
          WHERE contracts.room_id = rooms.id AND contracts.status = 'Active'
          ORDER BY contracts.id DESC LIMIT 1) AS tenant_code,
        (SELECT tenants.email FROM contracts
          INNER JOIN tenants ON tenants.id = contracts.tenant_id
          WHERE contracts.room_id = rooms.id AND contracts.status = 'Active'
          ORDER BY contracts.id DESC LIMIT 1) AS tenant_email,
        (SELECT tenants.contact_number FROM contracts
          INNER JOIN tenants ON tenants.id = contracts.tenant_id
          WHERE contracts.room_id = rooms.id AND contracts.status = 'Active'
          ORDER BY contracts.id DESC LIMIT 1) AS tenant_contact
      FROM rooms
      WHERE rooms.landlord_id = ?
      ORDER BY rooms.id DESC
    ''', [landlordId]);
  }

  Future<int> addRoom({
    required int landlordId,
    required String name,
    required int floor,
    required String location,
    required String description,
    required double price,
    required int bedrooms,
    required int bathrooms,
    String? image,
  }) async {
    final db = await database;

    return await db.insert('rooms', {
      'landlord_id': landlordId,
      'name': name,
      'floor': floor,
      'location': location,
      'description': description,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'image': image ?? '',
      'available': 1,
    });
  }

  Future<String> storeRoomImage({
    required int landlordId,
    required String sourcePath,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException(
          'Selected photo is no longer available.', sourcePath);
    }
    if (await source.length() == 0) {
      throw FileSystemException('Selected photo is empty.', sourcePath);
    }

    final directory =
        Directory(p.join(await getDatabasesPath(), 'room_images'));
    await directory.create(recursive: true);
    final extension = p.extension(sourcePath);
    final filename =
        'room_${landlordId}_${DateTime.now().microsecondsSinceEpoch}${extension.isEmpty ? '.jpg' : extension}';
    final destination = File(p.join(directory.path, filename));
    await source.copy(destination.path);
    return destination.path;
  }

  Future<int> updateRoom({
    required int roomId,
    required int landlordId,
    required String name,
    required int floor,
    required String location,
    required String description,
    required double price,
    required int bedrooms,
    required int bathrooms,
    String? image,
  }) async {
    final db = await database;
    return db.update(
      'rooms',
      {
        'name': name,
        'floor': floor,
        'location': location,
        'description': description,
        'price': price,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'image': image ?? '',
      },
      where: 'id = ? AND landlord_id = ?',
      whereArgs: [roomId, landlordId],
    );
  }

  /// Deletes a property only when it belongs to the signed-in landlord.
  Future<int> deleteRoom({
    required int roomId,
    required int landlordId,
  }) async {
    final db = await database;
    return db.delete(
      'rooms',
      where: 'id = ? AND landlord_id = ?',
      whereArgs: [roomId, landlordId],
    );
  }

  Future<int> updateRoomAvailability(
    int roomId,
    bool available,
  ) async {
    final db = await database;

    return await db.update(
      'rooms',
      {'available': available ? 1 : 0},
      where: 'id = ?',
      whereArgs: [roomId],
    );
  }

  Future<List<Map<String, dynamic>>> getViewingBlackouts(int landlordId) async {
    final db = await database;
    return db.query(
      'viewing_blackouts',
      where: 'landlord_id = ?',
      whereArgs: [landlordId],
      orderBy: 'rule_type, rule_value',
    );
  }

  Future<int> addViewingBlackout({
    required int landlordId,
    required String ruleType,
    required String ruleValue,
  }) async {
    if (!const {'weekday', 'month', 'date', 'time'}.contains(ruleType)) {
      throw ArgumentError.value(ruleType, 'ruleType');
    }
    final db = await database;
    return db.insert(
      'viewing_blackouts',
      {
        'landlord_id': landlordId,
        'rule_type': ruleType,
        'rule_value': ruleValue,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<int> removeViewingBlackout({
    required int landlordId,
    required int blackoutId,
  }) async {
    final db = await database;
    return db.delete(
      'viewing_blackouts',
      where: 'id = ? AND landlord_id = ?',
      whereArgs: [blackoutId, landlordId],
    );
  }

  DateTime? _parseViewingDate(String value) {
    final isoDate = DateTime.tryParse(value);
    if (isoDate != null) return isoDate;
    final parts = value.split('/');
    if (parts.length != 3) return null;
    final month = int.tryParse(parts[0]);
    final day = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (month == null || day == null || year == null) return null;
    final parsed = DateTime(year, month, day);
    if (parsed.year != year || parsed.month != month || parsed.day != day) {
      return null;
    }
    return parsed;
  }

  int? _parseViewingTime(String value) {
    final match = RegExp(
      r'^\s*(\d{1,2}):(\d{2})\s*(AM|PM)?\s*$',
      caseSensitive: false,
    ).firstMatch(value);
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    final period = match.group(3)?.toUpperCase();
    if (hour == null || minute == null || minute > 59) {
      return null;
    }
    if (period == null && hour > 23) return null;
    if (period != null && (hour < 1 || hour > 12)) return null;
    final hour24 =
        period == null ? hour : (hour % 12) + (period == 'PM' ? 12 : 0);
    return hour24 * 60 + minute;
  }

  bool _isViewingTimeAllowed(String value) {
    final minutesAfterMidnight = _parseViewingTime(value);
    return minutesAfterMidnight != null &&
        minutesAfterMidnight >= 8 * 60 &&
        minutesAfterMidnight <= 18 * 60;
  }

  Future<void> _validateViewingSlot({
    required DatabaseExecutor executor,
    required int landlordId,
    required String date,
    required String time,
  }) async {
    final parsedDate = _parseViewingDate(date);
    if (parsedDate == null) throw StateError('INVALID_VIEWING_DATE');
    if (!_isViewingTimeAllowed(time)) {
      throw StateError('VIEWING_TIME_OUT_OF_RANGE');
    }
    final requestedTime = _parseViewingTime(time)!;

    final dateValue = _dateOnly(parsedDate);
    final rules = await executor.query(
      'viewing_blackouts',
      columns: ['rule_type', 'rule_value'],
      where: 'landlord_id = ?',
      whereArgs: [landlordId],
    );
    for (final rule in rules) {
      final type = rule['rule_type'];
      final value = rule['rule_value'].toString();
      if ((type == 'date' && value == dateValue) ||
          (type == 'month' &&
              value ==
                  '${parsedDate.year.toString().padLeft(4, '0')}-${parsedDate.month.toString().padLeft(2, '0')}') ||
          (type == 'weekday' && int.tryParse(value) == parsedDate.weekday)) {
        throw StateError('VIEWING_DAY_BLOCKED');
      }
      if (type == 'time' && _parseViewingTime(value) == requestedTime) {
        throw StateError('VIEWING_TIME_BLOCKED');
      }
    }
  }

  // ==========================================================
  // VIEWING REQUESTS
  // ==========================================================

  Future<int> requestViewing({
    required int tenantId,
    required int landlordId,
    required int roomId,
    required String date,
    required String time,
    String message = '',
  }) async {
    final db = await database;
    final requestId = await db.transaction((txn) async {
      final rooms = await txn.query(
        'rooms',
        columns: ['landlord_id', 'available'],
        where: 'id = ?',
        whereArgs: [roomId],
        limit: 1,
      );
      if (rooms.isEmpty ||
          (rooms.first['landlord_id'] as num).toInt() != landlordId ||
          (rooms.first['available'] as num?)?.toInt() != 1) {
        throw StateError('ROOM_NOT_AVAILABLE');
      }
      await _validateViewingSlot(
        executor: txn,
        landlordId: landlordId,
        date: date,
        time: time,
      );
      return txn.insert('viewing_requests', {
        'tenant_id': tenantId,
        'landlord_id': landlordId,
        'room_id': roomId,
        'requested_date': date,
        'requested_time': time,
        'message': message,
        'status': 'Pending',
      });
    });

    await addNotification(
      userId: landlordId,
      title: 'New Viewing Request',
      message: 'A tenant requested to view a room on $date at $time.',
    );

    return requestId;
  }

  Future<List<Map<String, dynamic>>> getTenantViewingRequests(
      int tenantId) async {
    final db = await database;

    return await db.rawQuery('''
      SELECT viewing_requests.*, rooms.name AS room_name
      FROM viewing_requests
      INNER JOIN rooms ON rooms.id = viewing_requests.room_id
      WHERE viewing_requests.tenant_id = ?
      ORDER BY viewing_requests.id DESC
    ''', [tenantId]);
  }

  Future<List<Map<String, dynamic>>> getLandlordViewingRequests(
      int landlordId) async {
    final db = await database;

    return await db.rawQuery('''
      SELECT viewing_requests.*, 
             rooms.name AS room_name, rooms.price AS room_price,
             users.name AS tenant_name
      FROM viewing_requests
      INNER JOIN rooms ON rooms.id = viewing_requests.room_id
      INNER JOIN users ON users.id = viewing_requests.tenant_id
      WHERE viewing_requests.landlord_id = ?
      ORDER BY viewing_requests.id DESC
    ''', [landlordId]);
  }

  Future<void> updateViewingRequest(
    int requestId,
    String status,
  ) async {
    final db = await database;

    final request = await db.query(
      'viewing_requests',
      where: 'id = ?',
      whereArgs: [requestId],
      limit: 1,
    );

    if (request.isEmpty) return;

    await db.update(
      'viewing_requests',
      {'status': status},
      where: 'id = ?',
      whereArgs: [requestId],
    );

    final tenantId = request.first['tenant_id'] as int;
    final roomId = request.first['room_id'] as int;
    final roomRows = await db.query('rooms',
        columns: ['name'], where: 'id = ?', whereArgs: [roomId], limit: 1);
    final roomName = roomRows.isEmpty
        ? 'your requested unit'
        : roomRows.first['name'].toString();

    await addNotification(
      userId: tenantId,
      title: 'Viewing Request $status',
      message:
          'Your viewing request for $roomName has been ${status.toLowerCase()}.',
    );
  }

  /// Finalizes an approved viewing as a rental and activates the tenant.
  /// Approval of a viewing alone does not create a tenancy.
  Future<void> activateTenantFromViewingRequest(
    int requestId, {
    String? contractImage,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      final rows = await txn.rawQuery('''
        SELECT viewing_requests.*, rooms.price AS room_price,
               rooms.available AS room_available
        FROM viewing_requests
        INNER JOIN rooms ON rooms.id = viewing_requests.room_id
        WHERE viewing_requests.id = ?
        LIMIT 1
      ''', [requestId]);
      if (rows.isEmpty) throw StateError('VIEWING_REQUEST_NOT_FOUND');
      final request = rows.first;
      if (request['status'] != 'Approved') {
        throw StateError('VIEWING_REQUEST_NOT_APPROVED');
      }
      if ((request['room_available'] as int? ?? 0) != 1) {
        throw StateError('ROOM_NOT_AVAILABLE');
      }
      final roomId = request['room_id'] as int;
      final tenantId = request['tenant_id'] as int;
      final landlordId = request['landlord_id'] as int;
      final active = await txn.query(
        'contracts',
        where: 'room_id = ? AND status = ?',
        whereArgs: [roomId, 'Active'],
        limit: 1,
      );
      if (active.isNotEmpty) throw StateError('ROOM_ALREADY_OCCUPIED');
      await txn.insert('contracts', {
        'tenant_id': tenantId,
        'landlord_id': landlordId,
        'room_id': roomId,
        'start_date': DateTime.now().toIso8601String(),
        'end_date': null,
        'monthly_rent': (request['room_price'] as num).toDouble(),
        'contract_image': contractImage,
        'status': 'Active',
      });
      await txn.update('rooms', {'available': 0},
          where: 'id = ?', whereArgs: [roomId]);
      await txn.update('viewing_requests', {'status': 'Confirmed'},
          where: 'id = ?', whereArgs: [requestId]);
    });
    final request = (await db.query('viewing_requests',
            where: 'id = ?', whereArgs: [requestId], limit: 1))
        .first;
    await addNotification(
      userId: request['tenant_id'] as int,
      title: 'You are now an active tenant',
      message:
          'Your rental has been confirmed. Your room is now assigned to you.',
    );
  }

  // ==========================================================
  // VIEWING REQUEST DETAILS (for contract preview)
  // ==========================================================

  /// Returns the full request + room + tenant info needed to show the
  /// contract preview dialog before the landlord confirms a tenant.
  Future<Map<String, dynamic>?> getViewingRequestDetails(int requestId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        viewing_requests.*,
        rooms.name       AS room_name,
        rooms.price      AS room_price,
        rooms.location   AS room_location,
        rooms.floor      AS room_floor,
        rooms.bedrooms   AS room_bedrooms,
        rooms.bathrooms  AS room_bathrooms,
        users.name       AS tenant_name,
        users.email      AS tenant_email
      FROM viewing_requests
      INNER JOIN rooms  ON rooms.id  = viewing_requests.room_id
      INNER JOIN users  ON users.id  = viewing_requests.tenant_id
      WHERE viewing_requests.id = ?
      LIMIT 1
    ''', [requestId]);
    return result.isEmpty ? null : result.first;
  }

  // ==========================================================
  // MESSAGES
  // ==========================================================

  Future<int> sendMessage({
    required int senderId,
    required int receiverId,
    required String message,
    int? roomId,
  }) async {
    final db = await database;
    final senderRows = await db.query(
      'users',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [senderId],
      limit: 1,
    );
    final roomRows = roomId == null
        ? <Map<String, Object?>>[]
        : await db.query(
            'rooms',
            columns: ['name'],
            where: 'id = ?',
            whereArgs: [roomId],
            limit: 1,
          );
    final senderName =
        senderRows.isEmpty ? 'A user' : senderRows.first['name'].toString();
    final roomName =
        roomRows.isEmpty ? null : roomRows.first['name'].toString();

    final id = await db.insert('messages', {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
      'room_id': roomId,
      'is_read': 0,
    });

    await addNotification(
      userId: receiverId,
      title: 'New Message',
      message: roomName == null
          ? '$senderName: $message'
          : '$senderName • $roomName: $message',
    );

    return id;
  }

  Future<List<Map<String, dynamic>>> getConversation(
    int user1,
    int user2,
  ) async {
    final db = await database;
    await db.update(
      'messages',
      {'is_read': 1},
      where: 'sender_id = ? AND receiver_id = ? AND is_read = 0',
      whereArgs: [user2, user1],
    );

    return await db.rawQuery('''
      SELECT messages.*, users.name AS sender_name
      FROM messages
      INNER JOIN users ON users.id = messages.sender_id
      WHERE
      (sender_id = ? AND receiver_id = ?)
      OR
      (sender_id = ? AND receiver_id = ?)
      ORDER BY messages.id ASC
    ''', [user1, user2, user2, user1]);
  }

  Future<List<Map<String, dynamic>>> getLandlordMessageThreads(
    int landlordId,
  ) async {
    final db = await database;
    final tenantThreads = await db.rawQuery('''
      WITH thread_summary AS (
        SELECT
          CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END AS contact_id,
          MAX(id) AS latest_id,
          SUM(CASE WHEN receiver_id = ? AND is_read = 0 THEN 1 ELSE 0 END) AS unread_count
        FROM messages
        WHERE sender_id = ? OR receiver_id = ?
        GROUP BY contact_id
      )
      SELECT 'tenant' AS participant_type,
             users.id AS participant_id,
             users.name AS participant_name,
             messages.room_id AS room_id,
             COALESCE(rooms.name, (
               SELECT rooms.name
               FROM contracts
               INNER JOIN rooms ON rooms.id = contracts.room_id
               WHERE contracts.tenant_id = users.id
                 AND contracts.landlord_id = ?
               ORDER BY contracts.id DESC LIMIT 1
             )) AS room_name,
             messages.message AS last_message,
             messages.created_at AS last_at,
             thread_summary.unread_count AS unread_count,
             CASE WHEN EXISTS (
               SELECT 1 FROM contracts
               WHERE contracts.tenant_id = users.id
                 AND contracts.landlord_id = ?
                 AND contracts.status = 'Active'
             ) THEN 1 ELSE 0 END AS is_current
      FROM thread_summary
      INNER JOIN messages ON messages.id = thread_summary.latest_id
      INNER JOIN users ON users.id = thread_summary.contact_id
      LEFT JOIN rooms ON rooms.id = messages.room_id
      WHERE LOWER(users.role) = 'tenant'
        AND users.account_deleted = 0
    ''', [
      landlordId,
      landlordId,
      landlordId,
      landlordId,
      landlordId,
      landlordId,
    ]);

    final guestThreads = await db.rawQuery('''
      SELECT 'guest' AS participant_type,
             guest_accounts.id AS participant_id,
             guest_accounts.name AS participant_name,
             rooms.id AS room_id,
             rooms.name AS room_name,
             COALESCE(
               (SELECT guest_messages.message
                FROM guest_messages
                WHERE guest_messages.guest_id = guest_accounts.id
                  AND guest_messages.landlord_id = guest_viewing_requests.landlord_id
                  AND guest_messages.room_id = rooms.id
                ORDER BY guest_messages.id DESC LIMIT 1),
               'Viewing ' || guest_viewing_requests.status || ' • ' ||
                 guest_viewing_requests.requested_date || ' ' ||
                 guest_viewing_requests.requested_time
             ) AS last_message,
             COALESCE(
               (SELECT guest_messages.created_at
                FROM guest_messages
                WHERE guest_messages.guest_id = guest_accounts.id
                  AND guest_messages.landlord_id = guest_viewing_requests.landlord_id
                  AND guest_messages.room_id = rooms.id
                ORDER BY guest_messages.id DESC LIMIT 1),
               guest_viewing_requests.created_at
             ) AS last_at,
             (SELECT COUNT(*)
              FROM guest_messages
              WHERE guest_messages.guest_id = guest_accounts.id
                AND guest_messages.landlord_id = guest_viewing_requests.landlord_id
                AND guest_messages.room_id = rooms.id
                AND guest_messages.sender_role = 'guest'
                AND guest_messages.is_read = 0) AS unread_count,
             guest_viewing_requests.requested_date AS viewing_date,
             guest_viewing_requests.requested_time AS viewing_time,
             guest_viewing_requests.status AS viewing_status
      FROM guest_viewing_requests
      INNER JOIN guest_accounts ON guest_accounts.id = guest_viewing_requests.guest_id
      INNER JOIN rooms ON rooms.id = guest_viewing_requests.room_id
      WHERE guest_viewing_requests.landlord_id = ?
        AND guest_viewing_requests.id = (
          SELECT MAX(latest_request.id)
          FROM guest_viewing_requests AS latest_request
          WHERE latest_request.guest_id = guest_viewing_requests.guest_id
            AND latest_request.landlord_id = guest_viewing_requests.landlord_id
            AND latest_request.room_id = guest_viewing_requests.room_id
        )
    ''', [landlordId]);

    final threads = <Map<String, dynamic>>[
      ...tenantThreads,
      ...guestThreads,
    ];
    threads.sort((a, b) {
      final aDate = DateTime.tryParse(a['last_at']?.toString() ?? '');
      final bDate = DateTime.tryParse(b['last_at']?.toString() ?? '');
      if (aDate == null) return bDate == null ? 0 : 1;
      if (bDate == null) return -1;
      return bDate.compareTo(aDate);
    });
    return threads;
  }

  Future<int> sendGuestMessage({
    required int guestId,
    required int landlordId,
    required int roomId,
    required bool fromLandlord,
    required String message,
  }) async {
    final db = await database;
    final requests = await db.query(
      'guest_viewing_requests',
      columns: ['id'],
      where: 'guest_id = ? AND landlord_id = ? AND room_id = ?',
      whereArgs: [guestId, landlordId, roomId],
      limit: 1,
    );
    if (requests.isEmpty) throw StateError('GUEST_VIEWING_NOT_FOUND');

    final id = await db.insert('guest_messages', {
      'guest_id': guestId,
      'landlord_id': landlordId,
      'room_id': roomId,
      'sender_role': fromLandlord ? 'landlord' : 'guest',
      'message': message.trim(),
      'created_at': DateTime.now().toIso8601String(),
      'is_read': 0,
    });
    if (!fromLandlord) {
      final names = await db.rawQuery('''
        SELECT guest_accounts.name AS guest_name, rooms.name AS room_name
        FROM guest_accounts
        INNER JOIN rooms ON rooms.id = ?
        WHERE guest_accounts.id = ?
        LIMIT 1
      ''', [roomId, guestId]);
      if (names.isNotEmpty) {
        await addNotification(
          userId: landlordId,
          title: 'Guest Viewing Message',
          message:
              '${names.first['guest_name']} • ${names.first['room_name']}: ${message.trim()}',
        );
      }
    }
    return id;
  }

  Future<List<Map<String, dynamic>>> getGuestConversation({
    required int guestId,
    required int landlordId,
    required int roomId,
    required bool viewerIsLandlord,
  }) async {
    final db = await database;
    await db.update(
      'guest_messages',
      {'is_read': 1},
      where: '''
        guest_id = ? AND landlord_id = ? AND room_id = ?
        AND sender_role = ? AND is_read = 0
      ''',
      whereArgs: [
        guestId,
        landlordId,
        roomId,
        viewerIsLandlord ? 'guest' : 'landlord',
      ],
    );
    return db.query(
      'guest_messages',
      where: 'guest_id = ? AND landlord_id = ? AND room_id = ?',
      whereArgs: [guestId, landlordId, roomId],
      orderBy: 'id ASC',
    );
  }

  // ==========================================================
  // CONTRACTS
  // ==========================================================

  Future<void> _expireContracts() async {
    final db = await database;
    final today = _dateOnly(DateTime.now());
    final expired = await db.query(
      'contracts',
      where:
          'status = ? AND contract_end_date IS NOT NULL AND date(contract_end_date) < date(?)',
      whereArgs: ['Active', today],
    );

    for (final contract in expired) {
      final contractId = contract['id'] as int;
      await db.transaction((txn) async {
        final changed = await txn.update(
          'contracts',
          {
            'status': 'Terminated',
            'end_date': contract['contract_end_date'],
          },
          where: 'id = ? AND status = ?',
          whereArgs: [contractId, 'Active'],
        );
        if (changed == 0) return;

        await txn.update(
          'rooms',
          {'available': 1},
          where: 'id = ?',
          whereArgs: [contract['room_id']],
        );
        await txn.insert('notifications', {
          'user_id': contract['tenant_id'],
          'title': 'Rental Contract Ended',
          'message':
              'Your rental contract has ended. Please leave a rating and feedback about your stay.',
          'created_at': DateTime.now().toIso8601String(),
          'is_read': 0,
        });
      });
    }
  }

  Future<int> setContractEndDate({
    required int contractId,
    required int landlordId,
    required String? contractEndDate,
  }) async {
    final db = await database;
    final rows = await db.update(
      'contracts',
      {'contract_end_date': contractEndDate},
      where: 'id = ? AND landlord_id = ? AND status = ?',
      whereArgs: [contractId, landlordId, 'Active'],
    );
    if (rows > 0) {
      final contract = (await db.query('contracts',
              where: 'id = ?', whereArgs: [contractId], limit: 1))
          .first;
      await addNotification(
        userId: contract['tenant_id'] as int,
        title: 'Rental Contract Updated',
        message: contractEndDate == null
            ? 'Your rental contract is now marked as ongoing.'
            : 'Your rental contract end date is $contractEndDate.',
      );
    }
    return rows;
  }

  Future<Map<String, dynamic>?> getActiveContract(int tenantId) async {
    await _expireContracts();
    final db = await database;

    final result = await db.query(
      'contracts',
      where: 'tenant_id = ? AND status = ?',
      whereArgs: [tenantId, 'Active'],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<Map<String, dynamic>?> getLatestTerminatedContract(
      int tenantId) async {
    await _expireContracts();
    final db = await database;

    final result = await db.query(
      'contracts',
      where: 'tenant_id = ? AND status = ?',
      whereArgs: [tenantId, 'Terminated'],
      orderBy: 'id DESC',
      limit: 1,
    );

    return result.isEmpty ? null : result.first;
  }

  Future<Map<String, dynamic>?> getLatestLandlordContractForTenant(
      int tenantId) async {
    await _expireContracts();
    final db = await database;
    final result = await db.query(
      'contracts',
      where: 'tenant_id = ? AND status IN (?, ?)',
      whereArgs: [tenantId, 'Active', 'Terminated'],
      orderBy: "CASE WHEN status = 'Active' THEN 0 ELSE 1 END, id DESC",
      limit: 1,
    );
    return result.isEmpty ? null : result.first;
  }

  Future<List<Map<String, dynamic>>> getLandlordActiveContracts(
      int landlordId) async {
    await _expireContracts();
    final db = await database;
    return db.rawQuery('''
      SELECT contracts.*, rooms.name AS room_name, tenants.name AS tenant_name
      FROM contracts
      INNER JOIN rooms ON rooms.id = contracts.room_id
      INNER JOIN tenants ON tenants.id = contracts.tenant_id
      WHERE contracts.landlord_id = ? AND contracts.status = 'Active'
      ORDER BY contracts.id DESC
    ''', [landlordId]);
  }

  Future<int> createContract({
    required int tenantId,
    required int landlordId,
    required int roomId,
    required double monthlyRent,
  }) async {
    final db = await database;

    final contractId = await db.insert('contracts', {
      'tenant_id': tenantId,
      'landlord_id': landlordId,
      'room_id': roomId,
      'start_date': DateTime.now().toIso8601String(),
      'end_date': null,
      'monthly_rent': monthlyRent,
      'status': 'Active',
    });

    await updateRoomAvailability(roomId, false);

    return contractId;
  }

  Future<int> terminateContract({
    required int contractId,
    required int landlordId,
  }) async {
    final db = await database;

    final contract = await db.query(
      'contracts',
      where: 'id = ? AND landlord_id = ? AND status = ?',
      whereArgs: [contractId, landlordId, 'Active'],
      limit: 1,
    );

    if (contract.isEmpty) return 0;

    final roomId = contract.first['room_id'] as int;
    final tenantId = contract.first['tenant_id'] as int;

    final result = await db.update(
      'contracts',
      {
        'status': 'Terminated',
        'end_date': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND landlord_id = ? AND status = ?',
      whereArgs: [contractId, landlordId, 'Active'],
    );

    if (result == 0) return 0;
    await updateRoomAvailability(roomId, true);

    await addNotification(
      userId: tenantId,
      title: 'Contract Terminated',
      message: 'Your landlord has terminated your rental contract.',
    );

    return result;
  }

  // ==========================================================
  // PAYMENTS
  // ==========================================================

  Future<int> createPayment({
    required int tenantId,
    required int landlordId,
    required int contractId,
    required double amount,
    required String dueDate,
  }) async {
    final db = await database;

    final existing = await db.query(
      'payments',
      where: 'contract_id = ? AND due_date = ?',
      whereArgs: [contractId, dueDate],
      limit: 1,
    );
    if (existing.isNotEmpty) throw StateError('PAYMENT_DUE_ALREADY_EXISTS');

    final id = await db.insert('payments', {
      'tenant_id': tenantId,
      'landlord_id': landlordId,
      'contract_id': contractId,
      'amount': amount,
      'due_date': dueDate,
      'status': 'Pending',
    });
    await addNotification(
      userId: tenantId,
      title: 'Rent Payment Added',
      message:
          'Your rent payment of ₱${amount.toStringAsFixed(2)} is due on $dueDate.',
    );
    return id;
  }

  Future<void> sendPaymentReminder(int paymentId) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT payments.*, rooms.name AS room_name
      FROM payments
      INNER JOIN contracts ON contracts.id = payments.contract_id
      INNER JOIN rooms ON rooms.id = contracts.room_id
      WHERE payments.id = ? LIMIT 1
    ''', [paymentId]);
    if (rows.isEmpty) return;
    final payment = rows.first;
    if ((payment['status'] ?? '').toString().toLowerCase() == 'paid') {
      throw StateError('PAYMENT_ALREADY_PAID');
    }
    await addNotification(
      userId: payment['tenant_id'] as int,
      title: 'Rent Payment Reminder',
      message:
          'Reminder: ₱${(payment['amount'] as num).toStringAsFixed(2)} for ${payment['room_name']} is due on ${payment['due_date']}.',
    );
  }

  Future<List<Map<String, dynamic>>> getTenantPayments(int tenantId) async {
    final db = await database;

    return await db.query(
      'payments',
      where: 'tenant_id = ?',
      whereArgs: [tenantId],
      orderBy: 'id ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getLandlordPayments(int landlordId) async {
    final db = await database;

    return await db.rawQuery('''
      SELECT payments.*, users.name AS tenant_name, rooms.name AS room_name
      FROM payments
      INNER JOIN users ON users.id = payments.tenant_id
      INNER JOIN contracts ON contracts.id = payments.contract_id
      INNER JOIN rooms ON rooms.id = contracts.room_id
      WHERE payments.landlord_id = ?
      ORDER BY payments.id DESC
    ''', [landlordId]);
  }

  Future<int> updatePaymentStatus(
    int paymentId,
    String status,
  ) async {
    final db = await database;

    final paymentRows = await db.query('payments',
        where: 'id = ?', whereArgs: [paymentId], limit: 1);
    if (paymentRows.isEmpty) return 0;
    final normalizedStatus = status.trim();
    final changed = await db.update(
      'payments',
      {
        'status': normalizedStatus,
        'paid_at': normalizedStatus.toLowerCase() == 'paid'
            ? DateTime.now().toIso8601String()
            : null,
      },
      where: 'id = ?',
      whereArgs: [paymentId],
    );
    if (changed > 0) {
      await addNotification(
        userId: paymentRows.first['tenant_id'] as int,
        title: 'Payment Status Updated',
        message: 'Your rent payment status has been updated to $status.',
      );
    }
    return changed;
  }

  Future<List<Map<String, dynamic>>> getLandlordSalesByMonth({
    required int landlordId,
    required int year,
  }) async {
    final db = await database;
    final start = '$year-01-01';
    final end = '${year + 1}-01-01';
    return db.rawQuery('''
      SELECT CAST(strftime('%m', COALESCE(paid_at, due_date)) AS INTEGER) AS month,
             SUM(amount) AS total
      FROM payments
      WHERE landlord_id = ?
        AND LOWER(status) = 'paid'
        AND date(COALESCE(paid_at, due_date)) >= date(?)
        AND date(COALESCE(paid_at, due_date)) < date(?)
      GROUP BY strftime('%m', COALESCE(paid_at, due_date))
      ORDER BY month
    ''', [landlordId, start, end]);
  }

  Future<int> createAnnouncement({
    required int landlordId,
    required String title,
    required String message,
  }) async {
    final db = await database;
    return db.insert('announcements', {
      'landlord_id': landlordId,
      'title': title.trim(),
      'message': message.trim(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getLandlordAnnouncements(
      int landlordId) async {
    final db = await database;
    return db.query(
      'announcements',
      where: 'landlord_id = ?',
      whereArgs: [landlordId],
      orderBy: 'created_at DESC, id DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getTenantAnnouncements(
      int tenantId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT DISTINCT announcements.*, landlords.name AS landlord_name
      FROM announcements
      INNER JOIN contracts ON contracts.landlord_id = announcements.landlord_id
      INNER JOIN landlords ON landlords.id = announcements.landlord_id
      WHERE contracts.tenant_id = ? AND contracts.status = 'Active'
      ORDER BY announcements.created_at DESC, announcements.id DESC
    ''', [tenantId]);
  }

  Future<int> deleteAnnouncement({
    required int announcementId,
    required int landlordId,
  }) async {
    final db = await database;
    return db.delete(
      'announcements',
      where: 'id = ? AND landlord_id = ?',
      whereArgs: [announcementId, landlordId],
    );
  }

  Future<Map<String, dynamic>?> getActiveContractDetails(int tenantId) async {
    await _expireContracts();
    final db = await database;
    final result = await db.rawQuery('''
      SELECT contracts.*, rooms.name AS room_name, rooms.location AS room_location,
             rooms.floor AS room_floor, rooms.bedrooms AS room_bedrooms,
             rooms.bathrooms AS room_bathrooms,
             users.name AS landlord_name, users.email AS landlord_email
      FROM contracts
      INNER JOIN rooms ON rooms.id = contracts.room_id
      INNER JOIN users ON users.id = contracts.landlord_id
      WHERE contracts.tenant_id = ? AND contracts.status = 'Active'
      LIMIT 1
    ''', [tenantId]);
    return result.isEmpty ? null : result.first;
  }

  Future<List<Map<String, dynamic>>> getTenantReports(int tenantId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT reports.*, rooms.name AS room_name
      FROM reports LEFT JOIN rooms ON rooms.id = reports.room_id
      WHERE reports.tenant_id = ?
      ORDER BY reports.id DESC
    ''', [tenantId]);
  }

  Future<List<Map<String, dynamic>>> getLandlordReports(int landlordId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT reports.*, rooms.name AS room_name, users.name AS tenant_name
      FROM reports
      LEFT JOIN rooms ON rooms.id = reports.room_id
      INNER JOIN users ON users.id = reports.tenant_id
      WHERE reports.landlord_id = ?
      ORDER BY reports.id DESC
    ''', [landlordId]);
  }

  Future<int> createReport({
    required int tenantId,
    required int landlordId,
    int? roomId,
    required String category,
    required String subject,
    required String description,
  }) async {
    final db = await database;
    final id = await db.insert('reports', {
      'tenant_id': tenantId,
      'landlord_id': landlordId,
      'room_id': roomId,
      'category': category,
      'subject': subject,
      'description': description,
      'status': 'Submitted',
      'created_at': DateTime.now().toIso8601String(),
    });
    await addNotification(
      userId: landlordId,
      title: 'New Rental Concern',
      message: '$category: $subject',
    );
    return id;
  }

  Future<int> replyToReport({
    required int reportId,
    required int landlordId,
    required String reply,
  }) async {
    final db = await database;
    final rows = await db.query(
      'reports',
      where: 'id = ? AND landlord_id = ?',
      whereArgs: [reportId, landlordId],
      limit: 1,
    );
    if (rows.isEmpty) throw StateError('REPORT_NOT_FOUND');
    final now = DateTime.now().toIso8601String();
    final changed = await db.update(
      'reports',
      {'landlord_reply': reply.trim(), 'replied_at': now},
      where: 'id = ? AND landlord_id = ?',
      whereArgs: [reportId, landlordId],
    );
    await addNotification(
      userId: rows.first['tenant_id'] as int,
      title: 'Landlord Replied to Your Concern',
      message: reply.trim(),
    );
    return changed;
  }

  Future<int> updateReportStatus(int reportId, String status) async {
    final db = await database;
    final rows = await db.update('reports', {'status': status},
        where: 'id = ?', whereArgs: [reportId]);
    final report = await db.query('reports',
        where: 'id = ?', whereArgs: [reportId], limit: 1);
    if (report.isNotEmpty) {
      await addNotification(
        userId: report.first['tenant_id'] as int,
        title: 'Report Updated',
        message: 'Your rental concern is now $status.',
      );
    }
    return rows;
  }

  // ==========================================================
  // REVIEWS
  // ==========================================================

  Future<int> addReview({
    required int tenantId,
    required int landlordId,
    required int roomId,
    required int rating,
    required String comment,
    required String suggestions,
  }) async {
    final db = await database;
    final eligible = await db.query(
      'contracts',
      where: 'tenant_id = ? AND landlord_id = ? AND room_id = ? AND status = ?',
      whereArgs: [tenantId, landlordId, roomId, 'Terminated'],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (eligible.isEmpty) throw StateError('REVIEW_REQUIRES_ENDED_CONTRACT');
    final existing = await db.query(
      'reviews',
      where: 'tenant_id = ? AND room_id = ?',
      whereArgs: [tenantId, roomId],
      limit: 1,
    );
    if (existing.isNotEmpty) throw StateError('REVIEW_ALREADY_EXISTS');

    return await db.insert('reviews', {
      'tenant_id': tenantId,
      'landlord_id': landlordId,
      'room_id': roomId,
      'rating': rating,
      'comment': comment,
      'suggestions': suggestions,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<bool> hasReviewForContractRoom({
    required int tenantId,
    required int roomId,
  }) async {
    final db = await database;

    final result = await db.query(
      'reviews',
      where: 'tenant_id = ? AND room_id = ?',
      whereArgs: [tenantId, roomId],
      limit: 1,
    );

    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getRoomReviews(int roomId) async {
    final db = await database;

    return await db.rawQuery('''
      SELECT reviews.*, users.name AS tenant_name
      FROM reviews
      INNER JOIN users ON users.id = reviews.tenant_id
      WHERE reviews.room_id = ?
      ORDER BY reviews.id DESC
    ''', [roomId]);
  }

  Future<List<Map<String, dynamic>>> getLandlordReviews(int landlordId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT reviews.id, reviews.room_id, reviews.rating, reviews.comment,
             reviews.suggestions, reviews.created_at, rooms.name AS room_name
      FROM reviews
      INNER JOIN rooms ON rooms.id = reviews.room_id
      WHERE reviews.landlord_id = ?
      ORDER BY reviews.id DESC
    ''', [landlordId]);
  }

  // ==========================================================
  // NOTIFICATIONS
  // ==========================================================

  Future<int> addNotification({
    required int userId,
    required String title,
    required String message,
  }) async {
    final db = await database;

    return await db.insert('notifications', {
      'user_id': userId,
      'title': title,
      'message': message,
      'created_at': DateTime.now().toIso8601String(),
      'is_read': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getNotifications(int userId) async {
    final db = await database;

    return await db.query(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  // ==========================================================
  // RESET DATABASE
  // ==========================================================

  Future<void> clearDatabase() async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('notifications');
      await txn.delete('reviews');
      await txn.delete('payments');
      await txn.delete('messages');
      await txn.delete('viewing_requests');
      await txn.delete('guest_viewing_requests');
      await txn.delete('contracts');
      await txn.delete('rooms');
      await txn.delete('landlord_apartments');
      await txn.delete('guest_accounts');
      await txn.delete('tenants');
      await txn.delete('landlords');
      await txn.delete('superadmins');
      await txn.update('account_id_sequence', {'next_id': 1}, where: 'id = 1');
    });
  }
}
