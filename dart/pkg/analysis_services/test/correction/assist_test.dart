// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This code was auto-generated, is not intended to be edited, and is subject to
// significant change. Please see the README file for more information.

library test.services.correction.assist;

import 'package:analysis_services/correction/assist.dart';
import 'package:analysis_services/correction/change.dart';
import 'package:analysis_services/index/index.dart';
import 'package:analysis_services/index/local_memory_index.dart';
import 'package:analysis_services/src/search/search_engine.dart';
import 'package:analysis_testing/abstract_single_unit.dart';
import 'package:analysis_testing/reflective_tests.dart';
import 'package:collection/collection.dart';
import 'package:unittest/unittest.dart';


main() {
  groupSep = ' | ';
  runReflectiveTests(AssistProcessorTest);
}


@ReflectiveTestCase()
class AssistProcessorTest extends AbstractSingleUnitTest {
  Index index;
  SearchEngineImpl searchEngine;

  int offset;
  int length;

  Assist assist;
  Change change;
  String resultCode;
  LinkedEditGroup linkedPositionGroup;

  /**
   * Asserts that there is an [Assist] of the given [kind] at [offset] which
   * produces the [expected] code when applied to [testCode].
   */
  void assertHasAssist(AssistKind kind, String expected) {
    assist = _assertHasAssist(kind);
    change = assist.change;
    // apply to "file"
    List<FileEdit> fileEdits = change.edits;
    expect(fileEdits, hasLength(1));
    resultCode = _applyEdits(testCode, change.edits[0].edits);
    // verify
    expect(resultCode, expected);
  }

  /**
   * Calls [assertHasAssist] at the offset of [offsetSearch] in [testCode].
   */
  void assertHasAssistAt(String offsetSearch, AssistKind kind,
      String expected) {
    offset = findOffset(offsetSearch);
    assertHasAssist(kind, expected);
  }

  void assertHasPositionGroup(String id, int expectedLength,
      List<Position> expectedPositions) {
    List<LinkedEditGroup> linkedPositionGroups = change.linkedEditGroups;
    for (LinkedEditGroup group in linkedPositionGroups) {
      if (group.id == id) {
        expect(group.length, expectedLength);
        expect(group.positions, unorderedEquals(expectedPositions));
        linkedPositionGroup = group;
        return;
      }
    }
    fail('No PositionGroup with id=$id found in $linkedPositionGroups');
  }

  /**
   * Asserts that there is no [Assist] of the given [kind] at [offset].
   */
  void assertNoAssist(AssistKind kind) {
    List<Assist> assists =
        computeAssists(searchEngine, testUnit, offset, length);
    for (Assist assist in assists) {
      if (assist.kind == kind) {
        throw fail('Unexpected assist $kind in\n${assists.join('\n')}');
      }
    }
  }

  /**
   * Calls [assertNoAssist] at the offset of [offsetSearch] in [testCode].
   */
  void assertNoAssistAt(String offsetSearch, AssistKind kind) {
    offset = findOffset(offsetSearch);
    assertNoAssist(kind);
  }

  Position expectedPosition(String search) {
    int offset = resultCode.indexOf(search);
    return new Position(testFile, offset);
  }

  List<Position> expectedPositions(List<String> patterns) {
    List<Position> positions = <Position>[];
    patterns.forEach((String search) {
      positions.add(expectedPosition(search));
    });
    return positions;
  }

  List<LinkedEditSuggestion> expectedSuggestions(LinkedEditSuggestionKind kind,
      List<String> values) {
    return values.map((value) {
      return new LinkedEditSuggestion(kind, value);
    }).toList();
  }

  void setUp() {
    super.setUp();
    index = createLocalMemoryIndex();
    searchEngine = new SearchEngineImpl(index);
    offset = 0;
    length = 0;
  }

  void test_addTypeAnnotation_classField_OK_final() {
    _indexTestUnit('''
class A {
  final f = 0;
}
''');
    assertHasAssistAt('final ', AssistKind.ADD_TYPE_ANNOTATION, '''
class A {
  final int f = 0;
}
''');
  }

  void test_addTypeAnnotation_classField_OK_int() {
    _indexTestUnit('''
class A {
  var f = 0;
}
''');
    assertHasAssistAt('var ', AssistKind.ADD_TYPE_ANNOTATION, '''
class A {
  int f = 0;
}
''');
  }

  void test_addTypeAnnotation_local_OK_Function() {
    _indexTestUnit('''
main() {
  var v = () => 1;
}
''');
    assertHasAssistAt('v =', AssistKind.ADD_TYPE_ANNOTATION, '''
main() {
  Function v = () => 1;
}
''');
  }

  void test_addTypeAnnotation_local_OK_List() {
    _indexTestUnit('''
main() {
  var v = <String>[];
}
''');
    assertHasAssistAt('v =', AssistKind.ADD_TYPE_ANNOTATION, '''
main() {
  List<String> v = <String>[];
}
''');
  }

  void test_addTypeAnnotation_local_OK_int() {
    _indexTestUnit('''
main() {
  var v = 0;
}
''');
    assertHasAssistAt('v =', AssistKind.ADD_TYPE_ANNOTATION, '''
main() {
  int v = 0;
}
''');
  }

  void test_addTypeAnnotation_local_OK_onInitializer() {
    _indexTestUnit('''
main() {
  var v = 123;
}
''');
    assertHasAssistAt('23', AssistKind.ADD_TYPE_ANNOTATION, '''
main() {
  int v = 123;
}
''');
  }

  void test_addTypeAnnotation_local_OK_onName() {
    _indexTestUnit('''
main() {
  var abc = 0;
}
''');
    assertHasAssistAt('bc', AssistKind.ADD_TYPE_ANNOTATION, '''
main() {
  int abc = 0;
}
''');
  }

  void test_addTypeAnnotation_local_OK_onVar() {
    _indexTestUnit('''
main() {
  var v = 0;
}
''');
    assertHasAssistAt('var ', AssistKind.ADD_TYPE_ANNOTATION, '''
main() {
  int v = 0;
}
''');
  }

  void test_addTypeAnnotation_local_wrong_hasTypeAnnotation() {
    _indexTestUnit('''
main() {
  int v = 42;
}
''');
    assertNoAssistAt(' = 42', AssistKind.ADD_TYPE_ANNOTATION);
  }

  void test_addTypeAnnotation_local_wrong_multiple() {
    _indexTestUnit('''
main() {
  var a = 1, b = '';
}
''');
    assertNoAssistAt('var ', AssistKind.ADD_TYPE_ANNOTATION);
  }

