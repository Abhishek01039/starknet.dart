// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:starknet_flutter/starknet_flutter.dart';

class StoreExample extends StatefulWidget {
  const StoreExample({super.key});

  @override
  State<StoreExample> createState() => _StoreExampleState();
}

class _StoreExampleState extends State<StoreExample> {
  final _privateKeyId = "uuid1";
  String _password = "";
  String _privateKey = "";
  bool _biometricOnly = false;
  String? _writeError;
  String? _readError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<bool>(
            future: SecureStore.hasBiometricStore(),
            builder: (builderContext, snapshot) {
              final hasBiometrics = snapshot.data ?? false;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    if (!hasBiometrics)
                      TextField(
                        decoration: const InputDecoration(
                          hintText: "My password",
                          labelText: "Protect your key with this password",
                        ),
                        onChanged: (value) {
                          setState(() {
                            _password = value;
                          });
                        },
                      )
                    else
                      const SizedBox.shrink(),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: "🔐 My secret",
                        hintText: "Starknet private key...",
                      ),
                      onChanged: (value) {
                        setState(() {
                          _privateKey = value;
                        });
                      },
                    ),
                    CheckboxListTile(
                      value: _biometricOnly,
                      onChanged: (value) {
                        setState(() {
                          _biometricOnly = value == true;
                        });
                      },
                      title: const Text("Biometric only"),
                    ),
                    if (_writeError != null)
                      Text(
                        _writeError ?? "",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ElevatedButton(
                      onPressed: _privateKey.isEmpty
                          ? null
                          : !hasBiometrics && _password.isEmpty
                              ? null
                              : () async {
                                  try {
                                    final store = await SecureStore.get(
                                      passwordFallbackEnabled: !_biometricOnly,
                                      androidOptions:
                                          const AndroidSecureStoreOptions(
                                        authenticationValidityDurationSeconds:
                                            -1,
                                      ),
                                    );
                                    final privateKey = Uint8List.fromList(
                                      utf8.encode(_privateKey),
                                    );
                                    await store.when(
                                      biometric: (biometric) =>
                                          biometric.storePrivateKey(
                                        id: _privateKeyId,
                                        privateKey: privateKey,
                                      ),
                                      password: (password) =>
                                          password.storePrivateKey(
                                        id: _privateKeyId,
                                        password: _password,
                                        privateKey: privateKey,
                                      ),
                                    );
                                    setState(() {
                                      _writeError = null;
                                      _readError = null;
                                      showSnackBar(
                                        "Stored key $_privateKeyId: $_privateKey",
                                        success: true,
                                      );
                                    });
                                  } on NoBiometricAndNoFallbackException {
                                    setState(() {
                                      _writeError = """
No biometric store available and password fallback disabled.
You should notify the user that they can't use this secure feature.""";
                                      showSnackBar(
                                        "Error storing key $_privateKeyId",
                                        success: false,
                                      );
                                    });
                                  }
                                },
                      child: const Text("🔐 Store Private Key"),
                    ),
                    if (_readError != null)
                      Text("Read error: $_readError",
                          style: const TextStyle(color: Colors.red)),
                    ElevatedButton(
                      onPressed: () async {
                        final store = await SecureStore.get(
                          passwordFallbackEnabled: !_biometricOnly,
                        );
                        try {
                          final result = await store.when(
                            biometric: (biometric) => biometric.getPrivateKey(
                              id: _privateKeyId,
                            ),
                            password: (password) => password.getPrivateKey(
                              id: "uuid1",
                              password: _password,
                            ),
                          );

                          setState(() {
                            if (result == null) {
                              showSnackBar(
                                "Key was not present in store",
                                success: false,
                              );
                            } else {
                              showSnackBar(
                                "Retrieved key $_privateKeyId: ${utf8.decode(result)}",
                                success: true,
                              );
                            }
                          });
                        } on FailedToDecryptException catch (e) {
                          setState(() {
                            _readError = e.toString();
                            showSnackBar(
                              "Error retrieving key $_privateKeyId",
                              success: false,
                            );
                          });
                        }
                      },
                      child: const Text("🔑 Read private key"),
                    ),
                    TextButton(
                      onPressed: () async {
                        final store = await SecureStore.get(
                          passwordFallbackEnabled: !_biometricOnly,
                        );
                        await store.when(
                          biometric: (biometric) =>
                              biometric.deletePrivateKey(id: _privateKeyId),
                          password: (password) =>
                              password.deletePrivateKey(id: _privateKeyId),
                        );
                        setState(() {
                          _readError = null;
                          showSnackBar(
                            "Removed private key $_privateKeyId",
                            success: true,
                          );
                        });
                      },
                      child: const Text(
                        "🗑️ Remove private key",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final result = await Passcode.showScreen(context);
                        print(result);
                      },
                      child: const Text(
                        "🔏 Show passcode view",
                      ),
                    ),
                  ].separated(const SizedBox(height: 20)),
                ),
              );
            }),
      ),
    );
  }

  void showSnackBar(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        showCloseIcon: true,
        closeIconColor: Colors.white,
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(message),
      ),
    );
  }
}

extension SeparatedList<T> on List<T> {
  List<T> separated(T separator) {
    final newList = <T>[];
    for (var i = 0; i < length; i++) {
      if (i == 0) {
        newList.add(this[i]);
      } else {
        newList.add(separator);
        newList.add(this[i]);
      }
    }
    return newList;
  }
}
