var fs = require('fs');
global.pullID = '';
var querystring = require('querystring');
var request = require('request');
var form = {
    username: 'usr',
    password: 'pwd',
    opaque: 'opaque',
    logintype: '1'
};
var formData = querystring.stringify(form);
var contentLength = formData.length;
// process.argv.forEach(function(val, index, array) {
//     // console.log(index + ': ' + val);
//     pullID =
// });
pullID = process.argv[2];
request({
    'headers': {
        'Authorization': 'token 3272b88201ffe839a607a25c6620eb36d5d32178 ',
        'X-GitHub-Media-Type': 'application/vnd.github.symmetra-preview+json',
        'user-agent': 'node.js'
    },
    'uri': 'https://api.github.com/repos/ILC-Technology/Salesforce/pulls/' + pullID + '/files',
    'method': 'GET'
}, function(err, res, body) {
    var jsonData = JSON.parse(body);
    var collection = [];
    for (i = 0; i < jsonData.length; i++) {
        collection.push(jsonData[i].filename);
    }
    console.log(JSON.stringify(collection));
    fs.writeFile('./deploymentFiles.json', JSON.stringify(collection), 'utf8', function readFileCallback(err, data) {
        console.log("File Write Operation Successful")
    });
});