  void test_addTypeAnnotation_local_wrong_noValue() {
    verifyNoTestUnitErrors = false;
    _indexTestUnit('''
main() {
  var v;
}
''');
    assertNoAssistAt('var ', AssistKind.ADD_TYPE_ANNOTATION);
  }

  void test_addTypeAnnotation_local_wrong_null() {
    _indexTestUnit('''
main() {
  var v = null;
}
''');
    assertNoAssistAt('var ', AssistKind.ADD_TYPE_ANNOTATION);
  }

  void test_addTypeAnnotation_local_wrong_unknown() {
    verifyNoTestUnitErrors = false;
    _indexTestUnit('''
main() {
  var v = unknownVar;
}
''');
    assertNoAssistAt('var ', AssistKind.ADD_TYPE_ANNOTATION);
  }

  void test_addTypeAnnotation_topLevelField_OK_int() {
    _indexTestUnit('''
var V = 0;
''');
    assertHasAssistAt('var ', AssistKind.ADD_TYPE_ANNOTATION, '''
int V = 0;
''');
  }

  void test_addTypeAnnotation_topLevelField_wrong_multiple() {
    _indexTestUnit('''
var A = 1, V = '';
''');
    assertNoAssistAt('var ', AssistKind.ADD_TYPE_ANNOTATION);
  }

  void test_addTypeAnnotation_topLevelField_wrong_noValue() {
    _indexTestUnit('''
var V;
''');
    assertNoAssistAt('var ', AssistKind.ADD_TYPE_ANNOTATION);
  }

  void test_assignToLocalVariable() {
    _indexTestUnit('''
main() {
  List<int> bytes;
  readBytes();
}
List<int> readBytes() => <int>[];
''');
    assertHasAssistAt('readBytes();', AssistKind.ASSIGN_TO_LOCAL_VARIABLE, '''
main() {
  List<int> bytes;
  var readBytes = readBytes();
}
List<int> readBytes() => <int>[];
''');
    assertHasPositionGroup('NAME', 9, expectedPositions(['readBytes = ']));
    expect(
        linkedPositionGroup.suggestions,
        unorderedEquals(
            expectedSuggestions(
                LinkedEditSuggestionKind.VARIABLE,
                ['list', 'bytes2', 'readBytes'])));
  }

  void test_assignToLocalVariable_alreadyAssignment() {
    _indexTestUnit('''
main() {
  var vvv;
  vvv = 42;
}
''');
    assertNoAssistAt('vvv =', AssistKind.ASSIGN_TO_LOCAL_VARIABLE);
  }

  void test_assignToLocalVariable_throw() {
    _indexTestUnit('''
main() {
  throw 42;
}
''');
    assertNoAssistAt('throw ', AssistKind.ASSIGN_TO_LOCAL_VARIABLE);
  }

  void test_assignToLocalVariable_void() {
    _indexTestUnit('''
main() {
  f();
}
void f() {}
''');
    assertNoAssistAt('f();', AssistKind.ASSIGN_TO_LOCAL_VARIABLE);
  }

  void test_convertToBlockBody_OK_closure() {
    _indexTestUnit('''
setup(x) {}
main() {
  setup(() => print('done'));
}
''');
    assertHasAssistAt('() => print', AssistKind.CONVERT_INTO_BLOCK_BODY, '''
setup(x) {}
main() {
  setup(() {
    return print('done');
  });
}
''');
  }

  void test_convertToBlockBody_OK_method() {
    _indexTestUnit('''
class A {
  mmm() => 123;
}
''');
    assertHasAssistAt('mmm()', AssistKind.CONVERT_INTO_BLOCK_BODY, '''
class A {
  mmm() {
    return 123;
  }
}
''');
  }

  void test_convertToBlockBody_OK_onName() {
    _indexTestUnit('''
fff() => 123;
''');
    assertHasAssistAt('fff()', AssistKind.CONVERT_INTO_BLOCK_BODY, '''
fff() {
  return 123;
}
''');
  }

  void test_convertToBlockBody_OK_onValue() {
    _indexTestUnit('''
fff() => 123;
''');
    assertHasAssistAt('23;', AssistKind.CONVERT_INTO_BLOCK_BODY, '''
fff() {
  return 123;
}
''');
  }

  void test_convertToBlockBody_wrong_noEnclosingFunction() {
    _indexTestUnit('''
var v = 123;
''');
    assertNoAssistAt('v =', AssistKind.CONVERT_INTO_BLOCK_BODY);
  }

  void test_convertToBlockBody_wrong_notExpressionBlock() {
    _indexTestUnit('''
fff() {
  return 123;
}
''');
    assertNoAssistAt('fff() {', AssistKind.CONVERT_INTO_BLOCK_BODY);
  }

  void test_convertToExpressionBody_OK_closure() {
    _indexTestUnit('''
setup(x) {}
main() {
  setup(() {
    return 42;
  });
}
''');
    assertHasAssistAt('42;', AssistKind.CONVERT_INTO_EXPRESSION_BODY, '''
setup(x) {}
main() {
  setup(() => 42);
}
''');
  }

  void test_convertToExpressionBody_OK_function_onBlock() {
    _indexTestUnit('''
fff() {
  return 42;
}
''');
    assertHasAssistAt('{', AssistKind.CONVERT_INTO_EXPRESSION_BODY, '''
fff() => 42;
''');
  }

  void test_convertToExpressionBody_OK_function_onName() {
    _indexTestUnit('''
fff() {
  return 42;
}
''');
    assertHasAssistAt('ff()', AssistKind.CONVERT_INTO_EXPRESSION_BODY, '''
fff() => 42;
''');
  }

  void test_convertToExpressionBody_OK_method_onBlock() {
    _indexTestUnit('''
class A {
  m() { // marker
    return 42;
  }
}
''');
    assertHasAssistAt(
        '{ // marker',
        AssistKind.CONVERT_INTO_EXPRESSION_BODY,
        '''
class A {
  m() => 42;
}
''');
  }

  void test_convertToExpressionBody_OK_topFunction_onReturnStatement() {
    _indexTestUnit('''
fff() {
  return 42;
}
''');
    assertHasAssistAt('return', AssistKind.CONVERT_INTO_EXPRESSION_BODY, '''
fff() => 42;
''');
  }

