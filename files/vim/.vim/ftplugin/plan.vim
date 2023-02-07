" +---------------------------------------------------------------------------+
" | # Terminology                                                             |
" |                                                                           |
" | "Task" -> a dictionary which contains:                                    |
" |           - 'path' -> Full path to task file                              |
" |           - 'file' -> Name of the task file                               |
" |           - 'idStr' -> Task ID represented as a string                    |
" |           - 'idArr' -> Task ID as an array of integers                    |
" |           - 'depth' -> Distance from the root                             |
" |                                                                           |
" |               ┌──────┐              |     1. First task                   |
" |               │ Root │              |     2. Second task                  |
" |               └──┬───┘              |         2.1. First child task       |
" |           ┌──────┼──────┐           |         2.2. Second child task      |
" |         ┌─┴─┐  ┌─┴─┐  ┌─┴─┐         |         2.3. Third child task       |
" |         │ 1 │  │ 2 │  │ 3 │         |     3. Last task                    |
" |         └───┘  └─┬─┘  └───┘         |                                     |
" |         ┌────────┼────────┐         |                                     |
" |      ┌──┴──┐  ┌──┴──┐  ┌──┴──┐      |                                     |
" |      │ 2.1 │  │ 2.2 │  │ 2.3 │      |                                     |
" |      └─────┘  └─────┘  └─────┘      |                                     |
" | Ref: https://efanzh.org/tree-graph-generator/                             |
" |                                                                           |
" | NOTE: The above two images are a representation of the same thing. Each   |
" |       "node" is known as a __Task__. Each node is "up/down/next/prev" to  |
" |       another node. For example:                                          |
" |       > next("1") == "2"                                                  |
" |       > next("2") == "3"                                                  |
" |       > prev("2") = "1"                                                   |
" |       > down("2") == "2.1"                                                |
" |       > down("2.1") == "2.1.1" # True despite 2.1.1. not existing         |
" |       > up("2.1") == "2"                                                  |
" |       > depth("2") == 1                                                   |
" |       > depth("2.1") == 2                                                 |
" +---------------------------------------------------------------------------+
" | # Feature requests                                                        |
" |                                                                           |
" | ## Stage 1: Bare Minimium                                                 |
" |                                                                           |
" | [x] Creating `root.plan` should create the _contents_ page automatically  |
" | [x] All the `.task` files should be put on the screen                     |
" | [x] Contents page should get title from task files                        |
" | [x] Clicking 'Enter' should open the file                                 |
" | [x] Fix sorting bug                                                       |
" | [x] Should be able to create new tasks from this special file (`.task`)   |
" | [x] Get title and put into plan file                                      |
" | [x] .plan file updates itself every time a change is made                 |
" |                                                                           |
" | ## Stage 2: Minimium Viable Product                                       |
" |                                                                           |
" | [x] Create Sub Tasks                                                      |
" | [x] Delete tasks                                                          |
" | [x] Recursivly delete tasks                                               |
" | [x] Recursivly move tasks (Using ctrl-hjkl)                               |
" |   [x] Up                                                                  |
" |   [x] Down                                                                |
" |   [x] Next                                                                |
" |   [x] Prev                                                                |
" | [x] Handle the case where we create the plan but have not existing tasks  |
" | [x] Moving cursor over task should immediatly show it on the right        |
" |                                                                           |
" | ## Stage 3: Bugs                                                          |
" |                                                                           |
" | [ ] When opening a task in planner, why isn't it markdown                 |
" | [ ] Why does the help menu appear twice when opening an existing plan?    |
" | [ ] Remove the need to push <CR> to open a file (we don't need it)        |
" |   [ ] Moving cursor over task should open it (even if there's not other   |
" |       open ones                                                           |
" |                                                                           |
" | ## Stage 4: Simple Quality of Life                                        |
" |                                                                           |
" | [ ] Moving tasks should move the cursor to the right location             |
" | [ ] Refreshing .plan file shouldn't move the cursor to the top everytime  |
" | [ ] Consistent format for storing metadata in task files                  |
" |   [ ] Should have special syntax (e.g. "//")                              |
" |   [ ] Should have the title and date created                              |
" | [ ] Refreshing the page should also print the usage                       |
" |                                                                           |
" | ## Stage 5: More Quality of life but almost pointless                     |
" |                                                                           |
" | [x] Use vim keys to move around tree                                      |
" |   [x] H -> Up                                                             |
" |   [x] J -> Next                                                           |
" |   [x] K -> Previous                                                       |
" |   [x] L -> Down                                                           |
" |                                                                           |
" | ## Stage 6: Quality of life but might be hard to implement                |
" |                                                                           |
" | [ ] Store file name of .plan file in the .plan metadata (similar to java) |
" | [ ] .plan file should show how many tasks a complete out of the total     |
" | [ ] .plan file should highlight lines bases on tasks completed/finished   |
" | [x] Modify two .task files at the same time                               |
" | [ ] "Save" state feature (opening/closing the plan) - saves all current   |
" |     buffers                                                               |
" | [ ] Command to fix corrupted plan (e.g. when a task get's deleted on disk |
" |     but the tree isn't updated                                            |
" +---------------------------------------------------------------------------+

