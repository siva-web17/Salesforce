/**
 * Created by aneesh.bhat on 1/17/2018.
 */

public with sharing class RankingServiceResponse {
    public String LeadID{get;set;}
    public Boolean IsRanked{get;set;}
    public String Error{get;set;}
    public Integer Rank{get;set;}
    public Integer OriginalScaleDownRanking{get;set;}
}