  void test_convertToExpressionBody_wrong_already() {
    _indexTestUnit('''
fff() => 42;
''');
    assertNoAssistAt('fff()', AssistKind.CONVERT_INTO_EXPRESSION_BODY);
  }

  void test_convertToExpressionBody_wrong_moreThanOneStatement() {
    _indexTestUnit('''
fff() {
  var v = 42;
  return v;
}
''');
    assertNoAssistAt('fff()', AssistKind.CONVERT_INTO_EXPRESSION_BODY);
  }

  void test_convertToExpressionBody_wrong_noEnclosingFunction() {
    _indexTestUnit('''
var V = 42;
''');
    assertNoAssistAt('V = ', AssistKind.CONVERT_INTO_EXPRESSION_BODY);
  }

  void test_convertToExpressionBody_wrong_noReturn() {
    _indexTestUnit('''
fff() {
  var v = 42;
}
''');
    assertNoAssistAt('fff()', AssistKind.CONVERT_INTO_EXPRESSION_BODY);
  }

  void test_convertToExpressionBody_wrong_noReturnValue() {
    _indexTestUnit('''
fff() {
  return;
}
''');
    assertNoAssistAt('fff()', AssistKind.CONVERT_INTO_EXPRESSION_BODY);
  }

  void test_convertToIsNotEmpty_OK_on_isEmpty() {
    _indexTestUnit('''
main(String str) {
  !str.isEmpty;
}
''');
    assertHasAssistAt('isEmpty', AssistKind.CONVERT_INTO_IS_NOT_EMPTY, '''
main(String str) {
  str.isNotEmpty;
}
''');
  }

  void test_convertToIsNotEmpty_OK_on_str() {
    _indexTestUnit('''
main(String str) {
  !str.isEmpty;
}
''');
    assertHasAssistAt('str.', AssistKind.CONVERT_INTO_IS_NOT_EMPTY, '''
main(String str) {
  str.isNotEmpty;
}
''');
  }

  void test_convertToIsNotEmpty_OK_propertyAccess() {
    _indexTestUnit('''
main(String str) {
  !'text'.isEmpty;
}
''');
    assertHasAssistAt('isEmpty', AssistKind.CONVERT_INTO_IS_NOT_EMPTY, '''
main(String str) {
  'text'.isNotEmpty;
}
''');
  }

  void test_convertToIsNotEmpty_wrong_notInPrefixExpression() {
    _indexTestUnit('''
main(String str) {
  str.isEmpty;
}
''');
    assertNoAssistAt('isEmpty;', AssistKind.CONVERT_INTO_IS_NOT_EMPTY);
  }

  void test_convertToIsNotEmpty_wrong_notIsEmpty() {
    _indexTestUnit('''
main(int p) {
  !p.isEven;
}
''');
    assertNoAssistAt('isEven;', AssistKind.CONVERT_INTO_IS_NOT_EMPTY);
  }

  void test_convertToIsNotEmpty_wrote_noIsNotEmpty() {
    _indexTestUnit('''
class A {
  bool get isEmpty => false;
}
main(A a) {
  !a.isEmpty;
}
''');
    assertNoAssistAt('isEmpty;', AssistKind.CONVERT_INTO_IS_NOT_EMPTY);
  }

  void test_convertToIsNot_OK_childOfIs_left() {
    _indexTestUnit('''
main(p) {
  !(p is String);
}
''');
    assertHasAssistAt('p is', AssistKind.CONVERT_INTO_IS_NOT, '''
main(p) {
  p is! String;
}
''');
  }

  void test_convertToIsNot_OK_childOfIs_right() {
    _indexTestUnit('''
main(p) {
  !(p is String);
}
''');
    assertHasAssistAt('String)', AssistKind.CONVERT_INTO_IS_NOT, '''
main(p) {
  p is! String;
}
''');
  }

  void test_convertToIsNot_OK_is() {
    _indexTestUnit('''
main(p) {
  !(p is String);
}
''');
    assertHasAssistAt('is String', AssistKind.CONVERT_INTO_IS_NOT, '''
main(p) {
  p is! String;
}
''');
  }

  void test_convertToIsNot_OK_is_higherPrecedencePrefix() {
    _indexTestUnit('''
main(p) {
  !!(p is String);
}
''');
    assertHasAssistAt('is String', AssistKind.CONVERT_INTO_IS_NOT, '''
main(p) {
  !(p is! String);
}
''');
  }

  void test_convertToIsNot_OK_is_not_higherPrecedencePrefix() {
    _indexTestUnit('''
main(p) {
  !!(p is String);
}
''');
    assertHasAssistAt('!(p', AssistKind.CONVERT_INTO_IS_NOT, '''
main(p) {
  !(p is! String);
}
''');
  }

  void test_convertToIsNot_OK_not() {
    _indexTestUnit('''
main(p) {
  !(p is String);
}
''');
    assertHasAssistAt('!(p', AssistKind.CONVERT_INTO_IS_NOT, '''
main(p) {
  p is! String;
}
''');
  }

  void test_convertToIsNot_OK_parentheses() {
    _indexTestUnit('''
main(p) {
  !(p is String);
}
''');
    assertHasAssistAt('(p is', AssistKind.CONVERT_INTO_IS_NOT, '''
main(p) {
  p is! String;
}
''');
  }

  void test_convertToIsNot_wrong_is_alreadyIsNot() {
    _indexTestUnit('''
main(p) {
  p is! String;
}
''');
    assertNoAssistAt('is!', AssistKind.CONVERT_INTO_IS_NOT);
  }

  void test_convertToIsNot_wrong_is_noEnclosingParenthesis() {
    _indexTestUnit('''
main(p) {
  p is String;
}
''');
    assertNoAssistAt('is String', AssistKind.CONVERT_INTO_IS_NOT);
  }

  void test_convertToIsNot_wrong_is_noPrefix() {
    _indexTestUnit('''
main(p) {
  (p is String);
}
''');
    assertNoAssistAt('is String', AssistKind.CONVERT_INTO_IS_NOT);
  }

  void test_convertToIsNot_wrong_is_notIsExpression() {
    _indexTestUnit('''
main(p) {
  123 + 456;
}
''');
    assertNoAssistAt('123 +', AssistKind.CONVERT_INTO_IS_NOT);
  }

  void test_convertToIsNot_wrong_is_notTheNotOperator() {
    verifyNoTestUnitErrors = false;
    _indexTestUnit('''
main(p) {
  ++(p is String);
}
''');
    assertNoAssistAt('is String', AssistKind.CONVERT_INTO_IS_NOT);
  }

