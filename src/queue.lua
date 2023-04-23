Queue = {}

function Queue.new ()
  return {first = 0, last = -1, track_keys = {}}
end

function Queue.pushleft (queue, value, track_key)
  track_key = track_key or value
  local first = queue.first - 1

  queue.first = first
  queue[first] = value

  if track_key then 
    queue.track_keys[track_key] = first
  end
end

function Queue.pushright (queue, value, track_key)
  track_key = track_key or value
  local last = queue.last + 1

  queue.last = last
  queue[last] = value

  if track_key then
    queue.track_keys[track_key] = last
  end
end

function Queue.popleft (queue, track_key)
  local first = queue.first
  if first > queue.last then return nil end
  local value = queue[first]

  queue[first] = nil        -- to allow garbage collection
  queue.first = first + 1

  return value
end

function Queue.popright (queue, track_key)
  local last = queue.last
  if queue.first > last then return nil end
  local value = queue[last]
  
  queue[last] = nil         -- to allow garbage collection
  queue.last = last - 1

  return value
end

function Queue.get_tracked_idx(queue, value)
  return queue[queue.track_keys[value]]
end

function Queue.is_tracked(queue, value)
  return Queue.get_tracked_idx(queue, value)
end

function Queue.size(queue)
  return queue.last - queue.first
end