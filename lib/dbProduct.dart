import 'package:cloud_firestore/cloud_firestore.dart';
import 'dbCategory.dart';

class ProductDB {
  var categoryDB = new CategoryDB();
  var product = FirebaseFirestore.instance.collection('Product');

  Future<DocumentReference> insert(Map<String, dynamic> object) async {
    return await product.add(object);
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    var query = await product.get();
    var productList = query.docs.map((qds) {
      var item = qds.data();
      item.addAll({'id': qds.id});
      return item;
    }).toList();
    for (var product in productList) {
      String categoryId = product['category'].toString();
      var category = await categoryDB.getOne(categoryId);
      product['category'] = category;
    }
    return productList;
  }

  Future<DocumentSnapshot> getOne(String id) async {
    return await product.doc(id).get();
  }

  Future<void> update(String? id, Map<String, dynamic> object) async {
    await product.doc(id).update(object);
  }

  Future<void> deleteOne(String id) async {
    await product.doc(id).delete();
  }
}
