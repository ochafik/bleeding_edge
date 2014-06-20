// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:expect/expect.dart';
import "package:async_helper/async_helper.dart";
import 'memory_source_file_helper.dart';
import "memory_compiler.dart";
import "dart:async";

import 'package:compiler/implementation/dart2jslib.dart'
       as dart2js;

runTest(String mainScript, test) {
  Compiler compiler = compilerFor(MEMORY_SOURCE_FILES,
      outputProvider: new OutputCollector());
  asyncTest(() => compiler.run(Uri.parse(mainScript))
      .then((_) => test(compiler)));
}

void main() {
  runTest('memory:main.dart', (compiler) {
    var main = compiler.mainApp.find(dart2js.Compiler.MAIN);
    Expect.isNotNull(main, "Could not find 'main'");
    compiler.deferredLoadTask.onResolutionComplete(main);

    var outputUnitForElement = compiler.deferredLoadTask.outputUnitForElement;

    var lib = compiler.libraries["memory:lib.dart"];
    var a = lib.find("a");
    var b = lib.find("b");
    var c = lib.find("c");
    var d = lib.find("d");
    Expect.equals(outputUnitForElement(a), outputUnitForElement(b));
    Expect.equals(outputUnitForElement(a), outputUnitForElement(c));
    Expect.equals(outputUnitForElement(a), outputUnitForElement(d));
  });
}

// Make sure that the implicit references to supers are found by the deferred
// loading dependency mechanism.
const Map MEMORY_SOURCE_FILES = const {
  "main.dart":"""
import "lib.dart" deferred as lib;

void main() {
  lib.loadLibrary().then((_) {
    new lib.A2();
    new lib.B2();
    new lib.C3();
    new lib.D3(10);
  });
}
""",
  "lib.dart":"""
a() => print("123");

b() => print("123");

c() => print("123");

d() => print("123");

class B {
  B() {
    b();
  }
}

class B2 extends B {
  // No constructor creates a synthetic constructor that has an implicit
  // super-call.
}

class A {
  A() {
    a();
  }
}

class A2 extends A {
  // Implicit super call.
  A2();
}

class C1 {}

class C2 {
  C2() {
    c();
  }
}

class C2p {
  C2() {
    c();
  }
}

class C3 extends C2 with C1 {
  // Implicit redirecting "super" call via mixin.
}

class D1 {
}

class D2 {
  D2(x) {
    d();
  }
}

// Implicit redirecting "super" call with a parameter via mixin.
class D3 = D2 with D1;
""",
};
