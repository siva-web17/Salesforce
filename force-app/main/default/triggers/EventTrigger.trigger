trigger EventTrigger on Event ( before insert,before update,before delete,after insert,after update,after delete,after undelete ) {
   Boolean isTriggerDisabled=SFLangUtil.bypassTriggerForObject(Schema.SobjectType.Event.Name);
   if(!isTriggerDisabled)
   {
      EventsDispatcher.run();
   }
}