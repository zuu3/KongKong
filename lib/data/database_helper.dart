import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bid.dart';
import '../models/owned_asset.dart';
import '../models/asset.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  
  // Web Storage Cache
  List<Map<String, dynamic>> _webBids = [];
  List<Map<String, dynamic>> _webOwnedAssets = [];
  bool _webLoaded = false;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on Web. Use internal methods.');
    }
    if (_database != null) return _database!;
    _database = await _initDB('gongmae.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bids (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        asset_id INTEGER NOT NULL,
        asset_title TEXT NOT NULL,
        bidder_name TEXT NOT NULL,
        bid_amount INTEGER NOT NULL,
        bid_time TEXT NOT NULL,
        is_user INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE owned_assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        asset_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        min_price INTEGER NOT NULL,
        category TEXT NOT NULL,
        deadline TEXT,
        winning_bid INTEGER NOT NULL,
        acquired_at TEXT NOT NULL
      )
    ''');
  }

  // --- Web Helpers ---
  Future<void> _ensureWebLoaded() async {
    if (!_webLoaded) {
      final prefs = await SharedPreferences.getInstance();
      
      final bidsJson = prefs.getString('db_bids');
      if (bidsJson != null) {
        _webBids = List<Map<String, dynamic>>.from(jsonDecode(bidsJson));
      }
      
      final assetsJson = prefs.getString('db_owned_assets');
      if (assetsJson != null) {
        _webOwnedAssets = List<Map<String, dynamic>>.from(jsonDecode(assetsJson));
      }
      
      _webLoaded = true;
    }
  }

  Future<void> _saveWebBids() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('db_bids', jsonEncode(_webBids));
  }

  Future<void> _saveWebAssets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('db_owned_assets', jsonEncode(_webOwnedAssets));
  }

  // --- Bid Operations ---

  Future<int> insertBid(Bid bid) async {
    final data = {
      'asset_id': bid.assetId,
      'asset_title': bid.assetTitle,
      'bidder_name': bid.bidderName,
      'bid_amount': bid.bidAmount,
      'bid_time': bid.bidTime.toIso8601String(),
      'is_user': bid.isUser ? 1 : 0,
    };

    if (kIsWeb) {
      await _ensureWebLoaded();
      // Generate ID
      int id = 1;
      if (_webBids.isNotEmpty) {
        id = (_webBids.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
      }
      data['id'] = id;
      _webBids.add(data);
      await _saveWebBids();
      return id;
    } else {
      final db = await database;
      return await db.insert('bids', data);
    }
  }

  Future<List<Bid>> fetchAllBids() async {
    List<Map<String, dynamic>> result;
    if (kIsWeb) {
      await _ensureWebLoaded();
      result = List.from(_webBids);
      // Sort by time DESC
      result.sort((a, b) => (b['bid_time'] as String).compareTo(a['bid_time'] as String));
    } else {
      final db = await database;
      result = await db.query('bids', orderBy: 'bid_time DESC');
    }

    return result.map((json) => Bid(
      id: json['id'] as int,
      assetId: json['asset_id'] as int,
      assetTitle: json['asset_title'] as String,
      bidderName: json['bidder_name'] as String,
      bidAmount: json['bid_amount'] as int,
      bidTime: DateTime.parse(json['bid_time'] as String),
      isUser: (json['is_user'] as int) == 1,
    )).toList();
  }

  Future<List<Bid>> fetchUserBids() async {
    List<Map<String, dynamic>> result;
    if (kIsWeb) {
      await _ensureWebLoaded();
      result = _webBids.where((e) => (e['is_user'] as int) == 1).toList();
      result.sort((a, b) => (b['bid_time'] as String).compareTo(a['bid_time'] as String));
    } else {
      final db = await database;
      result = await db.query(
        'bids',
        where: 'is_user = ?',
        whereArgs: [1],
        orderBy: 'bid_time DESC',
      );
    }
    
    return result.map((json) => Bid(
      id: json['id'] as int,
      assetId: json['asset_id'] as int,
      assetTitle: json['asset_title'] as String,
      bidderName: json['bidder_name'] as String,
      bidAmount: json['bid_amount'] as int,
      bidTime: DateTime.parse(json['bid_time'] as String),
      isUser: (json['is_user'] as int) == 1,
    )).toList();
  }

  Future<void> clearBids() async {
    if (kIsWeb) {
      await _ensureWebLoaded();
      _webBids.clear();
      await _saveWebBids();
    } else {
      final db = await database;
      await db.delete('bids');
    }
  }

  Future<int> deleteBid(int id) async {
    if (kIsWeb) {
      await _ensureWebLoaded();
      final initialLen = _webBids.length;
      _webBids.removeWhere((e) => e['id'] == id);
      if (_webBids.length != initialLen) {
        await _saveWebBids();
        return 1;
      }
      return 0;
    } else {
      final db = await database;
      return await db.delete(
        'bids',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // --- Owned Asset Operations ---

  Future<int> insertOwnedAsset(OwnedAsset ownedAsset) async {
    final data = {
      'asset_id': ownedAsset.asset.id,
      'title': ownedAsset.asset.title,
      'min_price': ownedAsset.asset.minPrice,
      'category': ownedAsset.asset.category,
      'deadline': ownedAsset.asset.deadline?.toIso8601String(),
      'winning_bid': ownedAsset.winningBid,
      'acquired_at': ownedAsset.acquiredAt.toIso8601String(),
    };

    if (kIsWeb) {
      await _ensureWebLoaded();
      // Generate ID
      int id = 1;
      if (_webOwnedAssets.isNotEmpty) {
        id = (_webOwnedAssets.map((e) => e['id'] as int).reduce((a, b) => a > b ? a : b)) + 1;
      }
      data['id'] = id;
      _webOwnedAssets.add(data);
      await _saveWebAssets();
      return id;
    } else {
      final db = await database;
      return await db.insert('owned_assets', data);
    }
  }

  Future<List<OwnedAsset>> fetchOwnedAssets() async {
    List<Map<String, dynamic>> result;
    if (kIsWeb) {
      await _ensureWebLoaded();
      result = List.from(_webOwnedAssets);
      result.sort((a, b) => (b['acquired_at'] as String).compareTo(a['acquired_at'] as String));
    } else {
      final db = await database;
      result = await db.query('owned_assets', orderBy: 'acquired_at DESC');
    }

    return result.map((json) => OwnedAsset(
      asset: Asset(
        id: json['asset_id'] as int,
        title: json['title'] as String,
        minPrice: json['min_price'] as int,
        category: json['category'] as String,
        deadline: json['deadline'] != null ? DateTime.parse(json['deadline'] as String) : null,
      ),
      winningBid: json['winning_bid'] as int,
      acquiredAt: DateTime.parse(json['acquired_at'] as String),
    )).toList();
  }

  Future<void> deleteOwnedAsset(int assetId) async {
    if (kIsWeb) {
      await _ensureWebLoaded();
      _webOwnedAssets.removeWhere((e) => e['asset_id'] == assetId);
      await _saveWebAssets();
    } else {
      final db = await database;
      await db.delete(
        'owned_assets',
        where: 'asset_id = ?',
        whereArgs: [assetId],
      );
    }
  }
}
