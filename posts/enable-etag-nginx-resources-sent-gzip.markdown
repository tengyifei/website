---
title: Enable eTag in Nginx for files sent over gzip
published: 2014-09-26T19:49:40Z
categories: Computer Science,Web
tags: Grunt,Nginx
---

There are a myriad of measures to reduce loading time of websites and improve user experience, the most effective of which are probably caching and compression. ETags, or entity tags, are a powerful tool to improve client-side caching of web resources. Generally implemented using inode information or quick hashes, they uniquely represent a file served and should always change as long as the file is modified. It is a superior approach compared to Last-Modified header, which may be susceptible to a number of timing issues including slight out-of-sync between different server clocks, thus making ETags suitable for files that are subject to rapid changes. Compression on the other hand is typically performed on-the-fly using algorithms such as gzip. When I applied the two simultaneously, however, the ETag header was missing in the response:

```
http {
    location (some_parameter) {
        gzip on;
        etag on;
    }
}
```

![Response header](https://static.thinkingandcomputing.com/2014/09/response.png)
Response header

No ETag in response header!

The issue was discussed over several [forum threads](http://forum.nginx.org/read.php?2,240120,240127) and [trackers](http://code.google.com/p/phusion-passenger/issues/detail?id=903). It appeared that Nginx deliberately strips ETags once gzip is applied, The motivation behind was that ETag should serve as a byte-accurate comparison, and since the result of gzip is not guaranteed to be identical under different configurations, ETag is no longer a strong validator and Nginx decided that it was simpler to remove it as opposed to converting it to a weak one.

Fortunately, there is still a way to get ETag back, at least for static resources. By compiling Nginx with the `--with-http_gzip_static_module` parameter, support for a new directive, `gzip_static`, is added. The http gzip static module lets Nginx check if there is a pre-compressed version of a file available before serving it using on-the-fly compression. The primary objective is to save processing time, but a interesting side effect is that it leaves ETag intact.

The problem with this approach though, is that the compressed version has to be there for the whole thing to work. Otherwise Nginx will fallback to plain old gzip and not preservce eTags. A slapdash solution would be to write a script iterating through all the static resources and call tar on every one of them. For large projects with innumerable files, however, this turns into a kludge. Compressing all the files at each iteration leads to too much redundant work, and while manually keeping track of file modification time is feasible, it is hard to integrate with existing build process. I recommend using a task runner, [Grunt](http://gruntjs.com/), to handle the automatic compression. Here is my example Gruntfile:

```javascript
module.exports = function(grunt) {

  grunt.loadNpmTasks('grunt-contrib-compress');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-newer');

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
	copy: {
      main: {
        expand: true,
		cwd: 'www/',
		// source directory and exclusion
        src: ['**', '!**/_notes/**'],
        dest: 'build/'
      }
    },
    compress: {
      main: {
        options: {
          mode: 'gzip',
		  level: 9
        },
        files: [
          // Each of the files in the src/ folder will be output to
          // the dist/ folder each with the extension .gz.js
          {expand: true, src: ['build/**/*.css'], dest: '', ext: '.css.gz', extDot: 'last'},
		  {expand: true, src: ['build/**/*.html'], dest: '', ext: '.html.gz', extDot: 'last'},
		  {expand: true, src: ['build/**/*.js'], dest: '', ext: '.js.gz', extDot: 'last'},
		  {expand: true, src: ['build/**/*.htc'], dest: '', ext: '.htc.gz', extDot: 'last'}
        ]
      }
    }
  });

  // Task(s).
  grunt.registerTask('default', ['newer:copy:main', 'newer:compress']);

};
```

The config instructs Grunt to copy all newer contents from www, the development folder, to build, the local testing/deployment folder, and do compression at the "build" directory. The Grunt module named "newer" is required.
