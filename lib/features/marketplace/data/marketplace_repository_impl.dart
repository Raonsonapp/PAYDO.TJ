import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/product_model.dart';
import '../domain/marketplace_repository.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final FirebaseFirestore _firestore;

  MarketplaceRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _productsRef =>
      _firestore.collection(FirestorePaths.products);

  CollectionReference<Map<String, dynamic>> get _favoritesRef =>
      _firestore.collection(FirestorePaths.favorites);

  @override
  Stream<List<ProductModel>> watchProducts(ProductFilter filter) {
    Query<Map<String, dynamic>> query = _productsRef;

    if (filter.onlyAvailable) {
      query = query.where('isHidden', isEqualTo: false);
    }
    if (filter.category != null) {
      query = query.where('category', isEqualTo: filter.category);
    }
    if (filter.city != null) {
      query = query.where('city', isEqualTo: filter.city);
    }

    query = query.orderBy('createdAt', descending: true).limit(50);

    return query.snapshots().map(
          (snap) => snap.docs
              .map((d) => ProductModel.fromMap(d.id, d.data()))
              .toList(),
        );
    // ЭЗОҲ (banди "агар қарор интихоб кунӣ, сабт кун"): ин query ба
    // composite index-ҳо ниёз дорад (category+createdAt, city+createdAt
    // ва ғайра). Firestore дар console худаш пешниҳод медиҳад — ниг.
    // docs/database.md барои феҳристи index-ҳое, ки бояд сохта шаванд
    // пеш аз PHASE 21 (Testing).
  }

  @override
  Future<ProductModel> getProduct(String productId) async {
    final snap = await _productsRef.doc(productId).get();
    if (!snap.exists || snap.data() == null) {
      throw const ServerFailure('Маҳсулот ёфт нашуд.');
    }
    return ProductModel.fromMap(productId, snap.data()!);
  }

  @override
  Stream<Set<String>> watchFavoriteIds(String uid) {
    return _favoritesRef
        .where('userId', isEqualTo: uid)
        .where('itemType', isEqualTo: 'product')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => d.data()['itemId'] as String).toSet());
  }

  @override
  Future<void> toggleFavorite({
    required String uid,
    required String productId,
    required bool isFavorite,
  }) async {
    final docId = '${uid}_$productId';
    final ref = _favoritesRef.doc(docId);

    try {
      if (isFavorite) {
        await ref.set({
          'userId': uid,
          'itemId': productId,
          'itemType': 'product',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await ref.delete();
      }
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии favorite: ${e.message}');
    }
  }
}
