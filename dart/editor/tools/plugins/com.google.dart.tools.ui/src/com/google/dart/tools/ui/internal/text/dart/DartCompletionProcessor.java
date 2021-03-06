/*
 * Copyright (c) 2012, the Dart project authors.
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
package com.google.dart.tools.ui.internal.text.dart;

import com.google.common.util.concurrent.Uninterruptibles;
import com.google.dart.engine.services.assist.AssistContext;
import com.google.dart.server.CompletionIdConsumer;
import com.google.dart.tools.core.DartCore;
import com.google.dart.tools.core.DartCoreDebug;
import com.google.dart.tools.internal.corext.refactoring.util.ExecutionUtils;
import com.google.dart.tools.ui.internal.text.editor.DartEditor;
import com.google.dart.tools.ui.text.dart.ContentAssistInvocationContext;
import com.google.dart.tools.ui.text.dart.DartContentAssistInvocationContext;
import com.google.dart.tools.ui.text.editor.tmp.JavaScriptCore;

import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.jface.text.ITextViewer;
import org.eclipse.jface.text.contentassist.ContentAssistant;
import org.eclipse.jface.text.contentassist.IContextInformationValidator;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.ui.IEditorPart;

import java.util.HashMap;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;

/**
 * Java completion processor.
 */
public class DartCompletionProcessor extends ContentAssistProcessor {

  private final static String VISIBILITY = JavaScriptCore.CODEASSIST_VISIBILITY_CHECK;
  private final static String ENABLED = "enabled"; //$NON-NLS-1$
  private final static String DISABLED = "disabled"; //$NON-NLS-1$

  private IContextInformationValidator fValidator;
  protected final IEditorPart fEditor;
  private AssistContext assistContext;

  public DartCompletionProcessor(IEditorPart editor, ContentAssistant assistant, String partition) {
    super(assistant, partition);
    fEditor = editor;
  }

  /*
   * @see org.eclipse.jface.text.contentassist.IContentAssistProcessor#
   * getContextInformationValidator()
   */
  @Override
  public IContextInformationValidator getContextInformationValidator() {
    if (fValidator == null) {
      fValidator = new DartParameterListValidator();
    }
    return fValidator;
  }

  /**
   * Tells this processor to restrict is proposals to those starting with matching cases.
   * 
   * @param restrict <code>true</code> if proposals should be restricted
   */
  public void restrictProposalsToMatchingCases(boolean restrict) {
    // not yet supported
  }

  /**
   * Tells this processor to restrict its proposal to those element visible in the actual invocation
   * context.
   * 
   * @param restrict <code>true</code> if proposals should be restricted
   */
  public void restrictProposalsToVisibility(boolean restrict) {
    HashMap<String, String> options = DartCore.getOptions();
    Object value = options.get(VISIBILITY);
    if (value instanceof String) {
      String newValue = restrict ? ENABLED : DISABLED;
      if (!newValue.equals(value)) {
        options.put(VISIBILITY, newValue);
        DartCore.setOptions(options);
      }
    }
  }

  /**
   * Wait up to the given amount of time for the receiver to ready. This may involve communication
   * with the Analysis Server and should not be called on the UI thread.
   * 
   * @param millisToWait the # of milliseconds to wait for the processor to be ready
   * @return {@code true} if the processor is ready, else {@code false}
   */
  public boolean waitUntilReady(long millisToWait) {
    return DartCoreDebug.ENABLE_ANALYSIS_SERVER ? waitUntilReady_NEW(millisToWait)
        : waitUntilReady_OLD(millisToWait);
  }

  /*
   * @see com.google.dart.tools.ui.internal.text.dart.ContentAssistProcessor# createContext
   * (org.eclipse.jface.text.ITextViewer, int)
   */
  @Override
  protected ContentAssistInvocationContext createContext(ITextViewer viewer, int offset) {
    return new DartContentAssistInvocationContext(viewer, offset, fEditor, assistContext);
  }

  /*
   * @see com.google.dart.tools.ui.internal.text.dart.ContentAssistProcessor# filterAndSort
   * (java.util.List, org.eclipse.core.runtime.IProgressMonitor)
   */
  @SuppressWarnings("rawtypes")
  @Override
  protected List filterAndSortProposals(List proposals, IProgressMonitor monitor,
      ContentAssistInvocationContext context) {
    ProposalSorterRegistry.getDefault().getCurrentSorter().sortProposals(context, proposals);
    return proposals;
  }

  private boolean waitUntilReady_NEW(long millisToWait) {
    // TODO(scheglov) restore or remove for the new API
//  collector.acceptContext(new InternalCompletionContext());
    final CountDownLatch latch = new CountDownLatch(1);
    final DartEditor dartEditor = (DartEditor) fEditor;
    String filePath = dartEditor.getInputFilePath();
    int offset = dartEditor.getCachedSelectedRange().x;
    DartCore.getAnalysisServer().getCompletionSuggestions(
        filePath,
        offset,
        new CompletionIdConsumer() {
          @Override
          public void computedCompletionId(String completionId) {
            System.out.println(completionId);
            latch.countDown();
          }
        });
    Uninterruptibles.awaitUninterruptibly(latch, 8, TimeUnit.SECONDS);
    return false;
  }

  private boolean waitUntilReady_OLD(long millisToWait) {
    final DartEditor dartEditor = (DartEditor) fEditor;
    DartReconcilingStrategy strategy = dartEditor.getDartReconcilingStrategy();
    if (strategy != null) {
      strategy.reconcile();
    }
    long endTime = System.currentTimeMillis() + millisToWait;
    while (System.currentTimeMillis() < endTime) {
      StyledText control = dartEditor.getViewer().getTextWidget();
      if (control.isDisposed()) {
        return false;
      }
      control.getDisplay().syncExec(new Runnable() {
        @Override
        public void run() {
          assistContext = dartEditor.getAssistContext();
        }
      });
      if (assistContext != null) {
        return true;
      }
      ExecutionUtils.sleep(5);
    }
    return false;
  }
}
