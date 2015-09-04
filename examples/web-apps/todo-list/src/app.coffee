{go, events, map, join, observe} = require "fairmont-reactive"

$ = require "jquery"

$ ->

  todos = []

  input = $("input")
  ul = $("ul")

  go [
    events "change", input
    map (event) ->
      todos.push
        description: input.val()
        done: false
      input.val("")
  ]

  checkbox = (id, checked) ->
    if checked
      "<input id='#{id}' type='checkbox' checked>"
    else
      "<input id='#{id}' type='checkbox'>"

  todoItem = (i, item) ->
    "<li> #{checkbox i, item.done} #{item.description} </li>"

  todoList = (todos) ->
    i = 0
    map ((item) -> todoItem i++, item), todos

  go [
    events "change", observe todos
    map (todos) ->
      ul.html (join todoList todos)
      go [
        events "change", $("[type='checkbox']")
        map (event) ->
          id = $(event.target).attr("id")
          todos[id].done = !todos[id].done
      ]
  ]
