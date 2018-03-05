/**
* Created by arjun.mohan on 1/23/2018.
*/

public  class LTCourseProgramsSelector {

    Public static Map<Id,LTCourseProgram__c> getLTCoursePrograms(String market,String year,String brochureSeason,String currencycode)
    {
        system.debug('market' +market);
        system.debug('Year__c' +year);
        system.debug('brochureSeason' +brochureSeason);
        system.debug('CurrencyIsoCode' +currencycode);
        Map<Id,LTCourseProgram__c> LtProgramMap=new Map<Id,LTCourseProgram__c>();
        String status='Active';
        List<LTCourseProgram__c> LTCourseProgramsList=new List<LTCourseProgram__c>();
        if (String.isNotBlank(market) && String.isNotBlank(year)  && String.isNotBlank(brochureSeason) && String.isNotBlank(currencycode)) {
            String query = 'SELECT ';
            for (Schema.FieldSetMember f : SObjectType.LTCourseProgram__c.FieldSets.LTCourseProgramFieldSet.getFields()) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id,Name,Apttus_Config2_ProductId__c from LTCourseProgram__c  ' ;
            query +=     ' where Market__c = : ' + 'market' + ' and  Year__c = : ' + 'year' + ' and BrochureSeason__c = : ' + ' brochureSeason' +  '  and  CurrencyIsoCode = : ' + 'currencycode' + ' and CourseStatus__c = : ' + 'status' + ' ' ;
            system.debug('query' +query);
            LTCourseProgramsList=Database.query(query);
            for (LTCourseProgram__c LtRecord:LTCourseProgramsList) {
                LtProgramMap.put(LtRecord.Id,LtRecord);

            }
            system.debug('LtProgramMap' +LtProgramMap);
        }
        return LtProgramMap;
    }

}