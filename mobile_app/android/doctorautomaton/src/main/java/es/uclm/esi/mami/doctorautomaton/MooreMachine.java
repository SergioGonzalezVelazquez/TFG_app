/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.uclm.esi.mami.doctorautomaton;

/**
 *
 * @author alf
 */
import java.util.HashMap;
import java.util.Map;
import java.util.NoSuchElementException;

/**
 * A programmable Finite State Machine implementation. To use this class,
 * establish any number of states with the 'addState' method. Next, add some
 * MooreMachine.Transition objects (the Transition class is designed to be used as an
 * superclass for your anonymous implementation). Each Transition object has two
 * useful methods that can be defined by your implementation: doBeforeTransition
 * and doAfterTransition. To drive your MooreMachine, simply give it events using the
 * addEvent method with the name of an event. If there is an appropriate
 * transition for the current state, the transition's doBefore/doAfter methods
 * are called and the MooreMachine is put into the new state. It is legal (and highly
 * useful) for the start/end states of a transition to be the same state.
 **/
public class MooreMachine { // This class implements a Flying Spaghetti Monster

  protected String name;
  protected String currentState;
  protected String lastState;
  public Map<String, State> states;
  protected boolean debug;

  /**
   * Create a blank MooreMachine with the given name (which is arbitrary).
   */
  public MooreMachine(String name) {
    this.name = name;
    this.states = new HashMap<String, State>();
    this.currentState = null;
    this.lastState = null;
  }

  public void setName(String name) {
    this.name = name;
  }
  /**
   * Turn debugging on/off.
   */
  public void setDebugMode(boolean debug) {
    this.debug = debug;
  }

  /**
   * Report the current state of the finite state machine.
   */
  public String getState() {
    return currentState;
  }

  /**
   * Adds a new state with no entry or exit code.
   */
  public void addState(String state) {
    addState(state, null, null, null);
  }

  /**
   * Establish a new state the MooreMachine is aware of. If the MooreMachine does not currently
   * have any states, this state becomes the current, initial state. This is
   * the only way to put the MooreMachine into an initial state.
   * 
   * The entryCode, exitCode, and alwaysRunCode are Runnables that the MooreMachine
   * executes during the course of a transition. entryCode and exitCode are
   * run only if the transition is between two distinct states (i.e. A->B
   * where A != B). alwaysRunCode is executed even if the transition is
   * re-entrant (i.e. A->B where A = B).
   **/
  public void addState(String state, Runnable entryCode, Runnable exitCode, Runnable endStateCode) {
    boolean isInitial = (states.size() == 0);
    if (!states.containsKey(state)) {
      states.put(state, new State(entryCode,exitCode,endStateCode));
    }
    if (isInitial) {
      setState(state);
    }
  }

  public void setStateEntryCode(String state, Runnable entryCode) {
    states.get(state).entryCode = entryCode;
  }

  public void setStateExitCode(String state, Runnable exitCode) {
    states.get(state).outputCode = exitCode;
  }

  /**
   * There are cases where a state is meant to be transitional, and the MooreMachine
   * should always immediately transition to some other state. In those cases,
   * use this method to specify the start and end states. After the startState
   * has fully transitioned (and any change events have been fired) the MooreMachine
   * will check to see if there is another state that the MooreMachine should
   * automatically transition to. If there is one, addEvent(endState) is
   * called.
   * 
   * Note: this creates a special transition in the lookup table called
   * "(auto)".
   */
  public void setAutoTransition(String startState, String endState) {
    // if (debug) {
    // Debug.out("MooreMachine", "Establishing auto transition for " + startState +
    // " -> " + endState);
    // }
    states.get(startState).autoTransitionState = endState;
    addTransition(new Transition("(auto)", startState, endState));
  }

  /**
   * Sets the current state without following a transition. This will cause a
   * change event to be fired.
   */
  public void setState(String state) {
    setState(state, true);
  }

  /**
   * Sets the current state without followign a transition, and optionally
   * causing a change event to be triggered. During state transitions (with
   * the 'addEvent' method), this method is used with the triggerEvent
   * parameter as false.
   * 
   * The MooreMachine executes non-null runnables according to the following logic,
   * given start and end states A and B:
   * 
   * <ol>
   * <li>If A and B are distinct, run A's exit code.</li>
   * <li>Record current state as B.</li>
   * <li>Run B's "alwaysRunCode".</li>
   * <li>If A and B are distinct, run B's entry code.</li>
   * </ol>
   */
  public void setState(String state, boolean triggerEvent) {
    boolean runExtraCode = !state.equals(currentState);
    if (runExtraCode && currentState != null) {
      states.get(currentState).runExitCode();
    }
    currentState = state;
    if (runExtraCode) {
      states.get(currentState).runEntryCode();
    }
    if (triggerEvent) {
    }
  }

  /**
   * Establish a new transition. You might use this method something like
   * this:
   * 
   * fsm.addTransition(new MooreMachine.Transition("someEvent", "firstState",
   * "secondState") { public void doBeforeTransition() {
   * System.out.println("about to transition..."); } public void
   * doAfterTransition() { fancyOperation(); } });
   */
  public void addTransition(Transition trans) {
    State st = states.get(trans.startState);
    if (st == null) {
      throw new NoSuchElementException("Missing state: "
          + trans.startState);
    }
    st.addTransition(trans);
  }

  /**
   * Feed the MooreMachine with the named event. If the current state has a transition
   * that responds to the given event, the MooreMachine will performed the transition
   * using the following steps, assume start and end states are A and B:
   * 
   * <ol>
   * <li>Execute the transition's "doBeforeTransition" method</li>
   * <li>Run fsm.setState(B) -- see docs for that method</li>
   * <li>Execute the transition's "doAfterTransition" method</li>
   * <li>Fire a change event, notifying interested observers that the
   * transition has completed.</li>
   * <li>Now firmly in state B, see if B has a third state C that we must
   * automatically transition to via addEvent(C).</li>
   * </ol>
   */
  public void addEvent(String evtName) {
    State state = states.get(currentState);
    if (state.transitions.containsKey(evtName)) {
      Transition trans = state.transitions.get(evtName);
      // if (debug) {
      // Debug.out("MooreMachine", "Event: " + evtName + ", " + trans.startState +
      // " --> " + trans.endState);
      // }
      setLastState(trans.startState);
      setState(trans.endState, false);
      if (states.get(trans.endState).autoTransitionState != null) {
        // if (debug) {
        // Debug.out("MooreMachine", "Automatically transitioning from " +
        // trans.endState + " to "
        // + states.get(trans.endState).autoTransitionState);
        // }
        addEvent("(auto)");
      }
    }
  }

  public String getLastState() {
    return lastState;
  }

  public void setLastState(String lastState) {
    this.lastState = lastState;
  }
}


   

