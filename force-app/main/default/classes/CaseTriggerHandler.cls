public with sharing class CaseTriggerHandler extends TriggerHandler{

    private List<Case> newList;
    private Map<Id, Case> newMap;
    /**
     * @description CaseTriggerHandler description
     * @return   return description
     */ 
    public CaseTriggerHandler() {
        this.newList = (List<Case>) Trigger.new;
        this.newMap = (Map<Id, Case>) Trigger.newMap;
    }

    /**
     * @description beforeInsert description
     */

    public override void beforeInsert() {
        CaseTriggerHelper.validateCasesBeforeInsert(newList);
    }

    /**
     * @description beforeUpdate description
     */
    public override void beforeUpdate(){
        CaseTriggerHelper.registerAttendeesBeforeUpdate(newMap);
    }
}