var app = angular.module('calendarDemoApp', ['ui.rCalendar']);
app.directive('numbersOnly', function() {
    return {
        require: 'ngModel',
        link: function(scope, element, attr, ngModelCtrl) {
            function fromUser(text) {
                if (text) {
                    var transformedInput = text.replace(/[^0-9]/g, '');

                    if (transformedInput !== text) {
                        ngModelCtrl.$setViewValue(transformedInput);
                        ngModelCtrl.$render();
                    }
                    return transformedInput;
                }
                return undefined;
            }
            ngModelCtrl.$parsers.push(fromUser);
        }
    };
});
angular.module('calendarDemoApp').controller('CalendarDemoCtrl', ['$scope', '$rootScope', function($scope, $rootScope) {
    'use strict';
    $scope.quantity = 1;
    $scope.onClickTimeFired = false;
    $scope.changeMode = function(mode) {
        $scope.mode = mode;
    };
    $scope.today = function() {
        $scope.currentDate = new Date();
    };
    $scope.isToday = function() {
        var today = new Date(),
            currentCalendarDate = new Date($scope.currentDate);

        today.setHours(0, 0, 0, 0);
        currentCalendarDate.setHours(0, 0, 0, 0);
        return today.getTime() === currentCalendarDate.getTime();
    };
    $scope.LoadDateConverted = function(data) {
        if (data != undefined) {
            var year = data.getFullYear();
            var month = ((data.getMonth() + 1) < 10 ? '0' : '') + (data.getMonth() + 1); // months are zero indexed 
            var day = (data.getDate() < 10 ? '0' : '') + data.getDate();
            $scope.LoadDateConvertedDate = year + '-' + month + '-' + day;
            return $scope.LoadDateConvertedDate;
        } else {
            return false;
        }
    }
    $scope.eventSource = [{
            "title": "null",
            "startTime": "2017-08-28T00:00:00.000Z",
            "endTime": "2017-08-28T00:00:00.000Z",
            "allDay": false,
            "prefer": false
        },
        {
            "title": "null",
            "startTime": "2017-09-04T00:00:00.000Z",
            "endTime": "2017-09-04T00:00:00.000Z",
            "allDay": false,
            "prefer": false
        },
        {
            "title": "null",
            "startTime": "2017-09-11T00:00:00.000Z",
            "endTime": "2017-09-11T00:00:00.000Z",
            "allDay": false,
            "prefer": false
        },
        {
            "title": "null",
            "startTime": "2017-09-18T00:00:00.000Z",
            "endTime": "2017-09-18T00:00:00.000Z",
            "allDay": false,
            "prefer": false
        },
        {
            "title": "null",
            "startTime": "2017-09-25T00:00:00.000Z",
            "endTime": "2017-09-25T00:00:00.000Z",
            "allDay": false,
            "prefer": false
        }
    ];
    $scope.ivalidCheck = false;
    $scope.preferDateFinder = function(prefer) {
        for (var i = 0; i < prefer.length; i++) {
            if (prefer[i].prefer == true) {
                return prefer[i].startTime;
                $scope.ivalidCheck = false
            }else{
                if($scope.ivalidCheck == true){
                    $scope.ivalidCheck = true;
                }else{
                    $scope.ivalidCheck = false;
                }
                return false;
            }
        }

    }

    $rootScope.preferDate =  new Date($scope.preferDateFinder($scope.eventSource).toString());
    $rootScope.preferDateFormatted = $scope.LoadDateConverted(new Date($scope.preferDateFinder($scope.eventSource).toString()));
    $scope.onEventSelected = function(event) {
        $scope.event = event;
    };

    $scope.validateStartDate = function(startDate) {
        var validateReturn = false;
        for (var i = 0; i < $scope.eventSource.length; i++) {
            var concatenateDate = $scope.LoadDateConverted(new Date(startDate.toISOString())) + 'T00:00:00.000Z';
            if ($scope.eventSource[i].startTime == concatenateDate) {
                validateReturn = true
            } else {
                if (validateReturn == true) {
                    validateReturn = true
                }else{
                    validateReturn = false;
                }
                
            }
        }
        if (validateReturn == true) {
            return startDate;
        } else {
            $scope.currentDate = $rootScope.preferDateFormatted;
            $scope.selectedTime = $rootScope.preferDateFormatted;
            return $rootScope.preferDate;
        }

    }
    $scope.EndDateValidator = function(qty, startFired) {
        startFired = (startFired == undefined | null ? $rootScope.preferDate : $scope.validateStartDate(startFired));
        if (qty == 0 || qty == undefined) { $scope.quantity = 1; }
        if (parseInt(qty) == 1 && $scope.onClickTimeFired == false) {
            var getStartDate = $rootScope.preferDate;
            var processStartDate = moment(getStartDate, "DD-MM-YYYY").add(4, 'days');
            var E_DAY = processStartDate.format('DD');
            var E_MONTH = processStartDate.format('MM');
            var E_YEAR = processStartDate.format('YYYY');
            $scope.endDateProcessed = $scope.LoadDateConverted(new Date(processStartDate));
            // $scope.startFormatMoment = $scope.LoadDateConverted($rootScope.preferDate) == false ? $rootScope.preferDateFormatted : $scope.LoadDateConverted($rootScope.preferDate);
        } else if (parseInt(qty) >= 1) {
            var getStartDate = startFired;
            var processingDateval = (parseInt(qty - 1) * 7) + 4;
            var processStartDate = moment(getStartDate, "DD-MM-YYYY").add(processingDateval, 'days');
            var E_DAY = processStartDate.format('DD');
            var E_MONTH = processStartDate.format('MM');
            var E_YEAR = processStartDate.format('YYYY');
            $scope.endDateProcessed = $scope.LoadDateConverted(new Date(processStartDate));
            // $scope.startFormatMoment = $scope.LoadDateConverted($rootScope.preferDate) == false ? $rootScope.preferDateFormatted : $scope.LoadDateConverted($rootScope.preferDate);
        }
    }
    $scope.onTimeSelected = function(selectedTime, events) {
        $scope.SelectionValidation = true;
        $scope.currentDate = selectedTime;
        selectedTime == undefined ? $scope.onClickTimeFired = false : $scope.onClickTimeFired = true;
        $scope.onClickTimeFired;
        $scope.selectedTime = $scope.LoadDateConverted(selectedTime) == false ? $rootScope.preferDateFormatted : $scope.LoadDateConverted(selectedTime);
        $scope.EndDateValidator($scope.quantity, selectedTime);
        //console.log('Selected time: ' + selectedTime + ' hasEvents: ' + (events !== undefined && events.length !== 0));
    };

    $scope.onTimeSelected();
    $scope.EndDateValidator();

}]);