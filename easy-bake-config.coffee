module.exports =
  library:
    join: 'background.js'
    compress: true
    files: [
      'src/background_core.coffee'
      'src/background_job.coffee'
      'src/background_job_queue.coffee'
      'src/background_job_list.coffee'
      'src/background_range.coffee'
      'src/background_range_xN.coffee'
      'src/background_array_iterator.coffee'
      'src/background_array_iterator_xN.coffee'
    ]
    _build:
      commands: [
        'cp background.js packages/npm/background.js'
        'cp background.min.js packages/npm/background.min.js'
        'cp background.js packages/nuget/Content/Scripts/background.js'
        'cp background.min.js packages/nuget/Content/Scripts/background.min.js'
      ]

  examples:
    output: 'build'
    directories: 'examples'

  tests:
    output: 'build'
    directories: [
      'test/core'
    ]
    _build:
      commands: [
        'mbundle test/packaging/bundle-config.coffee'
      ]

    _test:
      command: 'phantomjs'
      runner: 'phantomjs-jasmine-runner.js'
      files: ['**/*.html']
      directories: [
        'test/core'
        'test/packaging'
        'test/lodash'
      ]