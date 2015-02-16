window.microapps or= {}

path = require 'path'
fs = require 'fs'
MiniappCreatorView = require './miniapp-creator-view'
{CompositeDisposable, View, $} = require 'atom'

microapps.ScriptCreatorView = require './script-create'

microapps.scriptsPath = path.join(atom.getConfigDirPath(), 'scripts')
microapps.miniAppsPath = path.join(atom.getConfigDirPath(), 'miniapps')

if not fs.existsSync(microapps.scriptsPath) then fs.mkdirSync microapps.scriptsPath
if not fs.existsSync(microapps.miniAppsPath) then fs.mkdirSync microapps.miniAppsPath

# extract?
class PromptSaveView extends View

  @content: (params) ->
    @div class: 'prompt-save-view', =>
      @tag 'atom-text-editor', mini: true, 'placeholder-text': 'Name:', outlet: 'editor'
      @button class: 'btn', click: 'cancelClicked', "Cancel"
      @button class: 'btn', click: 'createClicked', "Create " +params.type

  initialize: (params) ->
    @callback = params.callback || (o) => console.log 'Callback: '+o
    @cancel = params.cancel || => $(@).remove()

  cancelClicked: -> @cancel()
  createClicked: ->
    $(@).parent().remove()
    @callback(@editor.element.getModel().getText())

#scr.replace(/[^a-z0-9]/gi, '').toLowerCase()
module.exports = MiniappCreator =
  miniappCreatorView: null
  modalPanel: null
  subscriptions: null

  getGlobal: -> microapps

  activate: (state) ->
    @miniappCreatorView = new MiniappCreatorView(state.miniappCreatorViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @miniappCreatorView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'miniapp-creator:new-app': => @newapp()
    @subscriptions.add atom.commands.add 'atom-workspace', 'miniapp-creator:new-script': => @newscript()
    @subscriptions.add atom.commands.add 'atom-workspace', 'miniapp-creator:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @miniappCreatorView.destroy()

  # atom-text-editor.getElement().getBuffer() (or .buffer) -> load (or loadSync)
  # then save

  createPrompt: (type, next) ->
    callback = (text) ->
      next(text)

    promptEl = new PromptSaveView(callback: callback, type: type)
    modal = atom.workspace.addModalPanel item: promptEl, visible: true

  serialize: ->
    miniappCreatorViewState: @miniappCreatorView.serialize()

  newapp: ->
    console.log 'Run: New Mini-app'
    @createPrompt 'Miniapp', (name) ->
      # maybe a 'check for existing' needed here?
      name = name.replace(/[^a-z0-9]/gi, '').toLowerCase()
      path = path.join microapps.miniAppsPath, name+'.json'
      dir = path.join microapps.miniAppsPath, name
      data = { name, path, dir }
      console.dir data


  newscript: ->
    console.log 'Run: New script'
    @createPrompt 'Script', (name) ->
      name = name.replace(/[^a-z0-9]/gi, '').toLowerCase()
      path = path.join microapps.scriptsPath, name+'.js'
      data = { name, path }
      atom.workspace.activePane.activateItem new microapps.ScriptCreatorView(data)

  toggle: ->
    console.log 'Miniapp Panel (Injector / Scripts) Toggled.'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
