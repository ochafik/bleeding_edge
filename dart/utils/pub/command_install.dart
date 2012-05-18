// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/** Handles the `install` pub command. */
class InstallCommand extends PubCommand {
  String get description() => "install the current package's dependencies";

  void onRun() {
    entrypoint.installDependencies().then((_) {
      print('Dependencies installed!');
    });
  }
}
