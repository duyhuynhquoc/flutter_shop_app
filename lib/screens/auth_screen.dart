import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_shop_app/models/http_exception.dart';
import 'package:flutter_shop_app/providers/auth.dart';
import 'package:provider/provider.dart';

enum AuthMode { signUp, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  const Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20.0),
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          const BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        '阿里哈哈',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('出错了！'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('我知道了'),
          )
        ],
      ),
    );
  }

  void _submit() async {
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      // Invalid!

      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).logIn(_authData['email']!, _authData['password']!);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signUp(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (e) {
      String errorMessage = '认证失败，再试试。';

      if (e.toString().contains('EMAIL_EXISTS')) {
        errorMessage = '邮件已被使用了。';
      } else if (e.toString().contains('INVALID_EMAIL')) {
        errorMessage = '邮件不合格。';
      } else if (e.toString().contains('WEAK_PASSWORD')) {
        errorMessage = '密码太弱。';
      } else if (e.toString().contains('EMAIL_NOT_FOUND') || e.toString().contains('INVALID_PASSWORD')) {
        errorMessage = '邮件或者密码不合格。';
      }

      _showDialog(errorMessage);
    } catch (e) {
      String errorMessage = '出错了。';

      _showDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.signUp ? 320 : 260,
        constraints: BoxConstraints(minHeight: _authMode == AuthMode.signUp ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: '邮件'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null) {
                      if (value.isEmpty || !value.contains('@')) {
                        return '邮件不合格';
                      }
                    }
                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      _authData['email'] = value;
                    }
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: '密码'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value != null) {
                      if (value.isEmpty || value.length < 5) {
                        return '密码太短';
                      }
                    }

                    return null;
                  },
                  onSaved: (value) {
                    if (value != null) {
                      _authData['password'] = value;
                    }
                  },
                ),
                if (_authMode == AuthMode.signUp)
                  TextFormField(
                    enabled: _authMode == AuthMode.signUp,
                    decoration: const InputDecoration(labelText: '确认密码'),
                    obscureText: true,
                    validator: _authMode == AuthMode.signUp
                        ? (value) {
                            if (value != _passwordController.text) {
                              return '确认的密码不相似';
                            }
                          }
                        : null,
                  ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                      foregroundColor: Theme.of(context).primaryTextTheme.button?.color,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: _submit,
                    child: Text(_authMode == AuthMode.Login ? '登陆' : '注册'),
                  ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_authMode == AuthMode.Login ? '没有账号？' : '已有账号？'),
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        foregroundColor: Theme.of(context).primaryColor, // Text color

                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _switchAuthMode,
                      child: Text(_authMode == AuthMode.Login ? '注册' : '登陆'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
