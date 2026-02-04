import 'dart:io';
import 'dart:typed_data';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lendo/config/supabase_config.dart';
import 'package:lendo/models/asset_model.dart';

final assetServiceProvider = Provider<AssetService>((ref) {
  return AssetService();
});

class AssetService {
  final _supabase = SupabaseConfig.client;

  // Upload image to Supabase Storage and return public URL
  Future<String?> uploadImage(File imageFile, String fileName) async {
    try {
      print('Attempting to upload to bucket: assets');
      print('File path: ' + imageFile.path);

      // Check if we're in a web environment (blob URL)
      if (imageFile.path.startsWith('blob:')) {
        print('Web environment detected - image upload not supported on web');
        throw Exception(
          'Image upload is not supported on web. Please use a mobile device or desktop application for image uploads.',
        );
      } else {
        print('Native environment detected - using SDK');
        // Use the standard SDK approach for native platforms
        await _supabase.storage.from('assets').upload(fileName, imageFile);

        // Get the public URL
        final publicUrl = _supabase.storage
            .from('assets')
            .getPublicUrl(fileName);
        return publicUrl;
      }
    } catch (e) {
      print('Error uploading image: ' + e.toString());
      throw Exception('Failed to upload image: ' + e.toString());
    }
  }

  // Upload image using REST API for web environments
  Future<String> _uploadImageWeb(File imageFile, String fileName) async {
    try {
      // Get the Supabase URL and access token
      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final accessToken = _supabase.auth.currentSession?.accessToken;

      if (supabaseUrl == null) {
        throw Exception('Supabase URL not found in environment');
      }

      if (accessToken == null) {
        throw Exception('User not authenticated');
      }

      // Upload using REST API - send the file directly
      final url = Uri.parse('$supabaseUrl/storage/v1/object/assets/$fileName');

      // For web, we need to handle the blob URL differently
      // Try to read the file as bytes
      Uint8List bytes;
      try {
        bytes = await imageFile.readAsBytes();
        print('File size: ' + bytes.length.toString() + ' bytes');
      } catch (e) {
        print('Error reading file as bytes: ' + e.toString());
        // Fallback to sync method
        bytes = imageFile.readAsBytesSync();
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'image/jpeg', // Adjust based on file type
          'cacheControl': '3600',
        },
        body: bytes,
      );

      if (response.statusCode == 200) {
        // Return the public URL
        return '$supabaseUrl/storage/v1/object/public/assets/$fileName';
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error in _uploadImageWeb: ' + e.toString());
      rethrow;
    }
  }

  // Get all assets
  Future<List<Asset>> getAllAssets() async {
    try {
      final response = await _supabase
          .from('assets')
          .select('*')
          .order('id', ascending: false);

      return response.map((data) => Asset.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to fetch assets: $e');
    }
  }

  // Get asset by ID
  Future<Asset?> getAssetById(String id) async {
    try {
      final response = await _supabase
          .from('assets')
          .select('*')
          .eq('id', id)
          .single();

      return Asset.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Create new asset
  Future<Asset> createAsset({
    required String name,
    required int category,
    required String code,
    required String status,
    String? pictureUrl,
    num? price,
  }) async {
    try {
      final response = await _supabase
          .from('assets')
          .insert({
            'name': name,
            'category': category,
            'code': code,
            'status': status,
            'picture_url': pictureUrl,
            'price': price,
          })
          .select()
          .single();

      return Asset.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create asset: $e');
    }
  }

  // Update asset
  Future<Asset> updateAsset({
    required String id,
    String? name,
    int? category,
    String? code,
    String? status,
    String? pictureUrl,
    num? price,
  }) async {
    try {
      final response = await _supabase
          .from('assets')
          .update({
            if (name != null) 'name': name,
            if (category != null) 'category': category,
            if (code != null) 'code': code,
            if (status != null) 'status': status,
            if (pictureUrl != null) 'picture_url': pictureUrl,
            if (price != null) 'price': price,
          })
          .eq('id', id)
          .select()
          .single();

      return Asset.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update asset: $e');
    }
  }

  // Delete asset
  Future<void> deleteAsset(String id) async {
    try {
      await _supabase.from('assets').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete asset: $e');
    }
  }

  // Search assets
  Future<List<Asset>> searchAssets(String query) async {
    try {
      final response = await _supabase
          .from('assets')
          .select('*')
          .or('name.ilike.%$query%,code.ilike.%$query%')
          .order('id', ascending: false);

      return response.map((data) => Asset.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to search assets: $e');
    }
  }

  // Filter assets by category
  Future<List<Asset>> getAssetsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('assets')
          .select('*')
          .eq('category', category)
          .order('id', ascending: false);

      return response.map((data) => Asset.fromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to filter assets: $e');
    }
  }
}
