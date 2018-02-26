// Configuration
const config = {
	// Important + exec.bat
	bat: require.resolve('./config/process.bat'),
	processBatPath: 'C:\\Work\\salesforce\\clean-script-mine\\DATALOADER\\samples\\conf', //dataloader conf folder path eg: C:\\Work\\salesforce\\prod\\samples\\conf
	dataloaderJar: 'C:\\Work\\salesforce\\clean-script-mine\\DATALOADER\\dataloader-41.0.0-uber.jar ', //Update your dataloader-41.0.0-uber.jar in dataloader eg:  C:\\Work\\salesforce\\prod\\dataloader-41.0.0-uber.jar
	configdataFile: './config/configdata.json',
	read_XML: './config/process-conf.xml', // update process-conf.xml file in dataloader eg: C:\\Work\\salesforce\\prod\\samples\\conf\\process-conf.xml
    write_XML: 'C:\\Work\\salesforce\\clean-script-mine\\DATALOADER\\samples\\conf\\process-conf.xml'
};
var fs = require('fs'),
	parseString = require('xml2js').parseString,
	xml2js = require('xml2js');
var prompt = require('prompt');
var cmd = require('node-command-line'),
	Promise = require('bluebird');
var colors = require('colors/safe');
prompt.message = colors.bgGreen(' ');
prompt.delimiter = colors.green(' ');
const ora = require('ora');
const spinner = ora('Loading Data');
var promisify = require('node-promisify');
var obj_temp = {
	xmlTojson_temp: '',
	xmlTojson_count: 0,
	xmlTojson_count_temp: 0,
	BeanIDs: 0,
	BeanIDs_Count: 0,
	BeanIDs_count_temp: 0,
	ls: '',
};
var scratchOrgs = {};
var child_process = require('child_process');
var spawn = require('child_process').spawn;
// Function
function Head(value) {
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
fs.readFile(config.configdataFile, 'utf8', function readFileCallback(err, data) {
	scratchOrgs = JSON.parse(data).ScratchOrgs;
	obj_temp.xmlTojson_count = JSON.parse(data).ApttusInsertDataBeanIDs.length;
	obj_temp.xmlTojson_count_temp = 0;
	obj_temp.BeanIDs = JSON.parse(data).ApttusInsertDataBeanIDs;
	obj_temp.BeanIDs_Count = JSON.parse(data).ApttusInsertDataBeanIDs.length;
	obj_temp.BeanIDs_count_temp = 0;
	scratchOrgsFun(obj_temp.xmlTojson_count_temp);
});
function loopCmd(count) {
	console.log('Installing Loader num : ' + obj_temp.BeanIDs_count_temp);
	if (obj_temp.xmlTojson_count > count) {
		if (obj_temp.BeanIDs_Count > obj_temp.BeanIDs_count_temp) {
			var dynamicBean = obj_temp.BeanIDs[obj_temp.BeanIDs_count_temp];
			console.log(config.processBatPath);
			console.log(dynamicBean);
			var ls = spawn(config.bat, [config.processBatPath, dynamicBean]);
			ls.stdout.on('data', function(data) {
				// continuous process
				//process.stdout.write(data + '\n');
				console.log(success(dynamicBean + '------------------------------------------------------'));
				console.log(data.toString());
			});
			setTimeout(() => {
				obj_temp.BeanIDs_count_temp = obj_temp.BeanIDs_count_temp + 1;
				loopCmd_temp(count);
			}, 120000);
			ls.stderr.on('data', function(data) {
				console.log(error('Invalid Comment, Please contact administrator'));
			});
		}
	}
}
function loopCmd_temp(count) {
	if (obj_temp.BeanIDs_Count > obj_temp.BeanIDs_count_temp) {
		loopCmd(count, obj_temp.BeanIDs_count_temp);
	}
}

function writeProcessConf(count, value) {
	//var builder = new xml2js.Builder();
	var builder = new xml2js.Builder({
		xmldec: {
			version: '1.0',
			encoding: 'UTF-8',
			standalone: false,
		},
		doctype: { pubID: '-//SPRING//DTD BEAN//EN', sysID: 'http://www.springframework.org/dtd/spring-beans.dtd' },
	});
	var xml = builder.buildObject(value);
	fs.writeFile(config.write_XML, xml, function(err, data) {
		if (err) console.log(err);
		loopCmd(count);
	});
}
function readProcessConf(count) {
	var temp_username = '';
	fs.readFile(config.read_XML, 'utf-8', function(err, data) {
		if (err) console.log(err);
		parseString(data, function(err, result) {
			if (err) console.log(err);
			var json = result;
			var jsonBeanProcessing = result.beans.bean;
			for (i = 0; i < jsonBeanProcessing.length; i++) {
				var map = jsonBeanProcessing[i].property[1]['map'][0]['entry'];
				for (j = 0; j < map.length; j++) {
					if (map[j]['$'].key == 'sfdc.username') {
						map[j]['$'].value = scratchOrgs[count].UserName;
						temp_username = scratchOrgs[count].UserName;
					}
					if (map[j]['$'].key == 'sfdc.password') {
						map[j]['$'].value = scratchOrgs[count].EncryptedPassword;
					}
					if (map[j]['$'].key == 'sfdc.endpoint') {
						map[j]['$'].value = scratchOrgs[count].InstanceURL;
                    }
                    if (map[j]['$'].key == 'sfdc.debugMessagesFile') {
						map[j]['$'].value = scratchOrgs[count].debug_Log;
                    }
                    if (map[j]['$'].key == 'process.encryptionKeyFile') {
						map[j]['$'].value = scratchOrgs[count].key;
					}
				}
			}
			writeProcessConf(count, json);
			obj_temp.BeanIDs_count_temp = 0;
			console.log(success('USER: ' + temp_username));
		});
	});
}
function scratchOrgsFun(count) {
	if (obj_temp.xmlTojson_count > count) {
		readProcessConf(count);
	}
}
