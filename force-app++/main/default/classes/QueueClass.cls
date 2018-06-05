public class QueueClass implements Queueable {
    Set<Id> recordids;
    public QueueClass(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }
    public void execute(QueueableContext context) {
         DcDiscardsHelper.WebServiceCallForRankingAfterFalseDupe(recordIds);
    }
}