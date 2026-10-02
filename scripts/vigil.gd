class_name Vigil

enum Action { AZEITE, SAL, REZA, TRAGO, ESCUTAR }
enum Status { PLAYING, WON, LOST_DARK, LOST_FEAR }

const MAX_LIGHT := 10
const MAX_FEAR := 10
const TOTAL_HOURS := 8

const START_LIGHT := 7
const START_FEAR := 2
const START_OIL := 5
const START_SALT := 3
const START_BOOZE := 2

const OIL_GAIN := 3
const WICK_BURN := 1
const PRAYER_LIGHT_COST := 1
const PRAYER_FEAR_RELIEF := 3
const BOOZE_FEAR_RELIEF := 4
const HANGOVER_FEAR := 2
const DREAD_PER_HOUR := 1
const DEFENSE_RELIEF := 1
const VAGUE_OMEN_CHANCE := 0.25

var light : int
var fear : int
var oil : int
var salt : int
var booze : int
var hour : int
var status

var deck = []
var current : NightEvent
var omen : String
var omen_is_vague : bool
var revealed : bool
var listen_next : bool
var hangover : bool
var report = []
var last_defended : bool
var last_halved : bool

func _init():
	reset()

func reset():
	randomize()
	light = START_LIGHT
	fear = START_FEAR
	oil = START_OIL
	salt = START_SALT
	booze = START_BOOZE
	hour = 1
	status = Status.PLAYING
	hangover = false
	listen_next = false
	report = []
	deck = EventDeck.build_deck()
	deck.shuffle()
	draw_event()

func draw_event():
	if deck.is_empty():
		deck = EventDeck.build_deck()
		deck.shuffle()
	current = deck.pop_front()

	revealed = listen_next
	listen_next = false
	omen_is_vague = false

	if revealed:
		omen = "Você escutou direito: vem coisa de %s \"%s\"." % [current.kind_name(), current.title]
	elif randf() < VAGUE_OMEN_CHANCE:
		omen = EventDeck.vague_omen()
		omen_is_vague = true
	else:
		omen = EventDeck.omen_for(current.kind)

func hour_label():
	return "%02dh" % ((21 + hour) % 24)

func hours_left():
	return TOTAL_HOURS - hour

func can_play(action):
	if status != Status.PLAYING:
		return false
	match action:
		Action.AZEITE: return oil > 0
		Action.SAL:     return salt > 0
		Action.TRAGO:  return booze > 0
		_:         return true

func stock_of(action):
	match action:
		Action.AZEITE: return oil
		Action.SAL:     return salt
		Action.TRAGO:  return booze
		_:         return -1

func action_defends(action):
	match action:
		Action.AZEITE: return NightEvent.Kind.SOMBRA
		Action.SAL:     return NightEvent.Kind.SOLEIRA
		Action.REZA:   return NightEvent.Kind.ALMA
		Action.TRAGO:  return NightEvent.Kind.PANICO
		_:         return -1

func play(action):
	report = []
	if status != Status.PLAYING or not can_play(action):
		return report

	var ev = current
	var defended := false
	var halved := false
	last_defended = false
	last_halved = false

	if hangover:
		hangover = false
		fear += HANGOVER_FEAR
		report.append("A coragem da cana passou, e o medo voltou de uma vez.")

	match action:
		Action.AZEITE:
			oil -= 1
			light += OIL_GAIN
			report.append("Você pinga azeite no pavio. A chama cresce e come um palmo de escuro.")
		Action.SAL:
			salt -= 1
			report.append("Você risca uma linha de sal grosso na soleira e nos cantos da porta.")
		Action.REZA:
			fear -= PRAYER_FEAR_RELIEF
			light -= PRAYER_LIGHT_COST
			report.append("Você faz uma oração em voz alta, devagar. Acalma — mas o pavio queima enquanto você ora.")
		Action.TRAGO:
			booze -= 1
			fear -= BOOZE_FEAR_RELIEF
			hangover = true
			report.append("Você toma um trago de cana. Esquenta o peito e firma a mão. Por ora.")
		Action.ESCUTAR:
			halved = true
			listen_next = true
			report.append("Você fica quieto, de ouvido no ar, escutando a casa por dentro.")

	if action != Action.ESCUTAR:
		defended = ev.kind == action_defends(action)
	last_defended = defended
	last_halved = halved

	report.append("")
	report.append("%s — [%s]" % [ev.title, ev.kind_name()])
	report.append(ev.text)

	if defended:
		fear -= DEFENSE_RELIEF
		report.append("A defesa pegou. A coisa recuou sem levar nada de você.")
	else:
		var f = ev.fear
		var l = ev.light
		if halved:
			f = int(ceil(f / 2.0))
			l = int(ceil(l / 2.0))
			report.append("Você escutou ela chegando e se encolheu em tempo. Doeu menos mas doeu.")
		else:
			report.append("Era outra coisa. O que você fez não serviu pra isso.")
		fear += f
		light -= l

	light -= WICK_BURN
	fear += DREAD_PER_HOUR

	light = clampi(light, 0, MAX_LIGHT)
	fear = clampi(fear, 0, MAX_FEAR)

	if light <= 0:
		status = Status.LOST_DARK
	elif fear >= MAX_FEAR:
		status = Status.LOST_FEAR
	elif hour >= TOTAL_HOURS:
		status = Status.WON
	else:
		hour += 1
		draw_event()

	return report

func is_over():
	return status != Status.PLAYING

func ending_title():
	match status:
		Status.WON:      return "O GALO CANTOU"
		Status.LOST_DARK: return "O ESCURO ENTROU"
		Status.LOST_FEAR: return "VOCÊ CORREU PRA NOITE"
		_:          return ""

func ending_text():
	match status:
		Status.WON:
			return "Seis da manhã. O galo do vizinho canta e a luz de fora entra pela fresta, cinzenta primeiro, depois alaranjada.\n\nO finado está do mesmo jeito que você deixou: quieto, de mãos postas, com o terço onde tem que estar.\nO candeeiro ainda tem um dedo de chama.\n\nVocê velou o corpo até o dia. Ninguém vai saber o que passou por esta sala à noite e você não vai contar."
		Status.LOST_DARK:
			return "O pavio soltou uma última fumaça e a sala virou um bloco de escuro.\n\nVocê não vê a mesa, não vê a porta, não vê o finado.\nMas escuta: tem alguma coisa dentro do escuro e ela não precisa de luz pra saber onde você está.\n\nNo outro dia encontraram o candeeiro seco, a casa aberta e dois corpos velando um ao outro."
		Status.LOST_FEAR:
			return "Você não aguentou mais. Empurrou a porta e saiu pro terreiro, correndo descalço no barro, sem olhar pra trás.\n\nA noite do sertão não tem parede pra se encostar. Você correu até não reconhecer mais o caminho, e o que estava na sala não ficou na sala.\n\nAo amanhecer o corpo do velho estava só. Como ninguém nunca deve deixar um corpo ficar."
		_:
			return ""