  void test_convertToIsNot_wrong_not_alreadyIsNot() {
    _indexTestUnit('''
main(p) {
  !(p is! String);
}
''');
    assertNoAssistAt('!(p', AssistKind.CONVERT_INTO_IS_NOT);
  }

  void test_convertToIsNot_wrong_not_noEnclosingParenthesis() {
    _indexTestUnit('''
main(p) {
  !p;
}
''');
    assertNoAssistAt('!p', AssistKind.CONVERT_INTO_IS_NOT);
  }

  void test_convertToIsNot_wrong_not_notIsExpression() {
    _indexTestUnit('''
main(p) {
  !(p == null);
}
''');
    assertNoAssistAt('!(p', AssistKind.CONVERT_INTO_IS_NOT);
  }

  void test_convertToIsNot_wrong_not_notTheNotOperator() {
    verifyNoTestUnitErrors = false;
    _indexTestUnit('''
main(p) {
  ++(p is String);
}
''');
    assertNoAssistAt('++(', AssistKind.CONVERT_INTO_IS_NOT);
  }

  void test_exchangeBinaryExpressionArguments_OK_extended_mixOperator_1() {
    _indexTestUnit('''
main() {
  1 * 2 * 3 + 4;
}
''');
    assertHasAssistAt('* 2', AssistKind.EXCHANGE_OPERANDS, '''
main() {
  2 * 3 * 1 + 4;
}
''');
  }

  void test_exchangeBinaryExpressionArguments_OK_extended_mixOperator_2() {
    _indexTestUnit('''
main() {
  1 + 2 - 3 + 4;
}
''');
    assertHasAssistAt('+ 2', AssistKind.EXCHANGE_OPERANDS, '''
main() {
  2 + 1 - 3 + 4;
}
''');
  }

  void
      test_exchangeBinaryExpressionArguments_OK_extended_sameOperator_afterFirst() {
    _indexTestUnit('''
main() {
  1 + 2 + 3;
}
''');
    assertHasAssistAt('+ 2', AssistKind.EXCHANGE_OPERANDS, '''
main() {
  2 + 3 + 1;
}
''');
  }

  void
      test_exchangeBinaryExpressionArguments_OK_extended_sameOperator_afterSecond() {
    _indexTestUnit('''
main() {
  1 + 2 + 3;
}
''');
    assertHasAssistAt('+ 3', AssistKind.EXCHANGE_OPERANDS, '''
main() {
  3 + 1 + 2;
}
''');
  }

  void test_exchangeBinaryExpressionArguments_OK_simple_afterOperator() {
    _indexTestUnit('''
main() {
  1 + 2;
}
''');
    assertHasAssistAt(' 2', AssistKind.EXCHANGE_OPERANDS, '''
main() {
  2 + 1;
}
''');
  }

  void test_exchangeBinaryExpressionArguments_OK_simple_beforeOperator() {
    _indexTestUnit('''
main() {
  1 + 2;
}
''');
    assertHasAssistAt('+ 2', AssistKind.EXCHANGE_OPERANDS, '''
main() {
  2 + 1;
}
''');
  }

  void test_exchangeBinaryExpressionArguments_OK_simple_fullSelection() {
    _indexTestUnit('''
main() {
  1 + 2;
}
''');
    length = '1 + 2'.length;
    assertHasAssistAt('1 + 2', AssistKind.EXCHANGE_OPERANDS, '''
main() {
  2 + 1;
}
''');
  }

  void test_exchangeBinaryExpressionArguments_OK_simple_withLength() {
    _indexTestUnit('''
main() {
  1 + 2;
}
''');
    length = 2;
    assertHasAssistAt('+ 2', AssistKind.EXCHANGE_OPERANDS, '''
main() {
  2 + 1;
}
''');
  }

  void test_exchangeBinaryExpressionArguments_wrong_extraLength() {
    _indexTestUnit('''
main() {
  111 + 222;
}
''');
    length = 3;
    assertNoAssistAt('+ 222', AssistKind.EXCHANGE_OPERANDS);
  }

  void test_exchangeBinaryExpressionArguments_wrong_onOperand() {
    _indexTestUnit('''
main() {
  111 + 222;
}
''');
    length = 3;
    assertNoAssistAt('11 +', AssistKind.EXCHANGE_OPERANDS);
  }

  void test_exchangeBinaryExpressionArguments_wrong_selectionWithBinary() {
    _indexTestUnit('''
main() {
  1 + 2 + 3;
}
''');
    length = '1 + 2 + 3'.length;
    assertNoAssistAt('1 + 2 + 3', AssistKind.EXCHANGE_OPERANDS);
  }

  void test_importAddShow_BAD_hasShow() {
    _indexTestUnit('''
import 'dart:math' show PI;
main() {
  PI;
}
''');
    assertNoAssistAt('import ', AssistKind.IMPORT_ADD_SHOW);
  }

  void test_importAddShow_BAD_unused() {
    _indexTestUnit('''
import 'dart:math';
''');
    assertNoAssistAt('import ', AssistKind.IMPORT_ADD_SHOW);
  }

  void test_importAddShow_OK_onDirective() {
    _indexTestUnit('''
import 'dart:math';
main() {
  PI;
  E;
  max(1, 2);
}
''');
    assertHasAssistAt('import ', AssistKind.IMPORT_ADD_SHOW, '''
import 'dart:math' show E, PI, max;
main() {
  PI;
  E;
  max(1, 2);
}
''');
  }

  void test_importAddShow_OK_onUri() {
    _indexTestUnit('''
import 'dart:math';
main() {
  PI;
  E;
  max(1, 2);
}
''');
    assertHasAssistAt('art:math', AssistKind.IMPORT_ADD_SHOW, '''
import 'dart:math' show E, PI, max;
main() {
  PI;
  E;
  max(1, 2);
}
''');
  }

  void test_invertIfStatement_blocks() {
    _indexTestUnit('''
main() {
  if (true) {
    0;
  } else {
    1;
  }
}
''');
    assertHasAssistAt('if (', AssistKind.INVERT_IF_STATEMENT, '''
main() {
  if (false) {
    1;
  } else {
    0;
  }
}
''');
  }

  void test_invertIfStatement_statements() {
    _indexTestUnit('''
main() {
  if (true)
    0;
  else
    1;
}
''');
    assertHasAssistAt('if (', AssistKind.INVERT_IF_STATEMENT, '''
main() {
  if (false)
    1;
  else
    0;
}
''');
  }

