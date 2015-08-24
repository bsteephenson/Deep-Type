
gulp = require 'gulp'
coffee = require 'gulp-coffee'
browserify = require 'gulp-browserify'
coffeeify = require 'coffeeify'
rename = require 'gulp-rename'

gulp.task 'coffee', () ->
	
	gulp.src('./src/*.coffee')
		.pipe(coffee({join: true}))
		.pipe(gulp.dest('./build/'))

gulp.task 'browser', () ->

	gulp.src('./src/checker.coffee', {read: false})
		.pipe(browserify({ extensions: ['.coffee'], transform: [coffeeify] }))
		.pipe(rename('checker-browser.js'))
		.pipe(gulp.dest('./build/'))

gulp.task 'default', ['coffee', 'browser']