import 'package:flutter/material.dart';
import 'dbCategory.dart';
import 'dbProduct.dart';

class Product extends StatefulWidget {
  const Product({Key? key}) : super(key: key);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  CategoryDB categoryDB = new CategoryDB();
  ProductDB productDB = new ProductDB();
  List<Map<String, dynamic>> _items = [];
  List<Map<String, dynamic>> _categories = [];
  String _initValue = '';
  String _inputValue = '';
  bool _isEditing = false;
  String? _selectId;
  String? _selectedCategory;

  void _displayItems() async {
    var categoryList = await categoryDB.getAll();
    var productList = await productDB.getAll();
    setState(() {
      _categories = categoryList;
      _items = productList;
    });
  }

  void _addItem() async {
    await productDB
        .insert({'category': _selectedCategory, 'name': _inputValue});
    _displayItems();
  }

  void _selectItem(Map<String, dynamic> item) async {
    _isEditing = true;
    _selectId = item['id'].toString();
    setState(() {
      _selectedCategory = item['category']['id'].toString();
      _initValue = item['name'].toString();
    });
  }

  void _updateItem() async {
    await productDB.update(
        _selectId, {'category': _selectedCategory, 'name': _inputValue});
    _displayItems();
    _isEditing = false;
  }

  void _deleteItem(String id) async {
    await productDB.deleteOne(id);
    _displayItems();
  }

  Widget itemView(Map<String, dynamic> item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Text(
              '${item['category']['name']} - ${item['name']}',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () => _selectItem(item),
              icon: Icon(
                Icons.edit,
                color: Colors.blue[700],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: () => _deleteItem(item['id'].toString()),
              icon: Icon(
                Icons.delete,
                color: Colors.red[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _displayItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Relationship Product CRUD'),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            DropdownButtonFormField(
              hint: Text('Select Category'),
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(
                    value: category['id'].toString(),
                    child: Text(category['name'].toString()));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value.toString();
                });
              },
            ),
            TextFormField(
              controller: TextEditingController(text: _initValue),
              decoration: InputDecoration(
                hintText: 'Enter the name here',
              ),
              onChanged: (value) => _inputValue = value,
              textInputAction: TextInputAction.send,
              onFieldSubmitted: (value) {
                if (value != '') {
                  if (_isEditing) return _updateItem();
                  return _addItem();
                }
              },
            ),
            ListView(
              shrinkWrap: true,
              children: _items.reversed.map((item) => itemView(item)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
