extends Node

var plugin_dictionary = {}

const NOTIFY_CODE_WORK_STARTED = 1
const NOTIFY_CODE_WORK_ENDED = 2

func register(name, plugin):
	assert(not plugin_dictionary.has(name), 'Plugin already registered for interop')
	plugin_dictionary[name] = plugin

func deregister(name, plugin):
	assert(plugin_dictionary.has(name), 'Plugin not registered, cannot deregister')
	assert(plugin_dictionary[name] == plugin, 'Plugin registered with different object, cannot deregister')
	plugin_dictionary.erase(name)

func get_plugin_or_null(name):
	return plugin_dictionary.get(name)

func _notify_plugins(code, args):
	for plugin_name in plugin_dictionary:
		var plugin = plugin_dictionary[plugin_name]
		if plugin.has_method("_interop_notification"):
			plugin._interop_notification(code, args)

func start_work(what):
	_notify_plugins(NOTIFY_CODE_WORK_STARTED, what)

func end_work(what):
	_notify_plugins(NOTIFY_CODE_WORK_ENDED, what)
