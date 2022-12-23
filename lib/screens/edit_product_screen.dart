// ignore_for_file: use_key_in_widget_constructors, prefer_void_to_null, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_shop_app/providers/product.dart';
import 'package:flutter_shop_app/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static String routeName = '/edit-product-screen';

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageFocusNode = FocusNode();

  final _imageUrlController = TextEditingController();

  final _form = GlobalKey<FormState>();

  bool _isLoading = false;

  Product _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  var _initValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    _imageFocusNode.addListener(_updateImageUrl);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (ModalRoute.of(context)?.settings.arguments != null) {
        final productId = ModalRoute.of(context)?.settings.arguments as String;

        _editedProduct = Provider.of<Products>(context, listen: false).findById(productId);
        _initValue = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': _editedProduct.imageUrl,
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();

    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageFocusNode.hasFocus && (Uri.tryParse(_imageUrlController.text)?.hasAbsolutePath ?? false)) {
      setState(() {});
    }
  }

  void _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (isValid == null || !isValid) {
      return;
    }

    _form.currentState?.save();

    setState(() {
      _isLoading = true;
    });

    if (_editedProduct.id != null) {
      await Provider.of<Products>(context, listen: false).updateProduct(_editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false).addProduct(_editedProduct);
      } catch (e) {
        return showDialog<Null>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: const Text('抱歉，出错了，再试试！'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('我知道了'),
              ),
            ],
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑产品'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: '名称'),
                      initialValue: _initValue['title'],
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      validator: (value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return '请输入产品的名称。';
                          }
                        }

                        return null;
                      },
                      onSaved: (newValue) {
                        if (newValue != null) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: newValue,
                            description: _editedProduct.description,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        }
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: '价格'),
                      initialValue: _initValue['price'],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      validator: (value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return '请输入产品的价格。';
                          }
                          if (double.tryParse(value) == null) {
                            return '请输入合格的价格。';
                          }
                          if (double.parse(value) <= 0) {
                            return '请输入比0大的价格。';
                          }
                        }

                        return null;
                      },
                      onSaved: (newValue) {
                        if (newValue != null) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            price: double.parse(newValue),
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        }
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: '描述'),
                      initialValue: _initValue['description'],
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return '请输入产品的描述。';
                          }
                          if (value.length < 10) {
                            return '描述至少要十字符。';
                          }
                        }

                        return null;
                      },
                      onSaved: (newValue) {
                        if (newValue != null) {
                          _editedProduct = Product(
                            id: _editedProduct.id,
                            title: _editedProduct.title,
                            description: newValue,
                            price: _editedProduct.price,
                            imageUrl: _editedProduct.imageUrl,
                            isFavorite: _editedProduct.isFavorite,
                          );
                        }
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(
                            top: 8,
                            right: 8,
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          )),
                          child: _imageUrlController.text.isEmpty
                              ? const Text('请输入链接！')
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: '图像链接'),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageFocusNode,
                            controller: _imageUrlController,
                            validator: (value) {
                              if (value != null) {
                                if (value.isEmpty) {
                                  return '请输入产品的图像链接。';
                                }
                                if (!(Uri.tryParse(value)?.hasAbsolutePath ?? false)) {
                                  return '请输入合格的图像链接。';
                                }
                              }

                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (newValue) {
                              if (newValue != null) {
                                _editedProduct = Product(
                                  id: _editedProduct.id,
                                  title: _editedProduct.title,
                                  description: _editedProduct.description,
                                  price: _editedProduct.price,
                                  imageUrl: newValue,
                                  isFavorite: _editedProduct.isFavorite,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
