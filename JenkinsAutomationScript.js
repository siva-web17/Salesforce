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
var obj_temp = {};
// Configuration
const config = {};
// Function
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
function cleanFolder(){
	spinner.start('Loading..');
	setTimeout(() => {
		spinner.color = 'yellow';
		spinner.text = 'Cleaning Folder...';
	}, 1000);
	Promise.coroutine(function*() {
		var response = yield cmd.run('git reset --hard origin/sub-branch && git fetch --all && git pull --rebase && git prune && git ls-files -i --exclude-from=.gitignore && git stash save --keep-index --include-untracked');
		if (response.success) {
			exitBuild();
			spinner.stop();
		} else {
			exitBuild();
			spinner.stop();
		}
	})();
}
function exitBuild(value) {
	spinner.start('Loading..');
	setTimeout(() => {
		spinner.color = 'yellow';
		spinner.text = 'Deploy data to server, please wait...!';
	}, 1000);
	Promise.coroutine(function*() {
		var response = yield cmd.run('exit 1');
		if (response.success) {
			spinner.stop();
			console.log(success('Build got breaked for some reasons'));
			prompt.start();
		} else {
			console.log(error('Invalid Comment, Please contact administrator'));
			spinner.stop();
		}
	})();
}

function deploy(value) {
	spinner.start('Loading..');
	setTimeout(() => {
		spinner.color = 'yellow';
		spinner.text = 'Deploy data to server, please wait...!';
	}, 1000);
	Promise.coroutine(function*() {
		var response = yield cmd.run('ant deploy');
		if (response.success) {
			spinner.stop();
			console.log(success('Successfully data '));
			prompt.start();
		} else {
			cleanFolder();
			spinner.stop();
		}
	})();
}

function convertSFDX2Metadata() {
	spinner.start('Loading..');
	setTimeout(() => {
		spinner.color = 'yellow';
		spinner.text = 'Converting SFDX to Metadata format';
	}, 1000);
	Promise.coroutine(function*() {
		var response = yield cmd.run('sfdx force:source:convert -d mdapioutput/ --json');
		if (response.success) {
			spinner.stop();
			console.log(success('Git updated successfully'));
			prompt.start();
			deploy();
		} else {
			cleanFolder();
			spinner.stop();
		}
	})();
}

function cleanGitRepo() { 
	spinner.start('Loading..');
	setTimeout(() => {
		spinner.color = 'yellow';
		spinner.text = 'Cleaning github repository';
	}, 1000);
	Promise.coroutine(function*() {
		var response = yield cmd.run('git reset --hard origin/sub-branch && git fetch --all && git pull --rebase && git prune && git ls-files -i --exclude-from=.gitignore && git stash save --keep-index --include-untracked');
		if (response.success) {
			spinner.stop();
			console.log(success('Git updated successfully'));
			prompt.start();
			convertSFDX2Metadata();
		} else {
			cleanFolder();
			spinner.stop();
		}
	})();
}

cleanGitRepo();
prompt.start();
