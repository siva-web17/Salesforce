// Imports
const gulp = require('gulp');
const cheerio = require('gulp-cheerio');
const color = require('gulp-color'); 
const log = require('fancy-log');
const using = require('gulp-using');
const removeHtmlComments = require('gulp-remove-html-comments');
const usage = require('gulp-help-doc');
const shell = require('gulp-shell');


// Help
gulp.task('help', function() { return usage(gulp, {padding:3}); });
gulp.task('default', ['help']);

// Scratch
gulp.task('sf:scratch-push', shell.task('echo Hello, World!'));


// Profiles
const PROFILES_FOLDER = './force-app/main/default/profiles';

/**
 * Removes (comments out) unwanted XML nodes from Salesforce profiles files
 *
 * @task {profiles:clean}
 * @group {Profiles}
 * @order {1}
 */
gulp.task('profiles:clean', function() {
    const patterns = [
        {
            node: 'applicationVisibilities',
            child:  'application',
            patterns: ['Service_Cloud_Console','standard__Content','standard__ServiceConsole']
        },
        {
            node: 'fieldPermissions',
            child:  'field',
            patterns: [/.*Local$/, /FAQ.*/,/SocialPost.*/]
        },
        {
            node: 'layoutAssignments',
            child:  'layout',
            patterns: [/EntityMilestone.*/, /ErrorLog.*/, /Event.*/, /FAQ__.*/, /Idea.*/, /Question.*/, /Reply.*/,/QuickText.*/,/Scorecard.*/,/CollaborationGroup-Group.*/,/SocialPost.*/]
        },
        {
            node: 'objectPermissions',
            child:  'object',
            patterns: ['ActiveScratchOrg', 'FAQ__kav', 'NamespaceRegistry', 'ScratchOrgInfo','QuickText','Scorecard','ScorecardAssociation','ScorecardMetric']
        },
        {
            node: 'pageAccesses',
            child:  'apexPage',
            patterns: [/Chatter.*/]
        },
        {
            node: 'recordTypeVisibilities',
            child:  'recordType',
            patterns: [/Idea.*/]
        },
        {
            node: 'tabVisibilities',
            child:  'tab',
            patterns: ['standard-ActiveScratchOrg', 'standard-NamespaceRegistry', 'standard-ScratchOrgInfo','standard-Scorecard','standard-SocialPost','standard-QuickText','ImportfromExcel']
        },
        {
            node: 'userPermissions',
            child:  'name',
            patterns: ['Packaging2','ApexRestServices','ViewRoles']
        },
        {
            node: 'classAccesses',
            child: 'apexClass',
            patterns: ['APTS_EFPricingCallback_Test']
        }
    ];
    const matchesAny = function(str, patterns) {
        return patterns.some(function(pattern){ return !!str.match(pattern) });
    }
    return gulp
         .src(PROFILES_FOLDER + '/*.profile-meta.xml')
         .pipe(using({prefix: 'Processing '}))
         .pipe(gulp.dest('build/original-profiles')) // Copy untouched files to build folder (for recovery)
        .pipe(cheerio({
            parserOptions: {xmlMode: true},
            run: function($, file) {
                patterns.forEach(function(patternObj) {
                    $(patternObj.node).each(function(i, element){
                        let $el = $(element);
                        let fieldValue = $($el.children(patternObj.child)[0]).text();
                        if (matchesAny(fieldValue, patternObj.patterns)) {
                            log.info(`Commenting out ${patternObj.node} with ${patternObj.child} == '${fieldValue}'`);
                            $el.replaceWith('<!--' + $el + '-->');
                        }
                    });
                });
            }
         }))
         .pipe(gulp.dest(PROFILES_FOLDER)); // Overwrite originals
});

/**
 * Reverts Salesforce profile files changes made by profiles:clean. All XML comments are uncommented
 * 
 * @task {profiles:revert}
 * @group {Profiles}
 * @order {2}
 */
gulp.task('profiles:revert', function(){
    return gulp
        .src(PROFILES_FOLDER + '/*.profile-meta.xml')
        .pipe(using({prefix: 'Processing '}))
        .pipe(removeHtmlComments())
        .pipe(gulp.dest(PROFILES_FOLDER));
});