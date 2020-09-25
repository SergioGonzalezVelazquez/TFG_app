/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.uclm.esi.mami.doctorautomaton;

import java.util.HashMap;
import java.util.Map;

/**
 *
 * @author alf
 */
public class State {
    Map<String, Transition> transitions;
    String autoTransitionState;
    Runnable entryCode;
    Runnable outputCode;
    Runnable endStateCode;

    State(Runnable entryCode, Runnable exitCode, Runnable endStateCode) {
      autoTransitionState = null;
      transitions = new HashMap<String, Transition>();
      this.outputCode = exitCode;
      this.entryCode = entryCode;
      this.endStateCode = endStateCode;
    }

    public void addTransition(Transition trans) {
      transitions.put(trans.evtName, trans);
    }

    public void runEntryCode() {
      if (entryCode != null) {
        entryCode.run();
      }
    }

    public void runExitCode() {
      if (outputCode != null) {
        outputCode.run();
      }
    }
    
    public void runEndStateCode() {
        endStateCode.run();
    }
  }
