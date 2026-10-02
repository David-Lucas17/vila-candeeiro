class_name NightEvent

enum Kind {
	SOMBRA,
	SOLEIRA,
	ALMA,
	PANICO,
}

var title : String
var text : String
var kind : Kind
var fear : int
var light : int

func _init(title, text, kind, fear, light):
	self.title = title
	self.text = text
	self.kind = kind
	self.fear = fear
	self.light = light

func kind_name():
	match self.kind:
		NightEvent.Kind.SOMBRA:   return "Sombra"
		NightEvent.Kind.SOLEIRA: return "Soleira"
		NightEvent.Kind.ALMA:   return "Alma"
		_:             return "Pânico"

func defense_name():
	match self.kind:
		NightEvent.Kind.SOMBRA:   return "pingar azeite"
		NightEvent.Kind.SOLEIRA: return "jogar sal"
		NightEvent.Kind.ALMA:   return "fazer uma oração"
		_:             return "tomar um trago"