let s:USAGE = [
	\"",
	\"[<CR>] Open Task",
	\"[ij] Create next task                   [il] Create sub task",
	\"[dd] Delete task                        [DD] Recursivly delete task",
	\"",
	\"[H] Move cursor up                      [J] Move cursor next",
	\"[L] Move cursor down                    [K] Move cursor prev",
	\"",
	\"[<C-j>] Swap current task with next task",
	\"[<C-k>] Swap current task with prev task",
	\"[<C-l>] Move current task down",
	\"[<C-h>] Move current task up",
	\"",
	\"[R] Refresh Page",
\]
let s:INDENT = '	'
let s:TITLE_MARKER = 'Title: ' " Indicates the title of the task

function! s:getTaskPaths()
	let task_files = []
	let base_path = s:getBasePath()

	let tmp = globpath(base_path, "*.task")
	let tmp = split(tmp, "\0")
	for f in tmp
		let file_name = split(f, "/")[-1]
		if file_name =~# '^\([0-9]\+\.\)\+task$'
			call add(task_files, f)
		endif
	endfor

	return task_files
endfunction

function! s:filePathToFileName(filePath)
	return split(a:filePath, "/")[-1]
endfunction

function! s:filePathsToFileNames(taskFilePaths)
	return map(
		\ copy(a:taskFilePaths),
		\ {i -> split(a:taskFilePaths[i], "/")[-1]}
	\ )
endfunction

function! s:removeFileExtension(fileName)
	return join(split(a:fileName, '\.')[:-2], '.')
endfunction

function! s:getBasePath()
	return expand('%:p:h')
endfunction

function! s:getTitleFromTaskFile(fileName)
	let basePath = s:getBasePath()

	let filePath = basePath . '/' . a:fileName
	let lines = readfile(filePath, 'b')

	let titleLineNum = match(lines, s:TITLE_MARKER)
	if titleLineNum == -1
		return '<ERROR: Title marker not found>'
	endif

	let titleIndex = match(lines[titleLineNum], s:TITLE_MARKER)
	let titleIndex += len(s:TITLE_MARKER)

	return lines[titleLineNum][titleIndex:]
endfunction

function! s:fileNameToContentsEntry(fileName)
	let nIndents = len(split(a:fileName, '\.')) - 2

	let tmp = ''
	let tmp = tmp . repeat(s:INDENT, nIndents)
	let tmp = tmp . s:removeFileExtension(a:fileName)
	let tmp = tmp . '. '
	let tmp = tmp . s:getTitleFromTaskFile(a:fileName)
	return tmp
endfunction

function! s:appendLines(lines)
	for line in a:lines
		call append(line('$'), line)
	endfor
endfunction

function! s:appendUsage(usage)
	for line in a:usage
		call append(line('$'), line)
	endfor
endfunction

function! s:fileNamesToContentsEntries(fileNames)
	let li = []
	for fileName in a:fileNames
		call add(li, s:fileNameToContentsEntry(fileName))
	endfor
	return li
endfunction

function! s:sortFileNamesCmp(itemA, itemB)

	" [:-2] should remove "task" from the array
	let itemAList = split(a:itemA, '\.')[:-2]
	let itemBList = split(a:itemB, '\.')[:-2]

	let i = 0
	while i < min([len(itemAList), len(itemBList)])
		if itemAList[i] != itemBList[i]
			break
		endif
		let i = i + 1
	endwhile

	if i == min([len(itemAList), len(itemBList)])
		return len(itemAList) - len(itemBList)
	endif

	return str2nr(itemAList[i], 10) - str2nr(itemBList[i], 10)
endfunction

