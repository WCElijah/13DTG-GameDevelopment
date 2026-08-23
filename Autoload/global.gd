extends Node

var canMount = false
var isMounted = false
var canMountShipBody = null
var fire_mode = false

var range_modifier = 5  # meaning range is 5x that of its size

# signals
signal freelook_button_pressed
signal shiplook_button_pressed
