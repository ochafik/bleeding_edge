// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.correction.fix;

import 'package:analysis_services/correction/change.dart';
import 'package:analysis_services/search/search_engine.dart';
import 'package:analysis_services/src/correction/fix.dart';
import 'package:analyzer/src/generated/ast.dart';
import 'package:analyzer/src/generated/error.dart';
import 'package:analyzer/src/generated/source.dart';


/**
 * Computes [Fix]s for the given [AnalysisError].
 *
 * Returns the computed [Fix]s, not `null`.
 */
List<Fix> computeFixes(SearchEngine searchEngine,
    CompilationUnit unit, AnalysisError error) {
  Source source = unit.element.source;
  String file = source.fullName;
  var processor = new FixProcessor(searchEngine, source, file, unit, error);
  return processor.compute();
}


/**
 * A description of a single proposed fix for some problem.
 */
class Fix {
  final FixKind kind;
  final Change change;

  Fix(this.kind, this.change);

  @override
  String toString() {
    return '[kind=$kind, change=$change]';
  }
}


/**
 * An enumeration of possible quick fix kinds.
 */
class FixKind {
  static const ADD_PACKAGE_DEPENDENCY =
      const FixKind('ADD_PACKAGE_DEPENDENCY', 50, "Add dependency on package '%s'");
  static const ADD_SUPER_CONSTRUCTOR_INVOCATION =
      const FixKind(
          'ADD_SUPER_CONSTRUCTOR_INVOCATION',
          50,
          "Add super constructor %s invocation");
  static const CHANGE_TO = const FixKind('CHANGE_TO', 51, "Change to '%s'");
  static const CHANGE_TO_STATIC_ACCESS =
      const FixKind(
          'CHANGE_TO_STATIC_ACCESS',
          50,
          "Change access to static using '%s'");
  static const CREATE_CLASS =
      const FixKind('CREATE_CLASS', 50, "Create class '%s'");
  static const CREATE_CONSTRUCTOR =
      const FixKind('CREATE_CONSTRUCTOR', 50, "Create constructor '%s'");
  static const CREATE_CONSTRUCTOR_SUPER =
      const FixKind('CREATE_CONSTRUCTOR_SUPER', 50, "Create constructor to call %s");
  static const CREATE_FUNCTION =
      const FixKind('CREATE_FUNCTION', 49, "Create function '%s'");
  static const CREATE_METHOD =
      const FixKind('CREATE_METHOD', 50, "Create method '%s'");
  static const CREATE_MISSING_OVERRIDES =
      const FixKind('CREATE_MISSING_OVERRIDES', 50, "Create %d missing override(s)");
  static const CREATE_NO_SUCH_METHOD =
      const FixKind('CREATE_NO_SUCH_METHOD', 49, "Create 'noSuchMethod' method");
  static const CREATE_PART =
      const FixKind('CREATE_PART', 50, "Create part '%s'");
  static const IMPORT_LIBRARY_PREFIX =
      const FixKind(
          'IMPORT_LIBRARY_PREFIX',
          51,
          "Use imported library '%s' with prefix '%s'");
  static const IMPORT_LIBRARY_PROJECT =
      const FixKind('IMPORT_LIBRARY_PROJECT', 51, "Import library '%s'");
  static const IMPORT_LIBRARY_SDK =
      const FixKind('IMPORT_LIBRARY_SDK', 51, "Import library '%s'");
  static const IMPORT_LIBRARY_SHOW =
      const FixKind('IMPORT_LIBRARY_SHOW', 51, "Update library '%s' import");
  static const INSERT_SEMICOLON =
      const FixKind('INSERT_SEMICOLON', 50, "Insert ';'");
  static const MAKE_CLASS_ABSTRACT =
      const FixKind('MAKE_CLASS_ABSTRACT', 50, "Make class '%s' abstract");
  static const REMOVE_PARAMETERS_IN_GETTER_DECLARATION =
      const FixKind(
          'REMOVE_PARAMETERS_IN_GETTER_DECLARATION',
          50,
          "Remove parameters in getter declaration");
  static const REMOVE_PARENTHESIS_IN_GETTER_INVOCATION =
      const FixKind(
          'REMOVE_PARENTHESIS_IN_GETTER_INVOCATION',
          50,
          "Remove parentheses in getter invocation");
  static const REMOVE_UNNECASSARY_CAST =
      const FixKind('REMOVE_UNNECASSARY_CAST', 50, "Remove unnecessary cast");
  static const REMOVE_UNUSED_IMPORT =
      const FixKind('REMOVE_UNUSED_IMPORT', 50, "Remove unused import");
  static const REPLACE_BOOLEAN_WITH_BOOL =
      const FixKind('REPLACE_BOOLEAN_WITH_BOOL', 50, "Replace 'boolean' with 'bool'");
  static const USE_CONST = const FixKind('USE_CONST', 50, "Change to constant");
  static const USE_EFFECTIVE_INTEGER_DIVISION =
      const FixKind(
          'USE_EFFECTIVE_INTEGER_DIVISION',
          50,
          "Use effective integer division ~/");
  static const USE_EQ_EQ_NULL =
      const FixKind('USE_EQ_EQ_NULL', 50, "Use == null instead of 'is Null'");
  static const USE_NOT_EQ_NULL =
      const FixKind('USE_NOT_EQ_NULL', 50, "Use != null instead of 'is! Null'");

  final name;
  final int relevance;
  final String message;

  const FixKind(this.name, this.relevance, this.message);

  @override
  String toString() => name;
}
