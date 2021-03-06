// Generated by CoffeeScript 1.3.3
var colors, exec, getBranch, git, gitContinue, readyCallback;

exec = require('child_process').exec;

colors = require('colors');

readyCallback = null;

git = module.exports = {
  branch: '',
  config: {
    branch: 'concrete.branch'
  },
  init: function(target, callback) {
    var path;
    readyCallback = callback;
    path = require('path');
    if (target.toString().charAt(0) !== '/') {
      target = process.cwd() + '/' + target;
    }
    process.chdir(target);
    git.target = path.normalize(target + '/.git/');
    git.failure = path.normalize(target + '/.git/hooks/build-failed');
    git.success = path.normalize(target + '/.git/hooks/build-worked');
    return path.exists(git.target, function(exists) {
      if (exists === false) {
        console.log(("'" + target + "' is not a valid Git repo").red);
        process.exit(1);
      }
      return getBranch();
    });
  },
  pull: function(next) {
    var jobs, out;
    jobs = require('./jobs');
    out = "Pulling '" + git.branch + "' branch";
    return jobs.updateLog(jobs.current, out, function() {
      var _this = this;
      console.log(out.grey);
      return exec('git fetch && git reset --hard origin/' + git.branch, function(error, stdout, stderr) {
        if (error != null) {
          out = "" + error;
          jobs.updateLog(jobs.current, out);
          return console.log(out.red);
        } else {
          out = "Updated '" + git.branch + "' branch";
          return jobs.updateLog(jobs.current, out, function() {
            console.log(out.grey);
            return next();
          });
        }
      });
    });
  }
};

getBranch = function() {
  var _this = this;
  return exec('git config --get ' + git.config.branch, function(error, stdout, stderr) {
    if (error != null) {
      git.branch = 'master';
      return gitContinue();
    } else {
      git.branch = stdout.toString().replace(/[\s\r\n]+$/, '');
      if (git.branch === '') {
        git.branch = 'master';
      }
      return gitContinue();
    }
  });
};

gitContinue = function() {
  if (git.branch === 'none') {
    git.branch = 'master';
  } else if (git.branch === '') {
    return false;
  }
  return readyCallback();
};
