/**
 * Created by savita.b on 9/12/2017.
 */

@isTest
private class RecurrenceCampaignTest {

    static testmethod void getRecurrenceForCampaignTest() {
        Test.startTest();
        system.runAs(TestDataFactory.createAdminUser(true)) {

            Map<String,String> campaignValues = new Map<String,String>{

                    'Market__c'=>'DEB',
                    'Program__c'=>'AY',
                    'Salesoffice__c'=>'DEB',
                    'Status'=>'Active',
                    'MeetingType__c'=>'ONM',
                    'MeetingCity__c'=>'Berlin',
                    'DateFrom__c'=>String.valueOf(DateTime.now().addminutes(5)),
                    'DateTo__c'=>String.valueOf(DateTime.now().addminutes(20))
            };

            Campaign campaignRecord= TestDataFactory.createCampaign('test Campaign',campaignValues,TRUE);

            datetime date1 = date.Today();
            List<String> allDates=new List<String>();
            for(integer i=1;i<5;i++){
                DateTime date2 = date1.addDays(i);
                string myDate = date2.format('MM/dd/yyyy');
                allDates.add(myDate);
            }
            integer numberOfRecurrenceExpected = allDates.size();
            integer numberOfRecCreated = RecurrenceCampaignController.getRecurrenceDetails(allDates, campaignRecord.id);
            System.assertEquals(numberOfRecurrenceExpected, numberOfRecCreated);
        }
        Test.stopTest();
    }

    static testmethod void getRecurrenceForCampaignWithDupeTest() {
        Test.startTest();
        system.runAs(TestDataFactory.createAdminUser(true)) {
            Map<String,String> campaignValues = new Map<String,String>{

                    'Market__c'=>'DEB',
                    'Program__c'=>'AY',
                    'Salesoffice__c'=>'DEB',
                    'Status'=>'Active',
                    'MeetingType__c'=>'ONM',
                    'MeetingCity__c'=>'Berlin',
                    'DateFrom__c'=>String.valueOf(DateTime.now().addminutes(5)),
                    'DateTo__c'=>String.valueOf(DateTime.now().addminutes(20))
            };

            Campaign campaignRecord= TestDataFactory.createCampaign('test Campaign',campaignValues,TRUE);

            datetime date1 = date.Today();
            List<String> allDates = new List<String>();
            for(integer i = 0; i < 5; i++) {
                Datetime date2 = date1.addDays(i);
                string mydate = date2.format('MM/dd/yyyy');
                allDates.add(myDate);
            }
            integer numberOfRecurrenceExpected = allDates.size();
            integer numberOfRecCreated = RecurrenceCampaignController.getRecurrenceDetails(allDates, campaignRecord.id);
            System.assertEquals(numberOfRecurrenceExpected - 1, numberOfRecCreated );
        }
        Test.stopTest();
    }
}