  void test_joinIfStatementInner_OK_conditionAndOr() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2 || 3 == 3) {
      print(0);
    }
  }
}
''');
    assertHasAssistAt('if (1 ==', AssistKind.JOIN_IF_WITH_INNER, '''
main() {
  if (1 == 1 && (2 == 2 || 3 == 3)) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementInner_OK_conditionInvocation() {
    _indexTestUnit('''
main() {
  if (isCheck()) {
    if (2 == 2) {
      print(0);
    }
  }
}
bool isCheck() => false;
''');
    assertHasAssistAt('if (isCheck', AssistKind.JOIN_IF_WITH_INNER, '''
main() {
  if (isCheck() && 2 == 2) {
    print(0);
  }
}
bool isCheck() => false;
''');
  }

  void test_joinIfStatementInner_OK_conditionOrAnd() {
    _indexTestUnit('''
main() {
  if (1 == 1 || 2 == 2) {
    if (3 == 3) {
      print(0);
    }
  }
}
''');
    assertHasAssistAt('if (1 ==', AssistKind.JOIN_IF_WITH_INNER, '''
main() {
  if ((1 == 1 || 2 == 2) && 3 == 3) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementInner_OK_onCondition() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2) {
      print(0);
    }
  }
}
''');
    assertHasAssistAt('1 ==', AssistKind.JOIN_IF_WITH_INNER, '''
main() {
  if (1 == 1 && 2 == 2) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementInner_OK_simpleConditions_block_block() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2) {
      print(0);
    }
  }
}
''');
    assertHasAssistAt('if (1 ==', AssistKind.JOIN_IF_WITH_INNER, '''
main() {
  if (1 == 1 && 2 == 2) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementInner_OK_simpleConditions_block_single() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2)
      print(0);
  }
}
''');
    assertHasAssistAt('if (1 ==', AssistKind.JOIN_IF_WITH_INNER, '''
main() {
  if (1 == 1 && 2 == 2) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementInner_OK_simpleConditions_single_blockMulti() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2) {
      print(1);
      print(2);
      print(3);
    }
  }
}
''');
    assertHasAssistAt('if (1 ==', AssistKind.JOIN_IF_WITH_INNER, '''
main() {
  if (1 == 1 && 2 == 2) {
    print(1);
    print(2);
    print(3);
  }
}
''');
  }

  void test_joinIfStatementInner_OK_simpleConditions_single_blockOne() {
    _indexTestUnit('''
main() {
  if (1 == 1)
    if (2 == 2) {
      print(0);
    }
}
''');
    assertHasAssistAt('if (1 ==', AssistKind.JOIN_IF_WITH_INNER, '''
main() {
  if (1 == 1 && 2 == 2) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementInner_wrong_innerNotIf() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    print(0);
  }
}
''');
    assertNoAssistAt('if (1 ==', AssistKind.JOIN_IF_WITH_INNER);
  }

  void test_joinIfStatementInner_wrong_innerWithElse() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2) {
      print(0);
    } else {
      print(1);
    }
  }
}
''');
    assertNoAssistAt('if (1 ==', AssistKind.JOIN_IF_WITH_INNER);
  }

  void test_joinIfStatementInner_wrong_targetNotIf() {
    _indexTestUnit('''
main() {
  print(0);
}
''');
    assertNoAssistAt('print', AssistKind.JOIN_IF_WITH_INNER);
  }

  void test_joinIfStatementInner_wrong_targetWithElse() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2) {
      print(0);
    }
  } else {
    print(1);
  }
}
''');
    assertNoAssistAt('if (1 ==', AssistKind.JOIN_IF_WITH_INNER);
  }

  void test_joinIfStatementOuter_OK_conditionAndOr() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2 || 3 == 3) {
      print(0);
    }
  }
}
''');
    assertHasAssistAt('if (2 ==', AssistKind.JOIN_IF_WITH_OUTER, '''
main() {
  if (1 == 1 && (2 == 2 || 3 == 3)) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementOuter_OK_conditionInvocation() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (isCheck()) {
      print(0);
    }
  }
}
bool isCheck() => false;
''');
    assertHasAssistAt('if (isCheck', AssistKind.JOIN_IF_WITH_OUTER, '''
main() {
  if (1 == 1 && isCheck()) {
    print(0);
  }
}
bool isCheck() => false;
''');
  }

  void test_joinIfStatementOuter_OK_conditionOrAnd() {
    _indexTestUnit('''
main() {
  if (1 == 1 || 2 == 2) {
    if (3 == 3) {
      print(0);
    }
  }
}
''');
    assertHasAssistAt('if (3 == 3', AssistKind.JOIN_IF_WITH_OUTER, '''
main() {
  if ((1 == 1 || 2 == 2) && 3 == 3) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementOuter_OK_onCondition() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2) {
      print(0);
    }
  }
}
''');
    assertHasAssistAt('if (2 == 2', AssistKind.JOIN_IF_WITH_OUTER, '''
main() {
  if (1 == 1 && 2 == 2) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementOuter_OK_simpleConditions_block_block() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2) {
      print(0);
    }
  }
}
''');
    assertHasAssistAt('if (2 == 2', AssistKind.JOIN_IF_WITH_OUTER, '''
main() {
  if (1 == 1 && 2 == 2) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementOuter_OK_simpleConditions_block_single() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2)
      print(0);
  }
}
''');
    assertHasAssistAt('if (2 == 2', AssistKind.JOIN_IF_WITH_OUTER, '''
main() {
  if (1 == 1 && 2 == 2) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementOuter_OK_simpleConditions_single_blockMulti() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2) {
      print(1);
      print(2);
      print(3);
    }
  }
}
''');
    assertHasAssistAt('if (2 == 2', AssistKind.JOIN_IF_WITH_OUTER, '''
main() {
  if (1 == 1 && 2 == 2) {
    print(1);
    print(2);
    print(3);
  }
}
''');
  }

  void test_joinIfStatementOuter_OK_simpleConditions_single_blockOne() {
    _indexTestUnit('''
main() {
  if (1 == 1)
    if (2 == 2) {
      print(0);
    }
}
''');
    assertHasAssistAt('if (2 == 2', AssistKind.JOIN_IF_WITH_OUTER, '''
