// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/expect.dart';

import 'dart:_js_helper' show Primitives;

main() {
  Expect.isFalse(Primitives.isD8);
  Expect.isTrue(Primitives.isJsshell);
}