function! s:sortTasksCmp(taskA, taskB)
	let i = 0
	while i < min([a:taskA['depth'], a:taskB['depth']])
		if a:taskA['idArr'][i] != a:taskB['idArr'][i]
			break
		endif
		let i = i + 1
	endwhile

	if i == min([a:taskA['depth'], a:taskB['depth']])
		return a:taskA['depth'] - a:taskB['depth']
	endif

	return a:taskA['idArr'][i] - a:taskB['idArr'][i]
endfunction

function! s:sortFileNames(fileNames)
	return sort(copy(a:fileNames), function('s:sortFileNamesCmp'))
endfunction

function! s:sortTasks(tasks)
	return sort(deepcopy(a:tasks), function('s:sortTasksCmp'))
endfunction

function! s:moveTask(src, dest)
	let cmd = 'mv '
	let cmd = cmd . fnameescape(a:src['path'])
	let cmd = cmd . ' '
	let cmd = cmd . fnameescape(a:dest['path'])
	call system(cmd)
endfunction

function! PlannerOpenTask()
	let line = getline('.')
	let taskId = split(line)[0]
	let filePath = s:getBasePath() . '/' . taskId . 'task'

	if filereadable(filePath) == 0
		echom 'ERROR: Cannot open ' . filePath
	else
		let cmd = 'vsplit ' . fnameescape(filePath)
		call execute(cmd)
	endif
endfunction

function! s:getCurrentTaskId()
	let line = getline('.')
	let taskId = split(line)[0]
	return taskId
endfunction

function! s:calcBrotherTaskId(taskId, offset)
	let li = split(a:taskId, '\.')
	let li[-1] = str2nr(li[-1], 10) + a:offset
	return join(li, '.') . '.'
endfunction

function! s:taskPathToTask(taskPath)
	let di = {}
	let di['path'] = a:taskPath
	let di['file'] = split(a:taskPath, "/")[-1]
	let di['idStr'] = join(split(di['file'], '\.')[:-2], '.')
	let di['idArr'] = map(split(di['idStr'], '\.'), {_, i -> str2nr(i)})
	let di['depth'] = len(di['idArr'])
	return di
endfunction

function! s:getAllTasks()
	let li = []
	let taskPaths = s:getTaskPaths()

	for taskPath in taskPaths
		let di = s:taskPathToTask(taskPath)
		call add(li, di)
	endfor

	return li
endfunction

function! s:taskIdStrToTask(taskIdStr)
	let taskPath = s:getBasePath() . '/' . trim(a:taskIdStr, '.') . '.task'
	return s:taskPathToTask(taskPath)
endfunction

function! s:getCurrentTask()
	let taskIdArr = split(getline('.'))
	if empty(taskIdArr)
		return {}
	endif

	let taskIdStr = taskIdArr[0]
	if taskIdStr !~ '^\([0-9]\+\.\)\+$'
		return {}
	endif

	return s:taskIdStrToTask(taskIdStr)
endfunction

function! s:taskIdArrToTask(taskIdArr)
	let taskIdStr = join(a:taskIdArr, '.')
	return s:taskIdStrToTask(taskIdStr)
endfunction

function! s:nextTask(currTask)
	let tmp = copy(a:currTask['idArr'])
	let tmp[-1] = tmp[-1] + 1
	return s:taskIdArrToTask(tmp)
endfunction

function! s:prevTask(currTask)
	let tmp = copy(a:currTask['idArr'])
	let tmp[-1] = tmp[-1] - 1
	return s:taskIdArrToTask(tmp)
endfunction

function! s:taskExists(task)
	return filereadable(a:task['path'])
endfunction

function! s:getAllNextTasks(currTask)
	let allTasks = s:getAllTasks()
	let allSortedTasks = s:sortTasks(allTasks)

	let li = []
	for task in allSortedTasks
		if task['idArr'][:-2] != a:currTask['idArr'][:-2]
			continue
		elseif task['idArr'][-1] <= a:currTask['idArr'][-1]
			continue
		endif

		call add(li, task)
	endfor

	return li
endfunction

function! s:getDescendents(rootTask)
	let allTasks = s:getAllTasks()
	let li = []

	for task in allTasks
		if task['depth'] < a:rootTask['depth']
			continue
		elseif task['idStr'] == a:rootTask['idStr']
			continue
		endif

		let i = 0
		let shouldAdd = 1
		while i < len(a:rootTask['idArr'])
			if task['idArr'][i] != a:rootTask['idArr'][i]
				let shouldAdd = 0
				break
			endif
			let i = i + 1
		endwhile


		if shouldAdd == 1
			call add(li, task)
		endif
	endfor
	return li