main() {
  if (1 == 1 && 2 == 2) {
    print(0);
  }
}
''');
  }

  void test_joinIfStatementOuter_wrong_outerNotIf() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    print(0);
  }
}
''');
    assertNoAssistAt('if (1 == 1', AssistKind.JOIN_IF_WITH_OUTER);
  }

  void test_joinIfStatementOuter_wrong_outerWithElse() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2) {
      print(0);
    }
  } else {
    print(1);
  }
}
''');
    assertNoAssistAt('if (2 == 2', AssistKind.JOIN_IF_WITH_OUTER);
  }

  void test_joinIfStatementOuter_wrong_targetNotIf() {
    _indexTestUnit('''
main() {
  print(0);
}
''');
    assertNoAssistAt('print', AssistKind.JOIN_IF_WITH_OUTER);
  }

  void test_joinIfStatementOuter_wrong_targetWithElse() {
    _indexTestUnit('''
main() {
  if (1 == 1) {
    if (2 == 2) {
      print(0);
    } else {
      print(1);
    }
  }
}
''');
    assertNoAssistAt('if (2 == 2', AssistKind.JOIN_IF_WITH_OUTER);
  }

  void test_joinVariableDeclaration_onAssignment_OK() {
    _indexTestUnit('''
main() {
  var v;
  v = 1;
}
''');
    assertHasAssistAt('v =', AssistKind.JOIN_VARIABLE_DECLARATION, '''
main() {
  var v = 1;
}
''');
  }

  void test_joinVariableDeclaration_onAssignment_wrong_hasInitializer() {
    _indexTestUnit('''
main() {
  var v = 1;
  v = 2;
}
''');
    assertNoAssistAt('v = 2', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_joinVariableDeclaration_onAssignment_wrong_notAdjacent() {
    _indexTestUnit('''
main() {
  var v;
  var bar;
  v = 1;
}
''');
    assertNoAssistAt('v = 1', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_joinVariableDeclaration_onAssignment_wrong_notAssignment() {
    _indexTestUnit('''
main() {
  var v;
  v += 1;
}
''');
    assertNoAssistAt('v += 1', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_joinVariableDeclaration_onAssignment_wrong_notDeclaration() {
    _indexTestUnit('''
main(var v) {
  v = 1;
}
''');
    assertNoAssistAt('v = 1', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_joinVariableDeclaration_onAssignment_wrong_notLeftArgument() {
    _indexTestUnit('''
main() {
  var v;
  1 + v; // marker
}
''');
    assertNoAssistAt('v; // marker', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_joinVariableDeclaration_onAssignment_wrong_notOneVariable() {
    _indexTestUnit('''
main() {
  var v, v2;
  v = 1;
}
''');
    assertNoAssistAt('v = 1', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_joinVariableDeclaration_onAssignment_wrong_notResolved() {
    verifyNoTestUnitErrors = false;
    _indexTestUnit('''
main() {
  var v;
  x = 1;
}
''');
    assertNoAssistAt('x = 1', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_joinVariableDeclaration_onAssignment_wrong_notSameBlock() {
    _indexTestUnit('''
main() {
  var v;
  {
    v = 1;
  }
}
''');
    assertNoAssistAt('v = 1', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_joinVariableDeclaration_onDeclaration_OK_onName() {
    _indexTestUnit('''
main() {
  var v;
  v = 1;
}
''');
    assertHasAssistAt('v;', AssistKind.JOIN_VARIABLE_DECLARATION, '''
main() {
  var v = 1;
}
''');
  }

  void test_joinVariableDeclaration_onDeclaration_OK_onType() {
    _indexTestUnit('''
main() {
  int v;
  v = 1;
}
''');
    assertHasAssistAt('int v', AssistKind.JOIN_VARIABLE_DECLARATION, '''
main() {
  int v = 1;
}
''');
  }

  void test_joinVariableDeclaration_onDeclaration_OK_onVar() {
    _indexTestUnit('''
main() {
  var v;
  v = 1;
}
''');
    assertHasAssistAt('var v', AssistKind.JOIN_VARIABLE_DECLARATION, '''
main() {
  var v = 1;
}
''');
  }

  void test_joinVariableDeclaration_onDeclaration_wrong_hasInitializer() {
    _indexTestUnit('''
main() {
  var v = 1;
  v = 2;
}
''');
    assertNoAssistAt('v = 1', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_joinVariableDeclaration_onDeclaration_wrong_lastStatement() {
    _indexTestUnit('''
main() {
  if (true)
    var v;
}
''');
    assertNoAssistAt('v;', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void
      test_joinVariableDeclaration_onDeclaration_wrong_nextNotAssignmentExpression() {
    _indexTestUnit('''
main() {
  var v;
  42;
}
''');
    assertNoAssistAt('v;', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void
      test_joinVariableDeclaration_onDeclaration_wrong_nextNotExpressionStatement() {
    _indexTestUnit('''
main() {
  var v;
  if (true) return;
}
''');
    assertNoAssistAt('v;', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void
      test_joinVariableDeclaration_onDeclaration_wrong_nextNotPureAssignment() {
    _indexTestUnit('''
main() {
  var v;
  v += 1;
}
''');
    assertNoAssistAt('v;', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_joinVariableDeclaration_onDeclaration_wrong_notOneVariable() {
    _indexTestUnit('''
main() {
  var v, v2;
  v = 1;
}
''');
    assertNoAssistAt('v, ', AssistKind.JOIN_VARIABLE_DECLARATION);
  }

  void test_removeTypeAnnotation_classField_OK() {
    _indexTestUnit('''
class A {
  int v = 1;
}
''');
    assertHasAssistAt('v = ', AssistKind.REMOVE_TYPE_ANNOTATION, '''
class A {
  var v = 1;
}
''');
  }

  void test_removeTypeAnnotation_localVariable_OK() {
    _indexTestUnit('''
main() {
  int a = 1, b = 2;
}
''');
    assertHasAssistAt('int ', AssistKind.REMOVE_TYPE_ANNOTATION, '''
main() {
  var a = 1, b = 2;
}
''');
  }

  void test_removeTypeAnnotation_topLevelVariable_OK() {
    _indexTestUnit('''
int V = 1;
''');
    assertHasAssistAt('int ', AssistKind.REMOVE_TYPE_ANNOTATION, '''
var V = 1;
''');
  }

  void test_replaceConditionalWithIfElse_OK_assignment() {
    _indexTestUnit('''
main() {
  var v;
  v = true ? 111 : 222;
}
''');
    // on conditional
    assertHasAssistAt('11 :', AssistKind.REPLACE_CONDITIONAL_WITH_IF_ELSE, '''
