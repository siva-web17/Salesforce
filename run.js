var fs = require('fs');
var prompt = require('prompt');
var cmd = require('node-command-line'),
    Promise = require('bluebird');
var colors = require('colors/safe');
prompt.message = colors.bgGreen(' ');
prompt.delimiter = colors.green(' ');
const ora = require('ora');
const spinner = ora('Loading Data');
var promisify = require('node-promisify');

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
    source: 'C:\\work\\SF\\Master\\Prod\\',
    destination: 'C:\\work\\SF\\Master\\Prod\\output\\',
    collection: require('./array'),
    valueHolder: '',
    lastElemt: '',
    currentValue: 0
}

function cmd_Exec(value, process) {
    spinner.start('Loading..');
    setTimeout(() => {
        spinner.color = 'yellow';
        spinner.text = 'Loading....';
    }, 1000);
    var value = value.split('/');
    var removeLast = value.splice(-1, 1);
    config.lastElemt = removeLast;
    var urlFormation = value.join('\\');
    config.valueHolder = urlFormation;
    spinner.stop();
}

for (i = 0; i < config.collection.length; i++) {
    cmd_Exec(config.collection[i]);
    fs.copyFile(config.source + config.valueHolder + '\\' + config.lastElemt, config.destination + config.valueHolder + '\\' + config.lastElemt, (err) => {
        if (err)
            throw err;
        console.log('source.txt was copied to destination.txt');
    });
    fs.copyFile(config.source + config.valueHolder + '\\' + config.lastElemt + '-meta.xml', config.destination + config.valueHolder + '\\' + config.lastElemt + '-meta.xml', (err) => {

        console.log('source.txt was copied to destination.txt');
    });
}