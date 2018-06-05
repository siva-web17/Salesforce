trigger DcDiscardTrigger on dupcheck__dcDiscard__c (after update,after insert,before insert,before update,after delete,before delete) {
  Boolean isTriggerDisabled=SFLangUtil.bypassTriggerForObject(Schema.SobjectType.dupcheck__dcDiscard__c.Name);
    if(!isTriggerDisabled) {
      DcDiscardsDispatcher.run();
    }
}