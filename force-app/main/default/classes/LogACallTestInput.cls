/**
 * Created by aneesh.bhat on 3/12/2018.
 */

public class LogACallTestInput {
    public string CallAction{get;set;}
    public string SubAction{get;set;}
    public String Comments{get;set;}
    public String CallResult{get;set;}
    public DateTime ActionDateTime{get;set;}
    public String CloseReason{get;set;}
    public Id recordId{get;set;}
    public String Program{get;set;}
    public DateTime VisitDatetime{get;set;}
    public String LikelihoodToBook{get;set;}
    public String HearAboutUs{get;set;}
    public String Destination{get;set;}
    public String Duration{get;set;}
    public String WhenYear{get;set;}
    public String WhenMonth{get;set;}
    public DateTime BookOn{get;set;}
    public LogACallTestInput(String callAction,String subAction, String comments, String callResult, DateTime actionDateTime,String closeReason,
    Id recordId,String program, DateTime visitDatetime, String likelihoodToBook, String hearAboutUs, String destination,
    String duration, String whenYear, String whenMonth, Datetime bookOn){
        this.CallAction = callAction;
        this.SubAction = subAction;
        this.Comments = comments;
        this.CallResult = callResult;
        this.ActionDateTime = actionDateTime;
        this.CloseReason = closeReason;
        this.recordId = recordId;
        this.Program = program;
        this.VisitDatetime = visitDatetime;
        this.LikelihoodToBook = likelihoodToBook;
        this.HearAboutUs = hearAboutUs;
        this.Destination = destination;
        this.Duration = duration;
        this.WhenYear = whenYear;
        this.WhenMonth = whenMonth;
        this.BookOn = bookOn;
    }
}