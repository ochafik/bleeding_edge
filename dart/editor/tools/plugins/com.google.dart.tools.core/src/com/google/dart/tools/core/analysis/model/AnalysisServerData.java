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

package com.google.dart.tools.core.analysis.model;

import com.google.dart.engine.error.ErrorCode;
import com.google.dart.engine.source.Source;
import com.google.dart.server.AnalysisError;
import com.google.dart.server.AnalysisServer;
import com.google.dart.server.HighlightRegion;
import com.google.dart.server.NavigationRegion;
import com.google.dart.server.Occurrences;
import com.google.dart.server.Outline;
import com.google.dart.server.OverrideMember;

/**
 * Instances of {@code AnalysisServerData} provide access to analysis results reported by
 * {@link AnalysisServer}.
 * 
 * @coverage dart.tools.core.model
 */
public interface AnalysisServerData {
  void addSearchResultsListener(String id, SearchResultsListener listener);

  /**
   * Returns {@link AnalysisError}s associated with the given file. May be empty, but not
   * {@code null}.
   */
  AnalysisError[] getErrors(String file);

  /**
   * Returns {@link NavigationRegion}s associated with the given context and {@link Source}. May be
   * empty, but not {@code null}.
   */
  NavigationRegion[] getNavigation(String file);

  /**
   * Returns {@link Occurrences}s associated with the given context and {@link Source}. May be
   * empty, but not {@code null}.
   */
  Occurrences[] getOccurrences(String file);

  /**
   * Returns {@code true} if the given {@link ErrorCode} may be fixed in the given file.
   */
  boolean isFixableErrorCode(String file, ErrorCode errorCode);

  void removeSearchResultsListener(String id, SearchResultsListener listener);

  /**
   * Specifies that the client wants to be notified about new {@link HighlightRegion}s.
   */
  void subscribeHighlights(String file, AnalysisServerHighlightsListener listener);

  /**
   * Specifies that the client wants to request navigation regions.
   */
  void subscribeNavigation(String file);

  /**
   * Specifies that the client wants to request occurrences.
   */
  void subscribeOccurrences(String file);

  /**
   * Specifies that the client wants to be notified about new {@link Outline}.
   */
  void subscribeOutline(String file, AnalysisServerOutlineListener listener);

  /**
   * Specifies that the client wants to be notified about new {@link OverrideMember}s.
   */
  void subscribeOverrides(String file, AnalysisServerOverridesListener listener);

  /**
   * Specifies that the client doesn't want to be notified about {@link HighlightRegion}s anymore.
   */
  void unsubscribeHighlights(String file, AnalysisServerHighlightsListener listener);

  /**
   * Specifies that the client doesn't need navigation information for the given file anymore.
   */
  void unsubscribeNavigation(String file);

  /**
   * Specifies that the client doesn't need occurrences information for the given file anymore.
   */
  void unsubscribeOccurrences(String file);

  /**
   * Specifies that the client doesn't want to be notified about {@link Outline} anymore.
   */
  void unsubscribeOutline(String file, AnalysisServerOutlineListener listener);

  /**
   * Specifies that the client doesn't want to be notified about {@link OverrideMember}s anymore.
   */
  void unsubscribeOverrides(String file, AnalysisServerOverridesListener listener);
}
