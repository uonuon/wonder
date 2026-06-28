extends Node
# Local-notification scaffolding. Real scheduling needs a platform plugin
# (Android/iOS local notifications); on desktop/headless these are safe no-ops.
# Autoloaded as `Notify`. Wire a plugin here for store builds.

func set_enabled(on: bool) -> void:
	if on:
		_request_permission()
		schedule_streak_reminder()
	else:
		cancel_all()

func _request_permission() -> void:
	if OS.has_feature("mobile"):
		# e.g. with a notifications plugin: Notifications.request_permissions()
		pass

func schedule_streak_reminder() -> void:
	# Intended: a gentle daily nudge ~20h after the last session so the streak
	# isn't lost. Implemented per-platform in a store build.
	if not AppState.notifications_on:
		return
	if OS.has_feature("mobile"):
		pass   # Notifications.schedule(title, body, when)

func cancel_all() -> void:
	if OS.has_feature("mobile"):
		pass