main() {
  var v;
  if (true) {
    v = 111;
  } else {
    v = 222;
  }
}
''');
    // on variable
    assertHasAssistAt('v =', AssistKind.REPLACE_CONDITIONAL_WITH_IF_ELSE, '''
main() {
  var v;
  if (true) {
    v = 111;
  } else {
    v = 222;
  }
}
''');
  }

  void test_replaceConditionalWithIfElse_OK_return() {
    _indexTestUnit('''
main() {
  return true ? 111 : 222;
}
''');
    assertHasAssistAt(
        'return ',
        AssistKind.REPLACE_CONDITIONAL_WITH_IF_ELSE,
        '''
main() {
  if (true) {
    return 111;
  } else {
    return 222;
  }
}
''');
  }

  void test_replaceConditionalWithIfElse_OK_variableDeclaration() {
    _indexTestUnit('''
main() {
  int a = 1, vvv = true ? 111 : 222, b = 2;
}
''');
    assertHasAssistAt('11 :', AssistKind.REPLACE_CONDITIONAL_WITH_IF_ELSE, '''
main() {
  int a = 1, vvv, b = 2;
  if (true) {
    vvv = 111;
  } else {
    vvv = 222;
  }
}
''');
  }

  void test_replaceConditionalWithIfElse_wrong_noEnclosingStatement() {
    _indexTestUnit('''
var v = true ? 111 : 222;
''');
    assertNoAssistAt('? 111', AssistKind.REPLACE_CONDITIONAL_WITH_IF_ELSE);
  }

  void test_replaceIfElseWithConditional_OK_assignment() {
    _indexTestUnit('''
main() {
  int vvv;
  if (true) {
    vvv = 111;
  } else {
    vvv = 222;
  }
}
''');
    assertHasAssistAt(
        'if (true)',
        AssistKind.REPLACE_IF_ELSE_WITH_CONDITIONAL,
        '''
main() {
  int vvv;
  vvv = true ? 111 : 222;
}
''');
  }

  void test_replaceIfElseWithConditional_OK_return() {
    _indexTestUnit('''
main() {
  if (true) {
    return 111;
  } else {
    return 222;
  }
}
''');
    assertHasAssistAt(
        'if (true)',
        AssistKind.REPLACE_IF_ELSE_WITH_CONDITIONAL,
        '''
main() {
  return true ? 111 : 222;
}
''');
  }

  void test_replaceIfElseWithConditional_wrong_notIfStatement() {
    _indexTestUnit('''
main() {
  print(0);
}
''');
    assertNoAssistAt('print', AssistKind.REPLACE_IF_ELSE_WITH_CONDITIONAL);
  }

  void test_replaceIfElseWithConditional_wrong_notSingleStatememt() {
    _indexTestUnit('''
main() {
  int vvv;
  if (true) {
    print(0);
    vvv = 111;
  } else {
    print(0);
    vvv = 222;
  }
}
''');
    assertNoAssistAt('if (true)', AssistKind.REPLACE_IF_ELSE_WITH_CONDITIONAL);
  }

  void test_splitAndCondition_OK_innerAndExpression() {
    _indexTestUnit('''
main() {
  if (1 == 1 && 2 == 2 && 3 == 3) {
    print(0);
  }
}
''');
    assertHasAssistAt('&& 2 == 2', AssistKind.SPLIT_AND_CONDITION, '''
main() {
  if (1 == 1) {
    if (2 == 2 && 3 == 3) {
      print(0);
    }
  }
}
''');
  }

  void test_splitAndCondition_OK_thenBlock() {
    _indexTestUnit('''
main() {
  if (true && false) {
    print(0);
    if (3 == 3) {
      print(1);
    }
  }
}
''');
    assertHasAssistAt('&& false', AssistKind.SPLIT_AND_CONDITION, '''
main() {
  if (true) {
    if (false) {
      print(0);
      if (3 == 3) {
        print(1);
      }
    }
  }
}
''');
  }

  void test_splitAndCondition_OK_thenBlock_elseBlock() {
    _indexTestUnit('''
main() {
  if (true && false) {
    print(0);
  } else {
    print(1);
    if (2 == 2) {
      print(2);
    }
  }
}
''');
    assertHasAssistAt('&& false', AssistKind.SPLIT_AND_CONDITION, '''
main() {
  if (true) {
    if (false) {
      print(0);
    } else {
      print(1);
      if (2 == 2) {
        print(2);
      }
    }
  }
}
''');
  }

  void test_splitAndCondition_OK_thenStatement() {
    _indexTestUnit('''
main() {
  if (true && false)
    print(0);
}
''');
    assertHasAssistAt('&& false', AssistKind.SPLIT_AND_CONDITION, '''
main() {
  if (true)
    if (false)
      print(0);
}
''');
  }

  void test_splitAndCondition_OK_thenStatement_elseStatement() {
    _indexTestUnit('''
main() {
  if (true && false)
    print(0);
  else
    print(1);
}
''');
    assertHasAssistAt('&& false', AssistKind.SPLIT_AND_CONDITION, '''
main() {
  if (true)
    if (false)
      print(0);
    else
      print(1);
}
''');
  }

  void test_splitAndCondition_wrong() {
    _indexTestUnit('''
main() {
  if (1 == 1 && 2 == 2) {
    print(0);
  }
  print(3 == 3 && 4 == 4);
}
''');
    // not binary expression
    assertNoAssistAt('main() {', AssistKind.SPLIT_AND_CONDITION);
    // selection is not empty and includes more than just operator
    {
      length = 5;
      assertNoAssistAt('&& 2 == 2', AssistKind.SPLIT_AND_CONDITION);
    }
  }

  void test_splitAndCondition_wrong_notAnd() {
    _indexTestUnit('''
main() {
  if (1 == 1 || 2 == 2) {
    print(0);
  }
}
''');
    assertNoAssistAt('|| 2', AssistKind.SPLIT_AND_CONDITION);
  }

  void test_splitAndCondition_wrong_notPartOfIf() {
    _indexTestUnit('''
main() {
  print(1 == 1 && 2 == 2);
}
''');
    assertNoAssistAt('&& 2', AssistKind.SPLIT_AND_CONDITION);
  }

  void test_splitAndCondition_wrong_notTopLevelAnd() {
    _indexTestUnit('''
