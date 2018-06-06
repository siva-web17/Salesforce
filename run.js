const copyFile = require('fs-copy-file');
var prompt = require('prompt');
var cmd = require('node-command-line'),
    Promise = require('bluebird');
var colors = require('colors/safe');
prompt.message = colors.bgGreen(' ');
prompt.delimiter = colors.green(' ');

var promisify = require('node-promisify');
var path = require("path");
// destination.txt will be created or overwritten by default.
function Head(value) {
    //return colors.inverse(colors.blackBG(' ' + colors.blue(colors.bold(value)) + ' '));
    return colors.bgBlue(' ' + colors.white(colors.bold(value)) + ' ');
}

function error(value) {
    return colors.yellow(value);
}

function success(value) {
    return colors.green(value);
}

function convertToJson(value) {
    return JSON.stringify(value);
}
const config = {
    source: path.resolve("./") + '/',
    destination: path.resolve("./output/") + '/',
    collection: require('./array'),
    valueHolder: '',
    lastElemt: '',
    currentValue: 0
}

function cmd_Exec(value, process) {

    var value = value.split('/');
    var removeLast = value.splice(-1, 1);
    config.lastElemt = removeLast;
    var urlFormation = value.join('\\');
    config.valueHolder = urlFormation;

}

// for (i = 0; i < config.collection.length; i++) {
//     cmd_Exec(config.collection[i]);
//     var primarySource = config.source + config.valueHolder + '/' + config.lastElemt;
//     var primaryDest = config.destination + config.valueHolder + '/' + config.lastElemt;
//     primarySource = primarySource.replace(/\\/g, "/")
//     primaryDest = primaryDest.replace(/\\/g, "/")
//     var regex = /(?<!https:)\//g;
//     primarySource = primarySource.replace(regex, "\\\\");
//     primaryDest = primaryDest.replace(regex, "\\\\");
//     console.log("primarySource:" + primarySource);
//     console.log('primaryDest:' + primaryDest);
//     copyFile(primarySource, primaryDest, (err) => {
//         if (err)
//             throw err;
//         console.log('source.txt was copied to destination.txt');
//     });
//     var secondarySource = config.source + config.valueHolder + '/' + config.lastElemt + '-meta.xml';
//     var secoundaryDest = config.destination + config.valueHolder + '/' + config.lastElemt + '-meta.xml';
//     secondarySource = secondarySource.replace(/\\/g, "/")
//     secoundaryDest = secoundaryDest.replace(/\\/g, "/")
//     secondarySource = secondarySource.replace(/\\/g, "\\\\")
//     secoundaryDest = secoundaryDest.replace(/\\/g, "\\\\")
//     var regex = /(?<!https:)\//g;
//     secondarySource = secondarySource.replace(regex, "\\\\");
//     secoundaryDest = secoundaryDest.replace(regex, "\\\\");
//     console.log("secondarySource:" + secondarySource);
//     console.log("secoundaryDest:" + secoundaryDest);
//     copyFile(secondarySource, secoundaryDest, (err) => {
//         console.log('source.txt was copied to destination.txt');
//     });
// }

var secondarySource = "\\home\\travis\\build\\siva-web17\\Salesforce\\force-app\\main\\default\\aura\\OpportunityLogACall\\OpportunityLogACallRenderer.js"
var secoundaryDest = "\\home\\travis\\build\\siva-web17\\Salesforce\\output\\force-app\\main\\default\\aura\\OpportunityLogACall\\OpportunityLogACallRenderer.js"
copyFile(secondarySource, secoundaryDest, (err) => {
    console.log('Run Executed Successfully');
});