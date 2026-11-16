import 'package:flutter/material.dart';

import 'app.dart';
import 'services/fake_auth_service.dart';

void main() {
  runApp(SUggestApp(auth: FakeAuthService()));
}
