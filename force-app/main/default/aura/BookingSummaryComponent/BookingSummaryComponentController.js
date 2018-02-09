({
  doInit: function(component, event, helper) {
         var quoteid = component.get("v.QuoteId");
         var Oppid = component.get("v.OpportunityID")
         //alert(quoteid); 
		 var action = component.get("c.dataBind");
         action.setParams({
            "QuoteId": component.get("v.QuoteId")
         });
      
          action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
              
            if (state == "SUCCESS") {
              //set response value in wrapperList attribute on component.
              var json_text = JSON.stringify(response.getReturnValue());
              console.log(json_text);
              component.set('v.wrapperList', response.getReturnValue());
              var u = component.get("v.wrapperList");
              component.set('v.pickGender',u.personAcc.Gender__c);
              component.set('v.salesoffval',u.opp.SalesOffice__c); 
              component.set('v.selectedCountry',u.personAcc.PersonMailingCountry);
              //component.set('v.selectedState',u.personAcc.PersonMailingState);
  			  component.set('v.selectedNationality',u.personAcc.Nationality__c);
              component.set('v.selectedPassportType',u.personAcc.PassportType__c);
              component.set('v.selectedBookingChannel',u.Quote.BookingChannel__c);
              component.set('v.pickBookingType',u.Quote.BookingType__c);
              component.set('v.pickCurrency',u.Quote.CurrencyIsoCode);
              //component.set('v.canLoadComponent',);
               //alert('pick======>' +component.get("v.pick"));
                
               /* var so = component.get("v.wrapperList");
              component.set('v.pick',so.opp.SalesOffice__c);
              alert('pick1======>' +component.get("v.pick"));  */
               
            }
          });
          $A.enqueueAction(action);
      var GenderAction = component.get("c.GetGender");
      //debugger;
       GenderAction.setCallback(this,function(res){
           
          switch(res.getState()){
              case 'SUCCESS':
                  var Gender = JSON.parse(res.getReturnValue());
                  var p = component.get("v.pickGender"); 
                  console.log('p=====>' +p);
                  var genderValue1 = component.get("v.genderValue");
					Gender.forEach(function(el){
                        console.log('el=========>' +el);
                        if(p != el){
                        	genderValue1.push({'label': el, 'value': el})
                        }
                        
                    })
                    
                    console.log('=========>' +genderValue1);
                    component.set('v.genderValue', genderValue1);
					console.log('=========>' +component.get('v.genderValue'));
                  	//$A.enqueueAction(component.get('c.doSomething'));
					//component.set('v.wrapperList.personAcc.Gender__pc', res.getReturnValue());
						debugger;
                  break;
              case 'INCOMPLETE':
                  break;
              case 'ERROR':
                  break;
          }
           
       });
       $A.enqueueAction(GenderAction);
    	//component.set('v.pick1',u.opp.SalesOffice__c);
    	//
    	//
    
     var CurrencyAction = component.get("c.GetCurrency");
      //debugger;
       CurrencyAction.setCallback(this,function(res){
           
          switch(res.getState()){
              case 'SUCCESS':
                  var Currency = JSON.parse(res.getReturnValue());
                  var p = component.get("v.pickCurrency"); 
                  console.log('p=====>' +p);
                  var CurrencyValue1 = component.get("v.CurrencyValue");
					Currency.forEach(function(el){
                        console.log('el=========>' +el);
                        if(p != el){
                        	CurrencyValue1.push({'label': el, 'value': el})
                        }
                        
                    })
                    
                    console.log('=========>' +CurrencyValue1);
                    component.set('v.CurrencyValue', CurrencyValue1);
					console.log('=========>' +component.get('v.CurrencyValue'));
                  	//$A.enqueueAction(component.get('c.doSomething'));
					//component.set('v.wrapperList.personAcc.Gender__pc', res.getReturnValue());
						debugger;
                  break;
              case 'INCOMPLETE':
                  break;
              case 'ERROR':
                  break;
          }
           
       });
       $A.enqueueAction(CurrencyAction);
      
      var SalesOfficeAction = component.get("c.GetSalesOffice");
      //debugger;
       SalesOfficeAction.setCallback(this,function(res){
           						//debugger;

          switch(res.getState()){
              case 'SUCCESS':
                  var SalesOffice = JSON.parse(res.getReturnValue());
                  var s = component.get("v.salesoffval"); 
                  console.log('s=====>' +s);
                  var SalesOfficeValue1 = component.get("v.SalesOfficeValue");
                  						//debugger;

					SalesOffice.forEach(function(el){
                        console.log('el=========>' +el);
                        if(s != el){
                        	SalesOfficeValue1.push({'label': el, 'value': el})
                            						//debugger;

                        }
                        
                    })
                    
                    console.log('=========>' +SalesOfficeValue1);
                    component.set('v.SalesOfficeValue', SalesOfficeValue1);
					console.log('=========>' +component.get('v.SalesOfficeValue'));
                  	
						debugger;
                  break;
              case 'INCOMPLETE':
                  break;
              case 'ERROR':
                  break;
          }
           
       });
       $A.enqueueAction(SalesOfficeAction);
      
      var CountryAction = component.get("c.GetCountryValues");
      //debugger;
       CountryAction.setCallback(this,function(res){
           
          switch(res.getState()){
              case 'SUCCESS':
                  var Countries = JSON.parse(res.getReturnValue());
                  var p = component.get("v.selectedCountry"); 
                  console.log('p=====>' +p);
                  var maillingCountryValue1 = component.get("v.maillingCountryValue");
					Countries.forEach(function(el){
                        console.log('el=========>' +el);
                        if(p != el){
                        	maillingCountryValue1.push({'label': el, 'value': el})
                        }
                        
                    })
                    
                    console.log('=========>' +maillingCountryValue1);
                    component.set('v.maillingCountryValue', maillingCountryValue1);
					console.log('=========>' +component.get('v.maillingCountryValue'));
                  	//$A.enqueueAction(component.get('c.doSomething'));
					//component.set('v.wrapperList.personAcc.Gender__pc', res.getReturnValue());
						debugger;
                  break;
              case 'INCOMPLETE':
                  break;
              case 'ERROR':
                  break;
          }
           
       });
       $A.enqueueAction(CountryAction);
      
       /*var StateAction = component.get("c.GetStateValues");
      //debugger;
       StateAction.setCallback(this,function(res){
           
          switch(res.getState()){
              case 'SUCCESS':
                  var Countries = JSON.parse(res.getReturnValue());
                  var p = component.get("v.selectedState"); 
                  console.log('p=====>' +p);
                  var maillingStateValue1 = component.get("v.maillingStateValue");
					Countries.forEach(function(el){
                        console.log('el=========>' +el);
                        if(p != el){
                        	maillingStateValue1.push({'label': el, 'value': el})
                        }
                        
                    })
                    
                    console.log('=========>' +maillingStateValue1);
                    component.set('v.maillingStateValue', maillingStateValue1);
					console.log('=========>' +component.get('v.maillingStateValue'));
                  	//$A.enqueueAction(component.get('c.doSomething'));
					//component.set('v.wrapperList.personAcc.Gender__pc', res.getReturnValue());
						debugger;
                  break;
              case 'INCOMPLETE':
                  break;
              case 'ERROR':
                  break;
          }
           
       });
       $A.enqueueAction(StateAction);*/
      
      var NationalityAction = component.get("c.GetNationality");
      //debugger;
       NationalityAction.setCallback(this,function(res){
           
          switch(res.getState()){
              case 'SUCCESS':
                  var Nationality = JSON.parse(res.getReturnValue());
                  var p = component.get("v.selectedNationality"); 
                  console.log('p=====>' +p);
                  var Nationalities1 = component.get("v.Nationalities");
					Nationality.forEach(function(el){
                        console.log('el=========>' +el);
                        if(p != el){
                        	Nationalities1.push({'label': el, 'value': el})
                        }
                        
                    })
                    
                    console.log('=========>' +Nationalities1);
                    component.set('v.Nationalities', Nationalities1);
					console.log('=========>' +component.get('v.Nationalities'));
                  	//$A.enqueueAction(component.get('c.doSomething'));
					//component.set('v.wrapperList.personAcc.Gender__pc', res.getReturnValue());
						debugger;
                  break;
              case 'INCOMPLETE':
                  break;
              case 'ERROR':
                  break;
          }
           
       });
       $A.enqueueAction(NationalityAction);
      
      var PassportTypeAction = component.get("c.GetPassportType");
      //debugger;
       PassportTypeAction.setCallback(this,function(res){
           
          switch(res.getState()){
              case 'SUCCESS':
                  var PassportType = JSON.parse(res.getReturnValue());
                  var p = component.get("v.selectedPassportType"); 
                  console.log('p=====>' +p);
                  var PassportTypes1 = component.get("v.PassportTypes");
					PassportType.forEach(function(el){
                        console.log('el=========>' +el);
                        if(p != el){
                        	PassportTypes1.push({'label': el, 'value': el})
                        }
                        
                    })
                    
                    console.log('=========>' +PassportTypes1);
                    component.set('v.PassportTypes', PassportTypes1);
					console.log('=========>' +component.get('v.PassportTypes'));
                  	//$A.enqueueAction(component.get('c.doSomething'));
					//component.set('v.wrapperList.personAcc.Gender__pc', res.getReturnValue());
						debugger;
                  break;
              case 'INCOMPLETE':
                  break;
              case 'ERROR':
                  break;
          }
           
       });
       $A.enqueueAction(PassportTypeAction);
      
      var BookingChannelAction = component.get("c.GetBookingChannel");
      //debugger;
       BookingChannelAction.setCallback(this,function(res){
           
          switch(res.getState()){
              case 'SUCCESS':
                  var BookingChannel = JSON.parse(res.getReturnValue());
                  var p = component.get("v.selectedBookingChannel"); 
                  console.log('p=====>' +p);
                  var BookingChannels1 = component.get("v.BookingChannels");
					BookingChannel.forEach(function(el){
                        console.log('el=========>' +el);
                        if(p != el){
                        	BookingChannels1.push({'label': el, 'value': el})
                        }
                        
                    })
                    
                    console.log('=========>' +BookingChannels1);
                    component.set('v.BookingChannels', BookingChannels1);
					console.log('=========>' +component.get('v.BookingChannels'));
                  	//$A.enqueueAction(component.get('c.doSomething'));
					//component.set('v.wrapperList.personAcc.Gender__pc', res.getReturnValue());
						debugger;
                  break;
              case 'INCOMPLETE':
                  break;
              case 'ERROR':
                  break;
          }
           
       });
       $A.enqueueAction(BookingChannelAction);


	var BookingTypeAction = component.get("c.GetBookingType");
      //debugger;
       BookingTypeAction.setCallback(this,function(res){
           
          switch(res.getState()){
              case 'SUCCESS':
                  var BookingType = JSON.parse(res.getReturnValue());
                  var p = component.get("v.pickBookingType"); 
                  console.log('p=====>' +p);
                  var BookingType1 = component.get("v.BookingTypeValue");
					BookingType.forEach(function(el){
                        console.log('el=========>' +el);
                        if(p != el){
                        	BookingType1.push({'label': el, 'value': el})
                        }
                        
                    })
                    
                    console.log('=========>' +BookingType1);
                    component.set('v.BookingTypeValue', BookingType1);
					console.log('=========>' +component.get('v.BookingTypeValue'));
                  	//$A.enqueueAction(component.get('c.doSomething'));
					//component.set('v.wrapperList.personAcc.Gender__pc', res.getReturnValue());
						debugger;
                  break;
              case 'INCOMPLETE':
                  break;
              case 'ERROR':
                  break;
          }
           
       });
       $A.enqueueAction(BookingTypeAction);
      
      /*var SalesOfficeAction = component.get("c.GetSalesOffice");
       SalesOfficeAction.setCallback(this,function(res){
           
          switch(res.getState()){
              case 'SUCCESS':
                  var SalesOffice = JSON.parse(res.getReturnValue());
                  component.set('v.SalesOffice',SalesOffice);
                  break;
              case 'INCOMPLETE':
                  break;
              case 'ERROR':
                  break;
          }
       });
       $A.enqueueAction(SalesOfficeAction);*/
  },
    
    getGenderValue: function (component, event, helper) {
    	var OptionSel = component.find("path_1_Field").get("v.value");
        component.set("v.wrapperList.personAcc.Gender__c", OptionSel);
     	console.log(OptionSel);     
        
    }, 
    
    getSalesOfficeValue: function (component, event, helper) {
    	var OptionSelect = component.find("path_4_Fields").get("v.value");
        component.set("v.wrapperList.opp.SalesOffice__c", OptionSelect);
     	console.log(OptionSelect);
    },
    
    getCountryValue: function (component, event, helper) {
    	var OptionSelect = component.find("path_1_fields").get("v.value");
        component.set("v.wrapperList.personAcc.PersonMailingCountry", OptionSelect);
     	console.log(OptionSelect);
    },

    getSelectedNationalityValue: function (component, event, helper) {
    	var OptionSelect = component.find("path_3_Fields").get("v.value");
        component.set("v.wrapperList.personAcc.Nationality__c", OptionSelect);
     	console.log(OptionSelect);
    },
    
    getSelectedPassportType: function (component, event, helper) {
    	var OptionSelect = component.find("path_5_Field").get("v.value");
        component.set("v.wrapperList.personAcc.PassportType__c", OptionSelect);
     	console.log(OptionSelect);
    },

    getSelectedBookingType: function (component, event, helper) {
        	var OptionSelect = component.find("path_4_Fields").get("v.value");
            component.set("v.wrapperList.Quote.BookingType__c", OptionSelect);
         	console.log(OptionSelect);
        },

    getSelectedCurrency: function (component, event, helper) {
            	var OptionSelect = component.find("path_4_Fields").get("v.value");
                component.set("v.wrapperList.Quote.CurrencyIsoCode", OptionSelect);
             	console.log(OptionSelect);
    },
    
    getSelectedBookingChannel: function (component, event, helper) {
    	var OptionSelect = component.find("path_6_Fields").get("v.value");
        component.set("v.wrapperList.Quote.BookingChannel__c", OptionSelect);
     	console.log(OptionSelect);
    },

    genderDetails: function(component, event, helper) {
    
     
      
    /*var BookingType = [{value: "", label: "Please select"}, 
                {value: "PRE", label: "Pre-Application"}, 
                {value: "BKN", label: "Booking"}];
    component.set("v.BookingType", BookingType);
      
      var SalesOffice = [{value: "", label: "Please select"},
                     {value: "DZA" ,label:"Algeria"},
                     {value: "ARB" ,label:"Argentina"},
                     {value: "ATV" ,label:"Austria"},
                     {value: "AZB" ,label:"Azerbaijan"},
                     {value: "BEB" ,label:"Belgium"},
                     {value: "BNA" ,label:"Belgium Dutch"},
                     {value: "BRS" ,label:"Brazil"},
                     {value: "CAT" ,label:"Canada"},
                     {value: "CNB" ,label:"China"},
                     {value: "CNN" ,label:"China E1"},
                     {value: "COB" ,label:"Colombia"},
                     {value: "CRS" ,label:"Costa Rica"},
                     {value: "CZP" ,label:"Czech Republic"},
                     {value: "DKC" ,label:"Denmark"},
                     {value: "ECQ" ,label:"Ecuador"},
                     {value: "FIH" ,label:"Finland"},
                     {value: "FRP" ,label:"France"},
                     {value: "DEB" ,label:"Germany"},
                     {value: "HKH" ,label:"Hong Kong"},
                     {value: "IDJ" ,label:"Indonesia"},
                     {value: "IRT" ,label:"Iran"},
                     {value: "ITM" ,label:"Italy"},
                     {value: "JPT" ,label:"Japan"},
                     {value: "KZA" ,label:"Kazakhstan"},
                     {value: "LYT" ,label:"Libya"},
                     {value: "LUL" ,label:"Luxembourg"},
                     {value: "MXM" ,label:"Mexico"},
                     {value: "NLA" ,label:"Netherlands"},
                     {value: "NOO" ,label:"Norway"},
                     {value: "PAP" ,label:"Panama"},
                     {value: "PEL" ,label:"Peru"},
                     {value: "PLW" ,label:"Poland"},
                     {value: "PTL" ,label:"Portugal"},
                     {value: "RUM" ,label:"Russia"},
                     {value: "SAR" ,label:"Saudi Arabia"},
                     {value: "KRS" ,label:"South Korea"},
                     {value: "ESB" ,label:"Spain"},
                     {value: "SES" ,label:"Sweden"},
                     {value: "CHL" ,label:"Switzerland (French)"},
                     {value: "CHZ" ,label:"Switzerland (German)"},
                     {value: "CHT" ,label:"Switzerland (Italian)"},
                     {value: "TWI" ,label:"Taiwan"},
                     {value: "THB" ,label:"Thailand"},
                     {value: "TNT" ,label:"Tunisia"},
                     {value: "TRI" ,label:"Turkey"},
                     {value: "AEA" ,label:"United Arab Emirates"},
                     {value: "UKA" ,label:"United Kingdom"},
                     {value: "UYM" ,label:"Uruguay"},
                     {value: "USB" ,label:"USA"},
                     {value: "VEC" ,label:"Venezuela"},
                     {value: "VNH" ,label:"Vietnam"},
                     {value: "WWA" ,label:"WWA"}];
      component.set("v.SalesOffice", SalesOffice);*/
    
      /*var Nationality = [{value: "", label: "Please select"},
                         {value: "United Arab Emirates", label: "United Arab Emirates"},
                         {value: "Argentinian", label: "Argentinian"},
                         {value: "Austrian", label: "Austrian"},
                         {value: "Australian", label: "Australian"},
                         {value: "Azerbaijani", label: "Azerbaijani"},
                         {value: "Belgian", label: "Belgian"},
                         {value: "Canadian", label: "Canadian"},
                         {value: "Swiss", label: "Swiss"},
                         {value: "Chilean", label: "Chilean"},
                         {value: "Chinese", label: "Chinese"},
                         {value: "Colombian", label: "Colombian"}, 
                         {value: "Costa Rican", label: "Costa Rican"},
                         {value: "Czech", label: "Czech"},
                         {value: "German", label: "German"},
                         {value: "Danish", label: "Danish"},
                         {value: "Algerian", label: "Algerian"},
                         {value: "Ecuadorian", label: "Ecuadorian"},
                         {value: "Spanish", label: "Spanish"}, 
                         {value: "Finnish", label: "Finnish"},
                         {value: "French", label: "French"},
                         {value: "Greek", label: "Greek"},
                         {value: "Hong Kong Chinese", label: "Hong Kong Chinese"},
                         {value: "Hungarian", label: "Hungarian"},
                         {value: "Indonesian", label: "Indonesian"},
                         {value: "Indian", label: "Indian"},
                         {value: "Iranian", label: "Iranian"},
                         {value: "Italian", label: "Italian"},
                         {value: "Japanese", label: "Japanese"},
                         {value: "South Korean", label: "South Korean"},
                         {value: "Kazakh", label: "Kazakh"}, 
                         {value: "Luxembourgish", label: "Luxembourgish"}, 
                         {value: "Libyan", label: "Libyan"}, 
                         {value: "Mexican", label: "Mexican"}, 
                         {value: "Dutch", label: "Dutch"}, 
                         {value: "Norwegian", label: "Norwegian"}, 
                         {value: "New Zealand", label: "New Zealand"}, 
                         {value: "Panamanian", label: "Panamanian"}, 
                         {value: "Peruvian", label: "Peruvian"}, 
                         {value: "Polish", label: "Polish"}, 
                         {value: "Portuguese", label: "Portuguese"}, 
                         {value: "Russian", label: "Russian"}, 
                         {value: "Saudi Arabian", label: "Saudi Arabian"}, 
                         {value: "Swedish", label: "Swedish"}, 
                         {value: "Thai", label: "Thai"}, 
                         {value: "Tunisian", label: "Tunisian"}, 
                         {value: "Turkish", label: "Turkish"}, 
                         {value: "Taiwanese", label: "Taiwanese"}, 
                         {value: "British", label: "British"}, 
                         {value: "American", label: "American"}, 
                         {value: "Uruguayan", label: "Uruguayan"}, 
                         {value: "Venezuelan", label: "Venezuelan"}, 
                         {value: "Vietnamese", label: "Vietnamese"}, 
                         {value: "World Wide Agent", label: "World Wide Agent"}, 
                         {value: "USA", label: "USA"}];
          component.set("v.Nationality", Nationality);*/
      
      var CountryOfBirth = [{value: "", label: "Please Select"},
															{value: "AF", label: "Afghanistan"},
															{value: "AX", label: "Åland Islands"},
															{value: "AL", label: "Albania"},
															{value: "DZ", label: "Algeria"},
															{value: "AS", label: "American Samoa"},
															{value: "AD", label: "Andorra"},
															{value: "AO", label: "Angola"},
															{value: "AI", label: "Anguilla"},
															{value: "AQ", label: "Antarctica"},
															{value: "AG", label: "Antigua and Barbuda"},
															{value: "AR", label: "Argentina"},
															{value: "AM", label: "Armenia"},
															{value: "AW", label: "Aruba"},
															{value: "AU", label: "Australia"},
															{value: "AT", label: "Austria"},
															{value: "AZ", label: "Azerbaijan"},
															{value: "BS", label: "Bahamas"},
															{value: "BH", label: "Bahrain"},
															{value: "BD", label: "Bangladesh"},
															{value: "BB", label: "Barbados"},
															{value: "BY", label: "Belarus"},
															{value: "BE", label: "Belgium"},
															{value: "BZ", label: "Belize"},
															{value: "BJ", label: "Benin"},
															{value: "BM", label: "Bermuda"},
															{value: "BT", label: "Bhutan"},
															{value: "BO", label: "Bolivia, Plurinational State of"},
															{value: "BQ", label: "Bonaire, Sint Eustatius and Saba"},
															{value: "BA", label: "Bosnia and Herzegovina"},
															{value: "BW", label: "Botswana"},
															{value: "BV", label: "Bouvet Island"},
															{value: "BR", label: "Brazil"},
															{value: "IO", label: "British Indian Ocean Territory"},
															{value: "BN", label: "Brunei Darussalam"},
															{value: "BG", label: "Bulgaria"},
															{value: "BF", label: "Burkina Faso"},
															{value: "BI", label: "Burundi"},
															{value: "KH", label: "Cambodia"},
															{value: "CM", label: "Cameroon"},
															{value: "CA", label: "Canada"},
															{value: "CV", label: "Cape Verde"},
															{value: "KY", label: "Cayman Islands"},
															{value: "CF", label: "Central African Republic"},
															{value: "TD", label: "Chad"},
															{value: "CL", label: "Chile"},
															{value: "CN", label: "China"},
															{value: "CX", label: "Christmas Island"},
															{value: "CC", label: "Cocos (Keeling) Islands"},
															{value: "CO", label: "Colombia"},
															{value: "KM", label: "Comoros"},
															{value: "CG", label: "Congo"},
															{value: "CD", label: "Congo, the Democratic Republic of the"},
															{value: "CK", label: "Cook Islands"},
															{value: "CR", label: "Costa Rica"},
															{value: "CI", label: "Côte d'Ivoire"},
															{value: "HR", label: "Croatia"},
															{value: "CU", label: "Cuba"},
															{value: "CW", label: "Curaçao"},
															{value: "CY", label: "Cyprus"},
															{value: "CZ", label: "Czech Republic"},
															{value: "DK", label: "Denmark"},
															{value: "DJ", label: "Djibouti"},
															{value: "DM", label: "Dominica"},
															{value: "DO", label: "Dominican Republic"},
															{value: "EC", label: "Ecuador"},
															{value: "EG", label: "Egypt"},
															{value: "SV", label: "El Salvador"},
															{value: "GQ", label: "Equatorial Guinea"},
															{value: "ER", label: "Eritrea"},
															{value: "EE", label: "Estonia"},
															{value: "ET", label: "Ethiopia"},
															{value: "FK", label: "Falkland Islands (Malvinas)"},
															{value: "FO", label: "Faroe Islands"},
															{value: "FJ", label: "Fiji"},
															{value: "FI", label: "Finland"},
															{value: "FR", label: "France"},
															{value: "GF", label: "French Guiana"},
															{value: "PF", label: "French Polynesia"},
															{value: "TF", label: "French Southern Territories"},
															{value: "GA", label: "Gabon"},
															{value: "GM", label: "Gambia"},
															{value: "GE", label: "Georgia"},
															{value: "DE", label: "Germany"},
															{value: "GH", label: "Ghana"},
															{value: "GI", label: "Gibraltar"},
															{value: "GR", label: "Greece"},
															{value: "GL", label: "Greenland"},
															{value: "GD", label: "Grenada"},
															{value: "GP", label: "Guadeloupe"},
															{value: "GU", label: "Guam"},
															{value: "GT", label: "Guatemala"},
															{value: "GG", label: "Guernsey"},
															{value: "GN", label: "Guinea"},
															{value: "GW", label: "Guinea-Bissau"},
															{value: "GY", label: "Guyana"},
															{value: "HT", label: "Haiti"},
															{value: "HM", label: "Heard Island and McDonald Islands"},
															{value: "VA", label: "Holy See (Vatican City State)"},
															{value: "HN", label: "Honduras"},
															{value: "HK", label: "Hong Kong"},
															{value: "HU", label: "Hungary"},
															{value: "IS", label: "Iceland"},
															{value: "IN", label: "India"},
															{value: "ID", label: "Indonesia"},
															{value: "IR", label: "Iran, Islamic Republic of"},
															{value: "IQ", label: "Iraq"},
															{value: "IE", label: "Ireland"},
															{value: "IM", label: "Isle of Man"},
															{value: "IL", label: "Israel"},
															{value: "IT", label: "Italy"},
															{value: "JM", label: "Jamaica"},
															{value: "JP", label: "Japan"},
															{value: "JE", label: "Jersey"},
															{value: "JO", label: "Jordan"},
															{value: "KZ", label: "Kazakhstan"},
															{value: "KE", label: "Kenya"},
															{value: "KI", label: "Kiribati"},
															{value: "KP", label: "Korea, Democratic People's Republic of"},
															{value: "KR", label: "Korea, Republic of"},
															{value: "KW", label: "Kuwait"},
															{value: "KG", label: "Kyrgyzstan"},
															{value: "LA", label: "Lao People's Democratic Republic"},
															{value: "LV", label: "Latvia"},
															{value: "LB", label: "Lebanon"},
															{value: "LS", label: "Lesotho"},
															{value: "LR", label: "Liberia"},
															{value: "LY", label: "Libya"},
															{value: "LI", label: "Liechtenstein"},
															{value: "LT", label: "Lithuania"},
															{value: "LU", label: "Luxembourg"},
															{value: "MO", label: "Macao"},
															{value: "MK", label: "Macedonia, the former Yugoslav Republic of"},
															{value: "MG", label: "Madagascar"},
															{value: "MW", label: "Malawi"},
															{value: "MY", label: "Malaysia"},
															{value: "MV", label: "Maldives"},
															{value: "ML", label: "Mali"},
															{value: "MT", label: "Malta"},
															{value: "MH", label: "Marshall Islands"},
															{value: "MQ", label: "Martinique"},
															{value: "MR", label: "Mauritania"},
															{value: "MU", label: "Mauritius"},
															{value: "YT", label: "Mayotte"},
															{value: "MX", label: "Mexico"},
															{value: "FM", label: "Micronesia, Federated States of"},
															{value: "MD", label: "Moldova, Republic of"},
															{value: "MC", label: "Monaco"},
															{value: "MN", label: "Mongolia"},
															{value: "ME", label: "Montenegro"},
															{value: "MS", label: "Montserrat"},
															{value: "MA", label: "Morocco"},
															{value: "MZ", label: "Mozambique"},
															{value: "MM", label: "Myanmar"},
															{value: "NA", label: "Namibia"},
															{value: "NR", label: "Nauru"},
															{value: "NP", label: "Nepal"},
															{value: "NL", label: "Netherlands"},
															{value: "NC", label: "New Caledonia"},
															{value: "NZ", label: "New Zealand"},
															{value: "NI", label: "Nicaragua"},
															{value: "NE", label: "Niger"},
															{value: "NG", label: "Nigeria"},
															{value: "NU", label: "Niue"},
															{value: "NF", label: "Norfolk Island"},
															{value: "MP", label: "Northern Mariana Islands"},
															{value: "NO", label: "Norway"},
															{value: "OM", label: "Oman"},
															{value: "PK", label: "Pakistan"},
															{value: "PW", label: "Palau"},
															{value: "PS", label: "Palestinian Territory, Occupied"},
															{value: "PA", label: "Panama"},
															{value: "PG", label: "Papua New Guinea"},
															{value: "PY", label: "Paraguay"},
															{value: "PE", label: "Peru"},
															{value: "PH", label: "Philippines"},
															{value: "PN", label: "Pitcairn"},
															{value: "PL", label: "Poland"},
															{value: "PT", label: "Portugal"},
															{value: "PR", label: "Puerto Rico"},
															{value: "QA", label: "Qatar"},
															{value: "RE", label: "Réunion"},
															{value: "RO", label: "Romania"},
															{value: "RU", label: "Russian Federation"},
															{value: "RW", label: "Rwanda"},
															{value: "BL", label: "Saint Barthélemy"},
															{value: "SH", label: "Saint Helena, Ascension and Tristan da Cunha "},
															{value: "KN", label: "Saint Kitts and Nevis"},
															{value: "LC", label: "Saint Lucia"},
															{value: "MF", label: "Saint Martin (French part)"},
															{value: "PM", label: "Saint Pierre and Miquelon"},
															{value: "VC", label: "Saint Vincent and the Grenadines"},
															{value: "WS", label: "Samoa"},
															{value: "SM", label: "San Marino"},
															{value: "ST", label: "Sao Tome and Principe"},
															{value: "SA", label: "Saudi Arabia"},
															{value: "SN", label: "Senegal"},
															{value: "RS", label: "Serbia"},
															{value: "SC", label: "Seychelles"},
															{value: "SL", label: "Sierra Leone"},
															{value: "SG", label: "Singapore"},
															{value: "SX", label: "Sint Maarten (Dutch part)"},
															{value: "SK", label: "Slovakia"},
															{value: "SI", label: "Slovenia"},
															{value: "SB", label: "Solomon Islands"},
															{value: "SO", label: "Somalia"},
															{value: "ZA", label: "South Africa"},
															{value: "GS", label: "South Georgia and the South Sandwich Islands "},
															{value: "SS", label: "South Sudan"},
															{value: "ES", label: "Spain"},
															{value: "LK", label: "Sri Lanka"},
															{value: "SD", label: "Sudan"},
															{value: "SR", label: "Suriname"},
															{value: "SJ", label: "Svalbard and Jan Mayen "},
															{value: "SZ", label: "Swaziland"},
															{value: "SE", label: "Sweden"},
															{value: "CH", label: "Switzerland"},
															{value: "SY", label: "Syrian Arab Republic"},
															{value: "TW", label: "Taiwan, Province of China "},
															{value: "TJ", label: "Tajikistan"},
															{value: "TZ", label: "Tanzania, United Republic of "},
															{value: "TH", label: "Thailand"},
															{value: "TL", label: "Timor-Leste"},
															{value: "TG", label: "Togo"},
															{value: "TK", label: "Tokelau"},
															{value: "TO", label: "Tonga"},
															{value: "TT", label: "Trinidad and Tobago "},
															{value: "TN", label: "Tunisia"},
															{value: "TR", label: "Turkey"},
															{value: "TM", label: "Turkmenistan"},
															{value: "TC", label: "Turks and Caicos Islands "},
															{value: "TV", label: "Tuvalu"},
															{value: "UG", label: "Uganda"},
															{value: "UA", label: "Ukraine"},
															{value: "AE", label: "United Arab Emirates"},
															{value: "GB", label: "United Kingdom"},
															{value: "US", label: "United States"},
															{value: "UM", label: "United States Minor Outlying Islands "},
															{value: "UY", label: "Uruguay"},
															{value: "UZ", label: "Uzbekistan"},
															{value: "VU", label: "Vanuatu"},
															{value: "VE", label: "Venezuela, Bolivarian Republic of "},
															{value: "VN", label: "Viet Nam"},
															{value: "VG", label: "Virgin Islands, British "},
															{value: "VI", label: "Virgin Islands, U.S. "},
															{value: "WF", label: "Wallis and Futuna"},
															{value: "EH", label: "Western Sahara"},
															{value: "YE", label: "Yemen"},
															{value: "ZM", label: "Zambia"},
															{value: "ZW", label: "Zimbabwe"}];
    component.set("v.CountryOfBirth", CountryOfBirth);
      
     /*var PassportType = [{value: "", label: "Please select"},
                          {value: "Argentino", label: "Argentino"},
                          {value: "Australian", label: "Australian"},
                          {value: "Belgium", label: "Belgium"},
                          {value: "BNO", label: "BNO"},
                          {value: "Brazilian Passport", label: "Brazilian Passport"},
                          {value: "Canadian", label: "Canadian"},
                          {value: "China Travel card", label: "China Travel card"},
                          {value: "Diplomatic", label: "Diplomatic"},
                          {value: "European Passport", label: "European Passport"},
                          {value: "Europeo", label: "Europeo"},
                          {value: "French", label: "French"}, 
                          {value: "Government", label: "Government"},
                          {value: "Greek ID", label: "Greek ID"},
                          {value: "Greek Passport", label: "Greek Passport"},
                          {value: "HKSAR", label: "HKSAR"},
                          {value: "Indian", label: "Indian"},
                          {value: "Japanese", label: "Japanese"},
                          {value: "Macau SAR", label: "Macau SAR"}, 
                          {value: "Malaysia", label: "Malaysia"},
						  {value: "National ID Card", label: "National ID Card"},
                          {value: "New Zealand", label: "New Zealand"},
                          {value: "Ordinary", label: "Ordinary"},
                          {value: "Philippine", label: "Philippine"},
                          {value: "Portuguese", label: "Portuguese"},
                          {value: "PRC", label: "PRC"},
                          {value: "Singapore", label: "Singapore"},
                          {value: "South Korea", label: "South Korea"},
                          {value: "Swedish", label: "Swedish"},
                          {value: "Taiwanese", label: "Taiwanese"},
                          {value: "Thai", label: "Thai"}, 
                          {value: "United Kingdom", label: "United Kingdom"},
                          {value: "USA", label: "USA"}];
    component.set("v.PassportType", PassportType);*/
      //alert(component.get("v.passportType"));
  },
     
  professionDetails: function(component, event, helper) {
    var opts = [{value: "", label: "Please select"}, {value: "Other", label: "Other"}];
    component.set("v.ProfessionValue", opts);
  },
  pathWayforward: function(component, event, helper) {
    // console.log(event.currentTarget);
    // console.log(event.target.getAttribute("data-path"));
    // var getPath = event.target.getAttribute("data-path");
    // var toggleText = component.find("path-content-1");
    // $A.util.toggleClass(toggleText, "panel-display-none");
    var whichOne = event.getSource().getLocalId();
  },
  moveNext: function(cmp, event, helper) {
    var age = cmp.get("v.wrapperList.personAcc.age__c");
    //alert(age);
    var fetchAgeID = cmp.find("ageField");
    //alert(fetchAgeID);
    var fetchdob = cmp.get("v.wrapperList.personAcc.PersonBirthdate");
    //alert(fetchdob);
    var fetchDOBID = cmp.find("dob");
    //alert(fetchDOBID);
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();
    
    if(dd<10) {
        dd = '0'+dd
    } 
    
    if(mm<10) {
        mm = '0'+mm
    } 
    
    today = yyyy + '-' + mm + '-' + dd;
    //alert(today);
    if(fetchdob > today){
        fetchDOBID.set("v.errors", [{message:"DOB cannot be future date: " + fetchdob}]);
    } 
    else if(age < 0){
        fetchAgeID.set("v.errors", [{message:"Age cannot negative: " + age}]);
    }
    else{
        var path_1_Fields = cmp.find("path_1_Fields").reduce(function(validSoFar, inputCmp) {
          inputCmp.showHelpMessageIfInvalid();
          return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
        }, true);
        //alert('%%%%%%%%%%%%%'+path_1_Fields);
    }
    
    if (path_1_Fields) {
        
      var whichOne = event.getSource().getLocalId();
      
      //alert(whichOne);
      if (whichOne == "next1") {
        var currentHeader = cmp.find("header-1");
        var nextHeader = cmp.find("header-3");
        var CurrentPanel = cmp.find("path-content-1");
        var nextPanel = cmp.find("path-content-3");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Disable Button
        $A.util.removeClass(finishBooking, "slds-button_brand");
        helper.accountData(cmp,event,helper);
      } else if (whichOne == "next2") {
        var currentHeader = cmp.find("header-1");
        var nextHeader = cmp.find("header-3");
        var CurrentPanel = cmp.find("path-content-1");
        var nextPanel = cmp.find("path-content-3");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Disable Button
        // $A.util.removeClass(finishBooking, "slds-button_brand");
      } else if (whichOne == "next3") {
        var currentHeader = cmp.find("header-3");
        var nextHeader = cmp.find("header-4");
        var CurrentPanel = cmp.find("path-content-3");
        var nextPanel = cmp.find("path-content-4");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Enable Button
        // $A.util.addClass(finishBooking, "slds-button_brand");
      }
        
    } else {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Error!",
        type: "error",
        message: "Please fill your information correctly."
      });
      toastEvent.fire();
    }
    
     $A.enqueueAction(cmp.get('c.submit')); 
  },
  moveNext2: function(cmp, event, helper) {
   
          var path_2_Fields = cmp.find("path_2_Fields").reduce(function(validSoFar, inputCmp) {
          inputCmp.showHelpMessageIfInvalid();
          return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
        }, true);
   
    if (path_2_Fields) {
      var whichOne = event.getSource().getLocalId();
      //console.log(whichOne);
      if (whichOne == "next1") {
        var currentHeader = cmp.find("header-1");
        var nextHeader = cmp.find("header-3");
        var CurrentPanel = cmp.find("path-content-1");
        var nextPanel = cmp.find("path-content-3");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Disable Button
        $A.util.removeClass(finishBooking, "slds-button_brand");
      } else if (whichOne == "next2") {
        var currentHeader = cmp.find("header-1");
        var nextHeader = cmp.find("header-3");
        var CurrentPanel = cmp.find("path-content-1");
        var nextPanel = cmp.find("path-content-3");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Disable Button
        $A.util.removeClass(finishBooking, "slds-button_brand");
      } else if (whichOne == "next3") {
        var currentHeader = cmp.find("header-3");
        var nextHeader = cmp.find("header-4");
        var CurrentPanel = cmp.find("path-content-3");
        var nextPanel = cmp.find("path-content-4");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Enable Button
        // $A.util.addClass(finishBooking, "slds-button_brand");
      }
    } else {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Error!",
        type: "error",
        message: "Please fill your information correctly."
      });
      toastEvent.fire();
    }
      //$A.enqueueAction(cmp.get('c.submit'));
  },
  moveNext3: function(cmp, event, helper) {
     
        var path_3_Fields = cmp.find("path_3_Fields").reduce(function(validSoFar, inputCmp) {
          inputCmp.showHelpMessageIfInvalid();
          return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
        }, true);

    if (path_3_Fields) {
      var whichOne = event.getSource().getLocalId();
      //console.log(whichOne);
      if (whichOne == "next1") {
        var currentHeader = cmp.find("header-1");
        var nextHeader = cmp.find("header-3");
        var CurrentPanel = cmp.find("path-content-1");
        var nextPanel = cmp.find("path-content-3");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Disable Button
        $A.util.removeClass(finishBooking, "slds-button_brand");
      } else if (whichOne == "next2") {
        var currentHeader = cmp.find("header-1");
        var nextHeader = cmp.find("header-3");
        var CurrentPanel = cmp.find("path-content-1");
        var nextPanel = cmp.find("path-content-3");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Disable Button
        $A.util.removeClass(finishBooking, "slds-button_brand");
      } else if (whichOne == "next3") {
        var currentHeader = cmp.find("header-3");
        var nextHeader = cmp.find("header-4");
        var CurrentPanel = cmp.find("path-content-3");
        var nextPanel = cmp.find("path-content-4");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Enable Button
        // $A.util.addClass(finishBooking, "slds-button_brand");
      }
    } else {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Error!",
        type: "error",
        message: "Please fill your information correctly."
      });
      toastEvent.fire();
    }
      $A.enqueueAction(cmp.get('c.submit'));
  },
  moveNext4: function(cmp, event, helper) {
    var path_4_Fields = cmp.find("path_4_Fields").reduce(function(validSoFar, inputCmp) {
      inputCmp.showHelpMessageIfInvalid();
      return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
        }, true);
    
      if (path_4_Fields) {
      var whichOne = event.getSource().getLocalId();
      console.log(whichOne);
      if (whichOne == "next1") {
        var currentHeader = cmp.find("header-1");
        var nextHeader = cmp.find("header-3");
        var CurrentPanel = cmp.find("path-content-1");
        var nextPanel = cmp.find("path-content-3");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Disable Button
        $A.util.removeClass(finishBooking, "slds-button_brand");
      } else if (whichOne == "next2") {
        var currentHeader = cmp.find("header-1");
        var nextHeader = cmp.find("header-3");
        var CurrentPanel = cmp.find("path-content-1");
        var nextPanel = cmp.find("path-content-3");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Disable Button
        $A.util.removeClass(finishBooking, "slds-button_brand");
      } else if (whichOne == "next3") {
        var currentHeader = cmp.find("header-3");
        var nextHeader = cmp.find("header-4");
        var CurrentPanel = cmp.find("path-content-3");
        var nextPanel = cmp.find("path-content-4");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        //Enable Button
        // $A.util.addClass(finishBooking, "slds-button_brand");
      } else if (whichOne == "next4") {
        var currentHeader = cmp.find("header-4");
        var nextHeader = cmp.find("header-5");
        var CurrentPanel = cmp.find("path-content-4");
        var nextPanel = cmp.find("path-content-5");
        var finishBooking = cmp.find("finishBooking");
        //For Next Header
        $A.util.addClass(nextHeader, "slds-is-current slds-is-active");
        $A.util.removeClass(nextHeader, "slds-is-incomplete");
        //For Current header
        $A.util.addClass(currentHeader, "slds-is-complete");
        $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
        //PanelCurrent
        $A.util.addClass(CurrentPanel, "slds-hide");
        $A.util.removeClass(CurrentPanel, "slds-show");
        //PanelCurrent
        $A.util.addClass(nextPanel, "slds-show");
        $A.util.removeClass(nextPanel, "slds-hide");
        $A.util.addClass(finishBooking, "slds-button_brand");
        //Enable Button
        // $A.util.addClass(finishBooking, "slds-button_brand");
      }
    } else {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        title: "Error!",
        type: "error",
        message: "Please fill your information correctly."
      });
      toastEvent.fire();
    }
      $A.enqueueAction(cmp.get('c.submit'));
  },
  movePrev: function(cmp, event, helper) {
    var whichOne = event.getSource().getLocalId();
    console.log(whichOne);
    if (whichOne == "prev2") {
      var currentHeader = cmp.find("header-3");
      var prevHeader = cmp.find("header-1");
      var CurrentPanel = cmp.find("path-content-3");
      var prevPanel = cmp.find("path-content-1");
      var finishBooking = cmp.find("finishBooking");
      //For Prev Header
      $A.util.addClass(prevHeader, "slds-is-current slds-is-active");
      $A.util.removeClass(prevHeader, "slds-is-complete");
      //For Current header
      $A.util.addClass(currentHeader, "slds-is-incomplete");
      $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
      //   //PanelCurrent
      $A.util.addClass(CurrentPanel, "slds-hide");
      $A.util.removeClass(CurrentPanel, "slds-show");
      //PanelCurrent
      $A.util.addClass(prevPanel, "slds-show");
      $A.util.removeClass(prevPanel, "slds-hide");
      //Disable Button
      $A.util.removeClass(finishBooking, "slds-button_brand");
    } else if (whichOne == "prev3") {
      var currentHeader = cmp.find("header-3");
      var prevHeader = cmp.find("header-1");
      var CurrentPanel = cmp.find("path-content-3");
      var prevPanel = cmp.find("path-content-1");
      var finishBooking = cmp.find("finishBooking");
      //For Prev Header
      $A.util.addClass(prevHeader, "slds-is-current slds-is-active");
      $A.util.removeClass(prevHeader, "slds-is-complete");
      //For Current header
      $A.util.addClass(currentHeader, "slds-is-incomplete");
      $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
      //   //PanelCurrent
      $A.util.addClass(CurrentPanel, "slds-hide");
      $A.util.removeClass(CurrentPanel, "slds-show");
      //PanelCurrent
      $A.util.addClass(prevPanel, "slds-show");
      $A.util.removeClass(prevPanel, "slds-hide");
      //Disable Button
      $A.util.removeClass(finishBooking, "slds-button_brand");
    } else if (whichOne == "prev4") {
      var currentHeader = cmp.find("header-4");
      var prevHeader = cmp.find("header-3");
      var CurrentPanel = cmp.find("path-content-4");
      var prevPanel = cmp.find("path-content-3");
      var finishBooking = cmp.find("finishBooking");
      //For Prev Header
      $A.util.addClass(prevHeader, "slds-is-current slds-is-active");
      $A.util.removeClass(prevHeader, "slds-is-complete");
      //For Current header
      $A.util.addClass(currentHeader, "slds-is-incomplete");
      $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
      //   //PanelCurrent
      $A.util.addClass(CurrentPanel, "slds-hide");
      $A.util.removeClass(CurrentPanel, "slds-show");
      //PanelCurrent
      $A.util.addClass(prevPanel, "slds-show");
      $A.util.removeClass(prevPanel, "slds-hide");
      //Enable Button
      $A.util.removeClass(finishBooking, "slds-button_brand");
    } else if (whichOne == "prev5") {
      var currentHeader = cmp.find("header-5");
      var prevHeader = cmp.find("header-4");
      var CurrentPanel = cmp.find("path-content-5");
      var prevPanel = cmp.find("path-content-4");
      var finishBooking = cmp.find("finishBooking");
      //For Prev Header
      $A.util.addClass(prevHeader, "slds-is-current slds-is-active");
      $A.util.removeClass(prevHeader, "slds-is-complete");
      //For Current header
      $A.util.addClass(currentHeader, "slds-is-incomplete");
      $A.util.removeClass(currentHeader, "slds-is-current slds-is-active");
      //   //PanelCurrent
      $A.util.addClass(CurrentPanel, "slds-hide");
      $A.util.removeClass(CurrentPanel, "slds-show");
      //PanelCurrent
      $A.util.addClass(prevPanel, "slds-show");
      $A.util.removeClass(prevPanel, "slds-hide");
      //Enable Button
      $A.util.removeClass(finishBooking, "slds-button_brand");
      $A.util.removeClass(finishBooking, "slds-button_brand");
    }
  },
  preValidateSubmit: function(cmp, event, helper) {
    $A.util.removeClass(finishBooking, "slds-button_brand");
    var finishBooking = cmp.find("finishBooking");
    var path_4_Fields = cmp.find("path_4_Fields").reduce(function(validSoFar, inputCmp) {
      inputCmp.showHelpMessageIfInvalid();
      return validSoFar && !inputCmp.get("v.validity").valueMissing && !inputCmp.get("v.validity").patternMismatch && !inputCmp.get("v.validity").typeMismatch;
    }, true);
    if (path_4_Fields) {
      $A.util.addClass(finishBooking, "slds-button_brand");
    } else {
      $A.util.removeClass(finishBooking, "slds-button_brand");
    }
  },
  submit: function(cmp, event, helper) {
      debugger;
      helper.insertRecord(cmp, event);
      cmp.set('v.isFinishBooking',false);
      // cmp.set('v.isFinishBooking',true);
             // alert(cmp.get("v.isFinishBooking"));
    //var toastEvent = $A.get("e.force:showToast");
    //toastEvent.setParams({
      //title: "Success!",
      //type: "success",
      //message: "The record has been updated successfully."
    //});
    //toastEvent.fire();
  },

    finishBooking: function(cmp, event, helper) {
        debugger;
        helper.insertRecord(cmp, event);
        cmp.set('v.isFinishBooking',true);
       // alert(cmp.get("v.isFinishBooking"));
      //var toastEvent = $A.get("e.force:showToast");
      //toastEvent.setParams({
        //title: "Success!",
        //type: "success",
        //message: "The record has been updated successfully."
      //});
      //toastEvent.fire();
    },
  onClick: function(cmp, evt, helper) {
    var allValid = cmp.find("field").reduce(function(validSoFar, inputCmp) {
      inputCmp.showHelpMessageIfInvalid();
      return validSoFar && inputCmp.get("v.validity").valid;
    }, true);
    if (allValid) {
      alert("All form entries look valid. Ready to submit!");
    } else {
      alert("Please update the invalid form entries and try again.");
    }
  },

  onClickTest: function(component, event, helper) {
    var inputCmp = component.find("path_1_Fields");
    console.log(event.getSource().get("v.name"));

    // if (isNaN(event.getSource().get("v.name"))) {
    // 	inputCmp.set("v.errors", [{ message: "Input not a number: " + value }]);
    //   } else {
    // 	inputCmp.set("v.errors", null);
    //   }
  },
  valueChangeValidation: function(component, event, helper) {
    var inputField = component.find("inputField");
    var value = component.get("v.value");
    if (value != "foo") {
      inputField.set("v.validity", {valid: false, badInput: true});
    }
  }
});

/* 
  slds-is-current slds-is-active
  slds-is-complete
  
  <aura:attribute name="whichButton" type="String" />
	  <p>You clicked: {!v.whichButton}</p>
  // Salesforce 
  cmp.set("v.whichButton", whichOne);
  onchange="{!c.onClickTest }"
  */