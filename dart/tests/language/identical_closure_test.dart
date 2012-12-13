// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// We assign the closure to a global to avoid potential optimizations.
var myIdentical = identical;

main() {
  Expect.isTrue(myIdentical(42, 42));
}
