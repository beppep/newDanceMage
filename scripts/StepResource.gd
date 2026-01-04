extends Resource
class_name Step

enum Kind { DIRECTION, WILDCARD }

@export var kind: Kind = Kind.DIRECTION
@export var direction: Vector2i = Vector2i.ZERO

static func make_direction(dir: Vector2i) -> Step:
	var s = Step.new()
	s.kind = Kind.DIRECTION
	s.direction = dir
	return s

static func make_wildcard() -> Step:
	var s = Step.new()
	s.kind = Kind.WILDCARD
	return s


func matches(step : Vector2i):
	if kind == Kind.WILDCARD:
		return true
	elif step == direction:
		return true
	else:
		return false
