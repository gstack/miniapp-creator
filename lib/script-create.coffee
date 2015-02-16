path = require 'path'
fs = require 'fs'
MiniappCreatorView = require './miniapp-creator-view'
{CompositeDisposable, View, $, TextEditor} = require 'atom'

module.exports =
class ScriptCreatorView extends View

  @content: (params) ->
    @div class: 'miniapps-gen script-creator', =>
      @div class: 'create-script-header', =>
        @p 'Name: '+params.name+' - Path: '+params.path, class: 'text-highlight'
      @tag 'atom-text-editor', outlet: 'editor'

  initialize: (params) ->
    # debugging
    window.microapps.scriptCreatorView = @

    @params = params
    @path = params.path # script path
    @title = 'Script: '+@params.name

    # test if this is neccessary / replace w. setImmediate if not
    setTimeout @createOrLoad.bind @, 1000

  createOrLoad: ->
    # somewhat annoying work around. can't require text-buffer?
    if not fs.existsSync(@path) then fs.writeFileSync @path, '// hello, script.\nvar hax;', 'utf-8'
    @model = @editor.element.getModel()
    @model.getBuffer().setText fs.readFileSync(@path).toString('utf-8')
    @model.getBuffer().saveAs @path
    console.log 'created / loaded script.'

  createTab: ->
    tabBarView = atom.workspaceView.find('.pane.active').find('.tab-bar').view()
    tabView = tabBarView.tabForItem @
    $tabView = $ tabView
    @tabView = $tabView
    @setTitle @title

  destroy: ->
    #super
    tabBarView  = atom.workspaceView.find('.pane.active').find('.tab-bar').view()
    tabView     = tabBarView?.tabForItem? @

    if tabView
      $tabView    = $ tabView
      $tabView.remove()

    @tabView = $tabView = null

  getClass:     -> ScriptCreatorView
  getViewClass: -> ScriptCreatorView
  getView:      -> @
  getPath:      -> 'miniapps://creator/'+@params?.name

  setTitle: (@title) ->
    if @tabView then @tabView.find('.title').text(@title)
  getTitle: -> @title
