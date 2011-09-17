# can be overridden
window.BGDEBUG = true     # enable assertions by default
window.BGASSERT_ACTION = (message) -> alert(message)
window.BGASSERT = (check_condition, message) -> 
  return if(not window.BGDEBUG)
  BGASSERT_ACTION(message) if(not check_condition)

class _BGJobContainer

  constructor: (@frequency) ->
    @jobs = [];
    @timeout = 0;
    @being_destroyed = false

  destroy:      -> @being_destroyed = true
  isDestroyed: -> return (@being_destroyed or @destroyed) 

  isEmpty: -> return (@jobs.length == 0)
  tick: ->
    # we are being destroyed
    (@_doDestroy(); return) if(@being_destroyed)

    # let the container process the list
    @_doTick()

    # we are being destroyed
    (@_doDestroy(); return) if(@being_destroyed)

  clear: ->
    # destroy the jobs
    while(job = @jobs.shift())
      job.destroy(true)

    # clear the timer
    if @timeout
      window.clearInterval(@timeout)
      @timeout = null

  _appendJob: (init_fn_or_job, run_fn, destroy_fn) -> 
    BGASSERT(not @isDestroyed(), "push shouldn't happen after destroy")
    return if(@isDestroyed())

    if(BGJob.isAJob(init_fn_or_job)) 
      job = init_fn_or_job 
    else 
      job = new BGJob(init_fn_or_job, run_fn, destroy_fn)

    # add the job and set a timeout if needed
    @jobs.push(job)
    @timeout = window.setInterval((=> @tick()), @frequency) if(not @timeout)

  _waitForJobs: ->
    if @timeout
      window.clearInterval(@timeout)
      @timeout = null
    
  _doDestroy: ->
    BGASSERT(@being_destroyed, "not in destroy")
    BGASSERT(not @is_destroyed, "already destroyed")
    return if(@is_destroyed)
    @is_destroyed = true
    
    # clear the jobs
    @clear()

class _BGArrayIterator

  constructor: (@batch_length, @total_count, @current_range) ->
    BGASSERT(@batch_length and @total_count and @current_range, "positive integer batch length and range required")
    @reset()

  reset: ->
    @batch_index = -1
    @batch_count = Math.ceil(@total_count/@batch_length)

  # checks whether all the steps are done
  isDone: -> return (@batch_index >= @batch_count-1) 
  updateCurrentRange: -> 
    index = @batch_index * @batch_length
    excluded_boundary = index + @batch_length
    excluded_boundary = @total_count if(excluded_boundary>@total_count)

    return @current_range.setIsDone() if(index>=excluded_boundary)
    @current_range.addBatchLength(excluded_boundary-index)
    return @current_range

  # updates the iteration and returns a range {index: , excluded_boundary: }
  step: -> 
    return @current_range.setIsDone() if @isDone()
    @batch_index++
    return if(@batch_index==0) then @current_range else @updateCurrentRange()

