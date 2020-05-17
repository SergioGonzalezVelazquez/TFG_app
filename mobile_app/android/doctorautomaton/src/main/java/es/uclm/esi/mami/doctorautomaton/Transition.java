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
public class Transition {
    String evtName;
    String startState;
    String endState;

    /**
     * Create a transition object that responds to the given event when in
     * the given startState, and puts the FSM into the endState provided.
     */
    public Transition(String evtName, String startState, String endState) {
      this.evtName = evtName;
      this.startState = startState;
      this.endState = endState;
    }

    public String getEventName(){
      return this.evtName;
    }    
    
    public String getStartState(){
      return this.startState;
    }    
    
    public String getEndState(){
      return this.endState;
    }

    /**
     * Override this to have FSM execute code immediately before following a
     * state transition.
     */
    public void doBeforeTransition() {
    }

    /**
     * Override this to have FSM execute code immediately after following a
     * state transition.
     */
    public void doAfterTransition() {
    }
 }