endfunction

function! s:incrementTask(rootTask, offset)
	let li = s:getDescendents(a:rootTask)
	call add(li, a:rootTask)
	let li = sort(li, function('s:sortTasksCmp'))

	let index = a:rootTask['depth'] - 1

	for oldTask in li
		let tmp = copy(oldTask['idArr'])
		let tmp[index] = tmp[index] + a:offset
		let newTask = s:taskIdArrToTask(tmp)
		call s:moveTask(oldTask, newTask)
	endfor

	let newIdArr = copy(a:rootTask['idArr'])
	let newIdArr[index] = newIdArr[index] + a:offset
	return s:taskIdArrToTask(newIdArr)
endfunction

function! s:clearContents()
	let nLines = line('$')
	let i = 0
	let index = -1
	while i < nLines
		if getline(i) ==# '---'
			if index ==# -1
				let index = i
			else
				let index = i
				break
			endif
		endif
		let i = i + 1
	endwhile

	let bufname = bufname("%")
	call deletebufline(bufname, index + 2, line('$'))
endfunction

function! PlannerRefreshPage()
	call s:clearContents()

	let filePaths = s:getTaskPaths()
	let fileNames = s:filePathsToFileNames(filePaths)
	let sortedFileNames = s:sortFileNames(fileNames)
	let contentsEntries = s:fileNamesToContentsEntries(sortedFileNames)
	call s:appendLines(contentsEntries)
	call s:appendUsage(s:USAGE)

endfunction

function! PlannerCreateBrotherTask()

	let title = input('Name of new task: ')

	let currTask = s:getCurrentTask()

	if empty(currTask)
		let firstTask = s:taskIdArrToTask([1])
		if !s:taskExists(firstTask)
			let contents = 'Title: ' . title
			call writefile([contents], firstTask['path'])
			call PlannerRefreshPage()
		else
			echom 'ERROR: Must put cursor on task'
		endif
		return
	endif

	let nextTask = s:nextTask(currTask)

	let existingNextTasks = s:getAllNextTasks(currTask)

	" We move each task (and children) down by one. This is done in reverse
	" so we don't delete anything by accident
	for task in reverse(existingNextTasks)
		call s:incrementTask(task, 1)
	endfor

	let contents = 'Title: ' . title
	call writefile([contents], nextTask['path'])

	call PlannerRefreshPage()

endfunction

function! s:downTask(task)
	let tmp = copy(a:task['idArr'])
	call add(tmp, 1)
	return s:taskIdArrToTask(tmp)
endfunction

function! s:upTask(task)
	let tmp = copy(a:task['idArr'])
	call remove(tmp, -1)
	return s:taskIdArrToTask(tmp)
endfunction

function! s:getSubTasks(rootTask)
	let descendents = s:getDescendents(a:rootTask)
	return filter(
		\ descendents,
		\ {_, val -> val['depth'] == a:rootTask['depth'] + 1}
	\ )
endfunction

function! PlannerCreateDownTask()
	let title = input('Name of new sub task: ')

	let currTask = s:getCurrentTask()

	if !s:taskExists(currTask)
		let firstTask = s:taskIdArrToTask([1])
		if !s:taskExists(firstTask)
			let contents = 'Title: ' . title
			call writefile([contents], firstTask['path'])
			call PlannerRefreshPage()
		else
			echom 'ERROR: Must put cursor on task'
		endif
		return
	endif

	let downTask = s:downTask(currTask)

	let subTasks = s:getSubTasks(currTask)

	for task in reverse(subTasks)
		call s:incrementTask(task, 1)
	endfor

	let contents = 'Title: ' . title
	call writefile([contents], downTask['path'])

	call PlannerRefreshPage()

endfunction

function! PlannerDeleteTask()
	let currTask = s:getCurrentTask()
	let descendents = s:getDescendents(currTask)

	let prompt = 'Are you sure you want to delete task "'
	let prompt = prompt . currTask['idStr'] . '"?'
	if confirm(prompt, "No\nYes") != 2
		return
	endif

	if len(descendents) != 0
		echom "ERROR: Can't delete tasks with descendents. Using \"DD\" instead!"
		return
	endif

	call delete(currTask['path'])

	let nextTasks = s:getAllNextTasks(currTask)

	for task in nextTasks
		call s:incrementTask(task, -1)
	endfor

	call PlannerRefreshPage()