main() {
  if (true || (1 == 1 && 2 == 2)) {
    print(0);
  }
  if (true && (3 == 3 && 4 == 4)) {
    print(0);
  }
}
''');
    assertNoAssistAt('&& 2', AssistKind.SPLIT_AND_CONDITION);
    assertNoAssistAt('&& 4', AssistKind.SPLIT_AND_CONDITION);
  }

  void test_splitVariableDeclaration_OK_onName() {
    _indexTestUnit('''
main() {
  var v = 1;
}
''');
    assertHasAssistAt('v =', AssistKind.SPLIT_VARIABLE_DECLARATION, '''
main() {
  var v;
  v = 1;
}
''');
  }

  void test_splitVariableDeclaration_OK_onType() {
    _indexTestUnit('''
main() {
  int v = 1;
}
''');
    assertHasAssistAt('int ', AssistKind.SPLIT_VARIABLE_DECLARATION, '''
main() {
  int v;
  v = 1;
}
''');
  }

  void test_splitVariableDeclaration_OK_onVar() {
    _indexTestUnit('''
main() {
  var v = 1;
}
''');
    assertHasAssistAt('var ', AssistKind.SPLIT_VARIABLE_DECLARATION, '''
main() {
  var v;
  v = 1;
}
''');
  }

  void test_splitVariableDeclaration_wrong_notOneVariable() {
    _indexTestUnit('''
main() {
  var v = 1, v2;
}
''');
    assertNoAssistAt('v = 1', AssistKind.SPLIT_VARIABLE_DECLARATION);
  }

  void test_surroundWith_block() {
    _indexTestUnit('''
main() {
// start
  print(0);
  print(1);
// end
}
''');
    _setStartEndSelection();
    assertHasAssist(AssistKind.SURROUND_WITH_BLOCK, '''
main() {
// start
  {
    print(0);
    print(1);
  }
// end
}
''');
  }

  void test_surroundWith_doWhile() {
    _indexTestUnit('''
main() {
// start
  print(0);
  print(1);
// end
}
''');
    _setStartEndSelection();
    assertHasAssist(AssistKind.SURROUND_WITH_DO_WHILE, '''
main() {
// start
  do {
    print(0);
    print(1);
  } while (condition);
// end
}
''');
  }

  void test_surroundWith_for() {
    _indexTestUnit('''
main() {
// start
  print(0);
  print(1);
// end
}
''');
    _setStartEndSelection();
    assertHasAssist(AssistKind.SURROUND_WITH_FOR, '''
main() {
// start
  for (var v = init; condition; increment) {
    print(0);
    print(1);
  }
// end
}
''');
  }

  void test_surroundWith_forIn() {
    _indexTestUnit('''
main() {
// start
  print(0);
  print(1);
// end
}
''');
    _setStartEndSelection();
    assertHasAssist(AssistKind.SURROUND_WITH_FOR_IN, '''
main() {
// start
  for (var item in iterable) {
    print(0);
    print(1);
  }
// end
}
''');
  }

  void test_surroundWith_if() {
    _indexTestUnit('''
main() {
// start
  print(0);
  print(1);
// end
}
''');
    _setStartEndSelection();
    assertHasAssist(AssistKind.SURROUND_WITH_IF, '''
main() {
// start
  if (condition) {
    print(0);
    print(1);
  }
// end
}
''');
  }

  void test_surroundWith_tryCatch() {
    _indexTestUnit('''
main() {
// start
  print(0);
  print(1);
// end
}
''');
    _setStartEndSelection();
    assertHasAssist(AssistKind.SURROUND_WITH_TRY_CATCH, '''
main() {
// start
  try {
    print(0);
    print(1);
  } on Exception catch (e) {
    // TODO
  }
// end
}
''');
  }

  void test_surroundWith_tryFinally() {
    _indexTestUnit('''
main() {
// start
  print(0);
  print(1);
// end
}
''');
    _setStartEndSelection();
    assertHasAssist(AssistKind.SURROUND_WITH_TRY_FINALLY, '''
main() {
// start
  try {
    print(0);
    print(1);
  } finally {
    // TODO
  }
// end
}
''');
  }

  void test_surroundWith_while() {
    _indexTestUnit('''
main() {
// start
  print(0);
  print(1);
// end
}
''');
    _setStartEndSelection();
    assertHasAssist(AssistKind.SURROUND_WITH_WHILE, '''
main() {
// start
  while (condition) {
    print(0);
    print(1);
  }
// end
}
''');
  }

  String _applyEdits(String code, List<Edit> edits) {
    mergeSort(edits, compare: (a, b) => a.offset - b.offset);
    edits.reversed.forEach((Edit edit) {
      code = code.substring(0, edit.offset) +
          edit.replacement +
          code.substring(edit.end);
    });
    return code;
  }

  /**
   * Computes assists and verifies that there is an assist of the given kind.
   */
  Assist _assertHasAssist(AssistKind kind) {
    List<Assist> assists =
        computeAssists(searchEngine, testUnit, offset, length);
    for (Assist assist in assists) {
      if (assist.kind == kind) {
        return assist;
      }
    }
    throw fail('Expected to find assist $kind in\n${assists.join('\n')}');
  }

  void _assertHasLinkedPositions(String groupId, List<String> expectedStrings) {
    List<Position> expectedPositions = _findResultPositions(expectedStrings);
    List<LinkedEditGroup> groups = change.linkedEditGroups;
    for (LinkedEditGroup group in groups) {
      if (group.id == groupId) {
        List<Position> actualPositions = group.positions;
        expect(actualPositions, unorderedEquals(expectedPositions));
        return;
      }
    }
    fail('No group with ID=$groupId foind in\n${groups.join('\n')}');
  }

  void _assertHasLinkedProposals(String groupId, List<String> expected) {
    List<LinkedEditGroup> groups = change.linkedEditGroups;
    for (LinkedEditGroup group in groups) {
      if (group.id == groupId) {
        expect(group.suggestions, expected);
        return;
      }
    }
    fail('No group with ID=$groupId foind in\n${groups.join('\n')}');
  }

  List<Position> _findResultPositions(List<String> searchStrings) {
    List<Position> positions = <Position>[];
    for (String search in searchStrings) {
      int offset = resultCode.indexOf(search);
      positions.add(new Position(testFile, offset));
    }
    return positions;
  }

  void _indexTestUnit(String code) {
    resolveTestUnit(code);
    index.indexUnit(context, testUnit);
  }

  void _setStartEndSelection() {
    offset = findOffset('// start\n') + '// start\n'.length;
    length = findOffset('// end') - offset;
  }
}
