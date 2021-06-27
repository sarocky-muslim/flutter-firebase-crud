import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDB {
  var category = FirebaseFirestore.instance.collection('Category1');
  var product = FirebaseFirestore.instance.collection('Product');

  Future<DocumentReference> insert(Map<String, dynamic> object) async {
    return await category.add(object);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    var queryList = await category.get();
    return queryList.docs.map((qds) {
      var item = qds.data();
      item.addAll({'id': qds.id});
      return item;
    }).toList();
  }

  Future<Map<String, dynamic>> getOne(String id) async {
    var ds = await category.doc(id).get();
    var item = ds.data() ?? {};
    item.addAll({'id': ds.id});
    return item;
  }

  Future<void> update(String? id, Map<String, dynamic> object) async {
    await category.doc(id).update(object);
  }

  Future<void> deleteOne(String id) async {
    await category.doc(id).delete();
    await deleteAllRelation(id);
  }

  Future<void> deleteAllRelation(String id) async {
    var categories = await product.where('category', isEqualTo: id).get();
    for (var doc in categories.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> deleteAll(String id) async {
    var snapshot = await category.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
