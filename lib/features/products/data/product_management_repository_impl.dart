import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/product_model.dart';
import '../domain/product_management_repository.dart';

class ProductManagementRepositoryImpl implements ProductManagementRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  ProductManagementRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection(FirestorePaths.products);

  @override
  Stream<List<ProductModel>> watchMyProducts(String sellerId) {
    return _productsRef
        .where('sellerId', isEqualTo: sellerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ProductModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<String> addProduct(ProductModel product) async {
    try {
      final docRef = await _productsRef.add(product.toMap(isCreate: true));
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии иловаи маҳсулот: ${e.message}');
    }
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _productsRef.doc(product.id).update(product.toMap());
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии тағйири маҳсулот: ${e.message}');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsRef.doc(productId).delete();
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии несткунии маҳсулот: ${e.message}');
    }
  }

  @override
  Future<void> setHidden({
    required String productId,
    required bool isHidden,
  }) async {
    try {
      await _productsRef.doc(productId).update({
        'isHidden': isHidden,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогӣ: ${e.message}');
    }
  }

  @override
  Future<void> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      await _productsRef.doc(productId).update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогӣ: ${e.message}');
    }
  }

  @override
  Future<String> uploadProductImage({
    required String sellerId,
    required File imageFile,
  }) async {
    try {
      final fileName = '${_uuid.v4()}.jpg';
      final ref =
          _storage.ref().child('product_images/$sellerId/$fileName');
      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии боркунии сурат: ${e.message}');
    }
  }

  @override
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (_) {
      // Сурат метавонад аллакай нест шуда бошад — ин критикӣ нест,
      // барои ҳамин хатогиро ба боло намепартоем (silent-fail мутобиқи
      // мантиқи "cleanup best-effort").
    }
  }
}