endfunction

function! PlannerRecursivlyDeleteTask()
	let currTask = s:getCurrentTask()

	let prompt = 'Are you sure you want to recursivly delete task "'
	let prompt = prompt . currTask['idStr'] . '"?'
	if confirm(prompt, "No\nYes") != 2
		return
	endif

	let descendents = s:getDescendents(currTask)

	for task in descendents
		call delete(task['path'])
	endfor
	call delete(currTask['path'])

	let nextTasks = s:getAllNextTasks(currTask)

	for task in nextTasks
		call s:incrementTask(task, -1)
	endfor

	call PlannerRefreshPage()
endfunction

function! PlannerSwapNext()
	let currTask = s:getCurrentTask()
	let nextTask = s:nextTask(currTask)

	if s:taskExists(nextTask) == 0
		" Nothing to swap with
		return
	endif

	let tmp = s:incrementTask(currTask, 999999)
	call s:incrementTask(nextTask, -1)
	call s:incrementTask(tmp, -999999 + 1)

	call PlannerRefreshPage()
endfunction

function! PlannerSwapPrev()
	let currTask = s:getCurrentTask()
	let prevTask = s:prevTask(currTask)

	if s:taskExists(prevTask) == 0
		" Nothing to swap with
		return
	endif

	let tmp = s:incrementTask(currTask, 999999)
	call s:incrementTask(prevTask, 1)
	call s:incrementTask(tmp, -999999 - 1)

	call PlannerRefreshPage()
endfunction

function! s:indentTask(currTask)
	let prevTask = s:prevTask(a:currTask)
	let tasks = s:getDescendents(a:currTask)
	call add(tasks, a:currTask)

	let prevSubTasks = s:getSubTasks(prevTask)

	if len(prevSubTasks) > 0
		let newTaskIdArrBase = copy(prevSubTasks[-1]['idArr'])
		let newTaskIdArrBase[-1] += 1
	else
		let newTaskIdArrBase = copy(prevTask['idArr']) + [1]
	endif

	let depth = a:currTask['depth']
	for task in tasks
		let newTaskIdArr = copy(newTaskIdArrBase)
		let newTaskIdArr += copy(task['idArr'][depth:])

		let newTask = s:taskIdArrToTask(newTaskIdArr)
		call s:moveTask(task, newTask)
	endfor

endfunction

function! PlannerMoveDown()
	let currTask = s:getCurrentTask()
	let downTask = s:downTask(currTask)
	let prevTask = s:prevTask(currTask)

	if s:taskExists(prevTask) == 0
		return
	endif

	call s:indentTask(currTask)

	let nextTasks = s:getAllNextTasks(currTask)
	for task in nextTasks
		call s:incrementTask(task, -1)
	endfor

	call PlannerRefreshPage()
endfunction

function! s:outdentTask(rootTask)
	let idArrBase = s:nextTask(s:upTask(a:rootTask))['idArr']

	let depth = a:rootTask['depth']

	let tasks = s:getDescendents(a:rootTask)
	call add(tasks, a:rootTask)

	for task in tasks
		let newIdArr = copy(idArrBase) + task['idArr'][depth:]
		let newTask = s:taskIdArrToTask(newIdArr)

		call s:moveTask(task, newTask)
	endfor
endfunction

function! PlannerMoveUp()
	let currTask = s:getCurrentTask()
	let upTask = s:upTask(currTask)

	if s:taskExists(upTask) == 0
		return
	endif

	let upNextTasks = s:getAllNextTasks(upTask)
	for task in reverse(upNextTasks)
		call s:incrementTask(task, 1)
	endfor

	call s:outdentTask(currTask)

	let currNextTasks = s:getAllNextTasks(currTask)
	for task in currNextTasks
		call s:incrementTask(task, -1)
	endfor

	call PlannerRefreshPage()
endfunction

function! s:getTaskLineNum(task)
	let i = 0
	let idStr = a:task['idStr'] . '.'
	while i < line('$') + 1

		let line = getline(i)
		let lineSplit = split(line)

		if len(lineSplit) > 0 && lineSplit[0] == idStr
			return i
		endif

		let i = i + 1
	endwhile

	return -1
endfunction

function! s:listIntersect(list1, list2)
	let result = copy(a:list1)
	call filter(result, 'index(a:list2, v:val) >= 0')
	return result
