/*
 * Copyright (c) 2014, the Dart project authors.
 * 
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */
package com.google.dart.server;

/**
 * An enumeration of the various refactoring kinds built into the server.
 */
public class RefactoringKind {
  public static final String CONVERT_GETTER_TO_METHOD = "CONVERT_GETTER_TO_METHOD";
  public static final String CONVERT_METHOD_TO_GETTER = "CONVERT_METHOD_TO_GETTER";
  public static final String EXTRACT_LOCAL_VARIABLE = "EXTRACT_LOCAL_VARIABLE";
  public static final String EXTRACT_METHOD = "EXTRACT_METHOD";
  public static final String INLINE_LOCAL_VARIABLE = "INLINE_LOCAL_VARIABLE";
  public static final String INLINE_METHOD = "INLINE_METHOD";
  public static final String RENAME = "RENAME";
}
