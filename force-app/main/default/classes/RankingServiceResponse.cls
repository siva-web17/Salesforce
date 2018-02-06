/**
 * Created by aneesh.bhat on 1/17/2018.
 */

public with sharing class RankingServiceResponse {
    public String SalesForceApplicationId{get;set;}
    public Boolean IsRanked{get;set;}
    public String Error{get;set;}
    public Integer ScaleDownRanking{get;set;}
    public Integer OriginalScaleDownRanking{get;set;}
}