endfunction

function! s:winIdToBufInfo(winId)
	let bufs = getbufinfo()
	let bufs = filter(bufs, {idx, val -> index(val['windows'], a:winId) != -1})
	if len(bufs) == 0
		return {}
	endif
	return bufs[0]
endfunction

function! s:getOldestOpenTask(tabId)
	let currWindows = sort(gettabinfo(a:tabId)[0]['windows'])

	let taskBufInfos = getbufinfo()
	let taskBufInfos = filter(taskBufInfos, {idx, val -> val['loaded'] == 1})
	let taskBufInfos = filter(taskBufInfos, {idx, val -> val['listed'] == 1})
	let taskBufInfos = filter(taskBufInfos, {idx, val -> val['hidden'] == 0})
	let taskBufInfos = filter(taskBufInfos, {
		\ idx, val -> split(val['name'], "/")[-1] =~# '^\([0-9]\+\.\)\+task$'
	\})

	let winIds = []
	for taskBufInfo in taskBufInfos
		let winIds += taskBufInfo['windows']
	endfor

	" Intersection of currently open window IDs and all open task winIds
	let tmp = s:listIntersect(winIds, currWindows)
	if empty(tmp)
		" No .task files open in current window
		return -1
	endif
	let tmp = sort(tmp)
	return tmp[0]

endfunction

function! s:tasksEqual(taskA, taskB)
	return get(a:taskA, 'idStr', '') == get(a:taskB, 'idStr', '')
endfunction

let s:LastTask = {}
function! s:handleCursorMove()

	let currTask = s:getCurrentTask()
	if empty(currTask) | return | endif
	if s:tasksEqual(s:LastTask, currTask) | return | endif

	let targetWinId = s:getOldestOpenTask('%')
	if targetWinId == -1 | return | endif

	let targetBuf = s:winIdToBufInfo(targetWinId)

	if targetBuf['changed']
		call win_execute(targetWinId, 'write')
	endif

	call win_execute(targetWinId, 'edit ' . currTask['path'])
	let s:LastTask = currTask

endfunction

function! PlannerMoveCursor(direction)
	let currTask = s:getCurrentTask()
	if empty(currTask)
		return
	endif

	if a:direction ==# "up"
		let tmpTask = s:upTask(currTask)
	elseif a:direction ==# "down"
		let tmpTask = s:downTask(currTask)
	elseif a:direction ==# "next"
		let tmpTask = s:nextTask(currTask)
	elseif a:direction ==# "prev"
		let tmpTask = s:prevTask(currTask)
	endif

	let line = s:getTaskLineNum(tmpTask)

	if line != -1
		let pos = getcurpos()
		let pos[1] = line
		call setpos('.', pos)
	endif
endfunction


function! s:entryPoint()
	call PlannerRefreshPage()

	nnoremap <buffer><silent> <CR>  :call PlannerOpenTask()<CR>
	nnoremap <buffer><silent> R     :call PlannerRefreshPage()<CR>
	" TODO get better key combinations for these two
	nnoremap <buffer><silent> ij    :call PlannerCreateBrotherTask()<CR>
	nnoremap <buffer><silent> il    :call PlannerCreateDownTask()<CR>
	nnoremap <buffer><silent> dd    :call PlannerDeleteTask()<CR>
	nnoremap <buffer><silent> DD    :call PlannerRecursivlyDeleteTask()<CR>

	" Vim keys to swap tasks
	nnoremap <buffer><silent> <C-j> :call PlannerSwapNext()<CR>
	nnoremap <buffer><silent> <C-k> :call PlannerSwapPrev()<CR>
	nnoremap <buffer><silent> <C-l> :call PlannerMoveDown()<CR>
	nnoremap <buffer><silent> <C-h> :call PlannerMoveUp()<CR>

	" Vim keys to move around tree
	nnoremap <buffer><silent> H :call PlannerMoveCursor('up')<CR>
	nnoremap <buffer><silent> L :call PlannerMoveCursor('down')<CR>
	nnoremap <buffer><silent> J :call PlannerMoveCursor('next')<CR>
	nnoremap <buffer><silent> K :call PlannerMoveCursor('prev')<CR>

	call s:appendUsage(s:USAGE)

	autocmd CursorMoved * call s:handleCursorMove()

"	TODO uncomment these
"	setlocal nomodifiable
endfunction

autocmd VimEnter * call s:entryPoint()
