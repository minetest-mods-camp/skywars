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



function Queue.popleft (queue)
  local first = queue.first
  if first > queue.last then return nil end
  local value = queue[first]

  queue[first] = nil        -- to allow garbage collection
  queue.first = first + 1

  return value
end



function Queue.popright (queue)
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
  return queue.last - queue.first + 1
end



local function merge_sort(queue, f)
  local function merge(first, last)
      if first < last then
          local middle = math.floor((first + last) / 2)
          merge(first, middle)
          merge(middle + 1, last)
          local left_index = first
          local right_index = middle + 1
          local temp = {}
          for i = first, last do
              if left_index <= middle and (right_index > last or f(queue[left_index], queue[right_index])) then
                  temp[i] = queue[left_index]
                  left_index = left_index + 1
              else
                  temp[i] = queue[right_index]
                  right_index = right_index + 1
              end
          end
          for i = first, last do
              queue[i] = temp[i]
          end
      end
  end

  merge(queue.first, queue.last)
end

function Queue.sort(queue, f)
  if Queue.size(queue) < 2 then return end

  merge_sort(queue, f)
end